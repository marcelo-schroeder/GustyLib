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

#import "GustyLibCoreUI.h"

@interface IFASlidingFrostedGlassViewController ()
@property(nonatomic) BOOL IFA_isDismissing;
@property(nonatomic, strong) UIImageView *frostedGlassImageView;
@property(nonatomic, strong) UIViewController *IFA_childViewController;
@property(nonatomic, strong) UITapGestureRecognizer *IFA_tapGestureRecogniser;
@property(nonatomic, strong) UISwipeGestureRecognizer *IFA_swipeGestureRecogniser;
@property(nonatomic, strong) NSLayoutConstraint *IFA_frostedGlassImageViewHeightConstraint;
@property(nonatomic) NSTimeInterval IFA_slidingAnimationDuration;
@property(nonatomic, strong) NSLayoutConstraint *IFA_childViewControllerContainerViewHeightConstraint;
@property(nonatomic, strong) NSLayoutConstraint *IFA_childViewControllerContainerViewTopSpaceConstraint;
@property(nonatomic, strong) UIView *IFA_childViewControllerContainerView;
@property(nonatomic, strong) UIView *IFA_backgroundView;
@end

@implementation IFASlidingFrostedGlassViewController {

}

#pragma mark - Private

- (UIView *)IFA_childViewControllerContainerView {
    if (!_IFA_childViewControllerContainerView) {
        _IFA_childViewControllerContainerView = [UIView new];
        _IFA_childViewControllerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        // Used during development only
//        _IFA_childViewControllerContainerView.backgroundColor = [UIColor purpleColor];
    }
    return _IFA_childViewControllerContainerView;
}

- (UITapGestureRecognizer *)IFA_tapGestureRecogniser {
    if (!_IFA_tapGestureRecogniser) {
        _IFA_tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(IFA_onTapGestureRecogniserAction)];
    }
    return _IFA_tapGestureRecogniser;
}

- (UISwipeGestureRecognizer *)IFA_swipeGestureRecogniser {
    if (!_IFA_swipeGestureRecogniser) {
        _IFA_swipeGestureRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(IFA_onSwipeGestureRecogniserAction)];
        _IFA_swipeGestureRecogniser.direction = UISwipeGestureRecognizerDirectionDown;
    }
    return _IFA_swipeGestureRecogniser;
}

- (void)IFA_onTapGestureRecogniserAction {
    [self IFA_dismissViewController];
}

- (void)IFA_onSwipeGestureRecogniserAction {
    [self IFA_dismissViewController];
}

- (void)IFA_dismissViewController {
    __weak __typeof(self) l_weakSelf = self;
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
        if ([l_weakSelf.delegate respondsToSelector:@selector(didDismissSlidingFrostedGlassViewController:)]) {
            [l_weakSelf.delegate didDismissSlidingFrostedGlassViewController:l_weakSelf];
        }
    }];
}

- (void)IFA_updateFrostedGlassImageViewHeightConstraintConstantForVisibleState {
    self.IFA_frostedGlassImageViewHeightConstraint.constant = [self IFA_frostedGlassViewHeight];
}

- (CGFloat)IFA_frostedGlassViewHeight {
    CGFloat l_newHeight = self.presentingViewController.view.frame.size.height;
    if ([self.delegate respondsToSelector:@selector(frostedGlassViewHeightForSlidingFrostedGlassViewController:)]) {
        l_newHeight = [self.delegate frostedGlassViewHeightForSlidingFrostedGlassViewController:self];
    }
    return l_newHeight;
}

- (NSLayoutConstraint *)IFA_newChildViewControllerContainerViewTopSpaceConstraint {
    return [NSLayoutConstraint constraintWithItem:self.IFA_childViewControllerContainerView
                                        attribute:NSLayoutAttributeTop
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:self.frostedGlassImageView
                                        attribute:NSLayoutAttributeTop
                                       multiplier:1
                                         constant:0];
}

- (NSLayoutConstraint *)IFA_newChildViewControllerContainerViewHeightConstraint {
    return [NSLayoutConstraint constraintWithItem:self.IFA_childViewControllerContainerView
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                        attribute:(NSLayoutAttribute) nil
                                       multiplier:1
                                         constant:[self IFA_frostedGlassViewHeight]];
}

- (void)IFA_updateChildViewControllerContainerViewHeightConstraintConstant {
    self.IFA_childViewControllerContainerViewHeightConstraint.constant = [self IFA_frostedGlassViewHeight];
}

- (NSLayoutConstraint *)IFA_newFrostedGlassImageViewHeightConstraintWithConstant:(CGFloat)a_constant {
    return [NSLayoutConstraint constraintWithItem:self.frostedGlassImageView
                                        attribute:NSLayoutAttributeHeight
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:nil
                                        attribute:NSLayoutAttributeNotAnAttribute
                                       multiplier:1
                                         constant:a_constant];
}

