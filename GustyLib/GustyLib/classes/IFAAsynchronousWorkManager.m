//
//  IFAAsynchronousWorkManager.m
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

#import "IFACommon.h"

@interface IFAAsynchronousWorkManager (){
}

@property (strong) NSOperationQueue *ifa_operationQueue;
@property (strong) NSOperation *ifa_operation;
@property (strong) IFAWorkInProgressModalViewManager *ifa_wipViewManager;
@property (strong) id ifa_callbackObject;
@property (strong) IFA_MBProgressHUD *ifa_hud;
@property (strong) NSString *ifa_nonModalProgressIndicatorOwnerUuid;
@property (strong) NSString *ifa_cancelAllBlocksRequestOwnerUuid;

@property SEL ifa_callbackSelector;
@property BOOL ifa_showProgressIndicator;
@property dispatch_queue_t ifa_mainSerialDispatchQueue;
@property BOOL areAllBlocksCancelled;
@property BOOL ifa_isSharedInstance;

@end

@implementation IFAAsynchronousWorkManager {
    
}

#pragma mark -
#pragma mark Private

-(void)doneWithOperation{
    
//    NSLog(@"doneWithOperation: %@", [self.ifa_operation description]);
    
    // Remove KVO observers
    [self.ifa_operation removeObserver:self forKeyPath:@"isFinished"];
    if (self.ifa_showProgressIndicator) {
        if ([self.ifa_operation isKindOfClass:[IFAOperation class]]) {
            [self.ifa_operation removeObserver:self forKeyPath:@"determinateProgress"];
            [self.ifa_operation removeObserver:self forKeyPath:@"determinateProgressPercentage"];
            [self.ifa_operation removeObserver:self forKeyPath:@"progressMessage"];
        }
    }
    
    // Remove modal WIP view
    if (self.ifa_showProgressIndicator) {
        [self.ifa_wipViewManager removeView];
    }
    
    // Perform callback selector
    if (self.ifa_callbackObject && self.ifa_callbackSelector) {
//        [v_callbackObject performSelector:v_callbackSelector withObject:v_operation];
        objc_msgSend(self.ifa_callbackObject, self.ifa_callbackSelector, self.ifa_operation);
    }

}

- (void)ifa_onNavigationEventNotification:(NSNotification*)aNotification{
//    NSLog(@"IFA_k_NOTIFICATION_NAVIGATION_EVENT received");
    [self cancelAllSerialBlocks];
}

-(void)cancelAllSerialBlocks {
    [self hideNonModalProgressIndicatorWithAnimation:NO];
    self.areAllBlocksCancelled = YES;
    self.ifa_cancelAllBlocksRequestOwnerUuid = nil;
//    NSLog(@"   ###   areAllBlocksCancelled = YES");
    dispatch_async(self.ifa_mainSerialDispatchQueue, ^{
        if (!self.ifa_cancelAllBlocksRequestOwnerUuid) {
            self.areAllBlocksCancelled = NO;
//            NSLog(@"   ###   areAllBlocksCancelled = NO");
        }
    });
}

-(void)ifa_dispatchConcurrentBlock:(dispatch_block_t)a_block priority:(long)a_priority{
    dispatch_async(dispatch_get_global_queue(a_priority, 0), a_block);
}

-(id)initAsSharedInstance{
    
    if (self=[self init]) {
        
        self.ifa_isSharedInstance = YES;
        
        // Add observers
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ifa_onNavigationEventNotification:)
                                                     name:IFA_k_NOTIFICATION_NAVIGATION_EVENT
                                                   object:nil];
        
    }
    
    return self;
    
}

#pragma mark -
#pragma mark Public

-(void)showNonModalProgressIndicatorInView:(UIView*)a_view{
    @synchronized(self){
//        NSLog(@"m_showNonModalProgressIndicatorForOwner in view: %@", [a_view description]);
        if (!self.ifa_hud) {
            self.ifa_hud = [[IFA_MBProgressHUD alloc] initWithView:a_view];
            self.ifa_hud.opacity = 0.2;
            self.ifa_hud.removeFromSuperViewOnHide = YES;
            self.ifa_hud.animationType = MBProgressHUDAnimationFade;
            self.ifa_hud.mode = MBProgressHUDModeIndeterminate;
            self.ifa_hud.userInteractionEnabled = NO;
            [a_view addSubview:self.ifa_hud];
            [self.ifa_hud show:YES];
//            NSLog(@"  @@@ PROGRESS INDICATOR SHOWN");
        }
    }
}

