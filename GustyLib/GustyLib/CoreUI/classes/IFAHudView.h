//
// Created by Marcelo Schroeder on 21/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
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

typedef NS_ENUM(NSUInteger, IFAHudViewChromeViewLayoutFittingMode) {

    IFAHudViewChromeViewLayoutFittingModeCompressed,
    IFAHudViewChromeViewLayoutFittingModeExpanded,

};

//wip: add doc
//wip: add lincense
//wip: attribution to the flicker images used
@interface IFAHudView : IFAView

@property(nonatomic, strong, readonly) UIView *chromeView;
@property(nonatomic, strong, readonly) UIView *contentView;
@property(nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong, readonly) UIProgressView *progressView;
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UILabel *detailTextLabel;
@property (nonatomic, strong) UIView *customView;

@property (nonatomic, strong) UIColor *overlayColour UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *chromeForegroundColour UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *chromeBackgroundColour UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIBlurEffectStyle blurEffectStyle UI_APPEARANCE_SELECTOR;

@property(nonatomic) CGSize chromeViewLayoutFittingSize;

@property(nonatomic) BOOL shouldAnimateLayoutChanges;

@property (nonatomic, readonly) IFAHudViewStyle style;

@property (nonatomic, strong) void (^chromeTapActionBlock) ();
@property (nonatomic, strong) void (^overlayTapActionBlock) ();

- (instancetype)initWithStyle:(IFAHudViewStyle)a_style NS_DESIGNATED_INITIALIZER;

@end