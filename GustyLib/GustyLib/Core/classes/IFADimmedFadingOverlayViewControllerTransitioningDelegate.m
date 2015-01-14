//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCore.h"


@implementation IFADimmedFadingOverlayViewControllerTransitioningDelegate {

}

#pragma mark - Overrides

- (instancetype)init {
    IFAViewControllerFadeTransitioning *viewControllerAnimatedTransitioning = [IFAViewControllerFadeTransitioning new];
    return [super initWithViewControllerAnimatedTransitioning:viewControllerAnimatedTransitioning];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
    return [[IFADimmedFadingOverlayPresentationController alloc] initWithPresentedViewController:presented
                                                                        presentingViewController:presenting];
}

@end