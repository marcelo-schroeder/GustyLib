//
// Created by Marcelo Schroeder on 21/01/15.
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
#import "IFAView.h"

/**
* HUD's view style.
*/
typedef NS_ENUM(NSUInteger, IFAHudViewStyle) {

    /** Plain style. A plain UIView instance is used as the content container view. */
            IFAHudViewStylePlain,

    /**
    * Blur style.
    * A UIVisualEffectView instance with a blur effect is used as the content container view.
    * If <[IFAHudView modal]> is YES, then [IFAHudView modalBlurEffectStyle] property determines the blur effect used.
    * If <[IFAHudView modal]> is NO, then [IFAHudView nonModalBlurEffectStyle] property determines the blur effect used.
    */
    IFAHudViewStyleBlur,

    /**
    * Blur style.
    * A UIVisualEffectView instance with a vibrancy effect, wrapped by a UIVisualEffectView instance with a blur effect, is used as the content container view.
    * If <[IFAHudView modal]> is YES, then [IFAHudView modalBlurEffectStyle] property determines the blur effect used.
    * If <[IFAHudView modal]> is NO, then [IFAHudView nonModalBlurEffectStyle] property determines the blur effect used.
    */
    IFAHudViewStyleBlurAndVibrancy,

};

/**
* Visual indicator mode.
*/
typedef NS_ENUM(NSUInteger, IFAHudViewVisualIndicatorMode) {

    /** No visual indicator is shown. */
            IFAHudViewVisualIndicatorModeNone,

    /** The view set in the <[IFAHudView customView]> property is shown. */
            IFAHudViewVisualIndicatorModeCustom,

    /** Progress indicator is shown using a UIActivityIndicatorView.*/
            IFAHudViewVisualIndicatorModeProgressIndeterminate,

    /** Progress indicator is shown using a UIProgressView. */
            IFAHudViewVisualIndicatorModeProgressDeterminate,

    /** A check mark is shown. **/
            IFAHudViewVisualIndicatorModeSuccess,

    /** An "X" is shown. **/
            IFAHudViewVisualIndicatorModeError,

};

/**
* Content subview unique identifier.
*/
typedef NS_ENUM(NSUInteger, IFAHudContentSubviewId) {

    /** Uniquely identifies the <[IFAHudView textLabel]> view. */
            IFAHudContentSubviewIdTextLabel,

    /** Uniquely identifies the <[IFAHudView detailTextLabel]> view. */
            IFAHudContentSubviewIdDetailTextLabel,

    /** Uniquely identifies the <[IFAHudView activityIndicatorView]> view. */
            IFAHudContentSubviewIdActivityIndicatorView,

    /** Uniquely identifies the <[IFAHudView progressView]> view. */
            IFAHudContentSubviewIdProgressView,

    /** Uniquely identifies the <[IFAHudView customView]> view. */
            IFAHudContentSubviewIdCustomView,

};

/**
* HUD (Heads Up Display) style view. An instance of this class is automatically created and managed by <IFAHudViewController>.
*
* Most HUD properties can be set on the <IFAHudViewController> instance with the exception of appearance related properties, which must be set directly on the instance of this class
* available via the <[IFAHudViewController hudView]> property (or via UIKit's appearance API).
*/
@interface IFAHudView : IFAView

/**
* HUD's chrome view (the centre area, where content is placed in).
*/
@property(nonatomic, strong, readonly) UIView *chromeView;

/**
* Content container view, which is placed inside <chromeView>.
*/
@property(nonatomic, strong, readonly) UIView *contentView;

/**
* Determines the order in which the various content subviews appear from top to bottom.
* To change the order in which the content subviews appear, change the order of the elements inside this array.
* The elements inside of the array are enum's of type <IFAHudContentSubviewId> wrapped by NSNumber instances.
*/
@property (nonatomic, strong, readonly) NSMutableArray *contentSubviewVerticalOrder;

/**
* Indicates whether layout calculations should be triggered as soon as any content subviews change.
*/
@property (nonatomic) BOOL shouldUpdateLayoutAutomaticallyOnContentChange;

/**
* Currently selected style, which depends on the <modal> property.
*/
@property (nonatomic, readonly) IFAHudViewStyle style;

/**
* Currently selected overlay colour, which depends on the <modal> property.
*/
@property (nonatomic, strong, readonly) UIColor *overlayColour;

/**
* Currently selected foreground colour for the chrome view, which depends on the <modal> property.
*/
@property (nonatomic, strong, readonly) UIColor *chromeForegroundColour;

/**
* Currently selected background colour for the chrome view, which depends on the <modal> property.
*/
@property (nonatomic, strong, readonly) UIColor *chromeBackgroundColour;

/**
* Currently selected track tint colour for the progress view, which depends on the <modal> property.
*/
@property (nonatomic, strong, readonly) UIColor *progressViewTrackTintColour;

/**
* ===================================================================================================================
* @name Content subviews
* ===================================================================================================================
*/

