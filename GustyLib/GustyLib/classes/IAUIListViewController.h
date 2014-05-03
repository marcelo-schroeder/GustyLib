//
//  IAUIListViewController.h
//  Gusty
//
//  Created by Marcelo Schroeder on 22/07/10.
//  Copyright 2009 InfoAccent Pty Limited. All rights reserved.
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

#import "IAUIFetchedResultsTableViewController.h"

@class NSManagedObjectID;
@class IAUIFormViewController;
@class NSManagedObject;

@interface IAUIListViewController : IAUIFetchedResultsTableViewController

@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong, readonly) dispatch_block_t p_refreshAndReloadDataAsyncBlock;
@property (nonatomic, strong) NSMutableArray *p_entities;
@property (nonatomic, strong) NSDate *p_lastRefreshAndReloadDate;
@property (nonatomic, readonly) BOOL p_refreshAndReloadDataAsyncRequested;
@property (nonatomic, strong) NSMutableArray *p_sectionHeaderTitles;
@property (nonatomic, strong) NSMutableArray *p_sectionsWithRows;
@property (nonatomic, strong) NSString *p_listGroupedBy;
@property (nonatomic, strong) UIBarButtonItem *p_addBarButtonItem;
@property (nonatomic, strong) NSManagedObjectID *p_editedManagedObjectId;

@property BOOL p_staleData;

- (id)initWithEntityName:(NSString *)anEntityName;
- (NSArray*)findEntities;
- (NSObject*)m_objectForIndexPath:(NSIndexPath*)a_indexPath;
- (NSIndexPath*)indexPathForObject:(NSObject*)a_object;
-(void)refreshSectionsWithRows;
- (void)refreshAndReloadDataAsync;

/* can be overriden by subclasses */
- (UITableViewStyle)tableViewStyle;
- (UITableViewCell*)cellForTableView:(UITableView*)a_tableView;
- (void)willRefreshAndReloadDataAsync;
- (void)didRefreshAndReloadDataAsync;

- (BOOL)shouldShowTipsForEditing:(BOOL)a_editing;
- (NSString*)tipTextForEditing:(BOOL)a_editing;
- (void)showTipForEditing:(BOOL)a_editing;

// IAUISelectionManagerDelegate
- (NSObject*)selectionManagerObjectForIndexPath:(NSIndexPath*)a_indexPath;
- (NSIndexPath*)selectionManagerIndexPathForObject:(NSObject*)a_object;
- (UITableView*)selectionTableView;

- (IAUIFormViewController*)formViewControllerForManagedObject:(NSManagedObject *)aManagedObject createMode:(BOOL)aCreateMode;
- (NSManagedObject*)newManagedobject;
- (void)showEditFormForManagedObject:(NSManagedObject *)aManagedObject;
- (void)showCreateManagedObjectForm;
- (void)onAddButtonTap:(id)sender;
- (NSString*)editFormNameForCreateMode:(BOOL)aCreateMode;

@end