- (void)IFA_configureFrostedGlassImageView {
    [self.view addSubview:self.frostedGlassImageView];
    [self.frostedGlassImageView ifa_addLayoutConstraintsToFillSuperviewHorizontally];
    [self.frostedGlassImageView.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.frostedGlassImageView
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.frostedGlassImageView.superview
                                                                                       attribute:NSLayoutAttributeBottom
                                                                                      multiplier:1
                                                                                        constant:0]];
}

- (void)IFA_updateFrostedGlassImageViewHeightConstraintForVisible:(BOOL)a_visible{
    [self.frostedGlassImageView removeConstraint:self.IFA_frostedGlassImageViewHeightConstraint];
    CGFloat l_constant = a_visible ? [self IFA_frostedGlassViewHeight] : 0;
    self.IFA_frostedGlassImageViewHeightConstraint = [self IFA_newFrostedGlassImageViewHeightConstraintWithConstant:l_constant];
    [self.frostedGlassImageView addConstraint:self.IFA_frostedGlassImageViewHeightConstraint];
}

#pragma mark - Public

- (id)initWithChildViewController:(UIViewController *)a_childViewController
         slidingAnimationDuration:(NSTimeInterval)a_slidingAnimationDuration {
    self = [super init];
    if (self) {

        self.IFA_childViewController = a_childViewController;
        [self ifa_addChildViewController:self.IFA_childViewController
                              parentView:self.IFA_childViewControllerContainerView
                     shouldFillSuperview:YES];

        self.IFA_slidingAnimationDuration = a_slidingAnimationDuration;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;

        self.blurEffect = IFASlidingFrostedGlassViewControllerBlurEffectLight;

        // Used during development only
//        UIView *l_view = [UIView new];
//        l_view.translatesAutoresizingMaskIntoConstraints = NO;
//        l_view.backgroundColor = [UIColor orangeColor];
//        [self.IFA_childViewControllerContainerView addSubview:l_view];
//        NSDictionary *l_views = NSDictionaryOfVariableBindings(l_view);
//        [l_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[l_view(80)]"
//                                                                                           options:(NSLayoutFormatOptions) nil
//                                                                                           metrics:nil
//                                                                                             views:l_views]];
//        [l_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[l_view(160)]"
//                                                                                           options:(NSLayoutFormatOptions) nil
//                                                                                           metrics:nil
//                                                                                             views:l_views]];
//        [l_view ifa_addLayoutConstraintsToCenterInSuperview];

    }
    return self;
}

