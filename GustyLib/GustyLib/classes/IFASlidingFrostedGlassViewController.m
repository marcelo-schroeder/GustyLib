//
// Created by Marcelo Schroeder on 10/04/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

#import "IFACommon.h"
#import "IFASlidingFrostedGlassViewController.h"

@interface IFASlidingFrostedGlassViewController ()
@property(nonatomic) BOOL XYZ_isDismissing;
@property(nonatomic, strong) UIImageView *frostedGlassImageView;
@property(nonatomic, strong) UIViewController *XYZ_childViewController;
@property(nonatomic, strong) UITapGestureRecognizer *XYZ_tapGestureRecogniser;
@property(nonatomic, strong) UISwipeGestureRecognizer *XYZ_swipeGestureRecogniser;
@property(nonatomic, strong) NSLayoutConstraint *XYZ_frostedGlassImageViewHeightConstraint;
@property(nonatomic) NSTimeInterval XYZ_slidingAnimationDuration;
@property(nonatomic, strong) NSLayoutConstraint *XYZ_childViewControllerContainerViewHeightConstraint;
@property(nonatomic, strong) NSLayoutConstraint *XYZ_childViewControllerContainerViewTopSpaceConstraint;
@property(nonatomic, strong) UIView *XYZ_childViewControllerContainerView;
@property(nonatomic, strong) UIView *XYZ_backgroundView;
@end

@implementation IFASlidingFrostedGlassViewController {

}

#pragma mark - Private

- (UIView *)XYZ_childViewControllerContainerView {
    if (!_XYZ_childViewControllerContainerView) {
        _XYZ_childViewControllerContainerView = [UIView new];
        _XYZ_childViewControllerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        // Used during development only
//        _XYZ_childViewControllerContainerView.backgroundColor = [UIColor purpleColor];
    }
    return _XYZ_childViewControllerContainerView;
}

- (UITapGestureRecognizer *)XYZ_tapGestureRecogniser {
    if (!_XYZ_tapGestureRecogniser) {
        _XYZ_tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(XYZ_onTapGestureRecogniserAction)];
    }
    return _XYZ_tapGestureRecogniser;
}

- (UISwipeGestureRecognizer *)XYZ_swipeGestureRecogniser {
    if (!_XYZ_swipeGestureRecogniser) {
        _XYZ_swipeGestureRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(XYZ_onSwipeGestureRecogniserAction)];
        _XYZ_swipeGestureRecogniser.direction = UISwipeGestureRecognizerDirectionDown;
    }
    return _XYZ_swipeGestureRecogniser;
}

- (void)XYZ_onTapGestureRecogniserAction {
    [self XYZ_dismissViewController];
}

- (void)XYZ_onSwipeGestureRecogniserAction {
    [self XYZ_dismissViewController];
}

- (void)XYZ_dismissViewController {
    [self.presentingViewController dismissViewControllerAnimated:YES //wip: hardcoded value
                                                      completion:nil];
}

- (void)XYZ_updateFrostedGlassImageViewHeightConstraintConstantForVisibleState {
    self.XYZ_frostedGlassImageViewHeightConstraint.constant = [self XYZ_frostedGlassViewHeight];
}

- (CGFloat)XYZ_frostedGlassViewHeight {
    CGFloat l_newHeight = self.presentingViewController.view.frame.size.height;
    if ([self.delegate respondsToSelector:@selector(frostedGlassViewHeight)]) {
        l_newHeight = [self.delegate frostedGlassViewHeight];
    }
    return l_newHeight;
}

- (NSLayoutConstraint *)XYZ_newChildViewControllerContainerViewTopSpaceConstraint {
    return [NSLayoutConstraint constraintWithItem:self.XYZ_childViewControllerContainerView
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.frostedGlassImageView
                                        attribute:NSLayoutAttributeTop
                                       multiplier:1
                                         constant:0];
}

- (NSLayoutConstraint *)XYZ_newChildViewControllerContainerViewHeightConstraint {
    return [NSLayoutConstraint constraintWithItem:self.XYZ_childViewControllerContainerView
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                        attribute:(NSLayoutAttribute) nil
                                       multiplier:1
                                         constant:[self XYZ_frostedGlassViewHeight]];
}

- (void)XYZ_updateChildViewControllerContainerViewHeightConstraintConstant {
    self.XYZ_childViewControllerContainerViewHeightConstraint.constant = [self XYZ_frostedGlassViewHeight];
}

- (NSLayoutConstraint *)XYZ_newFrostedGlassImageViewHeightConstraintWithConstant:(CGFloat)a_constant {
    return [NSLayoutConstraint constraintWithItem:self.frostedGlassImageView
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                       multiplier:1
                                         constant:a_constant];
}

