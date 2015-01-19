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

#import <Foundation/Foundation.h>

/**
* Presentation controller that presents content on top of a blurred presenting view controller.
* The type and amount of blur can be controlled by arguments passed to the designated initializer.
* A fading animation is used for transitions. The animation runs alongside the transition coordinator's animation.
*/
@interface IFABlurredFadingOverlayPresentationController : IFAFadingOverlayPresentationController <IFAFadingOverlayPresentationControllerDataSource>

/**
* Designated initializer.
* @param a_blurEffect Type of blur effect to be applied to the overlay view.
* @param a_radius Radius of the blur effect. The higher the value, the blurrier the results are.
* @param a_presentedViewController The view controller being presented.
* @param a_presentingViewController The view controller that is the starting point for the presentation.
*/
- (instancetype)initWithBlurEffect:(IFABlurEffect)a_blurEffect
                            radius:(CGFloat)a_radius
           presentedViewController:(UIViewController *)a_presentedViewController
          presentingViewController:(UIViewController *)a_presentingViewController;

@end