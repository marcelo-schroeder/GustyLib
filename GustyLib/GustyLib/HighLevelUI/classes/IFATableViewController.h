//
//  IFATableViewController.h
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

#import "IFAContextSwitchTarget.h"

@class IFAAbstractPagingContainerViewController;

@interface IFATableViewController : UITableViewController <IFAContextSwitchTarget>

@property (nonatomic) BOOL contextSwitchRequestPending;
@property (nonatomic) BOOL doneButtonSaves;
@property (nonatomic, strong) id contextSwitchRequestObject;
@property (nonatomic, readonly) BOOL selectedViewControllerInPagingContainer;
@property (nonatomic, readonly) IFAAbstractPagingContainerViewController *pagingContainerViewController;
@property (nonatomic, weak) UIViewController *previousVisibleViewController;
@property (nonatomic, strong) UIColor *tableCellTextColor;
@property (nonatomic) BOOL shouldCreateContainerViewOnLoadView;

/**
* Indicate whether reloadData will be called on the table view after quitting editing.
* This can be used to minimise issues with self sizing cell height calculations (i.e. when using system dynamic fonts).
* The default value is NO.
*/
@property (nonatomic) BOOL shouldReloadTableViewDataAfterQuittingEditing;

// Used to indicate to the setEditing method whether we are navigating away from the current view and that a UI stage change is no longer required
@property (nonatomic) BOOL skipEditingUiStateChange;

- (void)reloadData;
- (void)onContextSwitchRequestNotification:(NSNotification*)aNotification;
- (void)replyToContextSwitchRequestWithGranted:(BOOL)a_granted;
- (UITableViewCell*)visibleCellForIndexPath:(NSIndexPath*)a_indexPath;
- (UITableViewCell *)dequeueAndCreateReusableCellWithIdentifier:(NSString *)a_reuseIdentifier atIndexPath:(NSIndexPath*)a_indexPath;
- (UITableViewCell *)createReusableCellWithIdentifier:(NSString *)a_reuseIdentifier atIndexPath:(NSIndexPath*)a_indexPath;
- (UITableViewCellStyle)tableViewCellStyle;
-(CGFloat)sectionHeaderNonEditingXOffset;
-(void)updateSectionHeaderBounds;
//-(UIView*)newTableViewCellAccessoryView;

// Commented the method below out as it was causing issues with self sizing cells (i.e. cells would have incorrect height after reordering)

///**
//* Reload sections related to the index paths given as parameters.
//* This method assumes an implicit CATransaction (for example, implemented by UIKit when calling UITableViewDelegate's tableView:moveRowAtIndexPath:toIndexPath:).
//* The reloading of the sections involved is done after the CATransaction has been completed by UIKit.
//* This method is normally called to update the UI state of the table view sections involved in a row move after the model has been updated in the implementation of UITableViewDelegate's tableView:moveRowAtIndexPath:toIndexPath: method.
//* @param a_fromIndexPath Index path the cell has been moved from.
//* @param a_toIndexPath Index path the cell has been moved to.
//*/
//- (void)reloadInvolvedSectionsAfterImplicitAnimationForRowMovedFromIndexPath:(NSIndexPath *)a_fromIndexPath
//                                                                 toIndexPath:(NSIndexPath *)a_toIndexPath;

// Message "beginRefreshing" to self.refreshControl but does not show the control
-(void)beginRefreshing;
// Message "beginRefreshing" to self.refreshControl with option to show control or not
-(void)beginRefreshingWithControlShowing:(BOOL)a_shouldShowControl;

// Use this instead of the native clearsSelectionOnViewWillAppear to avoid issues caused by
// the interactive pop gesture recogniser's animation colliding with the deselection animation
- (BOOL)shouldClearSelectionOnViewDidAppear;

// to be overriden by subclasses
- (BOOL)automaticallyHandleContextSwitchingBasedOnEditingState;
- (void)quitEditing;

-(NSCalendar*)calendar;

- (NSUInteger)numberOfRows;

/**
* Calculates the height of a table view's section header view using auto layout.
* It can be called from methods such as UITableViewDelegate's tableView:heightForHeaderInSection: when dynamic system fonts are in use.
* @param a_section Table view section the header view belongs to.
*/
- (CGFloat)calculateHeaderHeightForSection:(NSInteger)a_section;

/**
* Calculates the height of a table view's section footer view using auto layout.
* It can be called from methods such as UITableViewDelegate's tableView:heightForFooterInSection: when dynamic system fonts are in use.
* @param a_section Table view section the footer view belongs to.
*/
- (CGFloat)calculateFooterHeightForSection:(NSInteger)a_section;

@end
