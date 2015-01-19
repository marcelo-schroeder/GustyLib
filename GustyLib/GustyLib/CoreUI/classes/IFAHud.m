//
// Created by Marcelo Schroeder on 15/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCoreUI.h"


//wip: memory profile this window thing
@interface IFAHud ()
@property(nonatomic, strong) UIWindow *IFA_window;
@property(nonatomic, strong) IFAHudViewController *IFA_hudViewController;
@property(nonatomic) IFAHudFrameViewLayoutFittingMode frameViewLayoutFittingMode;
@end

@implementation IFAHud {

}

#pragma mark - Public

- (instancetype)init {
    return [self initWithFrameViewLayoutFittingMode:IFAHudFrameViewLayoutFittingModeCompressed];
}

- (instancetype)initWithFrameViewLayoutFittingMode:(IFAHudFrameViewLayoutFittingMode)a_frameViewLayoutFittingMode {
    self = [super init];
    if (self) {
        self.frameViewLayoutFittingMode = a_frameViewLayoutFittingMode;
        self.progressMode = IFAHudProgressModeNone;
    }
    return self;
}

- (void)presentWithCompletion:(void (^)())a_completion {
    [self presentWithAutoDismissalDelay:0 completion:a_completion];
}

- (void)presentWithAutoDismissalDelay:(NSTimeInterval)a_autoDismissalDelay completion:(void (^)())a_completion {
    [self presentWithPresentingViewController:nil animated:YES autoDismissalDelay:a_autoDismissalDelay
                                   completion:a_completion];
}

- (void)presentWithPresentingViewController:(UIViewController *)a_presentingViewController animated:(BOOL)a_animated
                         autoDismissalDelay:(NSTimeInterval)a_autoDismissalDelay completion:(void (^)())a_completion {
    void (^completion)() = ^{
        __weak UIViewController *presentingViewController = a_presentingViewController?:self.IFA_window.rootViewController;
        if (a_autoDismissalDelay) {
            [IFAUtils dispatchAsyncMainThreadBlock:^{
                [self dismissWithPresentingViewController:presentingViewController
                                                 animated:a_animated completion:nil];
            } afterDelay:a_autoDismissalDelay];
        }
        if (a_completion) {
            a_completion();
        }
    };
    if (a_presentingViewController) {
        [a_presentingViewController presentViewController:self.IFA_hudViewController
                                                 animated:a_animated
                                               completion:completion];
    } else {
        if (self.IFA_window.hidden) {
            [self.IFA_window makeKeyAndVisible];
            [self.IFA_window.rootViewController presentViewController:self.IFA_hudViewController
                                                             animated:a_animated
                                                           completion:completion];
        }
    }
}

- (void)dismissWithCompletion:(void (^)())a_completion {
    [self dismissWithPresentingViewController:nil animated:YES completion:a_completion];
}

- (void)dismissWithPresentingViewController:(UIViewController *)a_presentingViewController animated:(BOOL)a_animated
                                 completion:(void (^)())a_completion {
    if (a_presentingViewController) {
        [a_presentingViewController dismissViewControllerAnimated:a_animated
                                                       completion:a_completion];
    } else {
        if (!self.IFA_window.hidden) {
            __weak __typeof(self) l_weakSelf = self;
            void(^completion)() = ^{
                if (a_completion) {
                    a_completion();
                }
                [l_weakSelf.IFA_window resignKeyWindow];
                l_weakSelf.IFA_window.hidden = YES;
            };
            [l_weakSelf.IFA_window.rootViewController dismissViewControllerAnimated:a_animated
                                                                         completion:completion];
        }
    }
}

- (void)setText:(NSString *)text {
    self.IFA_hudViewController.textLabel.text = text;
}

- (NSString *)text {
    return self.IFA_hudViewController.textLabel.text;
}


- (void)setDetailText:(NSString *)detailText {
    self.IFA_hudViewController.detailTextLabel.text = detailText;
}

- (NSString *)detailText {
    return self.IFA_hudViewController.detailTextLabel.text;
}

- (void)setTapActionBlock:(void (^)())tapActionBlock {
    _tapActionBlock = tapActionBlock;
    [self IFA_updateHudViewControllerTapActionBlock];
}

- (void)setShouldDismissOnTap:(BOOL)shouldDismissOnTap {
    _shouldDismissOnTap = shouldDismissOnTap;
    [self IFA_updateHudViewControllerTapActionBlock];
}

- (void)setProgress:(CGFloat)progress {
    self.IFA_hudViewController.progressView.progress = progress;
}

- (CGFloat)progress {
    return self.IFA_hudViewController.progressView.progress;
}

- (void)setProgressMode:(IFAHudProgressMode)progressMode {
    _progressMode = progressMode;
    if (progressMode==IFAHudProgressModeIndeterminate) {
        [self.IFA_hudViewController.activityIndicatorView startAnimating];
    } else {
        [self.IFA_hudViewController.activityIndicatorView stopAnimating];
    }
    self.IFA_hudViewController.progressView.hidden = progressMode!=IFAHudProgressModeDeterminate;
}

- (void)setFrameViewLayoutFittingMode:(IFAHudFrameViewLayoutFittingMode)frameViewLayoutFittingMode {
    _frameViewLayoutFittingMode = frameViewLayoutFittingMode;
    self.IFA_hudViewController.frameViewLayoutFittingSize = frameViewLayoutFittingMode == IFAHudFrameViewLayoutFittingModeExpanded ? UILayoutFittingExpandedSize : UILayoutFittingCompressedSize;
}

- (NSTimeInterval)presentationTransitionDuration {
    return self.IFA_hudViewController.viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.presentationTransitionDuration;
}

- (void)setPresentationTransitionDuration:(NSTimeInterval)presentationTransitionDuration {
    self.IFA_hudViewController.viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.presentationTransitionDuration = presentationTransitionDuration;
}

- (NSTimeInterval)dismissalTransitionDuration {
    return self.IFA_hudViewController.viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.dismissalTransitionDuration;
}

- (void)setDismissalTransitionDuration:(NSTimeInterval)dismissalTransitionDuration {
    self.IFA_hudViewController.viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.dismissalTransitionDuration = dismissalTransitionDuration;
}

#pragma mark - Private

- (UIWindow *)IFA_window {
    if (!_IFA_window) {
        _IFA_window = [[UIWindow alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
        _IFA_window.backgroundColor = [UIColor clearColor];
        UIViewController *rootViewController = [UIViewController new];
        _IFA_window.rootViewController = rootViewController;
    }
    return _IFA_window;
}

- (IFAHudViewController *)IFA_hudViewController {
    if (!_IFA_hudViewController) {
        _IFA_hudViewController = [IFAHudViewController new];
    }
    return _IFA_hudViewController;
}

- (void)IFA_updateHudViewControllerTapActionBlock {
    __weak __typeof(self) l_weakSelf = self;
    self.IFA_hudViewController.tapActionBlock = ^{
        if (l_weakSelf.tapActionBlock) {
            l_weakSelf.tapActionBlock();
        }
        if (l_weakSelf.shouldDismissOnTap) {
            [l_weakSelf dismissWithPresentingViewController:nil animated:YES completion:nil];
        }
    };
}

@end