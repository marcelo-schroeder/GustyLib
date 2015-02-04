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

typedef NS_ENUM(NSUInteger, IFAHudViewStyle) {

    IFAHudViewStylePlain,
    IFAHudViewStyleBlur,
    IFAHudViewStyleBlurAndVibrancy,

};

typedef NS_ENUM(NSUInteger, IFAHudViewVisualIndicatorMode) {

    /** No visual indicator is shown. */
            IFAHudViewVisualIndicatorModeNone,

    /** The view set in the 'customVisualIndicatorView' property is shown. */
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

typedef NS_ENUM(NSUInteger, IFAHudContentSubviewId) {

    IFAHudContentSubviewIdTextLabel,
    IFAHudContentSubviewIdDetailTextLabel,
    IFAHudContentSubviewIdActivityIndicatorView,
    IFAHudContentSubviewIdProgressView,
    IFAHudContentSubviewIdCustomView,

};

//wip: add doc
@interface IFAHudView : IFAView

@property(nonatomic, strong, readonly) UIView *chromeView;
@property(nonatomic, strong, readonly) UIView *contentView;
@property(nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong, readonly) UIProgressView *progressView;
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UILabel *detailTextLabel;
@property (nonatomic, strong) UIView *customView;

@property (nonatomic) BOOL modal;

@property (nonatomic) IFAHudViewStyle nonModalStyle UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIBlurEffectStyle nonModalBlurEffectStyle UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *nonModalOverlayColour UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *nonModalChromeForegroundColour UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *nonModalChromeBackgroundColour UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *nonModalProgressViewTrackTintColour UI_APPEARANCE_SELECTOR;

@property (nonatomic) IFAHudViewStyle modalStyle UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIBlurEffectStyle modalBlurEffectStyle UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *modalOverlayColour UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *modalChromeForegroundColour UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *modalChromeBackgroundColour UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *modalProgressViewTrackTintColour UI_APPEARANCE_SELECTOR;

@property(nonatomic) CGSize chromeViewLayoutFittingSize UI_APPEARANCE_SELECTOR;
@property(nonatomic) BOOL shouldAnimateLayoutChanges UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSString *textLabelFontTextStyle UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSString *detailTextLabelFontTextStyle UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont *textLabelFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont *detailTextLabelFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat chromeHorizontalPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat chromeVerticalPadding UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat chromeVerticalInteritemSpacing UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat chromeHorizontalMargin UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat chromeViewMaximumLayoutWidth UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) void (^chromeTapActionBlock) ();
@property (nonatomic, strong) void (^overlayTapActionBlock) ();

@property (nonatomic, strong, readonly) NSMutableArray *contentSubviewVerticalOrder;

@property (nonatomic) BOOL shouldUpdateLayoutAutomaticallyOnContentChange;

@property (nonatomic, readonly) IFAHudViewStyle style;
@property (nonatomic, strong, readonly) UIColor *overlayColour;
@property (nonatomic, strong, readonly) UIColor *chromeForegroundColour;
@property (nonatomic, strong, readonly) UIColor *chromeBackgroundColour;
@property (nonatomic, strong, readonly) UIColor *progressViewTrackTintColour;

@end