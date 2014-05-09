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

#import <Foundation/Foundation.h>
#import "IFAViewController.h"

static const CGFloat IFAMasterDetailViewControllerMasterViewDefaultWidth = 320;

@protocol IFAMasterDetailViewControllerDataSource;

/**
* Highly customisable master-detail view controller.
*/
@interface IFAMasterDetailViewController : IFAViewController

/**
* Use this property to set the master view controller.
*/
@property (strong, nonatomic) UIViewController *masterViewController;

/**
* Use this property to set the detail view controller.
*/
@property (strong, nonatomic) UIViewController *detailViewController;

@property (strong, nonatomic, readonly) UIView *masterContainerView;
@property (strong, nonatomic, readonly) UIView *detailContainerView;
@property (strong, nonatomic, readonly) UIView *separatorView;

@property (weak, nonatomic) id<IFAMasterDetailViewControllerDataSource> dataSource;
@end

/**
* Provides data to the master-detail view controller.
*/
@protocol IFAMasterDetailViewControllerDataSource <NSObject>

@optional

/**
* Determines the width for the master view.
* If not implemented IFAMasterDetailViewControllerMasterViewDefaultWidth will be used.
* @param a_masterDetailViewController Instance of IFAMasterDetailViewController making the call back.
* @param a_interfaceOrientation Interface orientation to provide the width for.
* @returns Width to be applied to the master view.
*/
- (CGFloat) masterDetailViewController:(IFAMasterDetailViewController *)a_masterDetailViewController
masterViewWidthForInterfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation;

typedef enum {
    IFAMasterDetailViewControllerPaneLayoutStyleDocked,     // The pane is always visible.
    IFAMasterDetailViewControllerPaneLayoutStyleSliding,    // The pane is not visible when the parent view is first presented and it slides into view when presented.
    IFAMasterDetailViewControllerPaneLayoutStylePopover,    // The pane is not visible when the parent view is first presented and it is shown in a popover when presented.
} IFAMasterDetailViewControllerPaneLayoutStyle;


/**
* Determines pane layout style for the master view.
* If not implemented IFAMasterDetailViewControllerPaneLayoutStyleDocked will be used for landscape and IFAMasterDetailViewControllerPaneLayoutStyleFloating will be used for portrait.
* @param a_masterDetailViewController Instance of IFAMasterDetailViewController making the call back.
* @param a_interfaceOrientation Interface orientation to provide the pane layout style for.
* @returns Pane layout style to be applied to the master view.
*/
- (IFAMasterDetailViewControllerPaneLayoutStyle)masterDetailViewController:(IFAMasterDetailViewController *)a_masterDetailViewController
          masterViewPaneLayoutStyleForInterfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation;

@end