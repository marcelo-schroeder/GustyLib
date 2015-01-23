//
// Created by Marcelo Schroeder on 15/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFAHudManager.h"
#import "IFAHudView.h"

@class IFAHudViewController;

typedef NS_ENUM(NSUInteger, IFAHudVisualIndicatorMode) {

    /** No visual indicator is shown. */
    IFAHudVisualIndicatorModeNone,

    /** The view set in the 'customVisualIndicatorView' property is shown. */
    IFAHudVisualIndicatorModeCustom,

    /** Progress indicator is shown using a UIActivityIndicatorView.*/
    IFAHudVisualIndicatorModeProgressIndeterminate,

    /** Progress indicator is shown using a UIProgressView. */
    IFAHudVisualIndicatorModeProgressDeterminate,

    /** A check mark is shown. **/
    IFAHudVisualIndicatorModeSuccess,

    /** An "X" is shown. **/
    IFAHudVisualIndicatorModeError,

};

typedef NS_ENUM(NSUInteger, IFAHudChromeViewLayoutFittingMode) {

    IFAHudChromeViewLayoutFittingModeCompressed,
    IFAHudChromeViewLayoutFittingModeExpanded,

};

// wip: add documentation
// wip: add license
// wip: rename to IFAHudManager
@interface IFAHudManager : NSObject

@property(nonatomic, strong, readonly) IFAHudViewController *hudViewController;

@property(nonatomic, readonly) IFAHudChromeViewLayoutFittingMode chromeViewLayoutFittingMode;

@property (nonatomic) IFAHudVisualIndicatorMode visualIndicatorMode;
@property (nonatomic) CGFloat progress;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) UIView *customVisualIndicatorView;

@property (nonatomic) BOOL shouldDismissOnChromeTap;
@property (nonatomic, strong) void (^chromeTapActionBlock) ();

@property (nonatomic) BOOL shouldDismissOnOverlayTap;
@property (nonatomic, strong) void (^overlayTapActionBlock) ();

@property (nonatomic) BOOL shouldAllowUserInteractionPassthrough;    //wip: implement this

@property (nonatomic, strong) UIColor *chromeForegroundColour;
@property (nonatomic, strong) UIColor *chromeBackgroundColour;

@property(nonatomic) BOOL shouldAnimateLayoutChanges;

@property (nonatomic, readonly) IFAHudViewStyle style;

/**
* Duration (in seconds) of the presentation's transition animation.
*/
@property(nonatomic) NSTimeInterval presentationTransitionDuration;


/**
* Duration (in seconds) of the dismissal's transition animation.
*/
@property(nonatomic) NSTimeInterval dismissalTransitionDuration;

- (void)presentWithCompletion:(void (^)())a_completion;

- (void)presentWithAutoDismissalDelay:(NSTimeInterval)a_autoDismissalDelay
                           completion:(void (^)())a_completion;

- (void)presentWithPresentingViewController:(UIViewController *)a_presentingViewController
                                   animated:(BOOL)a_animated
                         autoDismissalDelay:(NSTimeInterval)a_autoDismissalDelay
                                 completion:(void (^)())a_completion;

- (void)dismissWithCompletion:(void (^)())a_completion;

- (void)dismissWithPresentingViewController:(UIViewController *)a_presentingViewController
                                   animated:(BOOL)a_animated
                                 completion:(void (^)())a_completion;

- (instancetype)initWithStyle:(IFAHudViewStyle)a_style
  chromeViewLayoutFittingMode:(IFAHudChromeViewLayoutFittingMode)a_frameViewLayoutFittingMode NS_DESIGNATED_INITIALIZER;

@end