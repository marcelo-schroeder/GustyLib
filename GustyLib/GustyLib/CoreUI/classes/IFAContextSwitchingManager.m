//
// Created by Marcelo Schroeder on 4/09/2014.
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

#import "GustyLibCoreUI.h"

@interface IFAContextSwitchingManager ()

@property (nonatomic, strong) UIViewController *IFA_currentViewController;

@end

@implementation IFAContextSwitchingManager {

}

#pragma mark - Public

- (BOOL)requestContextSwitchForObject:(id)a_object {
    BOOL l_canGrantNow = YES;
    if ([self.IFA_currentViewController conformsToProtocol:@protocol(IFAContextSwitchTarget)] && ((id <IFAContextSwitchTarget>) self.IFA_currentViewController).contextSwitchRequestRequired) {
        NSNotification *l_notification = [NSNotification notificationWithName:IFANotificationContextSwitchRequest
                                                                       object:a_object userInfo:nil];
        [[NSNotificationQueue defaultQueue] enqueueNotification:l_notification
                                                   postingStyle:NSPostASAP
                                                   coalesceMask:NSNotificationNoCoalescing
                                                       forModes:nil];
        l_canGrantNow = NO;
    }
    return l_canGrantNow;
}

- (void)didCommitContextSwitchForViewController:(UIViewController *)a_viewController {

    if (self.IFA_currentViewController) {

        UIViewController *l_contentViewController = nil;

        if ([self.IFA_currentViewController isKindOfClass:[UINavigationController class]]) {

            // If the current view controller is a navigation controller then make sure to pop to its root view controller
            //  in order to minimise memory requirements and avoid complications with entities being changed somewhere else (for now)
            UINavigationController *l_navigationController = (UINavigationController *) self.IFA_currentViewController;
            [l_navigationController popToRootViewControllerAnimated:NO];

            UIViewController *l_topViewController = l_navigationController.topViewController;
            if ([l_topViewController isKindOfClass:[IFAAbstractPagingContainerViewController class]]) {
                IFAAbstractPagingContainerViewController *l_pagingContainerViewController = (IFAAbstractPagingContainerViewController *) l_topViewController;
                l_contentViewController = l_pagingContainerViewController.selectedViewController;
            } else {
                l_contentViewController = l_topViewController;
            }

        } else {
            l_contentViewController = (UITableViewController *) self.IFA_currentViewController;
        }

        if ([l_contentViewController isKindOfClass:[UITableViewController class]]) {

            UITableViewController *l_tableViewController = (UITableViewController *) l_contentViewController;

            // Deselect any previously selected table view row to avoid unnecessary "deselection animation"
            UITableView *l_tableView = l_tableViewController.tableView;
            NSIndexPath *l_selectedIndexPath = l_tableView.indexPathForSelectedRow;
            if (l_selectedIndexPath) {
                [l_tableView deselectRowAtIndexPath:l_selectedIndexPath animated:NO];
            }

        }

    }

    self.IFA_currentViewController = a_viewController;

}

#pragma mark - Overrides

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(IFA_onContextSwitchRequestGrantedNotification:)
                                                     name:IFANotificationContextSwitchRequestGranted
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(IFA_onContextSwitchRequestDeniedNotification:)
                                                     name:IFANotificationContextSwitchRequestDenied
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationContextSwitchRequestGranted
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationContextSwitchRequestDenied
                                                  object:nil];
}

#pragma mark - Private

- (void)IFA_onContextSwitchRequestGrantedNotification:(NSNotification*)a_notification {
    [self.delegate   contextSwitchingManager:self
didReceiveContextSwitchRequestReplyForObject:a_notification.object
                                     granted:YES];
}

- (void)IFA_onContextSwitchRequestDeniedNotification:(NSNotification*)a_notification {
    [self.delegate   contextSwitchingManager:self
didReceiveContextSwitchRequestReplyForObject:a_notification.object
                                     granted:NO];
}

@end