-(void)showNonModalProgressIndicator {
    [self showNonModalProgressIndicatorInView:[IFAUIUtils nonModalHudContainerView]];
}

-(void)hideNonModalProgressIndicatorWithAnimation:(BOOL)a_animate{
    @synchronized(self){
        //        NSLog(@"m_hideNonModalProgressIndicatorForOwner");
        if (self.ifa_hud) {
            [self.ifa_hud hide:a_animate];
            self.ifa_hud = nil;
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
    self.ifa_operation = a_operation;
    self.ifa_showProgressIndicator = a_showProgressIndicator;
    self.ifa_callbackObject = a_callbackObject;
    self.ifa_callbackSelector = a_callbackSelector;
    
    // Add observer for when operation is finished
    [self.ifa_operation addObserver:self forKeyPath:@"isFinished" options:0 context:nil];
    
    // Add observers for tracking progress
    if (self.ifa_showProgressIndicator) {
        if ([self.ifa_operation isKindOfClass:[IFAOperation class]]) {
            [self.ifa_operation addObserver:self forKeyPath:@"determinateProgress" options:0 context:nil];
            [self.ifa_operation addObserver:self forKeyPath:@"determinateProgressPercentage" options:0 context:nil];
            [self.ifa_operation addObserver:self forKeyPath:@"progressMessage" options:0 context:nil];
        }
    }

    // Show "work in progress" modal view
    if (self.ifa_showProgressIndicator) {
        NSString *l_message = nil;
        BOOL l_allowCancellation = NO;
        if ([self.ifa_operation isKindOfClass:[IFAOperation class]]) {
            IFAOperation *l_operation = ((IFAOperation *)a_operation);
            l_message = l_operation.progressMessage;
            l_allowCancellation = l_operation.allowCancellation;
        }
        if (l_allowCancellation) {
            self.ifa_wipViewManager = [[IFAWorkInProgressModalViewManager alloc] initWithCancellationCallbackReceiver:self
                                                                                        cancellationCallbackSelector:@selector(cancelAllOperations)
                                                                                        cancellationCallbackArgument:nil
                                                                                                             message:l_message];
        }else{
            self.ifa_wipViewManager = [[IFAWorkInProgressModalViewManager alloc] initWithMessage:l_message];
        }
        [self.ifa_wipViewManager showView];
    }
    
    // Add operation to execution queue
    [self.ifa_operationQueue addOperation:self.ifa_operation];

}

-(void)cancelAllOperations {
//    NSLog(@"Cancelling all operations in the queue...");
    [self.ifa_operationQueue cancelAllOperations];
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
progressIndicatorContainerView:a_showProgressIndicator ? [IFAUIUtils nonModalHudContainerView] : nil
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
    NSString *l_blockUuid = [IFAUtils generateUuid];
    
    // Cancel previous blocks if required
    if (a_cancelPreviousBlocks) {
        self.areAllBlocksCancelled = YES;
        self.ifa_cancelAllBlocksRequestOwnerUuid = l_blockUuid;
    }

    // Hide progress indicator if required
    if (a_progressIndicatorContainerView) {
        self.ifa_nonModalProgressIndicatorOwnerUuid = l_blockUuid;
//        NSLog(@"self.ifa_nonModalProgressIndicatorOwnerUuid set to %@", self.ifa_nonModalProgressIndicatorOwnerUuid);
        [self showNonModalProgressIndicatorInView:a_progressIndicatorContainerView];
    }
    
    dispatch_block_t l_block = [^{
        
//        NSLog(@"");
//        NSLog(@"*** BLOCK START - UUID: %@", l_blockUuid);
//        NSLog(@"self: %@", [self description]);
//        NSLog(@"ifa_cancelAllBlocksRequestOwnerUuid: %@", [ifa_cancelAllBlocksRequestOwnerUuid description]);
//        NSLog(@"a_block: %@", [a_block description]);
        
        // Reset the managed object context to avoid stale objects for this session
        [self.managedObjectContext reset];
        
        if (self.areAllBlocksCancelled && [self.ifa_cancelAllBlocksRequestOwnerUuid isEqualToString:l_blockUuid]) {
            self.areAllBlocksCancelled = NO;
            self.ifa_cancelAllBlocksRequestOwnerUuid = nil;
         }

        // Execute "the" block
//        NSLog(@"about to execute inner block...");
        NSMutableDictionary *l_threadDict = nil;
        if (a_usePrivateManagedObjectContext) {
            l_threadDict = [[NSThread currentThread] threadDictionary];
            [l_threadDict setObject:self.managedObjectContext forKey:IFA_k_KEY_SERIAL_QUEUE_MANAGED_OBJECT_CONTEXT];
        }
        a_block();
        if (l_threadDict) {
            [l_threadDict removeObjectForKey:IFA_k_KEY_SERIAL_QUEUE_MANAGED_OBJECT_CONTEXT];
        }
//        NSLog(@"inner block executed!");

        // Hide progress indicator if required
        if (a_progressIndicatorContainerView && [self.ifa_nonModalProgressIndicatorOwnerUuid isEqualToString:l_blockUuid]) {
            [IFAUtils dispatchAsyncMainThreadBlock:^{
                [self hideNonModalProgressIndicatorWithAnimation:YES];
            }];
//            NSLog(@"m_hideNonModalProgressIndicator scheduled for UUID %@", l_blockUuid);
        }

//        NSLog(@"*** BLOCK END - UUID: %@", l_blockUuid);

    } copy];

    // Start work requested
    dispatch_async(self.ifa_mainSerialDispatchQueue, l_block);

}

-(void)dispatchSerialBlock:(dispatch_block_t)a_block usePrivateManagedObjectContext:(BOOL)a_usePrivateManagedObjectContext{
    [self  dispatchSerialBlock:a_block progressIndicatorContainerView:nil cancelPreviousBlocks:NO
usePrivateManagedObjectContext:a_usePrivateManagedObjectContext];
}

-(void)dispatchConcurrentBackgroundBlock:(dispatch_block_t)a_block{
    [self ifa_dispatchConcurrentBlock:a_block priority:DISPATCH_QUEUE_PRIORITY_BACKGROUND];
}

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"isFinished"]) {
        [self performSelectorOnMainThread:@selector(doneWithOperation) withObject:nil waitUntilDone:NO];
    }else if ([keyPath isEqualToString:@"determinateProgress"]) {
        BOOL l_determinateProgress = [[self.ifa_operation valueForKey:keyPath] boolValue];
//        NSLog(@"l_determinateProgress: %u", l_determinateProgress);
        self.ifa_wipViewManager.determinateProgress = l_determinateProgress;
    }else if ([keyPath isEqualToString:@"determinateProgressPercentage"]) {
        float l_determinateProgressPercentage = [[self.ifa_operation valueForKey:keyPath] floatValue];
//        NSLog(@"l_determinateProgressPercentage: %f", l_determinateProgressPercentage);
        self.ifa_wipViewManager.determinateProgressPercentage = l_determinateProgressPercentage;
    }else if ([keyPath isEqualToString:@"progressMessage"]) {
        NSString *l_progressMessage = [self.ifa_operation valueForKey:keyPath];
//        NSLog(@"l_progressMessage: %@", l_progressMessage);
        self.ifa_wipViewManager.progressMessage = l_progressMessage;
    }else{
        NSAssert(NO, @"Unexpected key path: %@", keyPath);
    }
}

#pragma mark - Singleton functions

+ (IFAAsynchronousWorkManager *)instance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IFAAsynchronousWorkManager *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [[self alloc] initAsSharedInstance];
    });
    return c_instance;
}

#pragma mark - Overrides

-(id)init{

    if (self=[super init]) {

        self.ifa_operationQueue = [[NSOperationQueue alloc] init];
        NSString *l_mainSerialDispatchQueueId = [NSString stringWithFormat:@"com.infoaccent.IFAAsynchronousOperationManager.mainSerialDispatchQueue.%@", [IFAUtils generateUuid]];
//        NSLog(@"l_mainSerialDispatchQueueId: %@", l_mainSerialDispatchQueueId);
        self.ifa_mainSerialDispatchQueue = dispatch_queue_create([l_mainSerialDispatchQueueId UTF8String], DISPATCH_QUEUE_SERIAL);
        
        // Set default managed object context for this work manager's threads
        self.managedObjectContext = [IFAPersistenceManager sharedInstance].privateQueueManagedObjectContext;

    }

    return self;

}

-(void)dealloc{
    
    // Remove observers
    if (self.ifa_isSharedInstance) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IFA_k_NOTIFICATION_NAVIGATION_EVENT object:nil];
    }

}

@end
