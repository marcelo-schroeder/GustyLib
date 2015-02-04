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

#import "GustyLibCoreUI.h"

@interface IFAAsynchronousWorkManager (){
}

@property (strong) NSOperationQueue *IFA_operationQueue;
@property (strong) NSOperation *IFA_operation;
@property (strong) IFAWorkInProgressModalViewManager *IFA_wipViewManager;
@property (nonatomic, strong) IFAHudViewController *IFA_hudViewController;
@property (strong) NSString *IFA_nonModalProgressIndicatorOwnerUuid;
@property (strong) NSString *IFA_cancelAllBlocksRequestOwnerUuid;

@property BOOL IFA_showProgressIndicator;
@property dispatch_queue_t IFA_mainSerialDispatchQueue;
@property BOOL areAllBlocksCancelled;

@property (strong) IFAAsynchronousWorkManagerOperationCompletionBlock IFA_operationCompletionBlock;

@end

@implementation IFAAsynchronousWorkManager {
    
}

#pragma mark -
#pragma mark Private

-(void)IFA_doneWithOperation {
    
//    NSLog(@"IFA_doneWithOperation: %@", [self.IFA_operation description]);
    
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
        [self.IFA_wipViewManager hideView];
    }
    
    // Execute completion block
    if (self.IFA_operationCompletionBlock) {
        self.IFA_operationCompletionBlock(self.IFA_operation);
    }

}

-(void)IFA_dispatchConcurrentBlock:(dispatch_block_t)a_block priority:(long)a_priority{
    dispatch_async(dispatch_get_global_queue(a_priority, 0), a_block);
}

- (IFAHudViewController *)IFA_hudViewController {
    if (!_IFA_hudViewController) {
        _IFA_hudViewController = [IFAHudViewController new];
        _IFA_hudViewController.visualIndicatorMode = IFAHudViewVisualIndicatorModeProgressIndeterminate;
        _IFA_hudViewController.modal = NO;
    }
    return _IFA_hudViewController;
}

#pragma mark -
#pragma mark Public

-(void)showNonModalProgressIndicatorInViewController:(UIViewController *)a_viewController {
    @synchronized(self){
        [self.IFA_hudViewController presentHudViewControllerWithParentViewController:a_viewController
                                                                          parentView:nil
                                                                            animated:YES
                                                                          completion:nil];
    }
}

-(void)showNonModalProgressIndicator {
    [self showNonModalProgressIndicatorInViewController:[IFAUIUtils nonModalHudContainerViewController]];
}

-(void)hideNonModalProgressIndicatorWithAnimation:(BOOL)a_animate{
    @synchronized(self){
        [self.IFA_hudViewController dismissHudViewControllerWithAnimated:a_animate
                                                              completion:nil];
        self.IFA_hudViewController = nil;
    }
}

-(void)dispatchOperation:(NSOperation*)a_operation{
    [self dispatchOperation:a_operation showProgressIndicator:YES completionBlock:nil];
}

- (void)dispatchOperation:(NSOperation *)a_operation completionBlock:(void (^)(NSOperation *a_completedOperation))a_completionBlock {
    [self dispatchOperation:a_operation showProgressIndicator:YES completionBlock:a_completionBlock];
}

- (void)dispatchOperation:(NSOperation *)a_operation showProgressIndicator:(BOOL)a_showProgressIndicator
          completionBlock:(void (^)(NSOperation *a_completedOperation))a_completionBlock {
    
    // Store arguments
    self.IFA_operation = a_operation;
    self.IFA_showProgressIndicator = a_showProgressIndicator;
    self.IFA_operationCompletionBlock = a_completionBlock;

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
        self.IFA_wipViewManager = [IFAWorkInProgressModalViewManager new];
        if (l_allowCancellation) {
            __weak __typeof(self) weakSelf = self;
            self.IFA_wipViewManager.cancellationCompletionBlock = ^{
                [weakSelf cancelAllOperations];
            };
        }
        [self.IFA_wipViewManager showViewWithMessage:l_message];
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
    [self            dispatchSerialBlock:a_block
progressIndicatorContainerViewController:a_showProgressIndicator ? [IFAUIUtils nonModalHudContainerViewController] : nil
                    cancelPreviousBlocks:a_cancelPreviousBlocks];
}

