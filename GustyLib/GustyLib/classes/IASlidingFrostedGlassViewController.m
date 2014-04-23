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

#import "IACommon.h"
#import "IASlidingFrostedGlassViewController.h"

@interface IASlidingFrostedGlassViewController ()
@property(nonatomic) BOOL p_isDismissing;
@property(nonatomic, strong) UIImageView *p_frostedGlassImageView;
@property(nonatomic, strong) UIViewController *p_childViewController;
@property(nonatomic, strong) UITapGestureRecognizer *p_tapGestureRecogniser;
@property(nonatomic, strong) UISwipeGestureRecognizer *p_swipeGestureRecogniser;
@property(nonatomic, strong) NSLayoutConstraint *p_frostedGlassImageViewHeightConstraint;
@property(nonatomic) NSTimeInterval p_slidingAnimationDuration;
@property(nonatomic, strong) NSLayoutConstraint *p_childViewControllerContainerViewHeightConstraint;
@property(nonatomic, strong) NSLayoutConstraint *p_childViewControllerContainerViewTopSpaceConstraint;
@property(nonatomic, strong) UIView *p_childViewControllerContainerView;
@property(nonatomic, strong) UIView *p_backgroundView;
@end

@implementation IASlidingFrostedGlassViewController {

}

#pragma mark - Private

- (UIView *)p_childViewControllerContainerView {
    if (!_p_childViewControllerContainerView) {
        _p_childViewControllerContainerView = [UIView new];
        _p_childViewControllerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        // Used during development only
//        _p_childViewControllerContainerView.backgroundColor = [UIColor purpleColor];
    }
    return _p_childViewControllerContainerView;
}

- (UITapGestureRecognizer *)p_tapGestureRecogniser {
    if (!_p_tapGestureRecogniser) {
        _p_tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m_onTapGestureRecogniserAction)];
    }
    return _p_tapGestureRecogniser;
}

- (UISwipeGestureRecognizer *)p_swipeGestureRecogniser {
    if (!_p_swipeGestureRecogniser) {
        _p_swipeGestureRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(m_onSwipeGestureRecogniserAction)];
        _p_swipeGestureRecogniser.direction = UISwipeGestureRecognizerDirectionDown;
    }
    return _p_swipeGestureRecogniser;
}

- (void)m_onTapGestureRecogniserAction {
    [self m_dismissViewController];
}

- (void)m_onSwipeGestureRecogniserAction {
    [self m_dismissViewController];
}

- (void)m_dismissViewController {
    [self.presentingViewController dismissViewControllerAnimated:YES //wip: hardcoded value
                                                      completion:nil];
}

- (void)m_updateFrostedGlassImageViewHeightConstraintConstantForVisibleState {
    self.p_frostedGlassImageViewHeightConstraint.constant = [self m_frostedGlassViewHeight];
}

- (CGFloat)m_frostedGlassViewHeight {
    CGFloat l_newHeight = self.presentingViewController.view.frame.size.height;
    if ([self.p_delegate respondsToSelector:@selector(m_frostedGlassViewHeight)]) {
        l_newHeight = [self.p_delegate m_frostedGlassViewHeight];
    }
    return l_newHeight;
}

- (NSLayoutConstraint *)m_newChildViewControllerContainerViewTopSpaceConstraint {
    return [NSLayoutConstraint constraintWithItem:self.p_childViewControllerContainerView
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.p_frostedGlassImageView
                                        attribute:NSLayoutAttributeTop
                                       multiplier:1
                                         constant:0];
}

- (NSLayoutConstraint *)m_newChildViewControllerContainerViewHeightConstraint {
    return [NSLayoutConstraint constraintWithItem:self.p_childViewControllerContainerView
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                        attribute:(NSLayoutAttribute) nil
                                       multiplier:1
                                         constant:[self m_frostedGlassViewHeight]];
}

- (void)m_updateChildViewControllerContainerViewHeightConstraintConstant {
    self.p_childViewControllerContainerViewHeightConstraint.constant = [self m_frostedGlassViewHeight];
}

- (NSLayoutConstraint *)m_newFrostedGlassImageViewHeightConstraintWithConstant:(CGFloat)a_constant {
    return [NSLayoutConstraint constraintWithItem:self.p_frostedGlassImageView
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                       multiplier:1
                                         constant:a_constant];
}

