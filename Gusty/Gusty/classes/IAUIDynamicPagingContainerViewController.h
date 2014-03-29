//
//  IAUIDynamicPagingContainerViewController.h
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

#import "IAUIViewController.h"
#import "IAConstants.h"
#import "IAUIAbstractPagingContainerViewController.h"

@class IAUITableViewController;

@interface IAUIDynamicPagingContainerViewController : IAUIAbstractPagingContainerViewController{
    
    @protected
    IAUIScrollPage v_selectedPage;
    IAUITableViewController *v_childViewControllerLeftFar;
    IAUITableViewController *v_childViewControllerLeftNear;
    IAUITableViewController *v_childViewControllerCentre;
    IAUITableViewController *v_childViewControllerRightNear;
    IAUITableViewController *v_childViewControllerRightFar;
    IAUIScrollPage v_firstPageWithContent;
    UIBarButtonItem *v_previousViewBarButtonItem;
    UIBarButtonItem *v_nextViewBarButtonItem;
    
}

@property (weak, nonatomic) id<IAUIDynamicPagingContainerViewControllerDataSource> p_dataSource;
@property (nonatomic, strong) NSMutableArray *p_childViewControllers;
@property (nonatomic, strong, readonly) NSDate *p_lastFullChildViewControllerUpdate;

-(void)m_updateChildViewControllersForSelectedPage:(IAUIScrollPage)a_selectedPage;
-(UIViewController*)m_visibleChildViewController;

@end
