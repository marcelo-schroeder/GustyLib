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

/**
* HUD (Heads Up Display) style view controller. It uses <IFAHudView> as the underlying HUD view.
*
* Most HUD properties can be set here with the exception of appearance related properties, which must be set in the <hudView> property instance directly (or via UIKit's appearance API).
*
* Message <presentHudViewControllerWithParentViewController:parentView:animated:completion:> to present the view controller, and
* <dismissHudViewControllerWithAnimated:completion:> to dismiss it.
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

/**
* Block to execute when the user taps the HUD's chrome view.
*
* Setting this to a value other than nil, automatically sets the <modal> property to YES, which enables user interactivity in the HUD.
*/
@property (nonatomic, strong) void (^chromeTapActionBlock) ();

/**
* Indicates whether the view controller should be dismissed or not when the user taps the HUD's overlay view.
* Default: NO.
*
* Setting this to YES, automatically sets the <modal> property to YES, which enables user interactivity in the HUD.
*/
@property (nonatomic) BOOL shouldDismissOnOverlayTap;

/**
* Block to execute when the user taps the HUD's overlay view.
*
* Setting this to a value other than nil, automatically sets the <modal> property to YES, which enables user interactivity in the HUD.
*/
@property (nonatomic, strong) void (^overlayTapActionBlock) ();

/**
* Indicates whether the HUD will modal or not.
* When modal, the user will not be able to interact with the views behind the HUD view.
* Default: YES.
*/
@property (nonatomic) BOOL modal;

/**
* Delay, in seconds, after which the HUD view is dismissed automatically.
* This property has no effect when set to 0.
* Default: 0
*/
@property (nonatomic) NSTimeInterval autoDismissalDelay;

/**
* Duration (in seconds) of the presentation's transition animation.
* If set to 0, then no animation occurs.
*/
@property(nonatomic) NSTimeInterval presentationAnimationDuration;

/**
* Duration (in seconds) of the dismissal's transition animation.
* If set to 0, then no animation occurs.
*/
@property(nonatomic) NSTimeInterval dismissalAnimationDuration;

/**
* Presents the HUD view controller.
*
* @param a_parentViewController Parent view controller to which the receiver will be added as a child view controller.
* If nil, a dedicated UIWindow instance with a UIViewController instance as its root view controller will be created.
* The receiver will then be added as a child view controller of the dedicated UIWindow's root view controller.
*
* @param a_parentView Parent view controller's view to which the receiver's view will be added as a subview.
* If nil, a_parentViewController's view is used as the parent view.
*
* @param a_animated Indicates whether the presentation transition will be animated or not. The <presentationAnimationDuration> property determines the duration of the animation.
*
* @param a_completion Block to execute after the presentation transition completes.
*/
- (void)presentHudViewControllerWithParentViewController:(UIViewController *)a_parentViewController
                                              parentView:(UIView *)a_parentView animated:(BOOL)a_animated completion:(void (^)(BOOL a_finished))a_completion;

/**
* Dismisses the HUD view controller.
*
* @param a_animated Indicates whether the dismissal transition will be animated or not. The <dismissalAnimationDuration> property determines the duration of the animation.
*
* @param a_completion Block to execute after the dismissal transition completes.
*/
- (void)dismissHudViewControllerWithAnimated:(BOOL)a_animated completion:(void (^)(BOOL a_finished))a_completion;

@end