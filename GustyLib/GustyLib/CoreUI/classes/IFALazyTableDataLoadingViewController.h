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

//todo: need to take into consideration the increased status bar height when in the "in-call" state (iPhone)

/**
* View controller that manages the lazy loading of table view data.
* The load of next page worth of table view data is triggered by the user scrolling the content to the bottom end.
*/
@interface IFALazyTableDataLoadingViewController : IFAViewController

/**
* View used to indicate data loading activity.
*/
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;

/**
* View insets used around the view controller's view.
*/
@property (nonatomic) UIEdgeInsets viewInsets;

/**
* View controller's data source.
*/
@property (nonatomic, weak) id<IFALazyTableDataLoadingViewControllerDataSource> dataSource;

/**
* View controller's delegate.
*/
@property (nonatomic, weak) id<IFALazyTableDataLoadingViewControllerDelegate> delegate;


/**
* Call this method to indicate that the view has been scrolled.
*
* It is normally called from the UIScrollViewDelegate's scrollViewDidScroll: method.
* This method's implementation will determine when it is time to trigger a table view data load.
*/
- (void)didScroll;

/**
* Call this method to indicate that the table view data loading has been completed.
*/
- (void)dataLoadDidComplete;

@end

/**
* IFALazyTableDataLoadingViewController's data source.
*/
@protocol IFALazyTableDataLoadingViewControllerDataSource <NSObject>

@required

/**
* @param a_lazyTableDataLoadingViewController Sender.
* @returns Table view controller whose table view will be loading data lazily.
*/
- (UITableViewController *)
tableViewControllerForLazyTableDataLoadingViewController:(IFALazyTableDataLoadingViewController *)a_lazyTableDataLoadingViewController;

/**
* @param a_lazyTableDataLoadingViewController Sender.
* @returns Paging state manager managing the data paging.
*/
- (IFAPagingStateManager *)
pagingStateManagerForLazyTableDataLoadingViewController:(IFALazyTableDataLoadingViewController *)a_lazyTableDataLoadingViewController;

@optional

/**
* @param a_lazyTableDataLoadingViewController Sender.
* @returns Activity indicator style.
*/
- (UIActivityIndicatorViewStyle)
activityIndicatorViewStyleForLazyTableDataLoadingViewController:(IFALazyTableDataLoadingViewController *)a_lazyTableDataLoadingViewController;

@end

/**
* IFALazyTableDataLoadingViewController's delegate.
*/
@protocol IFALazyTableDataLoadingViewControllerDelegate <NSObject>

@required

/**
* Called to indicate that the next page worth of data is being requested.
* @param a_lazyTableDataLoadingViewController Sender.
*/
- (void)lazyTableDataLoadingViewControllerDidRequestDataLoad:(IFALazyTableDataLoadingViewController *)a_lazyTableDataLoadingViewController;

@end