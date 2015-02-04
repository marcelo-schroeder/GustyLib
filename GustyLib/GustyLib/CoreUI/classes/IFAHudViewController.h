//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
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
#import "IFAViewController.h"
#import "IFAHudView.h"

@class IFAHudView;

//wip: add documentation
@interface IFAHudViewController : IFAViewController

@property (nonatomic, strong, readonly) IFAHudView *hudView;

@property (nonatomic) IFAHudViewVisualIndicatorMode visualIndicatorMode;
@property (nonatomic) CGFloat progress;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) UIView *customVisualIndicatorView;

@property (nonatomic) BOOL shouldDismissOnChromeTap;
@property (nonatomic, strong) void (^chromeTapActionBlock) ();

@property (nonatomic) BOOL shouldDismissOnOverlayTap;
@property (nonatomic, strong) void (^overlayTapActionBlock) ();

@property (nonatomic) BOOL modal;

@property (nonatomic) NSTimeInterval autoDismissalDelay;

/**
* Duration (in seconds) of the presentation's transition animation.
*/
@property(nonatomic) NSTimeInterval presentationAnimationDuration;

/**
* Duration (in seconds) of the dismissal's transition animation.
*/
@property(nonatomic) NSTimeInterval dismissalAnimationDuration;

- (void)presentHudViewControllerWithParentViewController:(UIViewController *)a_parentViewController
                                              parentView:(UIView *)a_parentView animated:(BOOL)a_animated completion:(void (^)(BOOL a_finished))a_completion;
- (void)dismissHudViewControllerWithAnimated:(BOOL)a_animated completion:(void (^)(BOOL a_finished))a_completion;

@end