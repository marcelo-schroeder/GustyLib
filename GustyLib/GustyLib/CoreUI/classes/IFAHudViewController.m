//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCoreUI.h"

//wip: does the dynamic font stuff work?
//wip: test rotation again when some serious blurring is available (e.g. map view)
//wip: I'm relying on the dimming plumming - I am going to use a dimmed bg? Clean up.
//wip: does the motion stuff has to respect accessibility settings?
@interface IFAHudViewController ()
@property (nonatomic, strong) IFAHudView *hudView;
@property(nonatomic, strong) IFAViewControllerTransitioningDelegate *viewControllerTransitioningDelegate;
//@property(nonatomic, strong) UIVisualEffectView *IFA_blurEffectView;  //wip: clean up stuff related to visual effects (lots of comments)
//@property(nonatomic, strong) UIVisualEffectView *IFA_vibrancyEffectView;
@property (nonatomic, strong) UITapGestureRecognizer *IFA_tapGestureRecognizer;
@end

@implementation IFAHudViewController {

}

#pragma mark - Public

- (IFAHudView *)hudView {
    if (!_hudView) {
        _hudView = [IFAHudView new];
        _hudView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _hudView;
}

#pragma mark - Overrides

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.viewControllerTransitioningDelegate;
        [self.view addSubview:self.hudView];
        [self.hudView ifa_addLayoutConstraintsToFillSuperview];
        [self.hudView.frameView addGestureRecognizer:self.IFA_tapGestureRecognizer];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
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

- (UITapGestureRecognizer *)IFA_tapGestureRecognizer {
    if (!_IFA_tapGestureRecognizer) {
        _IFA_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(IFA_onTapGestureRecognizerAction)];
    }
    return _IFA_tapGestureRecognizer;
}

- (void)IFA_onTapGestureRecognizerAction {
    if (self.tapActionBlock) {
        self.tapActionBlock();
    }
}

//- (UIVisualEffectView *)IFA_blurEffectView {
//    if (!_IFA_blurEffectView) {
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        _IFA_blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//        _IFA_blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
//    }
//    return _IFA_blurEffectView;
//}

//- (UIVisualEffectView *)IFA_vibrancyEffectView {
//    if (!_IFA_vibrancyEffectView) {
//        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:(UIBlurEffect *) self.IFA_blurEffectView.effect];
//        _IFA_vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
//        _IFA_vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = NO;
//    }
//    return _IFA_vibrancyEffectView;
//}

@end