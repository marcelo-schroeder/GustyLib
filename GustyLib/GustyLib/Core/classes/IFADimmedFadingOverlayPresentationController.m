//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCore.h"


@interface IFADimmedFadingOverlayPresentationController ()
@property(nonatomic, strong) UIView *IFA_overlayView;
@end

@implementation IFADimmedFadingOverlayPresentationController {

}


#pragma mark - Overrides

-(instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController{
    self = [super initWithPresentedViewController:presentedViewController
                         presentingViewController:presentingViewController];
    if (self) {
        self.fadingOverlayPresentationControllerDataSource = self;
    }
    return self;
}

#pragma mark - IFAFadingOverlayPresentationControllerDataSource

- (UIView *)
overlayViewForFadingOverlayPresentationController:(IFAFadingOverlayPresentationController *)a_fadingOverlayPresentationController {
    return self.IFA_overlayView;
}

#pragma mark - Private

- (UIView *)IFA_overlayView {
    if (!_IFA_overlayView) {
        _IFA_overlayView = [UIView new];
        _IFA_overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];  //wip: review this - will need to be able to toggle the dimmed bg on and off
//        _IFA_overlayView.backgroundColor = [UIColor whiteColor];  //wip: test only
    }
    return _IFA_overlayView;
}

@end