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
@property (nonatomic, strong) UITapGestureRecognizer *IFA_tapGestureRecognizer;
@end

@implementation IFAHudViewController {

}

#pragma mark - Public

- (instancetype)initWithStyle:(IFAHudViewStyle)a_style {
    self = [super init];
    if (self) {

        self.hudView = [[IFAHudView alloc] initWithStyle:a_style];
        self.hudView.translatesAutoresizingMaskIntoConstraints = NO;

        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.viewControllerTransitioningDelegate;
        [self.view addSubview:self.hudView];
        [self.hudView ifa_addLayoutConstraintsToFillSuperview];
        [self.hudView.chromeView addGestureRecognizer:self.IFA_tapGestureRecognizer];

    }
    return self;
}

#pragma mark - Overrides

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

@end