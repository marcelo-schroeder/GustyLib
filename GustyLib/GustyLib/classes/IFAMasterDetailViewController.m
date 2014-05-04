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

#import "IFACommon.h"

@interface IFAMasterDetailViewController ()
@property (strong, nonatomic, readwrite) UIView *masterContainerView;
@property (strong, nonatomic, readwrite) UIView *detailContainerView;
@property (strong, nonatomic, readwrite) UIView *separatorView;
//@property(nonatomic, strong) UISwipeGestureRecognizer *p_swipeGestureRecogniser;
@end

@implementation IFAMasterDetailViewController {

}

#pragma mark - Private

- (void)ifa_configureSubViews {
    UIView *l_masterView = self.masterContainerView;
    UIView *l_detailView = self.detailContainerView;
    UIView *l_separatorView = self.separatorView;
    [self.view addSubview:l_masterView];
    [self.view addSubview:l_detailView];
    [self.view addSubview:l_separatorView];
    NSDictionary *l_views = NSDictionaryOfVariableBindings(l_masterView, l_detailView, l_separatorView);
    NSArray *l_horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[l_masterView(320)][l_separatorView(1)][l_detailView]|"
                                                                               options:(NSLayoutFormatOptions) 0
                                                                               metrics:nil
                                                                                 views:l_views];
    [self.view addConstraints:l_horizontalConstraints];
    [l_masterView IFA_addLayoutConstraintsToFillSuperviewVertically];
    [l_detailView IFA_addLayoutConstraintsToFillSuperviewVertically];
    [l_separatorView IFA_addLayoutConstraintsToFillSuperviewVertically];
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
    [self ifa_configureSubViews];
//    [self.view addGestureRecognizer:self.p_swipeGestureRecogniser];
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

- (void)setMasterViewController:(UIViewController *)masterViewController {
    _masterViewController = masterViewController;
    [self IFA_addChildViewController:_masterViewController parentView:self.masterContainerView];
}

- (void)setDetailViewController:(UIViewController *)detailViewController {
    _detailViewController = detailViewController;
    [self IFA_addChildViewController:_detailViewController parentView:self.detailContainerView];
}

@end