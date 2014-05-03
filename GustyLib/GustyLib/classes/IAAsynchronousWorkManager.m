//
//  IAAsynchronousWorkManager.m
//  Gusty
//
//  Created by Marcelo Schroeder on 19/04/11.
//  Copyright 2011 InfoAccent Pty Limited. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "IACommon.h"

@interface IAAsynchronousWorkManager (){
}

@property (strong) NSOperationQueue *p_operationQueue;
@property (strong) NSOperation *p_operation;
@property (strong) IAUIWorkInProgressModalViewManager *p_wipViewManager;
@property (strong) id p_callbackObject;
@property (strong) MBProgressHUD *p_hud;
@property (strong) NSString *p_nonModalProgressIndicatorOwnerUuid;
@property (strong) NSString *p_cancelAllBlocksRequestOwnerUuid;

@property SEL p_callbackSelector;
@property BOOL p_showProgressIndicator;
@property dispatch_queue_t p_mainSerialDispatchQueue;
@property BOOL p_areAllBlocksCancelled;
@property BOOL p_isSharedInstance;

@end

@implementation IAAsynchronousWorkManager{
    
}

#pragma mark -
#pragma mark Private

-(void)doneWithOperation{
    
//    NSLog(@"doneWithOperation: %@", [self.p_operation description]);
    
    // Remove KVO observers
    [self.p_operation removeObserver:self forKeyPath:@"isFinished"];
    if (self.p_showProgressIndicator) {
        if ([self.p_operation isKindOfClass:[IAOperation class]]) {
            [self.p_operation removeObserver:self forKeyPath:@"p_determinateProgress"];
            [self.p_operation removeObserver:self forKeyPath:@"p_determinateProgressPercentage"];
            [self.p_operation removeObserver:self forKeyPath:@"p_progressMessage"];
        }
    }
    
    // Remove modal WIP view
    if (self.p_showProgressIndicator) {
        [self.p_wipViewManager m_removeView];
    }
    
    // Perform callback selector
    if (self.p_callbackObject && self.p_callbackSelector) {
//        [v_callbackObject performSelector:v_callbackSelector withObject:v_operation];
        objc_msgSend(self.p_callbackObject, self.p_callbackSelector, self.p_operation);
    }

}

- (void)m_onNavigationEventNotification:(NSNotification*)aNotification{
//    NSLog(@"IA_NOTIFICATION_NAVIGATION_EVENT received");
    [self cancelAllSerialBlocks];
}

-(void)cancelAllSerialBlocks {
    [self hideNonModalProgressIndicatorWithAnimation:NO];
    self.p_areAllBlocksCancelled = YES;
    self.p_cancelAllBlocksRequestOwnerUuid = nil;
//    NSLog(@"   ###   p_areAllBlocksCancelled = YES");
    dispatch_async(self.p_mainSerialDispatchQueue, ^{
        if (!self.p_cancelAllBlocksRequestOwnerUuid) {
            self.p_areAllBlocksCancelled = NO;
//            NSLog(@"   ###   p_areAllBlocksCancelled = NO");
        }
    });
}

-(void)m_dispatchConcurrentBlock:(dispatch_block_t)a_block priority:(long)a_priority{
    dispatch_async(dispatch_get_global_queue(a_priority, 0), a_block);
}

-(id)initAsSharedInstance{
    
    if (self=[self init]) {
        
        self.p_isSharedInstance = YES;
        
        // Add observers
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(m_onNavigationEventNotification:)
                                                     name:IA_NOTIFICATION_NAVIGATION_EVENT
                                                   object:nil];
        
    }
    
    return self;
    
}

#pragma mark -
#pragma mark Public