- (void)m_configureFrostedGlassImageView {
    [self.view addSubview:self.p_frostedGlassImageView];
    [self.p_frostedGlassImageView m_addLayoutConstraintsToFillSuperviewHorizontally];
    [self.p_frostedGlassImageView.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.p_frostedGlassImageView
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.p_frostedGlassImageView.superview
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                      multiplier:1
                                                                                        constant:0]];
}

- (void)m_updateFrostedGlassImageViewHeightConstraintForVisible:(BOOL)a_visible{
    [self.p_frostedGlassImageView removeConstraint:self.p_frostedGlassImageViewHeightConstraint];
    CGFloat l_constant = a_visible ? [self m_frostedGlassViewHeight] : 0;
    self.p_frostedGlassImageViewHeightConstraint = [self m_newFrostedGlassImageViewHeightConstraintWithConstant:l_constant];
    [self.p_frostedGlassImageView addConstraint:self.p_frostedGlassImageViewHeightConstraint];
}

#pragma mark - Public

- (id)initWithChildViewController:(UIViewController *)a_childViewController
         slidingAnimationDuration:(NSTimeInterval)a_slidingAnimationDuration {
    self = [super init];
    if (self) {

        self.p_childViewController = a_childViewController;
        [self m_addChildViewController:self.p_childViewController parentView:self.p_childViewControllerContainerView shouldFillSuperview:YES];

        self.p_slidingAnimationDuration = a_slidingAnimationDuration;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;

        self.p_blurEffect = IASlidingFrostedGlassViewControllerBlurEffectLight;

        // Used during development only
//        UIView *l_view = [UIView new];
//        l_view.translatesAutoresizingMaskIntoConstraints = NO;
//        l_view.backgroundColor = [UIColor orangeColor];
//        [self.p_childViewControllerContainerView addSubview:l_view];
//        NSDictionary *l_views = NSDictionaryOfVariableBindings(l_view);
//        [l_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[l_view(80)]"
//                                                                                           options:(NSLayoutFormatOptions) nil
//                                                                                           metrics:nil
//                                                                                             views:l_views]];
//        [l_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[l_view(160)]"
//                                                                                           options:(NSLayoutFormatOptions) nil
//                                                                                           metrics:nil
//                                                                                             views:l_views]];
//        [l_view m_addLayoutConstraintsToCenterInSuperview];

    }
    return self;
}

- (UIImage *)m_newBlurredSnapshotImageFrom:(UIView *)a_viewToSnapshot {
    UIImage *l_snapshotImage = [a_viewToSnapshot m_snapshotImage];
    UIImage *l_blurredSnapshotImage;
    if (self.p_snapshotEffectBlock) {
        l_blurredSnapshotImage = self.p_snapshotEffectBlock(l_snapshotImage);
    }else if (self.p_blurEffectTintColor) {
        l_blurredSnapshotImage = [l_snapshotImage m_applyTintBlurEffectWithColor:self.p_blurEffectTintColor];
    } else {
        switch (self.p_blurEffect) {
            case IASlidingFrostedGlassViewControllerBlurEffectLight:
                l_blurredSnapshotImage = [l_snapshotImage m_applyLightBlurEffect];
                break;
            case IASlidingFrostedGlassViewControllerBlurEffectExtraLight:
                l_blurredSnapshotImage = [l_snapshotImage m_applyExtraLightBlurEffect];
                break;
            case IASlidingFrostedGlassViewControllerBlurEffectDark:
                l_blurredSnapshotImage = [l_snapshotImage m_applyDarkBlurEffect];
                break;
            default:
                NSAssert(NO, @"Unexpected blur effect: %u", self.p_blurEffect);
                break;
        }
    }
    return l_blurredSnapshotImage;
}

- (UIImageView *)p_frostedGlassImageView {
    if (!_p_frostedGlassImageView) {
        _p_frostedGlassImageView = [UIImageView new];
        _p_frostedGlassImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _p_frostedGlassImageView.contentMode = UIViewContentModeBottom;    // This is the trick that simulates 'live' blur
        _p_frostedGlassImageView.clipsToBounds = YES;
    }
    return _p_frostedGlassImageView;
}

- (void)m_configureChildViewControllerContainerView {
    UIView *l_view = self.p_childViewControllerContainerView;
    [self.view addSubview:l_view];
    [l_view m_addLayoutConstraintsToFillSuperviewHorizontally];
    [self m_updateChildViewControllerContainerViewVerticalConstraints];
}

- (void)m_updateChildViewControllerContainerViewVerticalConstraints{
    [self m_updateChildViewControllerContainerViewHeightConstraint];
    [self m_updateChildViewControllerContainerViewTopSpaceConstraint];
}