- (UIImage *)newBlurredSnapshotImageFrom:(UIView *)a_viewToSnapshot {
    UIImage *l_snapshotImage = [a_viewToSnapshot ifa_snapshotImage];
    UIImage *l_blurredSnapshotImage;
    if (self.snapshotEffectBlock) {
        l_blurredSnapshotImage = self.snapshotEffectBlock(l_snapshotImage);
    }else if (self.blurEffectTintColor) {
        l_blurredSnapshotImage = [l_snapshotImage ifa_imageWithTintBlurEffectForColor:self.blurEffectTintColor];
    } else {
        switch (self.blurEffect) {
            case IFASlidingFrostedGlassViewControllerBlurEffectLight:
                l_blurredSnapshotImage = [l_snapshotImage ifa_imageWithBlurEffect:IFABlurEffectLight];
                break;
            case IFASlidingFrostedGlassViewControllerBlurEffectExtraLight:
                l_blurredSnapshotImage = [l_snapshotImage ifa_imageWithBlurEffect:IFABlurEffectExtraLight];
                break;
            case IFASlidingFrostedGlassViewControllerBlurEffectDark:
                l_blurredSnapshotImage = [l_snapshotImage ifa_imageWithBlurEffect:IFABlurEffectDark];
                break;
            default:
                NSAssert(NO, @"Unexpected blur effect: %lu", (unsigned long)self.blurEffect);
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

- (void)IFA_configureChildViewControllerContainerView {
    UIView *l_view = self.IFA_childViewControllerContainerView;
    [self.view addSubview:l_view];
    [l_view ifa_addLayoutConstraintsToFillSuperviewHorizontally];
    [self IFA_updateChildViewControllerContainerViewVerticalConstraints];
}

- (void)IFA_updateChildViewControllerContainerViewVerticalConstraints {
    [self IFA_updateChildViewControllerContainerViewHeightConstraint];
    [self IFA_updateChildViewControllerContainerViewTopSpaceConstraint];
}

- (void)IFA_updateChildViewControllerContainerViewTopSpaceConstraint {
    UIView *l_view = self.IFA_childViewControllerContainerView;
    [l_view.superview removeConstraint:self.IFA_childViewControllerContainerViewTopSpaceConstraint];
    self.IFA_childViewControllerContainerViewTopSpaceConstraint = [self IFA_newChildViewControllerContainerViewTopSpaceConstraint];
    [l_view.superview addConstraint:self.IFA_childViewControllerContainerViewTopSpaceConstraint];
}

- (void)IFA_updateChildViewControllerContainerViewHeightConstraint {
    UIView *l_view = self.IFA_childViewControllerContainerView;
    [l_view removeConstraint:self.IFA_childViewControllerContainerViewHeightConstraint];
    self.IFA_childViewControllerContainerViewHeightConstraint = [self IFA_newChildViewControllerContainerViewHeightConstraint];
    [l_view addConstraint:self.IFA_childViewControllerContainerViewHeightConstraint];
}

- (void)IFA_configureBackgroundView {
    [self.view addSubview:self.IFA_backgroundView];
    [self.IFA_backgroundView ifa_addLayoutConstraintsToFillSuperview];
    [self.IFA_backgroundView addGestureRecognizer:self.IFA_tapGestureRecogniser];
}

- (UIView *)IFA_backgroundView {
    if (!_IFA_backgroundView) {
        _IFA_backgroundView = [UIView new];
        _IFA_backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _IFA_backgroundView;
}

- (void)IFA_configureView {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addGestureRecognizer:self.IFA_swipeGestureRecogniser];
}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    [self IFA_configureView];
    [self IFA_configureBackgroundView];
    [self IFA_configureFrostedGlassImageView];
    [self IFA_configureChildViewControllerContainerView];
//    self.view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.view.alpha = 0;
    [self IFA_updateChildViewControllerContainerViewHeightConstraintConstant];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    __weak __typeof(self) l_weakSelf = self;
    [IFAUtils dispatchAsyncMainThreadBlock:^{  // Had to run this async to allow for the correct snapshot to be taken when app enters foreground
        l_weakSelf.frostedGlassImageView.image = [l_weakSelf newBlurredSnapshotImageFrom:l_weakSelf.presentingViewController.view];
        [l_weakSelf IFA_updateFrostedGlassImageViewHeightConstraintConstantForVisibleState];
        [l_weakSelf.view layoutIfNeeded];
        [UIView animateWithDuration:0.3 animations:^{
            l_weakSelf.view.alpha = 1;
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
    self.IFA_isDismissing = YES;
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.IFA_slidingAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *l_fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *l_toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *l_containerView = transitionContext.containerView;

    if (self.IFA_isDismissing) {

        NSAssert([l_fromViewController isMemberOfClass:self.class], @"Unexpected class: %@", [l_fromViewController.class description]);
        NSAssert(self.presentingViewController==l_toViewController, @"Presenting view controller and 'to' view controller do not match");
        NSAssert(self.IFA_frostedGlassImageViewHeightConstraint != nil, @"self.IFA_frostedGlassImageViewHeightConstraint is nil");

        // Update layout constraints for animation
        [self IFA_updateFrostedGlassImageViewHeightConstraintForVisible:NO];
        [self IFA_updateChildViewControllerContainerViewVerticalConstraints];


    }else{

        NSAssert(self.presentingViewController==l_fromViewController, @"Presenting view controller and 'from' view controller do not match");
        NSAssert([l_toViewController isMemberOfClass:self.class], @"Unexpected class: %@", [l_toViewController.class description]);

        // Add 'to' view controller's view to the container view
        [l_containerView addSubview:l_toViewController.view];

        // Add layout constraints to the 'to' view controller
        [l_toViewController.view ifa_addLayoutConstraintsToFillSuperview];

        // Set the blurred snapshot image
        self.frostedGlassImageView.image = [self newBlurredSnapshotImageFrom:l_fromViewController.view];

        // Update layout constraints in the blurred snapshot view
        [self IFA_updateFrostedGlassImageViewHeightConstraintForVisible:NO];
        [self.view layoutIfNeeded];

        // Update layout constraints for animation
        [self IFA_updateFrostedGlassImageViewHeightConstraintForVisible:YES];

    }

    __weak __typeof(self) l_weakSelf = self;
    [UIView animateWithDuration:self.IFA_slidingAnimationDuration animations:^{
        if (self.IFA_isDismissing) {
            [self.frostedGlassImageView layoutIfNeeded];
            [self.IFA_childViewControllerContainerView layoutIfNeeded];
        } else {
            [self.view layoutIfNeeded];
        }
    }                completion:^(BOOL finished) {
        if (l_weakSelf.IFA_isDismissing) {
            [l_weakSelf.IFA_childViewController removeFromParentViewController];
            [l_weakSelf.view removeFromSuperview];
        }
        [transitionContext completeTransition:YES];
    }];

}

@end