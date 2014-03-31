//
//  IAUIPagingContainerViewController.h
//  Gusty
//
//  Created by Marcelo Schroeder on 31/05/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

@interface IAUIAbstractPagingContainerViewController : IAUIViewController <UIScrollViewDelegate>

@property (nonatomic, readonly) UIScrollView *p_scrollView;
@property (nonatomic, readonly, strong) IAUITableViewController *p_selectedViewController;
@property (nonatomic, readonly) NSUInteger p_selectedPageIndex;
@property (nonatomic) BOOL p_willRotate;
@property (nonatomic) NSUInteger p_interfaceOrientation;

@property (nonatomic) NSUInteger p_childViewDidAppearCount;
@property (nonatomic, readonly) NSUInteger p_newChildViewControllerCount;

-(void)m_updateContentLayout;
-(CGRect)m_visibleRectForPage:(NSUInteger)a_pageIndex;
-(void)m_scrollToPage:(NSUInteger)a_pageIndex animated:(BOOL)a_animated;
-(void)m_refreshAndReloadChildData;
-(NSArray*)m_dataLoadPageIndexes;
-(NSUInteger)m_calculateSelectedPageIndex;

-(void)m_addChildViewControllers:(NSArray*)a_childViewControllers;

@end