-(void)showNonModalProgressIndicatorInView:(UIView*)a_view{
    @synchronized(self){
//        NSLog(@"m_showNonModalProgressIndicatorForOwner in view: %@", [a_view description]);
        if (!self.p_hud) {
            self.p_hud = [[MBProgressHUD alloc] initWithView:a_view];
            self.p_hud.opacity = 0.2;
            self.p_hud.removeFromSuperViewOnHide = YES;
            self.p_hud.animationType = MBProgressHUDAnimationFade;
            self.p_hud.mode = MBProgressHUDModeIndeterminate;
            self.p_hud.userInteractionEnabled = NO;
            [a_view addSubview:self.p_hud];
            [self.p_hud show:YES];
//            NSLog(@"  @@@ PROGRESS INDICATOR SHOWN");
        }
    }
}

-(void)showNonModalProgressIndicator {
    [self showNonModalProgressIndicatorInView:[IAUIUtils nonModalHudContainerView]];
}

-(void)hideNonModalProgressIndicatorWithAnimation:(BOOL)a_animate{
    @synchronized(self){
        //        NSLog(@"m_hideNonModalProgressIndicatorForOwner");
        if (self.p_hud) {
            [self.p_hud hide:a_animate];
            self.p_hud = nil;
            //            NSLog(@"  @@@ PROGRESS INDICATOR hidden");
        }
    }
}

-(void)dispatchOperation:(NSOperation*)a_operation{
    [self dispatchOperation:a_operation showProgressIndicator:YES callbackObject:nil callbackSelector:NULL];
}

-(void)dispatchOperation:(NSOperation *)a_operation callbackObject:(id)a_callbackObject callbackSelector:(SEL)a_callbackSelector{
    [self dispatchOperation:a_operation showProgressIndicator:YES callbackObject:a_callbackObject
           callbackSelector:a_callbackSelector];
}

-(void)dispatchOperation:(NSOperation *)a_operation showProgressIndicator:(BOOL)a_showProgressIndicator
          callbackObject:(id)a_callbackObject callbackSelector:(SEL)a_callbackSelector{
    
    // Store arguments
    self.p_operation = a_operation;
    self.p_showProgressIndicator = a_showProgressIndicator;
    self.p_callbackObject = a_callbackObject;
    self.p_callbackSelector = a_callbackSelector;
    
    // Add observer for when operation is finished
    [self.p_operation addObserver:self forKeyPath:@"isFinished" options:0 context:nil];
    
    // Add observers for tracking progress
    if (self.p_showProgressIndicator) {
        if ([self.p_operation isKindOfClass:[IAOperation class]]) {
            [self.p_operation addObserver:self forKeyPath:@"p_determinateProgress" options:0 context:nil];
            [self.p_operation addObserver:self forKeyPath:@"p_determinateProgressPercentage" options:0 context:nil];
            [self.p_operation addObserver:self forKeyPath:@"p_progressMessage" options:0 context:nil];
        }
    }

    // Show "work in progress" modal view
    if (self.p_showProgressIndicator) {
        NSString *l_message = nil;
        BOOL l_allowCancellation = NO;
        if ([self.p_operation isKindOfClass:[IAOperation class]]) {
            IAOperation *l_operation = ((IAOperation*)a_operation);
            l_message = l_operation.p_progressMessage;
            l_allowCancellation = l_operation.p_allowCancellation;
        }
        if (l_allowCancellation) {
            self.p_wipViewManager = [[IAUIWorkInProgressModalViewManager alloc] initWithCancellationCallbackReceiver:self
                                                                                        cancellationCallbackSelector:@selector(cancelAllOperations)
                                                                                        cancellationCallbackArgument:nil
                                                                                                             message:l_message];
        }else{
            self.p_wipViewManager = [[IAUIWorkInProgressModalViewManager alloc] initWithMessage:l_message];
        }
        [self.p_wipViewManager m_showView];
    }
    
    // Add operation to execution queue
    [self.p_operationQueue addOperation:self.p_operation];

}

-(void)cancelAllOperations {
//    NSLog(@"Cancelling all operations in the queue...");
    [self.p_operationQueue cancelAllOperations];
}

-(void)dispatchSerialBlock:(dispatch_block_t)a_block{
    [self dispatchSerialBlock:a_block showProgressIndicator:NO cancelPreviousBlocks:NO];
}
    
