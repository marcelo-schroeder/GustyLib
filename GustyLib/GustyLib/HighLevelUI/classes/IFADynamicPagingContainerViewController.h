//
//  IFADynamicPagingContainerViewController.h
//  Gusty
//
//  Created by Marcelo Schroeder on 12/11/11.
//  Copyright (c) 2011 InfoAccent Pty Limited. All rights reserved.
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

#import "IFAViewController.h"
#import "IFACoreUiConstants.h"
#import "IFAAbstractPagingContainerViewController.h"

@class IFATableViewController;
@protocol IFADynamicPagingContainerViewControllerDataSource;

@interface IFADynamicPagingContainerViewController : IFAAbstractPagingContainerViewController

@property (weak, nonatomic) id<IFADynamicPagingContainerViewControllerDataSource> dataSource;
@property (nonatomic, strong) NSMutableArray *pagingContainerChildViewControllers;
@property (nonatomic, strong, readonly) NSDate *lastFullChildViewControllerUpdate;
@property(nonatomic) IFAScrollPage selectedPage;
@property(nonatomic, strong) IFATableViewController *childViewControllerLeftFar;
@property(nonatomic, strong) IFATableViewController *childViewControllerLeftNear;
@property(nonatomic, strong) IFATableViewController *childViewControllerCentre;
@property(nonatomic, strong) IFATableViewController *childViewControllerRightNear;
@property(nonatomic, strong) IFATableViewController *childViewControllerRightFar;
@property(nonatomic) IFAScrollPage firstPageWithContent;
@property(nonatomic, strong) UIBarButtonItem *previousViewBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *nextViewBarButtonItem;

-(void)updateChildViewControllersForSelectedPage:(IFAScrollPage)a_selectedPage;
-(UIViewController*)visibleChildViewController;

@end
