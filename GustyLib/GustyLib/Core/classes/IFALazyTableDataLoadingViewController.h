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

#import <Foundation/Foundation.h>
#import "IFAViewController.h"

@protocol IFALazyTableDataLoadingViewControllerDataSource;
@protocol IFALazyTableDataLoadingViewControllerDelegate;
@class IFAPagingStateManager;

//wip: add doc
//wip: need to take into consideration the increased status bar height when in the "in-call" state (iPhone)
@interface IFALazyTableDataLoadingViewController : IFAViewController
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) UIEdgeInsets viewInsets;
@property (nonatomic, weak) id<IFALazyTableDataLoadingViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<IFALazyTableDataLoadingViewControllerDelegate> delegate;

- (void)didScroll;
- (void)dataLoadDidComplete;
@end

@protocol IFALazyTableDataLoadingViewControllerDataSource <NSObject>
@required
- (UITableViewController *)
tableViewControllerForLazyTableDataLoadingViewController:(IFALazyTableDataLoadingViewController *)a_lazyTableDataLoadingViewController;
- (IFAPagingStateManager *)
pagingStateManagerForLazyTableDataLoadingViewController:(IFALazyTableDataLoadingViewController *)a_lazyTableDataLoadingViewController;
@optional
- (UIActivityIndicatorViewStyle)
activityIndicatorViewStyleForLazyTableDataLoadingViewController:(IFALazyTableDataLoadingViewController *)a_lazyTableDataLoadingViewController;
@end

@protocol IFALazyTableDataLoadingViewControllerDelegate <NSObject>
@required
- (void)lazyTableDataLoadingViewControllerDidRequestDataLoad:(IFALazyTableDataLoadingViewController *)a_lazyTableDataLoadingViewController;
@end