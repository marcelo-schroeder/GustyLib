//
//  IAUITableViewController.h
//  Gusty
//
//  Created by Marcelo Schroeder on 21/09/10.
//  Copyright 2010 InfoAccent Pty Limited. All rights reserved.
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

@class IAUIAbstractPagingContainerViewController;

@interface IAUITableViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic) BOOL p_contextSwitchRequestRequired;
@property (nonatomic) BOOL p_contextSwitchRequestPending;
@property (nonatomic) BOOL p_doneButtonSaves;
@property (nonatomic, strong) id p_contextSwitchRequestObject;
@property (nonatomic, readonly) BOOL p_selectedViewControllerInPagingContainer;
@property (nonatomic, readonly) IAUIAbstractPagingContainerViewController *p_pagingContainerViewController;
@property (nonatomic, weak) UIViewController *p_previousVisibleViewController;
@property (nonatomic, strong) UIView *p_sectionHeaderView;
@property (nonatomic, strong) UIColor *p_tableCellTextColor;
@property (nonatomic) BOOL p_shouldCreateContainerViewOnLoadView;

// Used to indicate to the setEditing method whether we are navigating away from the current view and that a UI stage change is no longer required
@property (nonatomic) BOOL p_skipEditingUiStateChange;

- (void)reloadData;
- (void)m_oncontextSwitchRequestNotification:(NSNotification*)aNotification;
- (void)m_replyToContextSwitchRequestWithGranted:(BOOL)a_granted;
- (UITableViewCell*)m_visibleCellForIndexPath:(NSIndexPath*)a_indexPath;
- (UITableViewCell *)m_dequeueAndInitReusableCellWithIdentifier:(NSString*)a_reuseIdentifier atIndexPath:(NSIndexPath*)a_indexPath;
- (UITableViewCell *)m_initReusableCellWithIdentifier:(NSString*)a_reuseIdentifier atIndexPath:(NSIndexPath*)a_indexPath;
- (UITableViewCellStyle) m_tableViewCellStyle;
-(CGFloat)m_sectionHeaderNonEditingXOffset;
-(void)m_updateSectionHeaderBounds;
-(UIView*)m_newTableViewCellAccessoryView;

// Reload target cell so it does appear on top of any custom section header or footer views
//  (i.e. it tries to fix what seems to be a UIKit bug)
-(void)m_reloadMovedCellAtIndexPath:(NSIndexPath*)a_indexPath;

// Message "beginRefreshing" to self.refreshControl but does not show the control
-(void)m_beginRefreshing;
// Message "beginRefreshing" to self.refreshControl with option to show control or not
-(void)m_beginRefreshingWithControlShowing:(BOOL)a_shouldShowControl;

// Use this instead of the native clearsSelectionOnViewWillAppear to avoid issues caused by
// the interactive pop gesture recogniser's animation colliding with the deselection animation
- (BOOL)m_shouldClearSelectionOnViewDidAppear;

// to be overriden by subclasses
- (BOOL)contextSwitchRequestRequiredInEditMode;
- (void)quitEditing;

-(NSCalendar*)m_calendar;

- (NSUInteger)m_numberOfRows;

@end
