//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibHighLevelUI.h"


@implementation IFADimmedFadingOverlayViewControllerTransitioningDelegate {

}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
    return [[IFADimmedFadingOverlayPresentationController alloc] initWithPresentedViewController:presented
                                                                        presentingViewController:presenting];
}

@end