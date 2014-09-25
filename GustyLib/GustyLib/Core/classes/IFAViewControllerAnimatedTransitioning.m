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
@property(nonatomic, strong) void (^IFA_animations)(BOOL, UIView *);
@property(nonatomic, strong) void (^IFA_completion)(BOOL, BOOL, UIView *);
@end

//wip: is this the correct name for this class- should it be more specific?
@implementation IFAViewControllerAnimatedTransitioning {

}

#pragma mark - Public

- (instancetype)initWithAnimations:(void (^)(BOOL a_isPresenting, UIView *a_animatingView))a_animations
                        completion:(void (^)(BOOL a_finished, BOOL a_isPresenting, UIView *a_animatingView))a_completion {
    self = [super init];
    if (self) {
        self.IFA_animations = a_animations;
        self.IFA_completion = a_completion;
    }
    return self;
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
        if (l_weakSelf.IFA_animations) {
            l_weakSelf.IFA_animations(l_weakSelf.isPresenting, animatingView);
        }
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        if (l_weakSelf.IFA_completion) {
            l_weakSelf.IFA_completion(finished, l_weakSelf.isPresenting, animatingView);
        }
        [transitionContext completeTransition:YES];
    };
    [UIView animateWithDuration:duration animations:animations completion:completion];
}

@end