-(void)              dispatchSerialBlock:(dispatch_block_t)a_block
progressIndicatorContainerViewController:(UIViewController *)a_progressIndicatorContainerViewController
                    cancelPreviousBlocks:(BOOL)a_cancelPreviousBlocks{
    [self            dispatchSerialBlock:a_block
progressIndicatorContainerViewController:a_progressIndicatorContainerViewController
                    cancelPreviousBlocks:a_cancelPreviousBlocks usePrivateManagedObjectContext:YES];
}

-(void)              dispatchSerialBlock:(dispatch_block_t)a_block
progressIndicatorContainerViewController:(UIViewController *)a_progressIndicatorContainerViewController
                    cancelPreviousBlocks:(BOOL)a_cancelPreviousBlocks usePrivateManagedObjectContext:(BOOL)a_usePrivateManagedObjectContext{
    
    // Generate a UUID to identify this block
    NSString *l_blockUuid = [IFAUtils generateUuid];
    
    // Cancel previous blocks if required
    if (a_cancelPreviousBlocks) {
        self.areAllBlocksCancelled = YES;
        self.IFA_cancelAllBlocksRequestOwnerUuid = l_blockUuid;
    }

    // Hide progress indicator if required
    if (a_progressIndicatorContainerViewController) {
        self.IFA_nonModalProgressIndicatorOwnerUuid = l_blockUuid;
//        NSLog(@"self.IFA_nonModalProgressIndicatorOwnerUuid set to %@", self.IFA_nonModalProgressIndicatorOwnerUuid);
        [self showNonModalProgressIndicatorInViewController:a_progressIndicatorContainerViewController];
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
        if (a_progressIndicatorContainerViewController && [l_weakSelf.IFA_nonModalProgressIndicatorOwnerUuid isEqualToString:l_blockUuid]) {
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
    [self  dispatchSerialBlock:a_block progressIndicatorContainerViewController:nil cancelPreviousBlocks:NO
usePrivateManagedObjectContext:a_usePrivateManagedObjectContext];
}

-(void)dispatchConcurrentBackgroundBlock:(dispatch_block_t)a_block{
    [self IFA_dispatchConcurrentBlock:a_block priority:DISPATCH_QUEUE_PRIORITY_BACKGROUND];
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

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    // The assumption here is that these observations are being done on a thread other than the main thread,
    // so dispatch UI work back to the main thread
    [IFAUtils dispatchAsyncMainThreadBlock:^{
        if ([keyPath isEqualToString:@"isFinished"]) {
            [self IFA_doneWithOperation];
        } else if ([keyPath isEqualToString:@"determinateProgress"]) {
            BOOL l_determinateProgress = [[self.IFA_operation valueForKey:keyPath] boolValue];
//            NSLog(@"l_determinateProgress: %u", l_determinateProgress);
            self.IFA_wipViewManager.determinateProgress = l_determinateProgress;
        } else if ([keyPath isEqualToString:@"determinateProgressPercentage"]) {
            CGFloat l_determinateProgressPercentage = [[self.IFA_operation valueForKey:keyPath] floatValue];
//            NSLog(@"l_determinateProgressPercentage: %f", l_determinateProgressPercentage);
            self.IFA_wipViewManager.determinateProgressPercentage = l_determinateProgressPercentage;
        } else if ([keyPath isEqualToString:@"progressMessage"]) {
            NSString *l_progressMessage = [self.IFA_operation valueForKey:keyPath];
//            NSLog(@"l_progressMessage: %@", l_progressMessage);
            self.IFA_wipViewManager.progressMessage = l_progressMessage;
        } else {
            NSAssert(NO, @"Unexpected key path: %@", keyPath);
        }
    }];
}

#pragma mark - Singleton functions

+ (IFAAsynchronousWorkManager *)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IFAAsynchronousWorkManager *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
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

@end
