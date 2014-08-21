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

/**
* Determines the persistent object fetching strategy.
* IFAListViewControllerFetchingStrategyFetchedResultsController: Uses an NSFetchedResultsController to fetch data. Consult the IFAFetchedResultsTableViewController API documentation for further details.
* IFAListViewControllerFetchingStrategyFindEntities: Calls the "findEntities" method to fetch data.
*/
typedef enum{
    IFAListViewControllerFetchingStrategyFetchedResultsController,
    IFAListViewControllerFetchingStrategyFindEntities,
}IFAListViewControllerFetchingStrategy;

@interface IFAListViewController : IFAFetchedResultsTableViewController <IFAFetchedResultsTableViewControllerDataSource>

@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) NSDate *lastRefreshAndReloadDate;
@property (nonatomic, readonly) BOOL refreshAndReloadDataRequested;
@property (nonatomic, strong) NSString *listGroupedBy;
@property (nonatomic, strong) UIBarButtonItem *addBarButtonItem;
@property (nonatomic, strong) NSManagedObjectID *editedManagedObjectId;

/**
* Called by IFAAbstractPagingContainerViewController to request a data refresh and reload to a child view controller
*/
@property (nonatomic, strong, readonly) dispatch_block_t pagingContainerChildRefreshAndReloadDataAsynchronousBlock;

/**
* Used to indicate whether the data is stale and it needs to be re-fetched next time the view is displayed (i.e. after being fully hidden).
*/
@property BOOL staleData;

/**
* Used to determine the persistent object fetching strategy.
* The default is IFAListViewControllerFetchingStrategyFetchedResultsController.
*/
@property (nonatomic) IFAListViewControllerFetchingStrategy fetchingStrategy;

/* "findEntities" fetching strategy specific properties */
@property (nonatomic, strong) NSMutableArray *entities; // Determines the persistent entity to be used to populate the list view.
@property (nonatomic, strong) NSMutableArray *sectionHeaderTitles;
@property (nonatomic, strong) NSMutableArray *sectionsWithRows;

/**
* Determines whether the data fetch will be asynchronous.
* Asynchronous fetches should only be used when fetchingStrategy is set to IFAListViewControllerFetchingStrategyFindEntities.
* Default = NO.
*/
@property (nonatomic) BOOL asynchronousFetch;

/**
* Designated initializer.
* @param anEntityName Determines the persistent entity to be used to populate the list view.
*/
- (id)initWithEntityName:(NSString *)anEntityName;

/* "fetchedResultsController" fetching strategy specific methods */
-(void)refreshSectionsWithRows;

/**
* This method is called to fetch data when the fetchingStrategy is set to IFAListViewControllerFetchingStrategyFindEntities.
* The default implementation of this method is to find all objects specified by the "entityName" property.
*/
- (NSArray*)findEntities;

- (id)objectForIndexPath:(NSIndexPath*)a_indexPath;
- (NSIndexPath*)indexPathForObject:(id)a_object;
- (NSArray *)objects;

/**
* Trigger a data refresh followed by a reload of the view.
*/
- (void)refreshAndReloadData;

/**
* Called before a data refresh and reload is performed.
*/
- (void)willRefreshAndReloadData;

/**
* Called after a data refresh and reload has been performed.
*/
- (void)didRefreshAndReloadData;

- (UITableViewStyle)tableViewStyle;
- (UITableViewCell*)cellForTableView:(UITableView*)a_tableView;

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
