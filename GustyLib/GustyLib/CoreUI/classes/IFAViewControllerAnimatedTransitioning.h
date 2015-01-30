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

typedef void (^IFAViewControllerAnimatedTransitioningBeforeAnimationsBlock)(id <UIViewControllerContextTransitioning> a_transitionContext, BOOL a_isPresenting, UIView *a_animatingView);
typedef void (^IFAViewControllerAnimatedTransitioningAnimationsBlock)(BOOL a_isPresenting, UIView *a_animatingView);
typedef void (^IFAViewControllerAnimatedTransitioningCompletionBlock)(BOOL a_finished, BOOL a_isPresenting, UIView *a_animatingView);

/**
* View controller animated transitioning object that encapsulates common transitioning life cycle management such as logic that runs before animations, during animations and upon animation completion.
* Code blocks for the various life cycle phases are provided in the designated initializer.
*/
@interface IFAViewControllerAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

/**
* Indicates whether the transition is for presenting or dismissal. YES = presenting. NO = dismissal.
*/
@property (nonatomic) BOOL isPresenting;

/**
* Duration (in seconds) of the presentation's transition animation.
*/
@property(nonatomic) NSTimeInterval presentationTransitionDuration;

/**
* Duration (in seconds) of the dismissal's transition animation.
*/
@property(nonatomic) NSTimeInterval dismissalTransitionDuration;

/**
* Designated initializer.
* @param a_beforeAnimationsBlock Block that runs before any transition animations.
* @param a_animationsBlock Block that provides animations.
* @param a_completionBlock Block that runs after transition animations have finished.
*/
- (instancetype)initWithBeforeAnimationsBlock:(IFAViewControllerAnimatedTransitioningBeforeAnimationsBlock)a_beforeAnimationsBlock
                              animationsBlock:(IFAViewControllerAnimatedTransitioningAnimationsBlock)a_animationsBlock
                              completionBlock:(IFAViewControllerAnimatedTransitioningCompletionBlock)a_completionBlock;
@end