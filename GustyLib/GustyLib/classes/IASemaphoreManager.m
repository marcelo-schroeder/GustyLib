//
// Created by Marcelo Schroeder on 30/01/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IACommon.h"

@interface IASemaphoreManager ()

@property(nonatomic, strong) IAUIWorkInProgressModalViewManager *p_progressIndicatorManager;
@property(nonatomic) BOOL p_isWaitingForSemaphore;

@end

@implementation IASemaphoreManager {

}

#pragma mark - Private

- (IAUIWorkInProgressModalViewManager *)p_progressIndicatorManager {
    if (!_p_progressIndicatorManager) {
        _p_progressIndicatorManager = [IAUIWorkInProgressModalViewManager new];
    }
    return _p_progressIndicatorManager;
}

#pragma mark - Public

- (BOOL)      m_waitForSemaphore:(dispatch_semaphore_t)a_semaphore
shouldShowModalProgressIndicator:(BOOL)a_shouldShowModalProgressIndicator
        progressIndicatorMessage:(NSString *)a_progressIndicatorMessage
            semaphoreNoWaitBlock:(void (^)())a_semaphoreNoWaitBlock
          semaphoreWaitOverBlock:(void (^)())a_semaphoreWaitOverBlock
           userCancellationBlock:(void (^)())a_userCancellationBlock {

    if (self.p_isWaitingForSemaphore) {
        return NO;
    }

    __weak IASemaphoreManager *l_weakSelf = self;

    long l_semaphoreTimeout = dispatch_semaphore_wait(a_semaphore, DISPATCH_TIME_NOW);
    if (l_semaphoreTimeout) {
        self.p_isWaitingForSemaphore = YES;
        if (a_shouldShowModalProgressIndicator) {
            self.p_progressIndicatorManager.p_progressMessage = a_progressIndicatorMessage;
            self.p_progressIndicatorManager.p_cancelationCompletionBlock = ^{
                [l_weakSelf.p_progressIndicatorManager m_removeView];
                l_weakSelf.p_isWaitingForSemaphore = NO;
                if (a_userCancellationBlock) {
                    a_userCancellationBlock();
                }
            };
            [self.p_progressIndicatorManager m_showView];
        }
    } else {
        dispatch_semaphore_signal(a_semaphore);
        if (a_semaphoreNoWaitBlock) {
            a_semaphoreNoWaitBlock();
        }
        return YES;
    }

    [IAUtils m_dispatchAsyncGlobalDefaultPriorityQueueBlock:^{
        dispatch_semaphore_wait(a_semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(a_semaphore);
        [IAUtils m_dispatchAsyncMainThreadBlock:^{
            if (l_weakSelf.p_isWaitingForSemaphore) {
                if (a_shouldShowModalProgressIndicator) {
                    [l_weakSelf.p_progressIndicatorManager m_removeView];
                }
                l_weakSelf.p_isWaitingForSemaphore = NO;
                if (a_semaphoreWaitOverBlock) {
                    a_semaphoreWaitOverBlock();
                }
            }
        }];
    }];

    return NO;

}

@end