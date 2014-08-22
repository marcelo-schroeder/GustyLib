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

@property (strong) NSOperationQueue *IFA_operationQueue;
@property (strong) NSOperation *IFA_operation;
@property (strong) IFAWorkInProgressModalViewManager *IFA_wipViewManager;
@property (strong) id IFA_callbackObject;
@property (strong) IFA_MBProgressHUD *IFA_hud;
@property (strong) NSString *IFA_nonModalProgressIndicatorOwnerUuid;
@property (strong) NSString *IFA_cancelAllBlocksRequestOwnerUuid;

@property SEL IFA_callbackSelector;
@property BOOL IFA_showProgressIndicator;
@property dispatch_queue_t IFA_mainSerialDispatchQueue;
@property BOOL areAllBlocksCancelled;
@property BOOL IFA_isSharedInstance;

@end

@implementation IFAAsynchronousWorkManager {
    
}

#pragma mark -
#pragma mark Private

-(void)doneWithOperation{
    
//    NSLog(@"doneWithOperation: %@", [self.IFA_operation description]);
    
    // Remove KVO observers
    [self.IFA_operation removeObserver:self forKeyPath:@"isFinished"];
    if (self.IFA_showProgressIndicator) {
        if ([self.IFA_operation isKindOfClass:[IFAOperation class]]) {
            [self.IFA_operation removeObserver:self forKeyPath:@"determinateProgress"];
            [self.IFA_operation removeObserver:self forKeyPath:@"determinateProgressPercentage"];
            [self.IFA_operation removeObserver:self forKeyPath:@"progressMessage"];
        }
    }
    
    // Remove modal WIP view
    if (self.IFA_showProgressIndicator) {
        [self.IFA_wipViewManager removeView];
    }
    
    // Perform callback selector
    if (self.IFA_callbackObject && self.IFA_callbackSelector) {
//        [v_callbackObject performSelector:v_callbackSelector withObject:v_operation];
        objc_msgSend(self.IFA_callbackObject, self.IFA_callbackSelector, self.IFA_operation);
    }

}

- (void)IFA_onNavigationEventNotification:(NSNotification*)aNotification{
//    NSLog(@"IFANotificationNavigationEvent received");
    [self cancelAllSerialBlocks];
}

-(void)cancelAllSerialBlocks {
    [self hideNonModalProgressIndicatorWithAnimation:NO];
    self.areAllBlocksCancelled = YES;
    self.IFA_cancelAllBlocksRequestOwnerUuid = nil;
//    NSLog(@"   ###   areAllBlocksCancelled = YES");
    __weak __typeof(self) l_weakSelf = self;
    dispatch_async(self.IFA_mainSerialDispatchQueue, ^{
        if (!l_weakSelf.IFA_cancelAllBlocksRequestOwnerUuid) {
            l_weakSelf.areAllBlocksCancelled = NO;
//            NSLog(@"   ###   areAllBlocksCancelled = NO");
        }
    });
}

-(void)IFA_dispatchConcurrentBlock:(dispatch_block_t)a_block priority:(long)a_priority{
    dispatch_async(dispatch_get_global_queue(a_priority, 0), a_block);
}

