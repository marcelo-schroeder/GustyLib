//
// Created by Marcelo Schroeder on 30/01/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

- (BOOL)waitForSemaphore:(dispatch_semaphore_t)a_semaphore
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
            self.p_progressIndicatorManager.progressMessage = a_progressIndicatorMessage;
            self.p_progressIndicatorManager.cancelationCompletionBlock = ^{
                [l_weakSelf.p_progressIndicatorManager removeView];
                l_weakSelf.p_isWaitingForSemaphore = NO;
                if (a_userCancellationBlock) {
                    a_userCancellationBlock();
                }
            };
            [self.p_progressIndicatorManager showView];
        }
    } else {
        dispatch_semaphore_signal(a_semaphore);
        if (a_semaphoreNoWaitBlock) {
            a_semaphoreNoWaitBlock();
        }
        return YES;
    }

    [IAUtils dispatchAsyncGlobalDefaultPriorityQueueBlock:^{
        dispatch_semaphore_wait(a_semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(a_semaphore);
        [IAUtils dispatchAsyncMainThreadBlock:^{
            if (l_weakSelf.p_isWaitingForSemaphore) {
                if (a_shouldShowModalProgressIndicator) {
                    [l_weakSelf.p_progressIndicatorManager removeView];
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