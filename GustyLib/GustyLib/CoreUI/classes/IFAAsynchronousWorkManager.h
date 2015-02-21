//
//  IFAAsynchronousWorkManager.h
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

typedef void (^IFAAsynchronousWorkManagerOperationCompletionBlock)(NSOperation *a_completedOperation);

/**
* This class manages asynchronous work in the form of operations or blocks sent to serial queues.
* There is also the option to show progress information on the UI.
* A shared instance can be used via the <sharedInstance> method, or independent instances can be created to isolate work.
* Each instance will create its own operation queue (for work based on NSOperation instances) and serial dispatch queue (for work based on dispatch blocks).
*/
@interface IFAAsynchronousWorkManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (readonly) BOOL areAllBlocksCancelled;

+ (IFAAsynchronousWorkManager *)sharedInstance;

-(void)showNonModalProgressIndicatorInViewController:(UIViewController *)a_viewController;
-(void)showNonModalProgressIndicator;
-(void)hideNonModalProgressIndicatorWithAnimation:(BOOL)a_animate;

/** @name Methods based on NSOperation */

/**
* Dispatch an operation to the receiver's operation queue.
*
* By default, this method will display progress information on the UI.
* @param a_operation Operation to be dispatched.
*/
-(void)dispatchOperation:(NSOperation*)a_operation;

/**
* Dispatch an operation to the receiver's operation queue.
*
* By default, this method will display progress information on the UI.
* @param a_operation Operation to be dispatched.
* @param a_completionBlock Block to execute when the operation finishes. The operation instance is available as block parameter.
*/
- (void)dispatchOperation:(NSOperation *)a_operation
          completionBlock:(IFAAsynchronousWorkManagerOperationCompletionBlock)a_completionBlock;


/**
* Dispatch an operation to the receiver's operation queue.
* @param a_operation Operation to be dispatched.
* @param a_showProgressIndicator Indicates whether progress information should be shown on the UI.
* @param a_completionBlock Block to execute when the operation finishes. The operation instance is available as block parameter.
*/
- (void)dispatchOperation:(NSOperation *)a_operation
    showProgressIndicator:(BOOL)a_showProgressIndicator
          completionBlock:(IFAAsynchronousWorkManagerOperationCompletionBlock)a_completionBlock;

/**
* Cancel all operations one receiver's operation queue.
*/
-(void)cancelAllOperations;

/** @name Methods based on GCD serial dispatch queues */

-(void)dispatchSerialBlock:(dispatch_block_t)a_block;
-(void)dispatchSerialBlock:(dispatch_block_t)a_block cancelPreviousBlocks:(BOOL)a_cancelPreviousBlocks;
-(void)dispatchSerialBlock:(dispatch_block_t)a_block showProgressIndicator:(BOOL)a_showProgressIndicator;
-(void)dispatchSerialBlock:(dispatch_block_t)a_block showProgressIndicator:(BOOL)a_showProgressIndicator
      cancelPreviousBlocks:(BOOL)a_cancelPreviousBlocks;
-(void)              dispatchSerialBlock:(dispatch_block_t)a_block
progressIndicatorContainerViewController:(UIViewController *)a_progressIndicatorContainerViewController
                    cancelPreviousBlocks:(BOOL)a_cancelPreviousBlocks;
-(void)              dispatchSerialBlock:(dispatch_block_t)a_block
progressIndicatorContainerViewController:(UIViewController *)a_progressIndicatorContainerViewController
                    cancelPreviousBlocks:(BOOL)a_cancelPreviousBlocks usePrivateManagedObjectContext:(BOOL)a_usePrivateManagedObjectContext;
-(void)dispatchSerialBlock:(dispatch_block_t)a_block usePrivateManagedObjectContext:(BOOL)a_usePrivateManagedObjectContext;
-(void)cancelAllSerialBlocks;

/* the methods below are based on GCD global concurrent dispatch queues */

-(void)dispatchConcurrentBackgroundBlock:(dispatch_block_t)a_block;

@end
