//
// Created by Marcelo Schroeder on 31/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

#import "GustyLibCoreUI.h"

static const int k_separatorViewWidth = 1;

@interface IFAMasterDetailViewController ()
@property (strong, nonatomic, readwrite) UIView *masterContainerView;
@property (strong, nonatomic, readwrite) UIView *detailContainerView;
@property (strong, nonatomic, readwrite) UIView *separatorView;
@property(nonatomic, strong) NSLayoutConstraint *IFA_masterViewLeftConstraint;
@property(nonatomic, strong) NSLayoutConstraint *IFA_detailViewLeftConstraint;
@property(nonatomic, strong) NSLayoutConstraint *IFA_masterContainerViewWidthConstraint;
@property(nonatomic, strong) NSLayoutConstraint *IFA_masterContainerViewRightConstraint;
@property(nonatomic, strong) UIBarButtonItem *IFA_showMasterViewButton;
@property(nonatomic, strong) UIBarButtonItem *IFA_showMasterViewButtonSpaceLeft;
@property(nonatomic, strong) UIBarButtonItem *IFA_showMasterViewButtonSpaceRight;
@end

@implementation IFAMasterDetailViewController {

}

#pragma mark - Private

- (UIBarButtonItem *)IFA_showMasterViewButton {
    if (!_IFA_showMasterViewButton) {
        _IFA_showMasterViewButton = [[UIBarButtonItem alloc] initWithTitle:self.masterViewController.title
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(IFA_onShowMasterViewButtonTap:)];
    }
    return _IFA_showMasterViewButton;
}

- (void)IFA_onShowMasterViewButtonTap:(UIBarButtonItem *)a_barButtonItem {
    [self ifa_presentModalSelectionViewController:self.masterViewController
                                fromBarButtonItem:a_barButtonItem shouldWrapWithNavigationController:NO];
}

- (IFAMasterDetailViewControllerPaneLayoutStyle)
IFA_masterViewPaneLayoutStyleForInterfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation {
    if ([self.dataSource respondsToSelector:@selector(masterDetailViewController:masterViewPaneLayoutStyleForInterfaceOrientation:)]) {
        return [self.dataSource masterDetailViewController:self
                masterViewPaneLayoutStyleForInterfaceOrientation:a_interfaceOrientation];
    }else{
        return [IFAUIUtils isDeviceInLandscapeOrientation] ? IFAMasterDetailViewControllerPaneLayoutStyleDocked : IFAMasterDetailViewControllerPaneLayoutStylePopover;
    }
}

- (UIInterfaceOrientation)IFA_interfaceOrientation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (void)IFA_configureSubViews {
    UIInterfaceOrientation l_interfaceOrientation = [self IFA_interfaceOrientation];
    [self IFA_configureDetailContainerView];
    [self IFA_configureSeparatorView];
    [self IFA_configureSubViewsForInterfaceOrientation:l_interfaceOrientation];
}

- (void)IFA_configureSeparatorView {
    [self.separatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.separatorView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:(NSLayoutAttribute) nil
                                                                  multiplier:1
                                                                    constant:k_separatorViewWidth]];
}

- (void)IFA_configureSubViewsForInterfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation {
    [self IFA_configureNavigationBarButtonsForInterfaceOrientation:a_interfaceOrientation];
    [self IFA_updateViewHierarchyForInterfaceOrientation:a_interfaceOrientation];
    [self IFA_updateLayoutConstraintsForInterfaceOrientation:a_interfaceOrientation];
}

- (void)IFA_configureDetailContainerView {
    [self ifa_addChildViewController:self.detailViewController parentView:self.detailContainerView];
    [self.view addSubview:self.detailContainerView];
    [self.detailContainerView ifa_addLayoutConstraintsToFillSuperviewVertically];
    [self.detailContainerView.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.detailContainerView
                                                                                   attribute:NSLayoutAttributeRight
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.detailContainerView.superview
                                                                                   attribute:NSLayoutAttributeRight
                                                                                  multiplier:1
                                                                                    constant:0]];
}

- (void)IFA_updateViewHierarchyForInterfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation {
    [self.masterContainerView removeFromSuperview];
    [self.separatorView removeFromSuperview];
    [self.masterViewController ifa_removeFromParentViewController];
    IFAMasterDetailViewControllerPaneLayoutStyle l_masterViewPaneLayoutStyle = [self IFA_masterViewPaneLayoutStyleForInterfaceOrientation:a_interfaceOrientation];
    switch (l_masterViewPaneLayoutStyle) {
        case IFAMasterDetailViewControllerPaneLayoutStylePopover:
            // Does not need any other subview added right now
            self.masterViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
            break;
        case IFAMasterDetailViewControllerPaneLayoutStyleSliding:
        case IFAMasterDetailViewControllerPaneLayoutStyleDocked:
            self.masterViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self ifa_addChildViewController:self.masterViewController parentView:self.masterContainerView];
            [self.view addSubview:self.masterContainerView];
            [self.masterContainerView ifa_addLayoutConstraintsToFillSuperviewVertically];
            [self.view addSubview:self.separatorView];
            [self.separatorView ifa_addLayoutConstraintsToFillSuperviewVertically];
    }
}

