//
// Created by Marcelo Schroeder on 19/09/2014.
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

#import "GustyLibHelp.h"

//wip: more styling to appearance theme

@interface IFAHelpViewController ()
@property (nonatomic, strong) IFAHelpPopTipView *popTipView;
@property (nonatomic, weak) UIViewController *IFA_targetViewController;
@end

@implementation IFAHelpViewController {

}

#pragma Overrides

- (instancetype)initWithTargetViewController:(UIViewController *)a_targetViewController {
    self = [super init];
    if (self) {
        self.IFA_targetViewController = a_targetViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor clearColor];
    [self ifa_addRightBarButtonItem:[[IFAHelpManager sharedInstance] newHelpBarButtonItemForViewController:self.IFA_targetViewController]];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(IFA_onBackgroundDismissalViewTap)];
    [self.navigationController.view addGestureRecognizer:tapGestureRecognizer];

    [self ifa_addNotificationObserverForName:UIApplicationWillChangeStatusBarFrameNotification
                                      object:nil
                                       queue:nil
                                  usingBlock:^(NSNotification *a_note) {
                                  }
                                 removalTime:IFAViewControllerNotificationObserverRemovalTimeDealloc];

    [self ifa_addNotificationObserverForName:UIApplicationDidChangeStatusBarFrameNotification
                                      object:nil
                                       queue:nil
                                  usingBlock:^(NSNotification *a_note) {
                                      [self.navigationController.view layoutIfNeeded];
                                      [self.navigationController.presentationController.containerView setNeedsLayout];
                                      [self.navigationController.presentationController.containerView layoutIfNeeded];
                                  }
                                 removalTime:IFAViewControllerNotificationObserverRemovalTimeDealloc];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.popTipView presentWithTitle:self.IFA_targetViewController.title
                          description:[[IFAHelpManager sharedInstance] helpForViewController:self.IFA_targetViewController]
                       pointingAtView:self.IFA_targetViewController.IFA_helpBarButtonItem.customView
                               inView:self.navigationController.view
                      completionBlock:nil];
}

#pragma mark - CMPopTipViewDelegate

- (void)popTipViewWasDismissedByUser:(IFA_CMPopTipView *)popTipView {
    [self IFA_dismissHelpViewController];
}

#pragma mark - Private

- (IFAHelpPopTipView *)popTipView {
    if (!_popTipView) {
        _popTipView = [IFAHelpPopTipView new];
        _popTipView.delegate = self;
    }
    return _popTipView;
}

- (void)IFA_onBackgroundDismissalViewTap {
    NSLog(@"IFA_onBackgroundDismissalViewTap"); //wip: clean up
    [[IFAHelpManager sharedInstance] toggleHelpModeForViewController:self.IFA_targetViewController];
}

- (void)IFA_dismissHelpViewController {
    NSLog(@"IFA_dismissHelpViewController"); //wip: clean up
    [self.navigationController ifa_notifySessionCompletion];
}

@end