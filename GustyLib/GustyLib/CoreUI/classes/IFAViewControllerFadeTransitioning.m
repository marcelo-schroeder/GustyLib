//
// Created by Marcelo Schroeder on 25/09/2014.
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


@implementation IFAViewControllerFadeTransitioning {

}

#pragma mark - Overrides

- (instancetype)init {
    IFAViewControllerAnimatedTransitioningBeforeAnimationsBlock beforeAnimationsBlock = ^(id <UIViewControllerContextTransitioning> a_transitionContext, BOOL a_isPresenting, UIView *a_animatingView) {
        if (a_isPresenting) {
            a_animatingView.alpha = 0;
            [a_transitionContext.containerView addSubview:a_animatingView];
            [a_animatingView ifa_addLayoutConstraintsToFillSuperview];
        }
    };
    IFAViewControllerAnimatedTransitioningAnimationsBlock animationsBlock = ^(BOOL a_isPresenting, UIView *a_animatingView) {
        CGFloat alpha = a_isPresenting ? 1 : 0;
        a_animatingView.alpha = alpha;
    };
    IFAViewControllerAnimatedTransitioningCompletionBlock completionBlock = ^(BOOL a_finished, BOOL a_isPresenting, UIView *a_animatingView) {
        if (!a_isPresenting) {
            [a_animatingView removeFromSuperview];
        }
    };
    self = [super initWithBeforeAnimationsBlock:beforeAnimationsBlock
                                animationsBlock:animationsBlock
                                completionBlock:completionBlock];
    if (self) {
    }
    return self;
}

@end