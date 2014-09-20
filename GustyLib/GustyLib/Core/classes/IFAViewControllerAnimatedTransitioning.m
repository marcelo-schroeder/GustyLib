//
// Created by Marcelo Schroeder on 19/09/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import "GustyLibCore.h"


@interface IFAViewControllerAnimatedTransitioning ()
//@property(nonatomic, strong) UIVisualEffectView *IFA_visualEffectView;    //wip: clean up
@property (nonatomic, strong) UIImageView *IFA_overlayImageView;
@end

//wip: is this the correct name for this class- should it be more specific?
@implementation IFAViewControllerAnimatedTransitioning {

}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]; //wip: clean up
    UIView *fromView = fromViewController.view;
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]; //wip: clean up
    UIView *toView = toViewController.view;

    UIView *animatingView = self.isPresenting ? toView : fromView;

    if (self.isPresenting) {
        //wip: clean up
//        self.IFA_visualEffectView.alpha = 0;
//        [transitionContext.containerView addSubview:self.IFA_visualEffectView];
//        [self.IFA_visualEffectView ifa_addLayoutConstraintsToFillSuperview];

        UIImage *overlayImage = [[fromView ifa_snapshotImage] ifa_imageWithBlurEffect:IFABlurEffectDark
                                                                               radius:3];
        self.IFA_overlayImageView.image = overlayImage;
        self.IFA_overlayImageView.alpha = 0;
        [transitionContext.containerView addSubview:self.IFA_overlayImageView];
        [self.IFA_overlayImageView ifa_addLayoutConstraintsToFillSuperview];

        toView.alpha = 0;
        [transitionContext.containerView addSubview:toView];
        [toView ifa_addLayoutConstraintsToFillSuperview];

    }
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    __weak __typeof(self) l_weakSelf = self;
    void (^animations)() = ^{
        CGFloat alpha = l_weakSelf.isPresenting ? 1 : 0;
        l_weakSelf.IFA_overlayImageView.alpha = alpha;
        animatingView.alpha = alpha;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        if (!l_weakSelf.isPresenting) {
            [l_weakSelf.IFA_overlayImageView removeFromSuperview];
            [animatingView removeFromSuperview];
        }
        [transitionContext completeTransition:YES];
    };
    [UIView animateWithDuration:duration animations:animations completion:completion];
}

#pragma mark - Private

//wip: clean up
//- (UIVisualEffectView *)IFA_visualEffectView {
//    if (!_IFA_visualEffectView) {
//        UIVisualEffect *visualEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        _IFA_visualEffectView = [[UIVisualEffectView alloc] initWithEffect:visualEffect];
//    }
//    return _IFA_visualEffectView;
//}

- (UIImageView *)IFA_overlayImageView {
    if (!_IFA_overlayImageView) {
        _IFA_overlayImageView = [UIImageView new];
    }
    return _IFA_overlayImageView;
}

@end