//
// Created by Marcelo Schroeder on 10/06/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//
//  Created by Marcelo Schroeder on 14/08/09.
//  Copyright 2009 InfoAccent Pty Limited. All rights reserved.
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

#import <Foundation/Foundation.h>

/**
* This class encapsulates interactions with GCD's dispatch queues.
* It allows for some degree of mocking when unit testing code that dispatches blocks to queues asynchronously.
*/
@interface IFADispatchQueueManager : NSObject

- (void)dispatchAsyncMainThreadBlock:(dispatch_block_t)a_block;
- (void)dispatchAsyncMainThreadBlock:(dispatch_block_t)a_block afterDelay:(NSTimeInterval)a_delay;
- (void)dispatchSyncMainThreadBlock:(dispatch_block_t)a_block;
- (void)dispatchAsyncGlobalDefaultPriorityQueueBlock:(dispatch_block_t)a_block;
- (void)dispatchAsyncGlobalQueueBlock:(dispatch_block_t)a_block priority:(dispatch_queue_priority_t)a_priority;

+ (dispatch_time_t)dispatchTimeForDelay:(NSTimeInterval)a_delay;

+ (instancetype)sharedInstance;
@end