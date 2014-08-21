//
//  IFAListViewController.h
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

#import "IFAFetchedResultsTableViewController.h"

@class NSManagedObjectID;
@class IFAFormViewController;
@class NSManagedObject;

//wip: document the below
typedef enum{
    IFAListViewControllerFetchingStrategyFetchedResultsController,
    IFAListViewControllerFetchingStrategyFindEntities,
}IFAListViewControllerFetchingStrategy;

//wip: should probably implement a delegate here to decouple all these methods such as will load data, did load data, etc
@interface IFAListViewController : IFAFetchedResultsTableViewController <IFAFetchedResultsTableViewControllerDataSource>

//wip: add documentation to some of these properties and methods, and group them together logically
@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong, readonly) dispatch_block_t refreshAndReloadDataAsynchronousBlock;
@property (nonatomic, strong) NSDate *lastRefreshAndReloadDate;
@property (nonatomic, readonly) BOOL refreshAndReloadDataRequested;
@property (nonatomic, strong) NSString *listGroupedBy;
@property (nonatomic, strong) UIBarButtonItem *addBarButtonItem;
@property (nonatomic, strong) NSManagedObjectID *editedManagedObjectId;
@property BOOL staleData;

/**
* Used to determine the persistent object fetching strategy.
* The default is IFAListViewControllerFetchingStrategyFetchedResultsController.
*/
@property (nonatomic) IFAListViewControllerFetchingStrategy fetchingStrategy;

/* "findEntities" fetching strategy specific properties */
@property (nonatomic, strong) NSMutableArray *entities;
@property (nonatomic, strong) NSMutableArray *sectionHeaderTitles;
@property (nonatomic, strong) NSMutableArray *sectionsWithRows;
@property (nonatomic) BOOL asynchronousFetch;   // Default = NO

- (id)initWithEntityName:(NSString *)anEntityName;

/* "fetchedResultsController" fetching strategy specific methods */
-(void)refreshSectionsWithRows;

/* "findEntities" fetching strategy specific methods */
- (NSArray*)findEntities;

/* generic methods that can be used for fetching strategies */
- (id)objectForIndexPath:(NSIndexPath*)a_indexPath;
- (NSIndexPath*)indexPathForObject:(id)a_object;
- (NSArray *)objects;

- (void)refreshAndReloadData;

/* can be overriden by subclasses */
- (UITableViewStyle)tableViewStyle;
- (UITableViewCell*)cellForTableView:(UITableView*)a_tableView;
- (void)willRefreshAndReloadData;
- (void)didRefreshAndReloadData;

- (BOOL)shouldShowTipsForEditing:(BOOL)a_editing;
- (NSString*)tipTextForEditing:(BOOL)a_editing;
- (void)showTipForEditing:(BOOL)a_editing;

// IFASelectionManagerDelegate
- (NSObject*)selectionManagerObjectForIndexPath:(NSIndexPath*)a_indexPath;
- (NSIndexPath*)selectionManagerIndexPathForObject:(NSObject*)a_object;
- (UITableView*)selectionTableView;

- (IFAFormViewController *)formViewControllerForManagedObject:(NSManagedObject *)aManagedObject createMode:(BOOL)aCreateMode;
- (NSManagedObject*)newManagedobject;
- (void)showEditFormForManagedObject:(NSManagedObject *)aManagedObject;
- (void)showCreateManagedObjectForm;
- (void)onAddButtonTap:(id)sender;
- (NSString*)editFormNameForCreateMode:(BOOL)aCreateMode;

@end