- (void)m_updateChildViewControllerContainerViewTopSpaceConstraint {
    UIView *l_view = self.p_childViewControllerContainerView;
    [l_view.superview removeConstraint:self.p_childViewControllerContainerViewTopSpaceConstraint];
    self.p_childViewControllerContainerViewTopSpaceConstraint = [self m_newChildViewControllerContainerViewTopSpaceConstraint];
    [l_view.superview addConstraint:self.p_childViewControllerContainerViewTopSpaceConstraint];
}

- (void)m_updateChildViewControllerContainerViewHeightConstraint {
    UIView *l_view = self.p_childViewControllerContainerView;
    [l_view removeConstraint:self.p_childViewControllerContainerViewHeightConstraint];
    self.p_childViewControllerContainerViewHeightConstraint = [self m_newChildViewControllerContainerViewHeightConstraint];
    [l_view addConstraint:self.p_childViewControllerContainerViewHeightConstraint];
}

- (void)m_configureBackgroundView {
    [self.view addSubview:self.p_backgroundView];
    [self.p_backgroundView m_addLayoutConstraintsToFillSuperview];
    [self.p_backgroundView addGestureRecognizer:self.p_tapGestureRecogniser];
}

- (UIView *)p_backgroundView {
    if (!_p_backgroundView) {
        _p_backgroundView = [UIView new];
        _p_backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _p_backgroundView;
}

- (void)m_configureView {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addGestureRecognizer:self.p_swipeGestureRecogniser];
}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    [self m_configureView];
    [self m_configureBackgroundView];
    [self m_configureFrostedGlassImageView];
    [self m_configureChildViewControllerContainerView];
//    self.view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.view.alpha = 0;
    [self m_updateChildViewControllerContainerViewHeightConstraintConstant];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [IAUtils m_dispatchAsyncMainThreadBlock:^{  // Had to run this async to allow for the correct snapshot to be taken when app enters foreground
        self.p_frostedGlassImageView.image = [self m_newBlurredSnapshotImageFrom:self.presentingViewController.view];
        [self m_updateFrostedGlassImageViewHeightConstraintConstantForVisibleState];
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
    self.p_isDismissing = YES;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.p_slidingAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *l_fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *l_toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *l_containerView = transitionContext.containerView;

    if (self.p_isDismissing) {

        NSAssert([l_fromViewController isMemberOfClass:self.class], @"Unexpected class: %@", [l_fromViewController.class description]);
        NSAssert(self.presentingViewController==l_toViewController, @"Presenting view controller and 'to' view controller do not match");
        NSAssert(self.p_frostedGlassImageViewHeightConstraint != nil, @"self.p_blurredSnapshotViewHeightConstraint is nil");

        // Update layout constraints for animation
        [self m_updateFrostedGlassImageViewHeightConstraintForVisible:NO];
        [self m_updateChildViewControllerContainerViewVerticalConstraints];


    }else{

        NSAssert(self.presentingViewController==l_fromViewController, @"Presenting view controller and 'from' view controller do not match");
        NSAssert([l_toViewController isMemberOfClass:self.class], @"Unexpected class: %@", [l_toViewController.class description]);

        // Add 'to' view controller's view to the container view
        [l_containerView addSubview:l_toViewController.view];

        // Add layout constraints to the 'to' view controller
        [l_toViewController.view m_addLayoutConstraintsToFillSuperview];

        // Set the blurred snapshot image
        self.p_frostedGlassImageView.image = [self m_newBlurredSnapshotImageFrom:l_fromViewController.view];

        // Update layout constraints in the blurred snapshot view
        [self m_updateFrostedGlassImageViewHeightConstraintForVisible:NO];
        [self.view layoutIfNeeded];

        // Update layout constraints for animation
        [self m_updateFrostedGlassImageViewHeightConstraintForVisible:YES];

    }

    [UIView animateWithDuration:self.p_slidingAnimationDuration animations:^{
        if (self.p_isDismissing) {
            [self.p_frostedGlassImageView layoutIfNeeded];
            [self.p_childViewControllerContainerView layoutIfNeeded];
        } else {
            [self.view layoutIfNeeded];
        }
    }                completion:^(BOOL finished) {
        if (self.p_isDismissing) {
            [self.p_childViewController removeFromParentViewController];
            [self.view removeFromSuperview];
        }
        [transitionContext completeTransition:YES];
    }];

}

@end