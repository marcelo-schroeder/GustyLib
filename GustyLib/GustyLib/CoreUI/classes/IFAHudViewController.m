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
        [self IFA_addObservers];
        [self.view addSubview:self.hudView];
        [self.hudView ifa_addLayoutConstraintsToFillSuperview];
        [self.hudView.frameView addGestureRecognizer:self.IFA_tapGestureRecognizer];
    }
    return self;
}

- (void)dealloc {
    [self IFA_removeObservers];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

//wip: clean up
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"text"] || [keyPath isEqualToString:@"hidden"]) {
        if ([keyPath isEqualToString:@"text"]) {
            UILabel *label = object;
            label.hidden = change[NSKeyValueChangeNewKey]==[NSNull null];
        }
        [self.hudView setNeedsLayout];
//        [self.hudView layoutIfNeeded];  //wip: are these correct?
    }
}

#pragma mark - Private

- (IFAViewControllerTransitioningDelegate *)viewControllerTransitioningDelegate {
    if (!_viewControllerTransitioningDelegate) {
        _viewControllerTransitioningDelegate = [IFADimmedFadingOverlayViewControllerTransitioningDelegate new];
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

- (void)IFA_addObservers {

    // "text" observations
    [self.hudView.textLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [self.hudView.detailTextLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];

    // "hidden" observations
    [self.hudView.activityIndicatorView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    [self.hudView.progressView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    [self.hudView.textLabel addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    [self.hudView.detailTextLabel addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)IFA_removeObservers {

    // "text" observations
    [self.hudView.textLabel removeObserver:self forKeyPath:@"text" context:nil];
    [self.hudView.detailTextLabel removeObserver:self forKeyPath:@"text" context:nil];

    // "hidden" observations
    [self.hudView.activityIndicatorView removeObserver:self forKeyPath:@"hidden" context:nil];
    [self.hudView.progressView removeObserver:self forKeyPath:@"hidden" context:nil];
    [self.hudView.textLabel removeObserver:self forKeyPath:@"hidden" context:nil];
    [self.hudView.detailTextLabel removeObserver:self forKeyPath:@"hidden" context:nil];

}

@end