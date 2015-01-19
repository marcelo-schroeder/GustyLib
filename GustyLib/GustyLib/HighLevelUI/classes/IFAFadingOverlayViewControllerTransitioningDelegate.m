//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibHighLevelUI.h"


@implementation IFAFadingOverlayViewControllerTransitioningDelegate {

}

#pragma mark - Overrides

- (instancetype)init {
    IFAViewControllerFadeTransitioning *viewControllerAnimatedTransitioning = [IFAViewControllerFadeTransitioning new];
    self = [super initWithViewControllerAnimatedTransitioning:viewControllerAnimatedTransitioning];
    if (self) {
    }
    return self;
}

@end