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

@interface IFAViewControllerTransitioningDelegate ()
@property (nonatomic, strong) IFAViewControllerAnimatedTransitioning *viewControllerAnimatedTransitioning;
@end

@implementation IFAViewControllerTransitioningDelegate {

}

#pragma mark - Public

- (instancetype)initWithViewControllerAnimatedTransitioning:(IFAViewControllerAnimatedTransitioning *)a_viewControllerAnimatedTransitioning {
    self = [super init];
    if (self) {
        self.viewControllerAnimatedTransitioning = a_viewControllerAnimatedTransitioning;
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    self.viewControllerAnimatedTransitioning.isPresenting = YES;
    return self.viewControllerAnimatedTransitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.viewControllerAnimatedTransitioning.isPresenting = NO;
    return self.viewControllerAnimatedTransitioning;
}

@end