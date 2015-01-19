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


@interface IFABlurredFadingOverlayViewControllerTransitioningDelegate ()
@property(nonatomic) IFABlurEffect IFA_blurEffect;
@property(nonatomic) CGFloat IFA_radius;
@end

@implementation IFABlurredFadingOverlayViewControllerTransitioningDelegate {

}

#pragma mark - Public

- (instancetype)initBlurEffect:(IFABlurEffect)a_blurEffect
                        radius:(CGFloat)a_radius {
    self = [super init];
    if (self) {
        self.IFA_blurEffect = a_blurEffect;
        self.IFA_radius = a_radius;
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
    return [[IFABlurredFadingOverlayPresentationController alloc] initWithBlurEffect:self.IFA_blurEffect
                                                                        radius:self.IFA_radius
                                                       presentedViewController:presented
                                                      presentingViewController:presenting];
}

@end