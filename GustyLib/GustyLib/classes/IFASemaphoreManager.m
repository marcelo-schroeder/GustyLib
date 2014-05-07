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

#import "IFACommon.h"

@interface IFASemaphoreManager ()

@property(nonatomic, strong) IFAWorkInProgressModalViewManager *XYZ_progressIndicatorManager;
@property(nonatomic) BOOL XYZ_isWaitingForSemaphore;

@end

@implementation IFASemaphoreManager {

}

#pragma mark - Private

- (IFAWorkInProgressModalViewManager *)XYZ_progressIndicatorManager {
    if (!_XYZ_progressIndicatorManager) {
        _XYZ_progressIndicatorManager = [IFAWorkInProgressModalViewManager new];
    }
    return _XYZ_progressIndicatorManager;
}

#pragma mark - Public

- (BOOL)waitForSemaphore:(dispatch_semaphore_t)a_semaphore
shouldShowModalProgressIndicator:(BOOL)a_shouldShowModalProgressIndicator
        progressIndicatorMessage:(NSString *)a_progressIndicatorMessage
            semaphoreNoWaitBlock:(void (^)())a_semaphoreNoWaitBlock
          semaphoreWaitOverBlock:(void (^)())a_semaphoreWaitOverBlock
           userCancellationBlock:(void (^)())a_userCancellationBlock {

    if (self.XYZ_isWaitingForSemaphore) {
        return NO;
    }

    __weak IFASemaphoreManager *l_weakSelf = self;

    long l_semaphoreTimeout = dispatch_semaphore_wait(a_semaphore, DISPATCH_TIME_NOW);
    if (l_semaphoreTimeout) {
        self.XYZ_isWaitingForSemaphore = YES;
        if (a_shouldShowModalProgressIndicator) {
            self.XYZ_progressIndicatorManager.progressMessage = a_progressIndicatorMessage;
            self.XYZ_progressIndicatorManager.cancelationCompletionBlock = ^{
                [l_weakSelf.XYZ_progressIndicatorManager removeView];
                l_weakSelf.XYZ_isWaitingForSemaphore = NO;
                if (a_userCancellationBlock) {
                    a_userCancellationBlock();
                }
            };
            [self.XYZ_progressIndicatorManager showView];
        }
    } else {
        dispatch_semaphore_signal(a_semaphore);
        if (a_semaphoreNoWaitBlock) {
            a_semaphoreNoWaitBlock();
        }
        return YES;
    }

    [IFAUtils dispatchAsyncGlobalDefaultPriorityQueueBlock:^{
        dispatch_semaphore_wait(a_semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(a_semaphore);
        [IFAUtils dispatchAsyncMainThreadBlock:^{
            if (l_weakSelf.XYZ_isWaitingForSemaphore) {
                if (a_shouldShowModalProgressIndicator) {
                    [l_weakSelf.XYZ_progressIndicatorManager removeView];
                }
                l_weakSelf.XYZ_isWaitingForSemaphore = NO;
                if (a_semaphoreWaitOverBlock) {
                    a_semaphoreWaitOverBlock();
                }
            }
        }];
    }];

    return NO;

}

@end