- (void)XYZ_configureFrostedGlassImageView {
    [self.view addSubview:self.frostedGlassImageView];
    [self.frostedGlassImageView IFA_addLayoutConstraintsToFillSuperviewHorizontally];
    [self.frostedGlassImageView.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.frostedGlassImageView
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.frostedGlassImageView.superview
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                      multiplier:1
                                                                                        constant:0]];
}

- (void)XYZ_updateFrostedGlassImageViewHeightConstraintForVisible:(BOOL)a_visible{
    [self.frostedGlassImageView removeConstraint:self.XYZ_frostedGlassImageViewHeightConstraint];
    CGFloat l_constant = a_visible ? [self XYZ_frostedGlassViewHeight] : 0;
    self.XYZ_frostedGlassImageViewHeightConstraint = [self XYZ_newFrostedGlassImageViewHeightConstraintWithConstant:l_constant];
    [self.frostedGlassImageView addConstraint:self.XYZ_frostedGlassImageViewHeightConstraint];
}

#pragma mark - Public

- (id)initWithChildViewController:(UIViewController *)a_childViewController
         slidingAnimationDuration:(NSTimeInterval)a_slidingAnimationDuration {
    self = [super init];
    if (self) {

        self.XYZ_childViewController = a_childViewController;
        [self IFA_addChildViewController:self.XYZ_childViewController parentView:self.XYZ_childViewControllerContainerView
                     shouldFillSuperview:YES];

        self.XYZ_slidingAnimationDuration = a_slidingAnimationDuration;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;

        self.blurEffect = IFASlidingFrostedGlassViewControllerBlurEffectLight;

        // Used during development only
//        UIView *l_view = [UIView new];
//        l_view.translatesAutoresizingMaskIntoConstraints = NO;
//        l_view.backgroundColor = [UIColor orangeColor];
//        [self.XYZ_childViewControllerContainerView addSubview:l_view];
//        NSDictionary *l_views = NSDictionaryOfVariableBindings(l_view);
//        [l_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[l_view(80)]"
//                                                                                           options:(NSLayoutFormatOptions) nil
//                                                                                           metrics:nil
//                                                                                             views:l_views]];
//        [l_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[l_view(160)]"
//                                                                                           options:(NSLayoutFormatOptions) nil
//                                                                                           metrics:nil
//                                                                                             views:l_views]];
//        [l_view IFA_addLayoutConstraintsToCenterInSuperview];

    }
    return self;
}

- (UIImage *)newBlurredSnapshotImageFrom:(UIView *)a_viewToSnapshot {
    UIImage *l_snapshotImage = [a_viewToSnapshot IFA_snapshotImage];
    UIImage *l_blurredSnapshotImage;
    if (self.snapshotEffectBlock) {
        l_blurredSnapshotImage = self.snapshotEffectBlock(l_snapshotImage);
    }else if (self.blurEffectTintColor) {
        l_blurredSnapshotImage = [l_snapshotImage IFA_applyTintBlurEffectWithColor:self.blurEffectTintColor];
    } else {
        switch (self.blurEffect) {
            case IFASlidingFrostedGlassViewControllerBlurEffectLight:
                l_blurredSnapshotImage = [l_snapshotImage IFA_applyLightBlurEffect];
                break;
            case IFASlidingFrostedGlassViewControllerBlurEffectExtraLight:
                l_blurredSnapshotImage = [l_snapshotImage IFA_applyExtraLightBlurEffect];
                break;
            case IFASlidingFrostedGlassViewControllerBlurEffectDark:
                l_blurredSnapshotImage = [l_snapshotImage IFA_applyDarkBlurEffect];
                break;
            default:
                NSAssert(NO, @"Unexpected blur effect: %u", self.blurEffect);
                break;
        }
    }
    return l_blurredSnapshotImage;
}

- (UIImageView *)frostedGlassImageView {
    if (!_frostedGlassImageView) {
        _frostedGlassImageView = [UIImageView new];
        _frostedGlassImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _frostedGlassImageView.contentMode = UIViewContentModeBottom;    // This is the trick that simulates 'live' blur
        _frostedGlassImageView.clipsToBounds = YES;
    }
    return _frostedGlassImageView;
}

- (void)XYZ_configureChildViewControllerContainerView {
    UIView *l_view = self.XYZ_childViewControllerContainerView;
    [self.view addSubview:l_view];
    [l_view IFA_addLayoutConstraintsToFillSuperviewHorizontally];
    [self XYZ_updateChildViewControllerContainerViewVerticalConstraints];
}

- (void)XYZ_updateChildViewControllerContainerViewVerticalConstraints {
    [self XYZ_updateChildViewControllerContainerViewHeightConstraint];
    [self XYZ_updateChildViewControllerContainerViewTopSpaceConstraint];
}

