//
//  IFAAbstractPagingContainerViewController.h
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

#import "IFAViewController.h"
#import "IFAContextSwitchTarget.h"

@class IFATableViewController;

@interface IFAAbstractPagingContainerViewController : IFAViewController <UIScrollViewDelegate, IFAContextSwitchTarget>

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly, strong) IFATableViewController *selectedViewController;
@property (nonatomic, readonly) NSUInteger selectedPageIndex;
@property (nonatomic) BOOL willRotate;
@property (nonatomic) NSUInteger lastActiveInterfaceOrientation;

@property (nonatomic) NSUInteger childViewDidAppearCount;
@property (nonatomic) NSUInteger newChildViewControllerCount;

- (void)updateContentLayout;
- (void)updateContentLayoutWithAnimation:(BOOL)a_animated;

-(CGRect)visibleRectForPage:(NSUInteger)a_pageIndex;
-(void)scrollToPage:(NSUInteger)a_pageIndex animated:(BOOL)a_animated;
-(void)refreshAndReloadChildData;
-(NSArray*)dataLoadPageIndexes;
-(NSUInteger)calculateSelectedPageIndex;

-(void)addChildViewControllers:(NSArray*)a_childViewControllers;

@end
