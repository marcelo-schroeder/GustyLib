//
//  IFAWorkInProgressModalViewManager.m
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

#import "GustyLibCore.h"

@interface IFAWorkInProgressModalViewManager ()
@property(nonatomic, strong) id IFA_cancellationCallbackReceiver;
@property(nonatomic) SEL IFA_cancellationCallbackSelector;
@property(nonatomic, strong) id IFA_cancellationCallbackArgument;
@property(nonatomic, strong) NSString *IFA_message;
@property(nonatomic, strong) IFA_MBProgressHUD *IFA_hud;
@end

@implementation IFAWorkInProgressModalViewManager

#pragma mark - Private

- (void)onCancelTap:(id)aSender{
    [self IFA_removeGestureRecogniser];
    self.IFA_hud.mode = MBProgressHUDModeIndeterminate;
    self.IFA_hud.labelText = @"Cancelling...";
    self.IFA_hud.detailsLabelText = @"";
    self.hasBeenCancelled = YES;
    if (self.cancelationCompletionBlock) {
        self.cancelationCompletionBlock();
    }else{
//    [v_cancellationCallbackReceiver performSelector:v_cancellationCallbackSelector withObject:nil];
        objc_msgSend(self.IFA_cancellationCallbackReceiver, self.IFA_cancellationCallbackSelector, self.IFA_cancellationCallbackArgument);
    }
}

- (void)IFA_removeGestureRecogniser {
    if ([self.IFA_hud.userInteractionView.gestureRecognizers count]==1) {
        [self.IFA_hud.userInteractionView removeGestureRecognizer:[[self.IFA_hud.userInteractionView gestureRecognizers] objectAtIndex:0]];
    }
}

- (id)initWithCancellationCallbackReceiver:(id)a_callbackReceiver 
              cancellationCallbackSelector:(SEL)a_callbackSelector
              cancellationCallbackArgument:(id)a_callbackArgument
               cancellationCompletionBlock:(void (^)())a_cancellationCompletionBlock
                                   message:(NSString *)a_message {
    if((self=[super init])){
        self.IFA_cancellationCallbackReceiver = a_callbackReceiver;
        self.IFA_cancellationCallbackSelector = a_callbackSelector;
        self.IFA_cancellationCallbackArgument = a_callbackArgument;
        self.cancelationCompletionBlock = a_cancellationCompletionBlock;
        self.progressMessage = a_message ? a_message : @"Work in progress...";
    }
    return self;
}

#pragma mark - Public

-(void)setDeterminateProgress:(BOOL)determinateProgress {
    self.IFA_hud.mode = determinateProgress ? MBProgressHUDModeDeterminate : MBProgressHUDModeIndeterminate;
}

-(BOOL)determinateProgress {
    return self.IFA_hud.mode == MBProgressHUDModeDeterminate;
}

-(void)setDeterminateProgressPercentage:(float)determinateProgressPercentage {
    self.IFA_hud.progress = determinateProgressPercentage;
}

-(float)determinateProgressPercentage {
    return self.IFA_hud.progress;
}

-(void)setProgressMessage:(NSString *)progressMessage {
    self.IFA_message = progressMessage;
    if (self.IFA_hud) {
        self.IFA_hud.labelText = self.IFA_message;
    }
}

-(NSString *)progressMessage {
    return self.IFA_message;
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

- (void)showView {
    [self showViewWithAnimation:YES];
}

- (void)showViewWithAnimation:(BOOL)a_animate{
    [self showViewForView:[UIApplication sharedApplication].delegate.window animate:a_animate];
}
    
- (void)showViewForView:(UIView*)a_view{
    [self showViewForView:a_view animate:YES];
}

- (void)showViewForView:(UIView *)a_view animate:(BOOL)a_animate{
    [self showViewForView:a_view animate:a_animate
    hudConfigurationBlock:nil];
}

- (void)showViewForView:(UIView *)a_view animate:(BOOL)a_animate hudConfigurationBlock:(void(^)(IFA_MBProgressHUD *))a_hudConfigurationBlock{

    self.hasBeenCancelled = NO;

    // Instantiate HUD
    self.IFA_hud = [[IFA_MBProgressHUD alloc] initWithView:a_view];
    
    // Configure HUD
    self.IFA_hud.opacity = 0.6;
    self.IFA_hud.labelText = self.progressMessage;
    self.IFA_hud.removeFromSuperViewOnHide = YES;
    self.IFA_hud.animationType = MBProgressHUDAnimationFade;
    self.IFA_hud.dimBackground = YES;
    self.IFA_hud.mode = MBProgressHUDModeIndeterminate;
    
    // Allow cancellation if required
    if (self.IFA_cancellationCallbackReceiver || self.cancelationCompletionBlock) {

        // Set details label to indicate that cancellation is possible
        self.IFA_hud.detailsLabelText = @"Tap to cancel";
        
        // Add tap gesture recogniser
        UITapGestureRecognizer *l_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancelTap:)];
        [self.IFA_hud.userInteractionView addGestureRecognizer:l_recognizer];
        
    }

    // Run HUD configuration block if required
    if (a_hudConfigurationBlock) {
        a_hudConfigurationBlock(self.IFA_hud);
    }

    // Show HUD
    [a_view addSubview:self.IFA_hud];
    [self.IFA_hud show:a_animate];
    
}

- (void)removeView {
    [self removeViewWithAnimation:YES];
}

- (void)removeViewWithAnimation:(BOOL)a_animate{
    [self.IFA_hud hide:a_animate];
    [self IFA_removeGestureRecogniser];
}

@end
