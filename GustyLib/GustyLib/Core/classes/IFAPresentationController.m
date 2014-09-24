//
// Created by Marcelo Schroeder on 24/09/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "GustyLibCore.h"

@interface IFAPresentationController ()
@property (nonatomic, strong) UIImageView *IFA_overlayImageView;
@end

@implementation IFAPresentationController {

}

#pragma mark - Overrides

- (void)presentationTransitionWillBegin {

    UIImage *overlayImage = [[self.presentingViewController.view ifa_snapshotImage] ifa_imageWithBlurEffect:IFABlurEffectDark];
    self.IFA_overlayImageView.image = overlayImage;
    self.IFA_overlayImageView.alpha = 0;
    [self.containerView addSubview:self.IFA_overlayImageView];
    [self.IFA_overlayImageView ifa_addLayoutConstraintsToFillSuperview];

    [[self.presentedViewController transitionCoordinator] animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        self.IFA_overlayImageView.alpha = 1;
    } completion:nil];

}

- (void)dismissalTransitionWillBegin {
    [[self.presentedViewController transitionCoordinator] animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        self.IFA_overlayImageView.alpha = 0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    [self.IFA_overlayImageView removeFromSuperview];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"NSStringFromCGSize(size) = %@", NSStringFromCGSize(size));  //wip: clean up
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    //wip: clean up
    NSLog(@"containerViewWillLayoutSubviews");
    NSLog(@"  NSStringFromCGRect(self.containerView.frame) = %@", NSStringFromCGRect(self.containerView.frame));
    NSLog(@"  NSStringFromCGRect(self.presentingViewController.view.frame) = %@", NSStringFromCGRect(self.presentingViewController.view.frame));
//    CGFloat l_statusBarHeight = [IFAUIUtils statusBarSize].height;
//    NSLog(@"  l_statusBarHeight = %f", l_statusBarHeight);
//    if (l_statusBarHeight==IFAIPhoneStatusBarDoubleHeight) {
//        l_statusBarHeight = IFAIPhoneStatusBarDoubleHeight / 2; // The extra height added by the double height status should not be added, for some strange reason...
//    }
//    CGRect containerViewNewFrame = self.containerView.frame;
//    containerViewNewFrame.origin.y = l_statusBarHeight==IFAIPhoneStatusBarDoubleHeight ? IFAIPhoneStatusBarDoubleHeight/2 : 0;
    self.containerView.frame = self.presentingViewController.view.frame;
}

- (void)containerViewDidLayoutSubviews {
    [super containerViewDidLayoutSubviews];
    //wip: clean up
    NSLog(@"containerViewDidLayoutSubviews");
    NSLog(@"  NSStringFromCGRect(self.containerView.frame) = %@", NSStringFromCGRect(self.containerView.frame));
}

#pragma mark - Private

- (UIImageView *)IFA_overlayImageView {
    if (!_IFA_overlayImageView) {
        _IFA_overlayImageView = [UIImageView new];
    }
    return _IFA_overlayImageView;
}

@end