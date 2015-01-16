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

#import <Foundation/Foundation.h>

@class IFAViewControllerAnimatedTransitioning;

/**
* View controller transitioning delegate that coordinates the use of a provided view controller animated transiting object.
* It encapsulates logic such as determining to the animated transitioning object when whether the view is being presented or dismissed.
*/
@interface IFAViewControllerTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

/**
* Underlying view controller transitioning delegate.
* The instance returned here can be used to set properties on for changing behaviour.
*/
@property (nonatomic, strong, readonly) IFAViewControllerAnimatedTransitioning *viewControllerAnimatedTransitioning;

/**
* Designated initializer.
* @param a_viewControllerAnimatedTransitioning A view controller animated transitioning object.
*/
- (instancetype)initWithViewControllerAnimatedTransitioning:(IFAViewControllerAnimatedTransitioning *)a_viewControllerAnimatedTransitioning NS_DESIGNATED_INITIALIZER;

@end