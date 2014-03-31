//
//  IAUIWorkInProgressModalViewManager.m
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

#import "IACommon.h"

@implementation IAUIWorkInProgressModalViewManager
{
    
@private
    id v_cancellationCallbackReceiver;
    SEL v_cancellationCallbackSelector;
    id v_cancellationCallbackArgument;
    NSString *v_message;
    MBProgressHUD *v_hud;
    
}

#pragma mark - Private

- (void)onCancelTap:(id)aSender{
    [self m_removeGestureRecogniser];
    v_hud.mode = MBProgressHUDModeIndeterminate;
    v_hud.labelText = @"Cancelling...";
    v_hud.detailsLabelText = @"";
    self.p_hasBeenCancelled = YES;
    if (self.p_cancelationCompletionBlock) {
        self.p_cancelationCompletionBlock();
    }else{
//    [v_cancellationCallbackReceiver performSelector:v_cancellationCallbackSelector withObject:nil];
        objc_msgSend(v_cancellationCallbackReceiver, v_cancellationCallbackSelector, v_cancellationCallbackArgument);
    }
}

- (void)m_removeGestureRecogniser {
    if ([v_hud.p_userInteractionView.gestureRecognizers count]==1) {
        [v_hud.p_userInteractionView removeGestureRecognizer:[[v_hud.p_userInteractionView gestureRecognizers] objectAtIndex:0]];
    }
}

- (id)initWithCancellationCallbackReceiver:(id)a_callbackReceiver 
              cancellationCallbackSelector:(SEL)a_callbackSelector
              cancellationCallbackArgument:(id)a_callbackArgument
               cancellationCompletionBlock:(void (^)())a_cancellationCompletionBlock
                                   message:(NSString *)a_message {
    if((self=[super init])){
        v_cancellationCallbackReceiver = a_callbackReceiver;
        v_cancellationCallbackSelector = a_callbackSelector;
        v_cancellationCallbackArgument = a_callbackArgument;
        self.p_cancelationCompletionBlock = a_cancellationCompletionBlock;
        self.p_progressMessage = a_message ? a_message : @"Work in progress...";
    }
    return self;
}

#pragma mark - Public

-(void)setP_determinateProgress:(BOOL)p_determinateProgress{
    v_hud.mode = p_determinateProgress ? MBProgressHUDModeDeterminate : MBProgressHUDModeIndeterminate;
}

-(BOOL)p_determinateProgress{
    return v_hud.mode == MBProgressHUDModeDeterminate;
}

-(void)setP_determinateProgressPercentage:(float)p_determinateProgressPercentage{
    v_hud.progress = p_determinateProgressPercentage;
}

-(float)p_determinateProgressPercentage{
    return v_hud.progress;
}

-(void)setP_progressMessage:(NSString *)p_progressMessage{
    v_message = p_progressMessage;
    if (v_hud) {
        v_hud.labelText = v_message;
    }
}

-(NSString *)p_progressMessage{
    return v_message;
}

-(id)initWithMessage:(NSString*)a_message{
    return [self initWithCancellationCallbackReceiver:nil cancellationCallbackSelector:NULL
                         cancellationCallbackArgument:nil
                                              message:a_message];
}

- (id)initWithCancellationCallbackReceiver:(id)a_callbackReceiver cancellationCallbackSelector:(SEL)a_callbackSelector
              cancellationCallbackArgument:(id)a_callbackArgument message:(NSString *)a_message {
    return [self initWithCancellationCallbackReceiver:a_callbackReceiver
                         cancellationCallbackSelector:a_callbackSelector
                         cancellationCallbackArgument:a_callbackArgument
                          cancellationCompletionBlock:nil
                                              message:a_message];
}

-(id)initWithCancellationCallbackReceiver:(id)a_callbackReceiver cancellationCallbackSelector:(SEL)a_callbackSelector{
    return [self initWithCancellationCallbackReceiver:a_callbackReceiver cancellationCallbackSelector:a_callbackSelector
                         cancellationCallbackArgument:nil
                                              message:nil ];
}

-(id)initWithCancellationCallbackReceiver:(id)a_callbackReceiver cancellationCallbackSelector:(SEL)a_callbackSelector cancellationCallbackArgument:(id)a_callbackArgument{
    return [self initWithCancellationCallbackReceiver:a_callbackReceiver cancellationCallbackSelector:a_callbackSelector
                         cancellationCallbackArgument:a_callbackArgument
                                              message:nil ];
}

- (id)initWithCancellationCompletionBlock:(void (^)())a_cancellationCompletionBlock {
    return [self initWithCancellationCallbackReceiver:nil
                         cancellationCallbackSelector:nil
                         cancellationCallbackArgument:nil
                          cancellationCompletionBlock:a_cancellationCompletionBlock
                                              message:nil];
}

- (void)m_showView{
    [self m_showViewWithAnimation:YES];
}

- (void)m_showViewWithAnimation:(BOOL)a_animate{
    [self m_showViewForView:[UIApplication sharedApplication].delegate.window animate:a_animate];
}
    
- (void)m_showViewForView:(UIView*)a_view{
    [self m_showViewForView:a_view animate:YES];
}

- (void)m_showViewForView:(UIView*)a_view animate:(BOOL)a_animate{
    [self m_showViewForView:a_view animate:a_animate
      hudConfigurationBlock:nil];
}

- (void)m_showViewForView:(UIView*)a_view animate:(BOOL)a_animate hudConfigurationBlock:(void(^)(MBProgressHUD *))a_hudConfigurationBlock{

    self.p_hasBeenCancelled = NO;

    // Instantiate HUD
    v_hud = [[MBProgressHUD alloc] initWithView:a_view];
    
    // Configure HUD
    v_hud.opacity = 0.6;
    v_hud.labelText = self.p_progressMessage;
    v_hud.removeFromSuperViewOnHide = YES;
    v_hud.animationType = MBProgressHUDAnimationFade;
    v_hud.dimBackground = YES;
    v_hud.mode = MBProgressHUDModeIndeterminate;
    
    // Allow cancellation if required
    if (v_cancellationCallbackReceiver || self.p_cancelationCompletionBlock) {

        // Set details label to indicate that cancellation is possible
        v_hud.detailsLabelText = @"Tap to cancel";
        
        // Add tap gesture recogniser
        UITapGestureRecognizer *l_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancelTap:)];
        [v_hud.p_userInteractionView addGestureRecognizer:l_recognizer];
        
    }

    // Run HUD configuration block if required
    if (a_hudConfigurationBlock) {
        a_hudConfigurationBlock(v_hud);
    }

    // Show HUD
    [a_view addSubview:v_hud];
    [v_hud show:a_animate];
    
}

- (void)m_removeView{
    [self m_removeViewWithAnimation:YES];
}

- (void)m_removeViewWithAnimation:(BOOL)a_animate{
    [v_hud hide:a_animate];
    [self m_removeGestureRecogniser];
}

@end
