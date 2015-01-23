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
@property (nonatomic) IFAHudViewStyle style;
@property(nonatomic) CGSize chromeViewLayoutFittingSize;

@property (nonatomic) IFAHudViewVisualIndicatorMode visualIndicatorMode;
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

@property (nonatomic) NSTimeInterval autoDismissalDelay;

/**
* Duration (in seconds) of the presentation's transition animation.
*/
@property(nonatomic) NSTimeInterval presentationTransitionDuration;

@property(nonatomic, strong, readonly) IFAViewControllerTransitioningDelegate *viewControllerTransitioningDelegate;

@end