/**
* Activity indicator view.
*/
@property(nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;

/**
* Progress indicator view.
*/
@property(nonatomic, strong, readonly) UIProgressView *progressView;

/**
* Main label view.
*/
@property (nonatomic, strong, readonly) UILabel *textLabel;

/**
* Secondary label view.
*/
@property (nonatomic, strong, readonly) UILabel *detailTextLabel;

/**
* Custom view.
* This property is managed by <IFAHudViewController>.
*/
@property (nonatomic, strong) UIView *customView;

/**
* ===================================================================================================================
* @name Non-modal appearance API properties
* ===================================================================================================================
*/

/**
* Non-modal style. See <IFAHudViewStyle> for possible values.
*/
@property (nonatomic) IFAHudViewStyle nonModalStyle UI_APPEARANCE_SELECTOR;

/**
* Non-modal blur effect style. See <UIBlurEffectStyle> for possible values.
* This property is only relevant when <nonModalStyle> is set to either <IFAHudViewStyleBlur> or <IFAHudViewStyleBlurAndVibrancy>.
*/
@property (nonatomic) UIBlurEffectStyle nonModalBlurEffectStyle UI_APPEARANCE_SELECTOR;

/**
* Non-modal overlay colour.
*/
@property (nonatomic, strong) UIColor *nonModalOverlayColour UI_APPEARANCE_SELECTOR;

/**
* Non-modal chrome foreground colour.
*/
@property (nonatomic, strong) UIColor *nonModalChromeForegroundColour UI_APPEARANCE_SELECTOR;

/**
* Non-modal chrome background colour.
*/
@property (nonatomic, strong) UIColor *nonModalChromeBackgroundColour UI_APPEARANCE_SELECTOR;

/**
* Non-modal progress view track tint colour.
*/
@property (nonatomic, strong) UIColor *nonModalProgressViewTrackTintColour UI_APPEARANCE_SELECTOR;

/**
* ===================================================================================================================
* @name Modal appearance API properties
* ===================================================================================================================
*/

/**
* Modal style. See <IFAHudViewStyle> for possible values.
*/
@property (nonatomic) IFAHudViewStyle modalStyle UI_APPEARANCE_SELECTOR;

/**
* Modal blur effect style. See <UIBlurEffectStyle> for possible values.
* This property is only relevant when <nonModalStyle> is set to either <IFAHudViewStyleBlur> or <IFAHudViewStyleBlurAndVibrancy>.
*/
@property (nonatomic) UIBlurEffectStyle modalBlurEffectStyle UI_APPEARANCE_SELECTOR;

/**
* Modal overlay colour.
*/
@property (nonatomic, strong) UIColor *modalOverlayColour UI_APPEARANCE_SELECTOR;

/**
* Modal chrome foreground colour.
*/
@property (nonatomic, strong) UIColor *modalChromeForegroundColour UI_APPEARANCE_SELECTOR;

/**
* Modal chrome background colour.
*/
@property (nonatomic, strong) UIColor *modalChromeBackgroundColour UI_APPEARANCE_SELECTOR;

/**
* Modal progress view track tint colour.
*/
@property (nonatomic, strong) UIColor *modalProgressViewTrackTintColour UI_APPEARANCE_SELECTOR;

/**
* ===================================================================================================================
* @name Other appearance API properties
* ===================================================================================================================
*/

/**
* Fitting size for the contents of the chrome view.
* Possible values are the same as the view fitting options used in UIView's systemLayoutSizeFittingSize: method.
*/
@property(nonatomic) CGSize chromeViewLayoutFittingSize UI_APPEARANCE_SELECTOR;

/**
* Indicates whether layout changes should be animated.
*/
@property(nonatomic) BOOL shouldAnimateLayoutChanges UI_APPEARANCE_SELECTOR;

/**
* Determines the font text style used by <textLabel>. This offers support for iOS dynamic type.
* Possible values are the same as text styles used in UIFont's preferredFontForTextStyle: method.
*/
@property(nonatomic, strong) NSString *textLabelFontTextStyle UI_APPEARANCE_SELECTOR;

/**
* Determines the font text style used by <detailTextLabel>. This offers support for iOS dynamic type.
* Possible values are the same as text styles used in UIFont's preferredFontForTextStyle: method.
*/
@property(nonatomic, strong) NSString *detailTextLabelFontTextStyle UI_APPEARANCE_SELECTOR;

/**
* Font to be used by <textLabel>.
* When not nil, it takes precedence over <textLabelFontTextStyle>.
*/
@property(nonatomic, strong) UIFont *textLabelFont UI_APPEARANCE_SELECTOR;

/**
* Font to be used by <detailTextLabel>.
* When not nil, it takes precedence over <detailTextLabelFontTextStyle>.
*/
@property(nonatomic, strong) UIFont *detailTextLabelFont UI_APPEARANCE_SELECTOR;

/**
* Horizontal padding for content in the chrome view (in points).
*/
@property (nonatomic) CGFloat chromeHorizontalPadding UI_APPEARANCE_SELECTOR;

/**
* Vertical padding for content in the chrome view (in points).
*/
@property (nonatomic) CGFloat chromeVerticalPadding UI_APPEARANCE_SELECTOR;

/**
* Vertical space between content subviews in the chrome view (in points).
*/
@property (nonatomic) CGFloat chromeVerticalInteritemSpacing UI_APPEARANCE_SELECTOR;

/**
* Horizontal margin between the chrome view and the edge of parent's view (in points).
*/
@property (nonatomic) CGFloat chromeHorizontalMargin UI_APPEARANCE_SELECTOR;

/**
* Maximum layout width for the chrome view.
*/
@property (nonatomic) CGFloat chromeViewMaximumLayoutWidth UI_APPEARANCE_SELECTOR;

/**
* ===================================================================================================================
* @name Managed by IFAHudViewController
* ===================================================================================================================
*/

/**
* Indicates whether the HUD will modal or not.
* When modal, the user will not be able to interact with the views behind the HUD view.
* Default: YES.
*/
@property (nonatomic) BOOL modal;

/**
* Block to execute when the user taps the HUD's chrome view.
*/
@property (nonatomic, strong) void (^chromeTapActionBlock) ();

/**
* Block to execute when the user taps the HUD's overlay view.
*/
@property (nonatomic, strong) void (^overlayTapActionBlock) ();

@end