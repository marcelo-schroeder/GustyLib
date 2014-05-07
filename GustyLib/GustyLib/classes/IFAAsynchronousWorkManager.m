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

@property (strong) NSOperationQueue *XYZ_operationQueue;
@property (strong) NSOperation *XYZ_operation;
@property (strong) IFAWorkInProgressModalViewManager *XYZ_wipViewManager;
@property (strong) id XYZ_callbackObject;
@property (strong) IFA_MBProgressHUD *XYZ_hud;
@property (strong) NSString *XYZ_nonModalProgressIndicatorOwnerUuid;
@property (strong) NSString *XYZ_cancelAllBlocksRequestOwnerUuid;

@property SEL XYZ_callbackSelector;
@property BOOL XYZ_showProgressIndicator;
@property dispatch_queue_t XYZ_mainSerialDispatchQueue;
@property BOOL areAllBlocksCancelled;
@property BOOL XYZ_isSharedInstance;

@end

@implementation IFAAsynchronousWorkManager {
    
}

#pragma mark -
#pragma mark Private

-(void)doneWithOperation{
    
//    NSLog(@"doneWithOperation: %@", [self.XYZ_operation description]);
    
    // Remove KVO observers
    [self.XYZ_operation removeObserver:self forKeyPath:@"isFinished"];
    if (self.XYZ_showProgressIndicator) {
        if ([self.XYZ_operation isKindOfClass:[IFAOperation class]]) {
            [self.XYZ_operation removeObserver:self forKeyPath:@"determinateProgress"];
            [self.XYZ_operation removeObserver:self forKeyPath:@"determinateProgressPercentage"];
            [self.XYZ_operation removeObserver:self forKeyPath:@"progressMessage"];
        }
    }
    
    // Remove modal WIP view
    if (self.XYZ_showProgressIndicator) {
        [self.XYZ_wipViewManager removeView];
    }
    
    // Perform callback selector
    if (self.XYZ_callbackObject && self.XYZ_callbackSelector) {
//        [v_callbackObject performSelector:v_callbackSelector withObject:v_operation];
        objc_msgSend(self.XYZ_callbackObject, self.XYZ_callbackSelector, self.XYZ_operation);
    }

}

- (void)XYZ_onNavigationEventNotification:(NSNotification*)aNotification{
//    NSLog(@"IFANotificationNavigationEvent received");
    [self cancelAllSerialBlocks];
}

-(void)cancelAllSerialBlocks {
    [self hideNonModalProgressIndicatorWithAnimation:NO];
    self.areAllBlocksCancelled = YES;
    self.XYZ_cancelAllBlocksRequestOwnerUuid = nil;
//    NSLog(@"   ###   areAllBlocksCancelled = YES");
    dispatch_async(self.XYZ_mainSerialDispatchQueue, ^{
        if (!self.XYZ_cancelAllBlocksRequestOwnerUuid) {
            self.areAllBlocksCancelled = NO;
//            NSLog(@"   ###   areAllBlocksCancelled = NO");
        }
    });
}

-(void)XYZ_dispatchConcurrentBlock:(dispatch_block_t)a_block priority:(long)a_priority{
    dispatch_async(dispatch_get_global_queue(a_priority, 0), a_block);
}

-(id)initAsSharedInstance{
    
    if (self=[self init]) {
        
        self.XYZ_isSharedInstance = YES;
        
        // Add observers
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(XYZ_onNavigationEventNotification:)
                                                     name:IFANotificationNavigationEvent
                                                   object:nil];
        
    }
    
    return self;
    
}

#pragma mark -
#pragma mark Public

