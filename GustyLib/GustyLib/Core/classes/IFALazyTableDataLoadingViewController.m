//
// Created by Marcelo Schroeder on 5/02/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
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

@interface IFALazyTableDataLoadingViewController ()
@property(nonatomic) BOOL IFA_hasDataLoadBeenRequested;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic) CGFloat IFA_additionalContentBottomInset;
@end

@implementation IFALazyTableDataLoadingViewController {

}

#pragma mark - Public

- (void)didScroll {

    BOOL isMoreDataBeingRequested = self.IFA_sourceTableView.contentOffset.y >= self.IFA_sourceTableView.contentSize.height - self.IFA_sourceTableView.bounds.size.height;
    BOOL isMoreDataAvailable = self.IFA_pagingStateManager.resultsCountShowing < self.IFA_pagingStateManager.resultsCountTotal;
    BOOL shouldMoreDataBeRequested = isMoreDataBeingRequested && isMoreDataAvailable && !self.IFA_hasDataLoadBeenRequested;
    if (!shouldMoreDataBeRequested) {
        return;
    }

    self.IFA_hasDataLoadBeenRequested = YES;

    self.IFA_additionalContentBottomInset = self.activityIndicatorView.bounds.size.height + self.viewInsets.top + self.viewInsets.bottom;

    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets l_newContentInsets = weakSelf.IFA_sourceTableView.contentInset;
        l_newContentInsets.bottom += weakSelf.IFA_additionalContentBottomInset;
        weakSelf.IFA_sourceTableView.contentInset = l_newContentInsets;
    } completion:^(BOOL finished) {
        [weakSelf IFA_updateActivityIndicatorViewFrame];
        [weakSelf.activityIndicatorView startAnimating];
        [weakSelf.IFA_sourceTableViewController ifa_addChildViewController:weakSelf
                                                                parentView:weakSelf.IFA_sourceTableViewController.view
                shouldFillSuperview:NO];
    }];

    [self.delegate lazyTableDataLoadingViewControllerDidRequestDataLoad:self];

}

- (void)dataLoadDidComplete {
    [self.activityIndicatorView stopAnimating];
    [self ifa_removeFromParentViewController];
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets l_newContentInsets = self.IFA_sourceTableView.contentInset;
        l_newContentInsets.bottom -= self.IFA_additionalContentBottomInset;
        weakSelf.IFA_sourceTableView.contentInset = l_newContentInsets;
    } completion:^(BOOL finished) {
        weakSelf.IFA_hasDataLoadBeenRequested = NO;
    }];
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
        if ([self.dataSource respondsToSelector:@selector(activityIndicatorViewStyleForLazyTableDataLoadingViewController:)]) {
            style = [self.dataSource activityIndicatorViewStyleForLazyTableDataLoadingViewController:NULL];
        }
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        [_activityIndicatorView sizeToFit];
    }
    return _activityIndicatorView;
}

#pragma mark - Overrides

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewInsets = UIEdgeInsetsMake(20, 0, 20, 0);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.activityIndicatorView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.activityIndicatorView.alpha = 0;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self IFA_updateActivityIndicatorViewFrame];
    self.activityIndicatorView.alpha = 1;
}

#pragma mark - Private

- (UITableViewController *)IFA_sourceTableViewController {
    return [self.dataSource tableViewControllerForLazyTableDataLoadingViewController:nil];
}

- (UITableView *)IFA_sourceTableView {
    return [self.dataSource tableViewControllerForLazyTableDataLoadingViewController:nil].tableView;
}

- (IFAPagingStateManager *)IFA_pagingStateManager {
    return [self.dataSource pagingStateManagerForLazyTableDataLoadingViewController:nil];
}

- (void)IFA_updateActivityIndicatorViewFrame {
    CGRect l_newFrame = self.activityIndicatorView.frame;
    l_newFrame.origin.x = self.IFA_sourceTableView.center.x - self.activityIndicatorView.bounds.size.width / 2;
    l_newFrame.origin.y = self.IFA_sourceTableView.contentSize.height + self.viewInsets.top;
    self.activityIndicatorView.frame = l_newFrame;
}

@end