- (void)IFA_updateLayoutConstraintsForInterfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation {
    CGFloat l_masterViewPreferredWidth = self.masterViewController.preferredContentSize.width;
    [self.masterContainerView.superview removeConstraint:self.IFA_masterViewLeftConstraint];
    [self.detailContainerView.superview removeConstraint:self.IFA_detailViewLeftConstraint];
    self.IFA_masterViewLeftConstraint = nil;
    self.IFA_detailViewLeftConstraint = nil;
    IFAMasterDetailViewControllerPaneLayoutStyle l_masterViewPaneLayoutStyle = [self IFA_masterViewPaneLayoutStyleForInterfaceOrientation:a_interfaceOrientation];
    switch (l_masterViewPaneLayoutStyle) {
        case IFAMasterDetailViewControllerPaneLayoutStyleDocked:
            self.IFA_masterViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.masterContainerView
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.masterContainerView.superview
                                                                             attribute:NSLayoutAttributeLeft
                                                                            multiplier:1 constant:0];
            self.IFA_detailViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.detailContainerView
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.separatorView
                                                                             attribute:NSLayoutAttributeRight
                                                                            multiplier:1 constant:0];
            break;
        case IFAMasterDetailViewControllerPaneLayoutStyleSliding: {
            self.IFA_masterViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.masterContainerView
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.masterContainerView.superview
                                                                             attribute:NSLayoutAttributeLeft
                                                                            multiplier:1
                                                                              constant:-l_masterViewPreferredWidth];
        }
        case IFAMasterDetailViewControllerPaneLayoutStylePopover:
            self.IFA_detailViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.detailContainerView
                                                                             attribute:NSLayoutAttributeLeft
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.detailContainerView.superview
                                                                             attribute:NSLayoutAttributeLeft
                                                                            multiplier:1 constant:0];
            break;
    }
    [self.masterContainerView removeConstraint:self.IFA_masterContainerViewWidthConstraint];
    [self.view removeConstraint:self.IFA_masterContainerViewRightConstraint];
    if (self.masterContainerView.superview) {
        self.IFA_masterContainerViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.masterContainerView
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:nil
                                                                                   attribute:(NSLayoutAttribute) nil
                                                                                  multiplier:1
                                                                                    constant:l_masterViewPreferredWidth];
        [self.masterContainerView addConstraint:self.IFA_masterContainerViewWidthConstraint];
        if (self.separatorView.superview) {
            self.IFA_masterContainerViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.masterContainerView
                                                                                       attribute:NSLayoutAttributeRight
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.separatorView
                                                                                       attribute:NSLayoutAttributeLeft
                                                                                      multiplier:1
                                                                                        constant:0];
            [self.view addConstraint:self.IFA_masterContainerViewRightConstraint];
        }
    }
    if (self.IFA_masterViewLeftConstraint) {
        [self.masterContainerView.superview addConstraint:self.IFA_masterViewLeftConstraint];
    }
    [self.detailContainerView.superview addConstraint:self.IFA_detailViewLeftConstraint];
}

- (void)IFA_configureNavigationBarButtonsForInterfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation {
    [self ifa_removeLeftBarButtonItem:self.IFA_showMasterViewButtonSpaceLeft];
    [self ifa_removeLeftBarButtonItem:self.IFA_showMasterViewButton];
    [self ifa_removeLeftBarButtonItem:self.IFA_showMasterViewButtonSpaceRight];
    IFAMasterDetailViewControllerPaneLayoutStyle l_masterViewPaneLayoutStyle = [self IFA_masterViewPaneLayoutStyleForInterfaceOrientation:a_interfaceOrientation];
    switch (l_masterViewPaneLayoutStyle) {
        case IFAMasterDetailViewControllerPaneLayoutStyleDocked:
            // Does not need to show any buttons
            break;
        case IFAMasterDetailViewControllerPaneLayoutStylePopover:
        case IFAMasterDetailViewControllerPaneLayoutStyleSliding:
            [self ifa_addLeftBarButtonItem:self.IFA_showMasterViewButtonSpaceLeft];
            [self ifa_addLeftBarButtonItem:self.IFA_showMasterViewButton];
            [self ifa_addLeftBarButtonItem:self.IFA_showMasterViewButtonSpaceRight];
            break;
    }
}

- (UIBarButtonItem *)IFA_showMasterViewButtonSpaceLeft {
    if (!_IFA_showMasterViewButtonSpaceLeft) {
        _IFA_showMasterViewButtonSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                           target:nil
                                                                                           action:nil];
    }
    return _IFA_showMasterViewButtonSpaceLeft;
}

- (UIBarButtonItem *)IFA_showMasterViewButtonSpaceRight {
    if (!_IFA_showMasterViewButtonSpaceRight) {
        _IFA_showMasterViewButtonSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                           target:nil
                                                                                           action:nil];
    }
    return _IFA_showMasterViewButtonSpaceRight;
}

//- (UISwipeGestureRecognizer *)p_swipeGestureRecogniser {
//    if (!_p_swipeGestureRecogniser) {
//        _p_swipeGestureRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self
//                                                                              action:@selector(m_onSwipeGesture:)];
//        _p_swipeGestureRecogniser.direction = UISwipeGestureRecognizerDirectionLeft;
//    }
//    return _p_swipeGestureRecogniser;
//}
//
//- (void)m_onSwipeGesture:(UISwipeGestureRecognizer *)a_gestureRecogniser {
//    NSLog(@"gesture");
//}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    [self IFA_configureSubViews];
    //    [self.view addGestureRecognizer:self.p_swipeGestureRecogniser];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    // Dismiss the popover controller, if shown
    if (self.ifa_activePopoverController) {
        [self ifa_dismissModalViewControllerWithChangesMade:NO data:nil];
    }
    // Reconfigure the whole view hierarchy to cater for the new orientation and master view pane layout style
    [self IFA_configureSubViewsForInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - Public

- (UIView *)masterContainerView {
    if (!_masterContainerView) {
        _masterContainerView = [UIView new];
    }
    return _masterContainerView;
}

- (UIView *)detailContainerView {
    if (!_detailContainerView) {
        _detailContainerView = [UIView new];
    }
    return _detailContainerView;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [UIView new];
    }
    return _separatorView;
}

@end