-(void)dispatchSerialBlock:(dispatch_block_t)a_block cancelPreviousBlocks:(BOOL)a_cancelPreviousBlocks{
    [self dispatchSerialBlock:a_block showProgressIndicator:NO cancelPreviousBlocks:a_cancelPreviousBlocks];
}

-(void)dispatchSerialBlock:(dispatch_block_t)a_block showProgressIndicator:(BOOL)a_showProgressIndicator{
    [self dispatchSerialBlock:a_block showProgressIndicator:a_showProgressIndicator cancelPreviousBlocks:NO];
}
    
-(void)dispatchSerialBlock:(dispatch_block_t)a_block showProgressIndicator:(BOOL)a_showProgressIndicator
      cancelPreviousBlocks:(BOOL)a_cancelPreviousBlocks{
    [self  dispatchSerialBlock:a_block
progressIndicatorContainerView:a_showProgressIndicator ? [IAUIUtils nonModalHudContainerView] : nil
          cancelPreviousBlocks:a_cancelPreviousBlocks];
}

-(void)    dispatchSerialBlock:(dispatch_block_t)a_block
progressIndicatorContainerView:(UIView *)a_progressIndicatorContainerView cancelPreviousBlocks:(BOOL)a_cancelPreviousBlocks{
    [self dispatchSerialBlock:a_block progressIndicatorContainerView:a_progressIndicatorContainerView
         cancelPreviousBlocks:a_cancelPreviousBlocks usePrivateManagedObjectContext:YES];
}

-(void)    dispatchSerialBlock:(dispatch_block_t)a_block
progressIndicatorContainerView:(UIView *)a_progressIndicatorContainerView
          cancelPreviousBlocks:(BOOL)a_cancelPreviousBlocks usePrivateManagedObjectContext:(BOOL)a_usePrivateManagedObjectContext{
    
    // Generate a UUID to identify this block
    NSString *l_blockUuid = [IAUtils generateUuid];
    
    // Cancel previous blocks if required
    if (a_cancelPreviousBlocks) {
        self.p_areAllBlocksCancelled = YES;
        self.p_cancelAllBlocksRequestOwnerUuid = l_blockUuid;
    }

    // Hide progress indicator if required
    if (a_progressIndicatorContainerView) {
        self.p_nonModalProgressIndicatorOwnerUuid = l_blockUuid;
//        NSLog(@"self.p_nonModalProgressIndicatorOwnerUuid set to %@", self.p_nonModalProgressIndicatorOwnerUuid);
        [self showNonModalProgressIndicatorInView:a_progressIndicatorContainerView];
    }
    
    dispatch_block_t l_block = [^{
        
//        NSLog(@"");
//        NSLog(@"*** BLOCK START - UUID: %@", l_blockUuid);
//        NSLog(@"self: %@", [self description]);
//        NSLog(@"p_cancelAllBlocksRequestOwnerUuid: %@", [p_cancelAllBlocksRequestOwnerUuid description]);
//        NSLog(@"a_block: %@", [a_block description]);
        
        // Reset the managed object context to avoid stale objects for this session
        [self.p_managedObjectContext reset];
        
        if (self.p_areAllBlocksCancelled && [self.p_cancelAllBlocksRequestOwnerUuid isEqualToString:l_blockUuid]) {
            self.p_areAllBlocksCancelled = NO;
            self.p_cancelAllBlocksRequestOwnerUuid = nil;
         }

        // Execute "the" block
//        NSLog(@"about to execute inner block...");
        NSMutableDictionary *l_threadDict = nil;
        if (a_usePrivateManagedObjectContext) {
            l_threadDict = [[NSThread currentThread] threadDictionary];
            [l_threadDict setObject:self.p_managedObjectContext forKey:IA_KEY_SERIAL_QUEUE_MANAGED_OBJECT_CONTEXT];
        }
        a_block();
        if (l_threadDict) {
            [l_threadDict removeObjectForKey:IA_KEY_SERIAL_QUEUE_MANAGED_OBJECT_CONTEXT];
        }
//        NSLog(@"inner block executed!");

        // Hide progress indicator if required
        if (a_progressIndicatorContainerView && [self.p_nonModalProgressIndicatorOwnerUuid isEqualToString:l_blockUuid]) {
            [IAUtils m_dispatchAsyncMainThreadBlock:^{
                [self hideNonModalProgressIndicatorWithAnimation:YES];}];
//            NSLog(@"m_hideNonModalProgressIndicator scheduled for UUID %@", l_blockUuid);
        }

//        NSLog(@"*** BLOCK END - UUID: %@", l_blockUuid);

    } copy];

    // Start work requested
    dispatch_async(self.p_mainSerialDispatchQueue, l_block);

}

