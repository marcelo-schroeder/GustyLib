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

//wip: add doc
//wip: fix issues found when building documentation with appledoc
/**
* HUD (Heads Up Display) style view controller. It uses <IFAHudView> as the underlying HUD view.
*
* All HUD properties can be set here with the exception of appearance related properties, which must be set in the <hudView> property instance directly.
*/
@interface IFAHudViewController : IFAViewController

/**
* The underlying HUD view.
*/
@property (nonatomic, strong, readonly) IFAHudView *hudView;

/**
* Visual indicator mode.
* Default: IFAHudViewVisualIndicatorModeNone.
* See <IFAHudViewVisualIndicatorMode> for possible values.
*/
@property (nonatomic) IFAHudViewVisualIndicatorMode visualIndicatorMode;

/**
* Used to keep of track of progress when <visualIndicatorMode> is set to IFAHudViewVisualIndicatorModeProgressDeterminate.
* The minimum value accepted is 0.0 (i.e. 0%) and maximum value is 1.0 (i.e. 100%).
*/
@property (nonatomic) CGFloat progress;

/**
* Text to be displayed in the main HUD's label view.
*/
@property (nonatomic, strong) NSString *text;

/**
* Text to be displayed in the HUD's secondary label view.
*/
@property (nonatomic, strong) NSString *detailText;

/**
* Custom view used when <visualIndicatorMode> is set to IFAHudViewVisualIndicatorModeCustom.
*/
@property (nonatomic, strong) UIView *customVisualIndicatorView;

/**
* Indicates whether the view controller should be dismissed or not when the user taps the HUD's chrome view.
* Default: NO.
*
* Setting this to YES, automatically sets the <modal> property to YES, which enables user interactivity in the HUD.
*/
@property (nonatomic) BOOL shouldDismissOnChromeTap;
@property (nonatomic, strong) void (^chromeTapActionBlock) ();


/**
* Indicates whether the view controller should be dismissed or not when the user taps the HUD's overlay view.
* Default: NO.
*
* Setting this to YES, automatically sets the <modal> property to YES, which enables user interactivity in the HUD.
*/
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