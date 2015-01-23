//
// Created by Marcelo Schroeder on 15/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "IFAHudManager.h"
#import "GustyLibCoreUI.h"


//wip: memory profile this window thing
@interface IFAHudManager ()
@property(nonatomic, strong) IFAHudViewController *hudViewController;
@end

@implementation IFAHudManager {

}

#pragma mark - Public

- (instancetype)initWithStyle:(IFAHudViewStyle)a_style
  chromeViewLayoutFittingMode:(IFAHudViewChromeViewLayoutFittingMode)a_chromeViewLayoutFittingMode {
    self = [super init];
    if (self) {
//        self.hudViewController = [[IFAHudViewController alloc] initWithStyle:a_style];
    }
    return self;
}

- (void)presentWithCompletion:(void (^)())a_completion {
    [self presentWithAutoDismissalDelay:0 completion:a_completion];
}

- (void)presentWithAutoDismissalDelay:(NSTimeInterval)a_autoDismissalDelay completion:(void (^)())a_completion {
    [self presentWithPresentingViewController:nil animated:YES autoDismissalDelay:a_autoDismissalDelay
                                   completion:a_completion];
}

- (void)presentWithPresentingViewController:(UIViewController *)a_presentingViewController animated:(BOOL)a_animated
                         autoDismissalDelay:(NSTimeInterval)a_autoDismissalDelay completion:(void (^)())a_completion {
    void (^completion)() = ^{
        __weak UIViewController *weakPresentingViewController = a_presentingViewController;
        if (a_autoDismissalDelay) {
            __weak __typeof(self) weakSelf = self;
            [IFAUtils dispatchAsyncMainThreadBlock:^{
                [weakSelf dismissWithPresentingViewController:weakPresentingViewController
                                                     animated:a_animated completion:nil];
            } afterDelay:a_autoDismissalDelay];
        }
        if (a_completion) {
            a_completion();
        }
    };
    [a_presentingViewController presentViewController:self.hudViewController
                                             animated:a_animated
                                           completion:completion];
}

- (void)dismissWithCompletion:(void (^)())a_completion {
    [self dismissWithPresentingViewController:nil animated:YES completion:a_completion];
}

- (void)dismissWithPresentingViewController:(UIViewController *)a_presentingViewController animated:(BOOL)a_animated
                                 completion:(void (^)())a_completion {
    [a_presentingViewController dismissViewControllerAnimated:a_animated
                                                   completion:a_completion];
}

#pragma mark - Overrides

- (instancetype)init {
    return [self initWithStyle:(IFAHudViewStylePlain)
   chromeViewLayoutFittingMode:IFAHudViewChromeViewLayoutFittingModeCompressed];
}

#pragma mark - Private

@end