- (void)XYZ_updateChildViewControllerContainerViewTopSpaceConstraint {
    UIView *l_view = self.XYZ_childViewControllerContainerView;
    [l_view.superview removeConstraint:self.XYZ_childViewControllerContainerViewTopSpaceConstraint];
    self.XYZ_childViewControllerContainerViewTopSpaceConstraint = [self XYZ_newChildViewControllerContainerViewTopSpaceConstraint];
    [l_view.superview addConstraint:self.XYZ_childViewControllerContainerViewTopSpaceConstraint];
}

- (void)XYZ_updateChildViewControllerContainerViewHeightConstraint {
    UIView *l_view = self.XYZ_childViewControllerContainerView;
    [l_view removeConstraint:self.XYZ_childViewControllerContainerViewHeightConstraint];
    self.XYZ_childViewControllerContainerViewHeightConstraint = [self XYZ_newChildViewControllerContainerViewHeightConstraint];
    [l_view addConstraint:self.XYZ_childViewControllerContainerViewHeightConstraint];
}

- (void)XYZ_configureBackgroundView {
    [self.view addSubview:self.XYZ_backgroundView];
    [self.XYZ_backgroundView IFA_addLayoutConstraintsToFillSuperview];
    [self.XYZ_backgroundView addGestureRecognizer:self.XYZ_tapGestureRecogniser];
}

- (UIView *)XYZ_backgroundView {
    if (!_XYZ_backgroundView) {
        _XYZ_backgroundView = [UIView new];
        _XYZ_backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _XYZ_backgroundView;
}

- (void)XYZ_configureView {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addGestureRecognizer:self.XYZ_swipeGestureRecogniser];
}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    [self XYZ_configureView];
    [self XYZ_configureBackgroundView];
    [self XYZ_configureFrostedGlassImageView];
    [self XYZ_configureChildViewControllerContainerView];
//    self.view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.view.alpha = 0;
    [self XYZ_updateChildViewControllerContainerViewHeightConstraintConstant];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [IFAUtils dispatchAsyncMainThreadBlock:^{  // Had to run this async to allow for the correct snapshot to be taken when app enters foreground
        self.frostedGlassImageView.image = [self newBlurredSnapshotImageFrom:self.presentingViewController.view];
        [self XYZ_updateFrostedGlassImageViewHeightConstraintConstantForVisibleState];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 1;
        }];
    }];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.XYZ_isDismissing = YES;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.XYZ_slidingAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *l_fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *l_toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *l_containerView = transitionContext.containerView;

    if (self.XYZ_isDismissing) {

        NSAssert([l_fromViewController isMemberOfClass:self.class], @"Unexpected class: %@", [l_fromViewController.class description]);
        NSAssert(self.presentingViewController==l_toViewController, @"Presenting view controller and 'to' view controller do not match");
        NSAssert(self.XYZ_frostedGlassImageViewHeightConstraint != nil, @"self.XYZ_frostedGlassImageViewHeightConstraint is nil");

        // Update layout constraints for animation
        [self XYZ_updateFrostedGlassImageViewHeightConstraintForVisible:NO];
        [self XYZ_updateChildViewControllerContainerViewVerticalConstraints];


    }else{

        NSAssert(self.presentingViewController==l_fromViewController, @"Presenting view controller and 'from' view controller do not match");
        NSAssert([l_toViewController isMemberOfClass:self.class], @"Unexpected class: %@", [l_toViewController.class description]);

        // Add 'to' view controller's view to the container view
        [l_containerView addSubview:l_toViewController.view];

        // Add layout constraints to the 'to' view controller
        [l_toViewController.view IFA_addLayoutConstraintsToFillSuperview];

        // Set the blurred snapshot image
        self.frostedGlassImageView.image = [self newBlurredSnapshotImageFrom:l_fromViewController.view];

        // Update layout constraints in the blurred snapshot view
        [self XYZ_updateFrostedGlassImageViewHeightConstraintForVisible:NO];
        [self.view layoutIfNeeded];

        // Update layout constraints for animation
        [self XYZ_updateFrostedGlassImageViewHeightConstraintForVisible:YES];

    }

    [UIView animateWithDuration:self.XYZ_slidingAnimationDuration animations:^{
        if (self.XYZ_isDismissing) {
            [self.frostedGlassImageView layoutIfNeeded];
            [self.XYZ_childViewControllerContainerView layoutIfNeeded];
        } else {
            [self.view layoutIfNeeded];
        }
    }                completion:^(BOOL finished) {
        if (self.XYZ_isDismissing) {
            [self.XYZ_childViewController removeFromParentViewController];
            [self.view removeFromSuperview];
        }
        [transitionContext completeTransition:YES];
    }];

}

@end