-(void)showNonModalProgressIndicatorInView:(UIView*)a_view{
    @synchronized(self){
//        NSLog(@"m_showNonModalProgressIndicatorForOwner in view: %@", [a_view description]);
        if (!self.XYZ_hud) {
            self.XYZ_hud = [[IFA_MBProgressHUD alloc] initWithView:a_view];
            self.XYZ_hud.opacity = 0.2;
            self.XYZ_hud.removeFromSuperViewOnHide = YES;
            self.XYZ_hud.animationType = MBProgressHUDAnimationFade;
            self.XYZ_hud.mode = MBProgressHUDModeIndeterminate;
            self.XYZ_hud.userInteractionEnabled = NO;
            [a_view addSubview:self.XYZ_hud];
            [self.XYZ_hud show:YES];
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
        if (self.XYZ_hud) {
            [self.XYZ_hud hide:a_animate];
            self.XYZ_hud = nil;
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
    self.XYZ_operation = a_operation;
    self.XYZ_showProgressIndicator = a_showProgressIndicator;
    self.XYZ_callbackObject = a_callbackObject;
    self.XYZ_callbackSelector = a_callbackSelector;
    
    // Add observer for when operation is finished
    [self.XYZ_operation addObserver:self forKeyPath:@"isFinished" options:0 context:nil];
    
    // Add observers for tracking progress
    if (self.XYZ_showProgressIndicator) {
        if ([self.XYZ_operation isKindOfClass:[IFAOperation class]]) {
            [self.XYZ_operation addObserver:self forKeyPath:@"determinateProgress" options:0 context:nil];
            [self.XYZ_operation addObserver:self forKeyPath:@"determinateProgressPercentage" options:0 context:nil];
            [self.XYZ_operation addObserver:self forKeyPath:@"progressMessage" options:0 context:nil];
        }
    }

    // Show "work in progress" modal view
    if (self.XYZ_showProgressIndicator) {
        NSString *l_message = nil;
        BOOL l_allowCancellation = NO;
        if ([self.XYZ_operation isKindOfClass:[IFAOperation class]]) {
            IFAOperation *l_operation = ((IFAOperation *)a_operation);
            l_message = l_operation.progressMessage;
            l_allowCancellation = l_operation.allowCancellation;
        }
        if (l_allowCancellation) {
            self.XYZ_wipViewManager = [[IFAWorkInProgressModalViewManager alloc] initWithCancellationCallbackReceiver:self
                                                                                        cancellationCallbackSelector:@selector(cancelAllOperations)
                                                                                        cancellationCallbackArgument:nil
                                                                                                             message:l_message];
        }else{
            self.XYZ_wipViewManager = [[IFAWorkInProgressModalViewManager alloc] initWithMessage:l_message];
        }
        [self.XYZ_wipViewManager showView];
    }
    
    // Add operation to execution queue
    [self.XYZ_operationQueue addOperation:self.XYZ_operation];

}

-(void)cancelAllOperations {
//    NSLog(@"Cancelling all operations in the queue...");
    [self.XYZ_operationQueue cancelAllOperations];
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
        self.XYZ_cancelAllBlocksRequestOwnerUuid = l_blockUuid;
    }

    // Hide progress indicator if required
    if (a_progressIndicatorContainerView) {
        self.XYZ_nonModalProgressIndicatorOwnerUuid = l_blockUuid;
//        NSLog(@"self.XYZ_nonModalProgressIndicatorOwnerUuid set to %@", self.XYZ_nonModalProgressIndicatorOwnerUuid);
        [self showNonModalProgressIndicatorInView:a_progressIndicatorContainerView];
    }
    
    dispatch_block_t l_block = [^{
        
//        NSLog(@"");
//        NSLog(@"*** BLOCK START - UUID: %@", l_blockUuid);
//        NSLog(@"self: %@", [self description]);
//        NSLog(@"XYZ_cancelAllBlocksRequestOwnerUuid: %@", [XYZ_cancelAllBlocksRequestOwnerUuid description]);
//        NSLog(@"a_block: %@", [a_block description]);
        
        // Reset the managed object context to avoid stale objects for this session
        [self.managedObjectContext reset];
        
        if (self.areAllBlocksCancelled && [self.XYZ_cancelAllBlocksRequestOwnerUuid isEqualToString:l_blockUuid]) {
            self.areAllBlocksCancelled = NO;
            self.XYZ_cancelAllBlocksRequestOwnerUuid = nil;
         }

        // Execute "the" block
//        NSLog(@"about to execute inner block...");
        NSMutableDictionary *l_threadDict = nil;
        if (a_usePrivateManagedObjectContext) {
            l_threadDict = [[NSThread currentThread] threadDictionary];
            [l_threadDict setObject:self.managedObjectContext forKey:IFAKeySerialQueueManagedObjectContext];
        }
        a_block();
        if (l_threadDict) {
            [l_threadDict removeObjectForKey:IFAKeySerialQueueManagedObjectContext];
        }
//        NSLog(@"inner block executed!");

        // Hide progress indicator if required
        if (a_progressIndicatorContainerView && [self.XYZ_nonModalProgressIndicatorOwnerUuid isEqualToString:l_blockUuid]) {
            [IFAUtils dispatchAsyncMainThreadBlock:^{
                [self hideNonModalProgressIndicatorWithAnimation:YES];
            }];
//            NSLog(@"m_hideNonModalProgressIndicator scheduled for UUID %@", l_blockUuid);
        }

//        NSLog(@"*** BLOCK END - UUID: %@", l_blockUuid);

    } copy];

    // Start work requested
    dispatch_async(self.XYZ_mainSerialDispatchQueue, l_block);

}

-(void)dispatchSerialBlock:(dispatch_block_t)a_block usePrivateManagedObjectContext:(BOOL)a_usePrivateManagedObjectContext{
    [self  dispatchSerialBlock:a_block progressIndicatorContainerView:nil cancelPreviousBlocks:NO
usePrivateManagedObjectContext:a_usePrivateManagedObjectContext];
}

-(void)dispatchConcurrentBackgroundBlock:(dispatch_block_t)a_block{
    [self XYZ_dispatchConcurrentBlock:a_block priority:DISPATCH_QUEUE_PRIORITY_BACKGROUND];
}

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"isFinished"]) {
        [self performSelectorOnMainThread:@selector(doneWithOperation) withObject:nil waitUntilDone:NO];
    }else if ([keyPath isEqualToString:@"determinateProgress"]) {
        BOOL l_determinateProgress = [[self.XYZ_operation valueForKey:keyPath] boolValue];
//        NSLog(@"l_determinateProgress: %u", l_determinateProgress);
        self.XYZ_wipViewManager.determinateProgress = l_determinateProgress;
    }else if ([keyPath isEqualToString:@"determinateProgressPercentage"]) {
        float l_determinateProgressPercentage = [[self.XYZ_operation valueForKey:keyPath] floatValue];
//        NSLog(@"l_determinateProgressPercentage: %f", l_determinateProgressPercentage);
        self.XYZ_wipViewManager.determinateProgressPercentage = l_determinateProgressPercentage;
    }else if ([keyPath isEqualToString:@"progressMessage"]) {
        NSString *l_progressMessage = [self.XYZ_operation valueForKey:keyPath];
//        NSLog(@"l_progressMessage: %@", l_progressMessage);
        self.XYZ_wipViewManager.progressMessage = l_progressMessage;
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

        self.XYZ_operationQueue = [[NSOperationQueue alloc] init];
        NSString *l_mainSerialDispatchQueueId = [NSString stringWithFormat:@"com.infoaccent.IFAAsynchronousOperationManager.mainSerialDispatchQueue.%@", [IFAUtils generateUuid]];
//        NSLog(@"l_mainSerialDispatchQueueId: %@", l_mainSerialDispatchQueueId);
        self.XYZ_mainSerialDispatchQueue = dispatch_queue_create([l_mainSerialDispatchQueueId UTF8String], DISPATCH_QUEUE_SERIAL);
        
        // Set default managed object context for this work manager's threads
        self.managedObjectContext = [IFAPersistenceManager sharedInstance].privateQueueManagedObjectContext;

    }

    return self;

}

-(void)dealloc{
    
    // Remove observers
    if (self.XYZ_isSharedInstance) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationNavigationEvent object:nil];
    }

}

@end
