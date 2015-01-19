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

#import "GustyLibCoreUI.h"

@interface IFAViewControllerAnimatedTransitioning ()
@property(nonatomic, strong) IFAViewControllerAnimatedTransitioningBeforeAnimationsBlock IFA_beforeAnimationsBlock;
@property(nonatomic, strong) IFAViewControllerAnimatedTransitioningAnimationsBlock IFA_animationsBlock;
@property(nonatomic, strong) IFAViewControllerAnimatedTransitioningCompletionBlock IFA_completionBlock;
@end

@implementation IFAViewControllerAnimatedTransitioning {

}

#pragma mark - Public

- (instancetype)initWithBeforeAnimationsBlock:(IFAViewControllerAnimatedTransitioningBeforeAnimationsBlock)a_beforeAnimationsBlock
                              animationsBlock:(IFAViewControllerAnimatedTransitioningAnimationsBlock)a_animationsBlock
                              completionBlock:(IFAViewControllerAnimatedTransitioningCompletionBlock)a_completionBlock {
    self = [super init];
    if (self) {
        self.presentationTransitionDuration = 1;
        self.dismissalTransitionDuration = 1;
        self.IFA_beforeAnimationsBlock = a_beforeAnimationsBlock;
        self.IFA_animationsBlock = a_animationsBlock;
        self.IFA_completionBlock = a_completionBlock;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return self.isPresenting ? self.presentationTransitionDuration : self.dismissalTransitionDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = fromViewController.view;
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toViewController.view;

    UIView *animatingView = self.isPresenting ? toView : fromView;

    if (self.IFA_beforeAnimationsBlock) {
        self.IFA_beforeAnimationsBlock(transitionContext, self.isPresenting, animatingView);
    }

    NSTimeInterval duration = [self transitionDuration:transitionContext];
    __weak __typeof(self) l_weakSelf = self;
    void (^animations)() = ^{
        if (l_weakSelf.IFA_animationsBlock) {
            l_weakSelf.IFA_animationsBlock(l_weakSelf.isPresenting, animatingView);
        }
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        if (l_weakSelf.IFA_completionBlock) {
            l_weakSelf.IFA_completionBlock(finished, l_weakSelf.isPresenting, animatingView);
        }
        [transitionContext completeTransition:YES];
    };
    [UIView animateWithDuration:duration animations:animations completion:completion];

}

@end