-(id)initAsSharedInstance{
    
    if (self=[self init]) {
        
        self.IFA_isSharedInstance = YES;
        
        // Add observers
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(IFA_onNavigationEventNotification:)
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
        if (!self.IFA_hud) {
            self.IFA_hud = [[IFA_MBProgressHUD alloc] initWithView:a_view];
            self.IFA_hud.opacity = 0.2;
            self.IFA_hud.removeFromSuperViewOnHide = YES;
            self.IFA_hud.animationType = MBProgressHUDAnimationFade;
            self.IFA_hud.mode = MBProgressHUDModeIndeterminate;
            self.IFA_hud.userInteractionEnabled = NO;
            [a_view addSubview:self.IFA_hud];
            [self.IFA_hud show:YES];
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
        if (self.IFA_hud) {
            [self.IFA_hud hide:a_animate];
            self.IFA_hud = nil;
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
    self.IFA_operation = a_operation;
    self.IFA_showProgressIndicator = a_showProgressIndicator;
    self.IFA_callbackObject = a_callbackObject;
    self.IFA_callbackSelector = a_callbackSelector;
    
    // Add observer for when operation is finished
    [self.IFA_operation addObserver:self forKeyPath:@"isFinished" options:0 context:nil];
    
    // Add observers for tracking progress
    if (self.IFA_showProgressIndicator) {
        if ([self.IFA_operation isKindOfClass:[IFAOperation class]]) {
            [self.IFA_operation addObserver:self forKeyPath:@"determinateProgress" options:0 context:nil];
            [self.IFA_operation addObserver:self forKeyPath:@"determinateProgressPercentage" options:0 context:nil];
            [self.IFA_operation addObserver:self forKeyPath:@"progressMessage" options:0 context:nil];
        }
    }

    // Show "work in progress" modal view
    if (self.IFA_showProgressIndicator) {
        NSString *l_message = nil;
        BOOL l_allowCancellation = NO;
        if ([self.IFA_operation isKindOfClass:[IFAOperation class]]) {
            IFAOperation *l_operation = ((IFAOperation *)a_operation);
            l_message = l_operation.progressMessage;
            l_allowCancellation = l_operation.allowCancellation;
        }
        if (l_allowCancellation) {
            self.IFA_wipViewManager = [[IFAWorkInProgressModalViewManager alloc] initWithCancellationCallbackReceiver:self
                                                                                        cancellationCallbackSelector:@selector(cancelAllOperations)
                                                                                        cancellationCallbackArgument:nil
                                                                                                             message:l_message];
        }else{
            self.IFA_wipViewManager = [[IFAWorkInProgressModalViewManager alloc] initWithMessage:l_message];
        }
        [self.IFA_wipViewManager showView];
    }
    
    // Add operation to execution queue
    [self.IFA_operationQueue addOperation:self.IFA_operation];

}

-(void)cancelAllOperations {
//    NSLog(@"Cancelling all operations in the queue...");
    [self.IFA_operationQueue cancelAllOperations];
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
        self.IFA_cancelAllBlocksRequestOwnerUuid = l_blockUuid;
    }

    // Hide progress indicator if required
    if (a_progressIndicatorContainerView) {
        self.IFA_nonModalProgressIndicatorOwnerUuid = l_blockUuid;
//        NSLog(@"self.IFA_nonModalProgressIndicatorOwnerUuid set to %@", self.IFA_nonModalProgressIndicatorOwnerUuid);
        [self showNonModalProgressIndicatorInView:a_progressIndicatorContainerView];
    }
    
    __weak __typeof(self) l_weakSelf = self;
    dispatch_block_t l_block = [^{
        
//        NSLog(@"");
//        NSLog(@"*** BLOCK START - UUID: %@", l_blockUuid);
//        NSLog(@"self: %@", [l_weakSelf description]);
//        NSLog(@"IFA_cancelAllBlocksRequestOwnerUuid: %@", [IFA_cancelAllBlocksRequestOwnerUuid description]);
//        NSLog(@"a_block: %@", [a_block description]);
        
        // Reset the managed object context to avoid stale objects for this session
        [l_weakSelf.managedObjectContext reset];
        
        if (l_weakSelf.areAllBlocksCancelled && [l_weakSelf.IFA_cancelAllBlocksRequestOwnerUuid isEqualToString:l_blockUuid]) {
            l_weakSelf.areAllBlocksCancelled = NO;
            l_weakSelf.IFA_cancelAllBlocksRequestOwnerUuid = nil;
         }

        // Execute "the" block
//        NSLog(@"about to execute inner block...");
        NSMutableDictionary *l_threadDict = nil;
        if (a_usePrivateManagedObjectContext) {
            l_threadDict = [[NSThread currentThread] threadDictionary];
            l_threadDict[IFAKeySerialQueueManagedObjectContext] = l_weakSelf.managedObjectContext;
        }
        a_block();
        if (l_threadDict) {
            [l_threadDict removeObjectForKey:IFAKeySerialQueueManagedObjectContext];
        }
//        NSLog(@"inner block executed!");

        // Hide progress indicator if required
        if (a_progressIndicatorContainerView && [l_weakSelf.IFA_nonModalProgressIndicatorOwnerUuid isEqualToString:l_blockUuid]) {
            [IFAUtils dispatchAsyncMainThreadBlock:^{
                [l_weakSelf hideNonModalProgressIndicatorWithAnimation:YES];
            }];
//            NSLog(@"m_hideNonModalProgressIndicator scheduled for UUID %@", l_blockUuid);
        }

//        NSLog(@"*** BLOCK END - UUID: %@", l_blockUuid);

    } copy];

    // Start work requested
    dispatch_async(self.IFA_mainSerialDispatchQueue, l_block);

}

-(void)dispatchSerialBlock:(dispatch_block_t)a_block usePrivateManagedObjectContext:(BOOL)a_usePrivateManagedObjectContext{
    [self  dispatchSerialBlock:a_block progressIndicatorContainerView:nil cancelPreviousBlocks:NO
usePrivateManagedObjectContext:a_usePrivateManagedObjectContext];
}

-(void)dispatchConcurrentBackgroundBlock:(dispatch_block_t)a_block{
    [self IFA_dispatchConcurrentBlock:a_block priority:DISPATCH_QUEUE_PRIORITY_BACKGROUND];
}

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"isFinished"]) {
        [self performSelectorOnMainThread:@selector(doneWithOperation) withObject:nil waitUntilDone:NO];
    }else if ([keyPath isEqualToString:@"determinateProgress"]) {
        BOOL l_determinateProgress = [[self.IFA_operation valueForKey:keyPath] boolValue];
//        NSLog(@"l_determinateProgress: %u", l_determinateProgress);
        self.IFA_wipViewManager.determinateProgress = l_determinateProgress;
    }else if ([keyPath isEqualToString:@"determinateProgressPercentage"]) {
        float l_determinateProgressPercentage = [[self.IFA_operation valueForKey:keyPath] floatValue];
//        NSLog(@"l_determinateProgressPercentage: %f", l_determinateProgressPercentage);
        self.IFA_wipViewManager.determinateProgressPercentage = l_determinateProgressPercentage;
    }else if ([keyPath isEqualToString:@"progressMessage"]) {
        NSString *l_progressMessage = [self.IFA_operation valueForKey:keyPath];
//        NSLog(@"l_progressMessage: %@", l_progressMessage);
        self.IFA_wipViewManager.progressMessage = l_progressMessage;
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

        self.IFA_operationQueue = [[NSOperationQueue alloc] init];
        NSString *l_mainSerialDispatchQueueId = [NSString stringWithFormat:@"com.infoaccent.IFAAsynchronousOperationManager.mainSerialDispatchQueue.%@", [IFAUtils generateUuid]];
//        NSLog(@"l_mainSerialDispatchQueueId: %@", l_mainSerialDispatchQueueId);
        self.IFA_mainSerialDispatchQueue = dispatch_queue_create([l_mainSerialDispatchQueueId UTF8String], DISPATCH_QUEUE_SERIAL);
        
        // Set default managed object context for this work manager's threads
        self.managedObjectContext = [IFAPersistenceManager sharedInstance].privateQueueManagedObjectContext;

    }

    return self;

}

-(void)dealloc{
    
    // Remove observers
    if (self.IFA_isSharedInstance) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationNavigationEvent object:nil];
    }

}

@end
