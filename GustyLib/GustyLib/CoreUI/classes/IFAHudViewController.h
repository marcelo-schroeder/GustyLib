//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
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

@property (nonatomic) BOOL shouldAllowUserInteractionPassthrough;

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