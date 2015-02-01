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

typedef NS_ENUM(NSUInteger, IFAHudContentSubviewId) {

    IFAHudContentSubviewIdTextLabel,
    IFAHudContentSubviewIdDetailTextLabel,
    IFAHudContentSubviewIdActivityIndicatorView,
    IFAHudContentSubviewIdProgressView,
    IFAHudContentSubviewIdCustomView,

};

//wip: add doc
//wip: add license
//wip: use the new enum macro everywhere so that they can be used from Swift
@interface IFAHudView : IFAView

@property(nonatomic, strong, readonly) UIView *chromeView;
@property(nonatomic, strong, readonly) UIView *contentView;
@property(nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong, readonly) UIProgressView *progressView;
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UILabel *detailTextLabel;
@property (nonatomic, strong) UIView *customView;

@property (nonatomic) BOOL modal;

//wip: move nonModal/Modal to front
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