-(void)dispatchSerialBlock:(dispatch_block_t)a_block usePrivateManagedObjectContext:(BOOL)a_usePrivateManagedObjectContext{
    [self  dispatchSerialBlock:a_block progressIndicatorContainerView:nil cancelPreviousBlocks:NO
usePrivateManagedObjectContext:a_usePrivateManagedObjectContext];
}

-(void)dispatchConcurrentBackgroundBlock:(dispatch_block_t)a_block{
    [self m_dispatchConcurrentBlock:a_block priority:DISPATCH_QUEUE_PRIORITY_BACKGROUND];
}

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"isFinished"]) {
        [self performSelectorOnMainThread:@selector(doneWithOperation) withObject:nil waitUntilDone:NO];
    }else if ([keyPath isEqualToString:@"p_determinateProgress"]) {
        BOOL l_determinateProgress = [[self.p_operation valueForKey:keyPath] boolValue];
//        NSLog(@"l_determinateProgress: %u", l_determinateProgress);
        self.p_wipViewManager.p_determinateProgress = l_determinateProgress;
    }else if ([keyPath isEqualToString:@"p_determinateProgressPercentage"]) {
        float l_determinateProgressPercentage = [[self.p_operation valueForKey:keyPath] floatValue];
//        NSLog(@"l_determinateProgressPercentage: %f", l_determinateProgressPercentage);
        self.p_wipViewManager.p_determinateProgressPercentage = l_determinateProgressPercentage;
    }else if ([keyPath isEqualToString:@"p_progressMessage"]) {
        NSString *l_progressMessage = [self.p_operation valueForKey:keyPath];
//        NSLog(@"l_progressMessage: %@", l_progressMessage);
        self.p_wipViewManager.p_progressMessage = l_progressMessage;
    }else{
        NSAssert(NO, @"Unexpected key path: %@", keyPath);
    }
}

#pragma mark - Singleton functions

+ (IAAsynchronousWorkManager*)instance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IAAsynchronousWorkManager *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [[self alloc] initAsSharedInstance];
    });
    return c_instance;
}

#pragma mark - Overrides

-(id)init{

    if (self=[super init]) {

        self.p_operationQueue = [[NSOperationQueue alloc] init];
        NSString *l_mainSerialDispatchQueueId = [NSString stringWithFormat:@"com.infoaccent.IAAsynchronousOperationManager.mainSerialDispatchQueue.%@", [IAUtils generateUuid]];
//        NSLog(@"l_mainSerialDispatchQueueId: %@", l_mainSerialDispatchQueueId);
        self.p_mainSerialDispatchQueue = dispatch_queue_create([l_mainSerialDispatchQueueId UTF8String], DISPATCH_QUEUE_SERIAL);
        
        // Set default managed object context for this work manager's threads
        self.p_managedObjectContext = [IAPersistenceManager sharedInstance].privateQueueManagedObjectContext;

    }

    return self;

}

-(void)dealloc{
    
    // Remove observers
    if (self.p_isSharedInstance) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IA_NOTIFICATION_NAVIGATION_EVENT object:nil];
    }

}

@end
