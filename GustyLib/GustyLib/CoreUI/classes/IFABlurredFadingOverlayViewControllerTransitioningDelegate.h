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
#import "IFAViewControllerTransitioningDelegate.h"
#import "IFAFadingOverlayViewControllerTransitioningDelegate.h"

/**
* View controller transitioning delegate that provides a fading transition with a blurred presenting view controller.
* The blur effect can be fine tuned with the arguments of the designated initializer.
*/
@interface IFABlurredFadingOverlayViewControllerTransitioningDelegate : IFAFadingOverlayViewControllerTransitioningDelegate

/**
* Designated initializer.
* @param a_blurEffect Type of blur effect to be applied to the overlay view.
* @param a_radius Radius of the blur effect. The higher the value, the blurrier the results are.
*/
- (instancetype)initBlurEffect:(IFABlurEffect)a_blurEffect radius:(CGFloat)a_radius;

@end