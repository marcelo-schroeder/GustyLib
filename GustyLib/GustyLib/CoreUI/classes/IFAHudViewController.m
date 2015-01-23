//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCoreUI.h"

//wip: does the dynamic font stuff work?
//wip: I'm relying on the dimming plumming - I am going to use a dimmed bg? Clean up.
//wip: does the motion stuff has to respect accessibility settings?
@interface IFAHudViewController ()
@property (nonatomic, strong) IFAHudView *hudView;
@property(nonatomic, strong) IFAViewControllerTransitioningDelegate *viewControllerTransitioningDelegate;
@property(nonatomic) IFAHudViewChromeViewLayoutFittingMode chromeViewLayoutFittingMode;
@end

@implementation IFAHudViewController {

}

#pragma mark - Public

- (instancetype)initWithStyle:(IFAHudViewStyle)a_style
  chromeViewLayoutFittingMode:(IFAHudViewChromeViewLayoutFittingMode)a_chromeViewLayoutFittingMode {
    self = [super init];
    if (self) {

        self.chromeViewLayoutFittingMode = a_chromeViewLayoutFittingMode;
        self.visualIndicatorMode = IFAHudViewVisualIndicatorModeNone;
        self.shouldAllowUserInteractionPassthrough = YES;

        self.hudView = [[IFAHudView alloc] initWithStyle:a_style];
        self.hudView.translatesAutoresizingMaskIntoConstraints = NO;

        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.viewControllerTransitioningDelegate;
        [self.view addSubview:self.hudView];
        [self.hudView ifa_addLayoutConstraintsToFillSuperview];

    }
    return self;
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

- (void)setChromeViewLayoutFittingMode:(IFAHudViewChromeViewLayoutFittingMode)chromeViewLayoutFittingMode {
    _chromeViewLayoutFittingMode = chromeViewLayoutFittingMode;
    self.hudView.chromeViewLayoutFittingSize = chromeViewLayoutFittingMode == IFAHudViewChromeViewLayoutFittingModeExpanded ? UILayoutFittingExpandedSize : UILayoutFittingCompressedSize;
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

- (IFAHudViewStyle)style {
    return self.hudView.style;
}


#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
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
//            [l_weakSelf dismissWithPresentingViewController:nil animated:YES completion:nil]; //wip: replace with final code
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
//            [l_weakSelf dismissWithPresentingViewController:nil animated:YES completion:nil]; //wip: replace with final code
        }
    };
}

@end