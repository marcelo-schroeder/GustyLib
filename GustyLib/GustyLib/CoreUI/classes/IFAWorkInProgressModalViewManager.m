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

#import "GustyLibCoreUI.h"

@interface IFAWorkInProgressModalViewManager ()
@property (nonatomic, strong) IFAHudViewController *hudViewController;
@end

@implementation IFAWorkInProgressModalViewManager

#pragma mark - Public

-(void)setDeterminateProgress:(BOOL)determinateProgress {
    self.hudViewController.visualIndicatorMode = determinateProgress ? IFAHudViewVisualIndicatorModeProgressDeterminate : IFAHudViewVisualIndicatorModeProgressIndeterminate;
}

-(BOOL)determinateProgress {
    return self.hudViewController.visualIndicatorMode == IFAHudViewVisualIndicatorModeProgressDeterminate;
}

-(void)setDeterminateProgressPercentage:(CGFloat)determinateProgressPercentage {
    self.hudViewController.progress = determinateProgressPercentage;
}

-(CGFloat)determinateProgressPercentage {
    return self.hudViewController.progress;
}

- (NSString *)progressMessage {
    return self.hudViewController.text;
}

- (void)setProgressMessage:(NSString *)progressMessage {
    self.hudViewController.text = progressMessage;
}

- (void)showViewWithMessage:(NSString *)a_message {
    [self showViewWithMessage:a_message parentViewController:nil
                   parentView:nil animated:YES];
}

- (void)hideView {
    [self hideViewAnimated:YES];
}

- (void)showViewWithMessage:(NSString *)a_message
       parentViewController:(UIViewController *)a_parentViewController
                 parentView:(UIView *)a_parentView
                   animated:(BOOL)a_animated {
    self.hasBeenCancelled = NO;
    self.hudViewController.text = a_message;
    if (self.cancelationCompletionBlock) {
        self.hudViewController.detailText = @"Tap to cancel";
        __weak __typeof(self) weakSelf = self;
        self.hudViewController.chromeTapActionBlock = ^{
            weakSelf.hasBeenCancelled = YES;
            weakSelf.hudViewController.visualIndicatorMode = IFAHudViewVisualIndicatorModeProgressIndeterminate;
            weakSelf.hudViewController.detailText = @"Cancelling...";
            weakSelf.cancelationCompletionBlock();
        };
    } else {
        self.hudViewController.detailText = nil;
        self.hudViewController.chromeTapActionBlock = ^{};
    }
    [self.hudViewController presentHudViewControllerWithParentViewController:a_parentViewController
                                                                  parentView:a_parentView
                                                                    animated:a_animated
                                                                  completion:nil];
}

- (void)hideViewAnimated:(BOOL)a_animated {
    [self.hudViewController dismissHudViewControllerWithAnimated:a_animated
                                                      completion:nil];
}

- (IFAHudViewController *)hudViewController {
    if (!_hudViewController) {
        _hudViewController = [IFAHudViewController new];
        _hudViewController.visualIndicatorMode = IFAHudViewVisualIndicatorModeProgressIndeterminate;
        //wip: set this stuff in the appearance theme - see notes below
        // OPTION 1
        // - Introduce the modal mode and associated modal colours
        // OPTION 2
        // - subclass IFAHudView and name it IFAModalHudView
        // - create the defaultAppearancePropertiesForHudView method (currently in default theme) in the protocol and make it an instance method instead of a class method
        // - in the defaultAppearancePropertiesForHudView in the default theme, handle the customisation of the IFAModalHudView class according to the code below
        // - subclass IFAHudViewController and name the new class IFAModalHudViewController
        // - in the new class, hudView should return an instance of IFAModalHudView (carefull to move the translatesAutoresizingMaskIntoConstraints current in the getter in IFAHudViewController)
        // - instantiate the new class in the init above
//        _hudViewController.hudView.style = IFAHudViewStylePlain;
//        _hudViewController.hudView.nonModalOverlayColour = [[UIColor blackColor] colorWithAlphaComponent:0.6];
//        _hudViewController.hudView.nonModalChromeForegroundColour = [UIColor blackColor];
//        _hudViewController.hudView.nonModalChromeBackgroundColour = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    }
    return _hudViewController;
}

@end
