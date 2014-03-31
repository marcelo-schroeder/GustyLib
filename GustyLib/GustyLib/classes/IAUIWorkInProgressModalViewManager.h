//
//  IAUIWorkInProgressModalViewManager.h
//  Gusty
//
//  Created by Marcelo Schroeder on 18/04/11.
//  Copyright 2010 InfoAccent Pty Limited. All rights reserved.
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

@class MBProgressHUD;

@interface IAUIWorkInProgressModalViewManager : NSObject

@property (nonatomic) BOOL p_determinateProgress;
@property (nonatomic) float p_determinateProgressPercentage;
@property (nonatomic, strong) NSString *p_progressMessage;
@property (nonatomic) BOOL p_hasBeenCancelled;

@property(nonatomic, copy) void (^p_cancelationCompletionBlock)();

-(id)initWithMessage:(NSString*)a_message;
-(id)initWithCancellationCallbackReceiver:(id)a_callbackReceiver cancellationCallbackSelector:(SEL)a_callbackSelector;

- (id)initWithCancellationCallbackReceiver:(id)a_callbackReceiver cancellationCallbackSelector:(SEL)a_callbackSelector
                                                                  cancellationCallbackArgument:(id)a_callbackArgument;

- (id)initWithCancellationCallbackReceiver:(id)a_callbackReceiver cancellationCallbackSelector:(SEL)a_callbackSelector
              cancellationCallbackArgument:(id)a_callbackArgument message:(NSString *)a_message;

- (id)initWithCancellationCompletionBlock:(void (^)())a_cancellationCompletionBlock;

- (void)m_showView;
- (void)m_showViewWithAnimation:(BOOL)a_animate;
- (void)m_showViewForView:(UIView*)a_view;
- (void)m_showViewForView:(UIView*)a_view animate:(BOOL)a_animate;

- (void)m_showViewForView:(UIView *)a_view animate:(BOOL)a_animate
    hudConfigurationBlock:(void (^)(MBProgressHUD *))a_hudConfigurationBlock;

- (void)m_removeView;
- (void)m_removeViewWithAnimation:(BOOL)a_animate;

@end
