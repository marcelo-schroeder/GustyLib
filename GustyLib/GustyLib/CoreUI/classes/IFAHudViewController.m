//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
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

@interface IFAHudViewController ()
@property (nonatomic, strong) IFAHudView *hudView;
@property(nonatomic, strong) UIWindow *IFA_window;
@end

@implementation IFAHudViewController {

}

#pragma mark - Public

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self ifa_commonInit];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self ifa_commonInit];
    }
    return self;
}

- (IFAHudView *)hudView {
    if (!_hudView) {
        _hudView = [IFAHudView new];
        _hudView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _hudView;
}

- (void)setText:(NSString *)text {
    self.hudView.textLabel.text = text;
}

- (NSString *)text {
    return self.hudView.textLabel.text;
}

- (void)setDetailText:(NSString *)detailText {
    self.hudView.detailTextLabel.text = detailText;
}

- (NSString *)detailText {
    return self.hudView.detailTextLabel.text;
}

- (BOOL)modal {
    return self.hudView.modal;
}

- (void)setModal:(BOOL)modal {
    self.hudView.modal = modal;
    self.IFA_window.userInteractionEnabled = modal;
}

- (void)setOverlayTapActionBlock:(void (^)())overlayTapActionBlock {
    _overlayTapActionBlock = overlayTapActionBlock;
    if (_overlayTapActionBlock) {
        self.modal = YES;
    }
    [self IFA_updateHudViewControllerOverlayTapActionBlock];
}

- (void)setShouldDismissOnOverlayTap:(BOOL)shouldDismissOnOverlayTap {
    _shouldDismissOnOverlayTap = shouldDismissOnOverlayTap;
    if (_shouldDismissOnOverlayTap) {
        self.modal = YES;
    }
    [self IFA_updateHudViewControllerOverlayTapActionBlock];
}

- (void)setChromeTapActionBlock:(void (^)())chromeTapActionBlock {
    _chromeTapActionBlock = chromeTapActionBlock;
    if (_chromeTapActionBlock) {
        self.modal = YES;
    }
    [self IFA_updateHudViewControllerChromeTapActionBlock];
}

- (void)setShouldDismissOnChromeTap:(BOOL)shouldDismissOnChromeTap {
    _shouldDismissOnChromeTap = shouldDismissOnChromeTap;
    if (_shouldDismissOnChromeTap) {
        self.modal = YES;
    }
    [self IFA_updateHudViewControllerChromeTapActionBlock];
}

- (void)setProgress:(CGFloat)progress {
    self.hudView.progressView.progress = progress;
}

- (CGFloat)progress {
    return self.hudView.progressView.progress;
}

- (void)setVisualIndicatorMode:(IFAHudViewVisualIndicatorMode)visualIndicatorMode {
    _visualIndicatorMode = visualIndicatorMode;
    if (visualIndicatorMode == IFAHudViewVisualIndicatorModeProgressIndeterminate) {
        [self.hudView.activityIndicatorView startAnimating];
        self.hudView.activityIndicatorView.hidden = NO;
    } else {
        self.hudView.activityIndicatorView.hidden = YES;
        [self.hudView.activityIndicatorView stopAnimating];
    }
    self.hudView.progressView.hidden = visualIndicatorMode !=IFAHudViewVisualIndicatorModeProgressDeterminate;
    if (visualIndicatorMode == IFAHudViewVisualIndicatorModeSuccess || visualIndicatorMode == IFAHudViewVisualIndicatorModeError) {
        NSString *imageName = visualIndicatorMode == IFAHudViewVisualIndicatorModeSuccess ? @"IFA_Icon_HudSuccess" : @"IFA_Icon_HudError";
        UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.hudView.customView = imageView;
    }
}

- (UIView *)customVisualIndicatorView {
    return self.hudView.customView;
}

- (void)setCustomVisualIndicatorView:(UIView *)customVisualIndicatorView {
    if (customVisualIndicatorView) {
        self.visualIndicatorMode = IFAHudViewVisualIndicatorModeCustom;
    }
    self.hudView.customView = customVisualIndicatorView;
}

- (void)presentHudViewControllerWithParentViewController:(UIViewController *)a_parentViewController
                                              parentView:(UIView *)a_parentView animated:(BOOL)a_animated
                                              completion:(void (^)(BOOL a_finished))a_completion {
    UIViewController *parentViewController;
    if (a_parentViewController) {
        parentViewController = a_parentViewController;
    }
    else {
        [self.IFA_window makeKeyAndVisible];
        parentViewController = self.IFA_window.rootViewController;
    }
    UIView *parentView = a_parentView ? : parentViewController.view;
    __weak __typeof(self) weakSelf = self;
    void (^completion)(BOOL a_finished) = ^(BOOL a_finished) {
        if (a_completion) {
            a_completion(a_finished);
        }
        if (weakSelf.autoDismissalDelay) {
            [IFAUtils dispatchAsyncMainThreadBlock:^{
                [weakSelf dismissHudViewControllerWithAnimated:a_animated
                                                    completion:nil];
            } afterDelay:weakSelf.autoDismissalDelay];
        }
    };
    [parentViewController ifa_addChildViewController:self
                                          parentView:parentView
                                 shouldFillSuperview:YES
                                   animationDuration:a_animated && self.presentationAnimationDuration ? self.presentationAnimationDuration : 0
                                          completion:completion];
}

- (void)dismissHudViewControllerWithAnimated:(BOOL)a_animated completion:(void (^)(BOOL a_finished))a_completion {
    __weak __typeof(self) weakSelf = self;
    void (^completion)(BOOL a_finished) = ^(BOOL a_finished) {
        if (a_completion) {
            a_completion(a_finished);
        }
        [weakSelf.IFA_window resignKeyWindow];
        weakSelf.IFA_window = nil;
    };
    [self ifa_removeFromParentViewControllerWithAnimationDuration:a_animated && self.dismissalAnimationDuration ? self.dismissalAnimationDuration : 0
                                                       completion:completion];
}

#pragma mark - Overrides

- (void)ifa_commonInit {
    self.visualIndicatorMode = IFAHudViewVisualIndicatorModeNone;
    self.modal = YES;
    self.presentationAnimationDuration = 0.3;
    self.dismissalAnimationDuration = 1;
}

- (void)viewDidLoad {

    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    // Add HUD view
    [self.view addSubview:self.hudView];

    // Add layout constraints
    [self.hudView ifa_addLayoutConstraintsToFillSuperview];

    // Make sure layout is up to date
    [self.hudView layoutIfNeeded];

    // Then update constraints so that content changes done so far are taken into consideration
    [self.hudView setNeedsUpdateConstraints];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.hudView.shouldUpdateLayoutAutomaticallyOnContentChange = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.hudView.shouldUpdateLayoutAutomaticallyOnContentChange = NO;
}

#pragma mark - Private

- (void)IFA_updateHudViewControllerOverlayTapActionBlock {
    __weak __typeof(self) weakSelf = self;
    self.hudView.overlayTapActionBlock = ^{
        if (weakSelf.overlayTapActionBlock) {
            weakSelf.overlayTapActionBlock();
        }
        if (weakSelf.shouldDismissOnOverlayTap) {
            [weakSelf dismissHudViewControllerWithAnimated:YES
                                                completion:nil];
        }
    };
}

- (void)IFA_updateHudViewControllerChromeTapActionBlock {
    __weak __typeof(self) weakSelf = self;
    self.hudView.chromeTapActionBlock = ^{
        if (weakSelf.chromeTapActionBlock) {
            weakSelf.chromeTapActionBlock();
        }
        if (weakSelf.shouldDismissOnChromeTap) {
            [weakSelf dismissHudViewControllerWithAnimated:YES
                                                completion:nil];
        }
    };
}

- (UIWindow *)IFA_window {
    if (!_IFA_window) {
        _IFA_window = [[UIWindow alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
        _IFA_window.backgroundColor = [UIColor clearColor];
        UIViewController *rootViewController = [UIViewController new];
        _IFA_window.rootViewController = rootViewController;
    }
    return _IFA_window;
}

@end