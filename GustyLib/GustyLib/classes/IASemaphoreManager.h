//
// Created by Marcelo Schroeder on 30/01/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IASemaphoreManager : NSObject

- (BOOL)      m_waitForSemaphore:(dispatch_semaphore_t)a_semaphore
shouldShowModalProgressIndicator:(BOOL)a_shouldShowModalProgressIndicator
        progressIndicatorMessage:(NSString *)a_progressIndicatorMessage
            semaphoreNoWaitBlock:(void (^)())a_semaphoreNoWaitBlock
          semaphoreWaitOverBlock:(void (^)())a_semaphoreWaitOverBlock
           userCancellationBlock:(void (^)())a_userCancellationBlock;
@end