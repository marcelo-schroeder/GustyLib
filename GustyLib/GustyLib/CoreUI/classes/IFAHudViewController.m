//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <GustyLib/IFAHudView.h>
#import "GustyLibCoreUI.h"

//wip: does the dynamic font stuff work?
//wip: I'm relying on the dimming plumming - I am going to use a dimmed bg? Clean up.
//wip: does the motion stuff has to respect accessibility settings?
//wip: don't forget todo's in the demo app project
@interface IFAHudViewController ()
@property (nonatomic, strong) IFAHudView *hudView;
@property(nonatomic, strong) IFAViewControllerTransitioningDelegate *viewControllerTransitioningDelegate;
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

- (void)setShouldAllowUserInteractionPassthrough:(BOOL)shouldAllowUserInteractionPassthrough {
    _shouldAllowUserInteractionPassthrough = shouldAllowUserInteractionPassthrough;
    self.viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.containerViewUserInteraction = !_shouldAllowUserInteractionPassthrough;  //wip: review this
}

- (void)setOverlayTapActionBlock:(void (^)())overlayTapActionBlock {
    _overlayTapActionBlock = overlayTapActionBlock;
    if (_overlayTapActionBlock) {
        self.shouldAllowUserInteractionPassthrough = NO;
    }
    [self IFA_updateHudViewControllerOverlayTapActionBlock];
}

- (void)setShouldDismissOnOverlayTap:(BOOL)shouldDismissOnOverlayTap {
    _shouldDismissOnOverlayTap = shouldDismissOnOverlayTap;
    if (_shouldDismissOnOverlayTap) {
        self.shouldAllowUserInteractionPassthrough = NO;
    }
    [self IFA_updateHudViewControllerOverlayTapActionBlock];
}

- (void)setChromeTapActionBlock:(void (^)())chromeTapActionBlock {
    _chromeTapActionBlock = chromeTapActionBlock;
    if (_chromeTapActionBlock) {
        self.shouldAllowUserInteractionPassthrough = NO;
    }
    [self IFA_updateHudViewControllerChromeTapActionBlock];
}

- (void)setShouldDismissOnChromeTap:(BOOL)shouldDismissOnChromeTap {
    _shouldDismissOnChromeTap = shouldDismissOnChromeTap;
    if (_shouldDismissOnChromeTap) {
        self.shouldAllowUserInteractionPassthrough = NO;
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
    } else {
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

- (IFAHudViewStyle)style {
    return self.hudView.style;
}

- (void)setStyle:(IFAHudViewStyle)style {
    self.hudView.style = style;
}

- (CGSize)chromeViewLayoutFittingSize {
    return self.hudView.chromeViewLayoutFittingSize;
}

- (void)setChromeViewLayoutFittingSize:(CGSize)chromeViewLayoutFittingSize {
    self.hudView.chromeViewLayoutFittingSize = chromeViewLayoutFittingSize;
}

- (NSTimeInterval)presentationTransitionDuration {
    return self.viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.presentationTransitionDuration;
}

- (void)setPresentationTransitionDuration:(NSTimeInterval)presentationTransitionDuration {
    self.viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.presentationTransitionDuration = presentationTransitionDuration;
}

- (NSTimeInterval)dismissalTransitionDuration {
    return self.viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.dismissalTransitionDuration;
}

- (void)setDismissalTransitionDuration:(NSTimeInterval)dismissalTransitionDuration {
    self.viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.dismissalTransitionDuration = dismissalTransitionDuration;
}

- (UIView *)customVisualIndicatorView {
    return self.hudView.customView;
}

- (void)setCustomVisualIndicatorView:(UIView *)customVisualIndicatorView {
    self.visualIndicatorMode = customVisualIndicatorView ? IFAHudViewVisualIndicatorModeCustom : IFAHudViewVisualIndicatorModeNone;
    self.hudView.customView = customVisualIndicatorView;
}

- (UIColor *)chromeForegroundColour {
    return self.hudView.chromeForegroundColour;
}

- (void)setChromeForegroundColour:(UIColor *)chromeForegroundColour {
    self.hudView.chromeForegroundColour = chromeForegroundColour;
}

- (UIColor *)chromeBackgroundColour {
    return self.hudView.chromeBackgroundColour;
}

- (void)setChromeBackgroundColour:(UIColor *)chromeBackgroundColour {
    self.hudView.chromeBackgroundColour = chromeBackgroundColour;
}

- (BOOL)shouldAnimateLayoutChanges {
    return self.hudView.shouldAnimateLayoutChanges;
}

- (void)setShouldAnimateLayoutChanges:(BOOL)shouldAnimateLayoutChanges {
    self.hudView.shouldAnimateLayoutChanges = shouldAnimateLayoutChanges;
}

#pragma mark - Overrides

- (void)ifa_commonInit {
    self.visualIndicatorMode = IFAHudViewVisualIndicatorModeNone;
    self.shouldAllowUserInteractionPassthrough = NO;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self.viewControllerTransitioningDelegate;
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
    if (self.autoDismissalDelay) {
        __weak __typeof(self) weakSelf = self;
        [IFAUtils dispatchAsyncMainThreadBlock:^{
            [weakSelf.presentingViewController dismissViewControllerAnimated:YES
                                                                  completion:nil];
        } afterDelay:self.autoDismissalDelay];
    }
}

#pragma mark - Private

- (IFAViewControllerTransitioningDelegate *)viewControllerTransitioningDelegate {
    if (!_viewControllerTransitioningDelegate) {
        _viewControllerTransitioningDelegate = [IFAFadingOverlayViewControllerTransitioningDelegate new];
        _viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.presentationTransitionDuration = 0.3;
        _viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.dismissalTransitionDuration = 1;
    }
    return _viewControllerTransitioningDelegate;
}

- (void)IFA_updateHudViewControllerOverlayTapActionBlock {
    __weak __typeof(self) l_weakSelf = self;
    self.hudView.overlayTapActionBlock = ^{
        if (l_weakSelf.overlayTapActionBlock) {
            l_weakSelf.overlayTapActionBlock();
        }
        if (l_weakSelf.shouldDismissOnOverlayTap) {
            [l_weakSelf.presentingViewController dismissViewControllerAnimated:YES
                                                                    completion:nil];
        }
    };
}

- (void)IFA_updateHudViewControllerChromeTapActionBlock {
    __weak __typeof(self) l_weakSelf = self;
    self.hudView.chromeTapActionBlock = ^{
        if (l_weakSelf.chromeTapActionBlock) {
            l_weakSelf.chromeTapActionBlock();
        }
        if (l_weakSelf.shouldDismissOnChromeTap) {
            [l_weakSelf.presentingViewController dismissViewControllerAnimated:YES
                                                                    completion:nil];
        }
    };
}

@end