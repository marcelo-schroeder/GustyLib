//
// Created by Marcelo Schroeder on 15/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

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
    IFAHudVisualIndicatorModeOk,

    /** An "X" is shown. **/
    IFAHudVisualIndicatorModeError,

};

typedef NS_ENUM(NSUInteger, IFAHudFrameViewLayoutFittingMode) {

    IFAHudFrameViewLayoutFittingModeCompressed,
    IFAHudFrameViewLayoutFittingModeExpanded,

};

// wip: add documentation
// wip: add license
@interface IFAHud : NSObject

@property(nonatomic, readonly) IFAHudFrameViewLayoutFittingMode frameViewLayoutFittingMode;

@property (nonatomic) IFAHudVisualIndicatorMode visualIndicatorMode;
@property (nonatomic) CGFloat progress;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) UIView *customVisualIndicatorView;

@property (nonatomic, strong) void (^tapActionBlock) ();

@property (nonatomic) BOOL shouldDismissOnTap;

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

- (instancetype)initWithFrameViewLayoutFittingMode:(IFAHudFrameViewLayoutFittingMode)a_frameViewLayoutFittingMode NS_DESIGNATED_INITIALIZER;

@end