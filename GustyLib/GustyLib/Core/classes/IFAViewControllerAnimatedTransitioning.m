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
@end

//wip: is this the correct name for this class- should it be more specific?
@implementation IFAViewControllerAnimatedTransitioning {

}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

//    transitionContext.containerView.backgroundColor = [UIColor redColor]; //wip: clean up

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]; //wip: clean up
    UIView *fromView = fromViewController.view;
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]; //wip: clean up
    UIView *toView = toViewController.view;

    UIView *animatingView = self.isPresenting ? toView : fromView;

    if (self.isPresenting) {
        toView.alpha = 0;
        [transitionContext.containerView addSubview:toView];
        [toView ifa_addLayoutConstraintsToFillSuperview];
    }
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    __weak __typeof(self) l_weakSelf = self;
    void (^animations)() = ^{
        CGFloat alpha = l_weakSelf.isPresenting ? 1 : 0;
        animatingView.alpha = alpha;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        if (!l_weakSelf.isPresenting) {
            [animatingView removeFromSuperview];
        }
        [transitionContext completeTransition:YES];
    };
    [UIView animateWithDuration:duration animations:animations completion:completion];
}

@end