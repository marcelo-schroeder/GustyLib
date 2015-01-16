//
// Created by Marcelo Schroeder on 15/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {

    /** No progress indicator is shown */
    IFAHudProgressModeNone,

    /** Progress is shown using a UIActivityIndicatorView.*/
    IFAHudProgressModeIndeterminate,

    /** Progress is shown using a UIProgressView. */
    IFAHudProgressModeDeterminate,

} IFAHudProgressMode;

typedef enum {

    IFAHudFrameViewLayoutFittingModeCompressed,
    IFAHudFrameViewLayoutFittingModeExpanded,

} IFAHudFrameViewLayoutFittingMode;

// wip: add documentation
// wip: add license
@interface IFAHud : NSObject

@property(nonatomic, readonly) IFAHudFrameViewLayoutFittingMode frameViewLayoutFittingMode;

@property (nonatomic) IFAHudProgressMode progressMode;
@property (nonatomic) CGFloat progress;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *detailText;

@property (nonatomic, strong) void (^tapActionBlock) ();

@property (nonatomic) BOOL shouldHideOnTap;

/**
* Duration (in seconds) of the presentation's transition animation.
*/
@property(nonatomic) NSTimeInterval presentationTransitionDuration;


/**
* Duration (in seconds) of the dismissal's transition animation.
*/
@property(nonatomic) NSTimeInterval dismissalTransitionDuration;

- (void)showWithAnimation:(BOOL)a_animated completion:(void(^)())a_completion;
- (void)hideWithAnimation:(BOOL)a_animated completion:(void(^)())a_completion;

- (instancetype)initWithFrameViewLayoutFittingMode:(IFAHudFrameViewLayoutFittingMode)a_frameViewLayoutFittingMode NS_DESIGNATED_INITIALIZER;

@end