//
// Created by Marcelo Schroeder on 15/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFAHudManager.h"
#import "IFAHudView.h"

@class IFAHudViewController;

//wip: this will become obsolete
// wip: add documentation
// wip: add license
// wip: rename to IFAHudManager
@interface IFAHudManager : NSObject

//@property(nonatomic, strong, readonly) IFAHudViewController *hudViewController;

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
  chromeViewLayoutFittingMode:(IFAHudViewChromeViewLayoutFittingMode)a_frameViewLayoutFittingMode NS_DESIGNATED_INITIALIZER;

@end