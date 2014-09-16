//
//  IFAListViewController.m
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

#import "GustyLibCore.h"

static const int k_tipLabelHorizontalMargin = 15;

@interface IFAListViewController ()

@property (nonatomic, strong) dispatch_block_t pagingContainerChildRefreshAndReloadDataAsynchronousBlock;
@property (nonatomic) BOOL refreshAndReloadDataRequested;
@property (nonatomic, strong) NSString *listGroupedBy;
@property(nonatomic, strong) void (^IFA_sectionDataBlock)(NSString *, NSObject *, NSArray *, NSMutableArray *, NSMutableArray *);
@property(nonatomic) BOOL IFA_childManagedObjectContextPushed;
@property(nonatomic, strong) UILabel *tipLabel;
@property(nonatomic, strong) NSLayoutConstraint *IFA_tipLabelCenterYConstraint;

@end

@implementation IFAListViewController {
    
}


#pragma mark - Private

- (void)IFA_refreshAndReloadDataSynchronously{
    switch(self.fetchingStrategy){
        case IFAListViewControllerFetchingStrategyFetchedResultsController:
            [self IFA_refreshAndReloadDataWithFetchedResultsController];
            break;
        case IFAListViewControllerFetchingStrategyFindEntities:
            [self IFA_refreshAndReloadDataWithFindEntitiesSynchronously];
            break;
        default:
            NSAssert(NO, @"Unexpected fetching strategy: %u", self.fetchingStrategy);
            break;
    }
    if (self.pagingContainerViewController || self.objects.count > 0) {
        self.staleData = NO;
    }
    [self IFA_didCompleteFindEntities];
}

- (void)IFA_refreshAndReloadDataWithFetchedResultsController {
    NSError *l_error;
    if (![self.fetchedResultsController performFetch:&l_error]) {
        [IFAUtils handleUnrecoverableError:l_error];
    };
}

- (void)IFA_refreshAndReloadDataWithFindEntitiesSynchronously {
    self.entities = [[self findEntities] mutableCopy];
}

/**
* Paging container coordination is only relevant to asynchronous fetches with the "findEntities" fetching strategy.
*/
- (void)IFA_refreshAndReloadDataWithPagingContainerCoordination:(BOOL)a_withPagingContainerCoordination {
//    NSLog(@" ");
//    NSLog(@"m_refreshAndReloadDataAsyncWithContainerCoordination for %@ - self.selectedViewControllerInPagingContainer: %u", [self description], self.selectedViewControllerInPagingContainer);

    if (self.asynchronousFetch) {
        [self IFA_refreshAndReloadDataAsynchronouslyWithPagingContainerCoordination:a_withPagingContainerCoordination];
    }else{
        [self IFA_refreshAndReloadDataSynchronously];
    }

}

- (void)IFA_refreshAndReloadDataAsynchronouslyWithPagingContainerCoordination:(BOOL)a_withPagingContainerCoordination {

    IFAListViewController *__weak l_weakSelf = self;

    void (^l_completionBlock)(NSMutableArray *) = ^(NSMutableArray *a_managedObjectIds) {
//        NSLog(@"completion block - start for %@", [l_weakSelf description]);
        @synchronized (l_weakSelf) {
            l_weakSelf.entities = [[IFAPersistenceManager sharedInstance] managedObjectsForIds:a_managedObjectIds];
            if (l_weakSelf.pagingContainerViewController || [l_weakSelf.entities count] > 0) {
                l_weakSelf.staleData = NO;
            }
        }
        [l_weakSelf IFA_didCompleteFindEntities];
//        NSLog(@"completion block - end");
    };

    dispatch_block_t l_block = [^{

        if (l_weakSelf.ifa_asynchronousWorkManager.areAllBlocksCancelled) {
            //            NSLog(@"all blocks cancelled - exiting block!");
            return;
        }

//        NSLog(@"block - start");
//        NSLog(@"going to sleep...");
//        [NSThread sleepForTimeInterval:5];
//        NSLog(@"woke up!");
//        if ([IFAAsynchronousOperationManager sharedInstance].areAllBlocksCancelled) {
//            NSLog(@"all blocks cancelled - exiting block - after sleeping!");
//            return;
//        }

        __block NSMutableArray *l_entities = [NSMutableArray new];
        [[IFAPersistenceManager sharedInstance] performBlockInPrivateQueueAndWait:^{
            l_entities = [IFAPersistenceManager idsForManagedObjects:[[NSMutableArray alloc] initWithArray:[l_weakSelf findEntities]]];
        }];
        //        NSLog(@"find done");

        if (l_weakSelf.ifa_asynchronousWorkManager.areAllBlocksCancelled) {
            //            NSLog(@"all blocks cancelled - exiting block - after find!");
            return;
        }

        [IFAUtils dispatchAsyncMainThreadBlock:^{
            l_completionBlock(l_entities);
        }];
        //        NSLog(@"block - end");

    } copy];

    if (a_withPagingContainerCoordination && self.pagingContainerViewController) {

//        NSLog(@"Container Coordination for child %@, block: %@", [self description], [l_block description]);

        self.pagingContainerChildRefreshAndReloadDataAsynchronousBlock = l_block;
        self.pagingContainerViewController.childViewDidAppearCount++;
//        NSLog(@"  self.pagingContainerViewController.newChildViewControllerCount: %u", self.pagingContainerViewController.newChildViewControllerCount);
//        NSLog(@"  self.pagingContainerViewController.childViewDidAppearCount: %u", self.pagingContainerViewController.childViewDidAppearCount);
        if (self.pagingContainerViewController.newChildViewControllerCount == self.pagingContainerViewController.childViewDidAppearCount) {
//            NSLog(@"  => calling refreshAndReloadChildData on container...");
            [self.pagingContainerViewController refreshAndReloadChildData];
        }

    } else {

//        NSLog(@"block dispatched for %@", [self description]);

        [self.ifa_asynchronousWorkManager dispatchSerialBlock:l_block progressIndicatorContainerView:self.view
                                         cancelPreviousBlocks:YES];

    }

}

- (void)IFA_didCompleteFindEntities {
    [self refreshSectionsWithRows];
    [self reloadData];
    [self didRefreshAndReloadData];
}

-(void)IFA_onPersistenceChangeNotification:(NSNotification*)a_notification{
    
//    NSLog(@"m_onPersistenceChangeNotification for %@ in %@", [a_notification.object description], [self description]);

    self.staleData = YES;

}

-(void)IFA_showTipWithText:(NSString*)a_text{
    self.tipLabel.text = a_text;
    self.tipLabel.hidden = NO;
}

- (BOOL)IFA_shouldRefreshAndReloadDueToStaleDataOnViewAppearance {
    return self.staleData && ![self ifa_isReturningVisibleViewController];
}

- (void)IFA_addTipLabelLayoutConstraints {
    [self.tableView addSubview:self.tipLabel];
    [self.tipLabel ifa_addLayoutConstraintToCenterInSuperviewHorizontally];
    [self.tipLabel.superview addConstraint:self.IFA_tipLabelCenterYConstraint];
    self.tipLabel.preferredMaxLayoutWidth = self.view.bounds.size.width - k_tipLabelHorizontalMargin * 2;
}

- (NSLayoutConstraint *)IFA_tipLabelCenterYConstraint {
    if (!_IFA_tipLabelCenterYConstraint) {
        _IFA_tipLabelCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.tipLabel
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.tipLabel.superview
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0];
    }
    return _IFA_tipLabelCenterYConstraint;
}

#pragma mark - Public

- (id)initWithEntityName:(NSString *)anEntityName{

    if ((self = [super initWithStyle:[self tableViewStyle]])) {

		self.entityName = anEntityName;

    }

	return self;

}

- (IFAListViewControllerFetchingStrategy)fetchingStrategy {
    if (!_fetchingStrategy) {
        _fetchingStrategy = self.listGroupedBy ? IFAListViewControllerFetchingStrategyFindEntities : IFAListViewControllerFetchingStrategyFetchedResultsController;
    }
    return _fetchingStrategy;
}

- (NSArray*)findEntities {
	return [[IFAPersistenceManager sharedInstance] findAllForEntity:self.entityName];
}

- (NSArray *)objects {
    return self.fetchedResultsController ? self.fetchedResultsController.fetchedObjects : self.entities;
}

- (void)refreshAndReloadData {
    [self willRefreshAndReloadData];
    [self IFA_refreshAndReloadDataWithPagingContainerCoordination:NO];
}

- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
	
}

- (UITableViewCell*)cellForTableView:(UITableView*)a_tableView{
    static NSString *CellIdentifier = @"Cell";
    return [self dequeueAndCreateReusableCellWithIdentifier:CellIdentifier atIndexPath:nil];
}

// to be overriden by subclasses
- (void)willRefreshAndReloadData {
//    NSLog(@"Disabling user interaction in %@", [self description]);
    // Disable user interaction while data is being refreshed asynchronously
    if (self.asynchronousFetch) {
        self.tableView.allowsSelection = NO;
        self.editButtonItem.enabled = NO;
        self.addBarButtonItem.enabled = NO;
    }
}

// to be overriden by subclasses
- (void)didRefreshAndReloadData {

    //    NSLog(@"Restoring user interaction in %@", [self description]);

    self.lastRefreshAndReloadDate = [NSDate date];
    
    // Restore user interaction now that async work has been done
    self.tableView.allowsSelection = YES;
    self.editButtonItem.enabled = YES;
    self.addBarButtonItem.enabled = YES;

}

-(BOOL)shouldShowTipsForEditing:(BOOL)a_editing{
    return self.objects.count==0 && [self.navigationItem.leftBarButtonItems containsObject:self.addBarButtonItem];
}

-(NSString*)tipTextForEditing:(BOOL)a_editing{
    NSString *l_textTemplate = @"Tap the '+' button to add %@ %@.";
    NSString *l_indefiniteArticle = [[IFAPersistenceManager sharedInstance].entityConfig indefiniteArticleForEntity:self.entityName];
    NSString *l_entityName = [[IFAPersistenceManager sharedInstance].entityConfig labelForEntity:self.entityName];
    return [NSString stringWithFormat:l_textTemplate, l_indefiniteArticle, l_entityName];
}

- (NSObject *)objectForIndexPath:(NSIndexPath*)a_indexPath{
    if (self.fetchedResultsController) {
        return [self.fetchedResultsController objectAtIndexPath:a_indexPath];
    }else{
        return [(self.sectionsWithRows)[(NSUInteger) a_indexPath.section] objectAtIndex:(NSUInteger) a_indexPath.row];
    }
}

- (NSIndexPath*)indexPathForObject:(NSObject *)a_object {
    if (self.fetchedResultsController) {
        return [self.fetchedResultsController indexPathForObject:a_object];
    }else{
        for (NSUInteger l_section = 0; l_section < [self.sectionsWithRows count]; l_section++) {
            NSUInteger l_row = [(self.sectionsWithRows)[l_section] indexOfObject:a_object];
            if (l_row != NSNotFound) {
                return [NSIndexPath indexPathForRow:l_row inSection:l_section];
            }
        }
        return nil;
    }
}

-(void)refreshSectionsWithRows {

    if (self.fetchedResultsController.sectionNameKeyPath) {
        return;
    }

    [self.sectionHeaderTitles removeAllObjects];
    [self.sectionsWithRows removeAllObjects];

    if (self.listGroupedBy) {

        BOOL l_firstTime = YES;
        NSObject *l_previousSectionObject = nil;
        NSMutableArray *l_sectionRows = [NSMutableArray new];
        for (NSObject *l_object in self.objects) {
            //                NSLog(@"sortLabel: %@", [l_object valueForKey:@"sortLabel"]);
            @autoreleasepool {
                id l_groupedByValue = [l_object valueForKey:self.listGroupedBy];
                NSObject *l_currentSectionObject = l_groupedByValue != nil ? l_groupedByValue : [NSNull null];
                if (l_firstTime || ![l_currentSectionObject isEqual:l_previousSectionObject]) {
                    if (l_firstTime) {
                        l_firstTime = NO;
                    } else {
                        self.IFA_sectionDataBlock(self.listGroupedBy, l_previousSectionObject, l_sectionRows, self.sectionHeaderTitles, self.sectionsWithRows);
                        l_sectionRows = [NSMutableArray new];
                    }
                    l_previousSectionObject = l_currentSectionObject;
                }
                [l_sectionRows addObject:l_object];
            }
        }
        if (!l_firstTime) {
            self.IFA_sectionDataBlock(self.listGroupedBy, l_previousSectionObject, l_sectionRows, self.sectionHeaderTitles, self.sectionsWithRows);
        }

    } else {
        [self.sectionsWithRows addObject:self.objects];
    }

}

- (IFAFormViewController *)formViewControllerForManagedObject:(NSManagedObject *)aManagedObject createMode:(BOOL)aCreateMode{
    Class l_formViewControllerClass = [[IFAPersistenceManager sharedInstance].entityConfig formViewControllerClassForEntity:[aManagedObject ifa_entityName]];
    if (!l_formViewControllerClass) {
        l_formViewControllerClass = NSClassFromString(@"IFAFormViewController");
    }
    NSString *l_formName = [self editFormNameForCreateMode:aCreateMode];
    if (aCreateMode) {
        return [[l_formViewControllerClass alloc] initWithObject:aManagedObject createMode:aCreateMode inForm:l_formName
                                        parentFormViewController:nil];
    }else{
        return [[l_formViewControllerClass alloc] initWithReadOnlyObject:aManagedObject inForm:l_formName
                                                parentFormViewController:nil
                                                          showEditButton:YES];
    }
}

- (void)showEditFormForManagedObject:(NSManagedObject *)a_managedObject {

    BOOL l_isCreateMode = a_managedObject ==nil;
    self.editedManagedObjectId = a_managedObject.objectID;
    
    IFAPersistenceManager *l_pm = [IFAPersistenceManager sharedInstance];
    
    NSManagedObject *l_mo;
    if(l_isCreateMode){

        // Push new child managed object context
        [l_pm pushChildManagedObjectContext];
        NSAssert(self.IFA_childManagedObjectContextPushed == NO, @"Unexpected value for self.IFA_childManagedObjectContextPushed: %u", self.IFA_childManagedObjectContextPushed);
        self.IFA_childManagedObjectContextPushed = YES;
        
        self.editing = NO;
        
        // Create new object
        l_mo = [self newManagedobject];
        self.editedManagedObjectId = l_mo.objectID;
        
    }else{
        
        l_mo = [l_pm findById:self.editedManagedObjectId];
        
    }
    
    // Present form view controller
    UIViewController *l_viewController = [self formViewControllerForManagedObject:l_mo createMode:l_isCreateMode];
    if (l_isCreateMode) {
        [self ifa_presentModalFormViewController:l_viewController];
    }else{
        l_viewController.ifa_presenter = self;
        [self.navigationController pushViewController:l_viewController
                                             animated:YES];
    }

}

- (void)showCreateManagedObjectForm{
    [self showEditFormForManagedObject:nil];
}

- (NSManagedObject*)newManagedobject{
	return [[IFAPersistenceManager sharedInstance] instantiate:self.entityName];
}

- (void)onAddButtonTap:(id)sender {
    [self showCreateManagedObjectForm];
}

- (NSString*)editFormNameForCreateMode:(BOOL)aCreateMode{
    return IFAEntityConfigFormNameDefault;
}

-(void)showTipForEditing:(BOOL)a_editing{
    //    NSLog(@"showTipForEditing");
    self.tipLabel.hidden = YES;
    if ([self shouldShowTipsForEditing:a_editing]) {
        //        NSLog(@"showTipWithText for %@", [self description]);
        [self IFA_showTipWithText:[self tipTextForEditing:a_editing]];
    }
}

- (NSString *)listGroupedBy {
    if (!_listGroupedBy) {
        _listGroupedBy = [[[IFAPersistenceManager sharedInstance] entityConfig] listGroupedByForEntity:self.entityName];
    }
    return _listGroupedBy;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [UILabel new];
        _tipLabel.backgroundColor = [UIColor yellowColor];
        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 0;
    }
    return _tipLabel;
}

#pragma mark - Overrides

-(void)viewDidLoad{

    [super viewDidLoad];

    if (self.fetchingStrategy==IFAListViewControllerFetchingStrategyFetchedResultsController) {
        self.fetchedResultsTableViewControllerDataSource = self;
    }

//    NSLog(@"self.entityName: %@", self.entityName);
    if (!self.title) {
        self.title = [[IFAPersistenceManager sharedInstance].entityConfig listLabelForEntity:self.entityName];
    }

    self.staleData = YES;
//    NSLog(@"self.staleData = YES in viewDidLoad");

    if (!self.fetchedResultsController) {
        self.sectionHeaderTitles = [NSMutableArray new];
        self.sectionsWithRows = [NSMutableArray new];
    }
    
    // Instantiate block that will provide table section data
    NSString *l_entityName = self.entityName;
    self.IFA_sectionDataBlock = ^(NSString *a_sectionGroupedBy, NSObject *a_sectionObject, NSArray *a_sectionRows, NSMutableArray *a_sectionHeaderTitles, NSMutableArray *a_sectionsWithRows){
        NSString *l_sectionHeaderTitle = nil;
        if (a_sectionObject == [NSNull null]) {
            NSString *l_relatedEntityName = [[IFAPersistenceManager sharedInstance].entityConfig entityNameForProperty:a_sectionGroupedBy inEntity:l_entityName];
            l_sectionHeaderTitle = [NSClassFromString(l_relatedEntityName) ifa_displayValueForNil];
        }else{
            l_sectionHeaderTitle = [a_sectionObject ifa_longDisplayValue];
        }
        [a_sectionHeaderTitles addObject:l_sectionHeaderTitle];
        [a_sectionsWithRows addObject:a_sectionRows];
    };
    
    if (self.shouldObservePersistenceChanges) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(IFA_onPersistenceChangeNotification:)
                                                     name:IFANotificationPersistentEntityChange
                                                   object:nil];
    }

    [self IFA_addTipLabelLayoutConstraints];

}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    if ([self IFA_shouldRefreshAndReloadDueToStaleDataOnViewAppearance]) {
        [self willRefreshAndReloadData];
    }

}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];

    if ([self IFA_shouldRefreshAndReloadDueToStaleDataOnViewAppearance]) {
        [self IFA_refreshAndReloadDataWithPagingContainerCoordination:YES];
        self.refreshAndReloadDataRequested = YES;
    }else{
        self.refreshAndReloadDataRequested = NO;
    }

}

-(void)dealloc{
    if (self.shouldObservePersistenceChanges) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationPersistentEntityChange
                                                      object:nil];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.IFA_tipLabelCenterYConstraint.constant = -(self.topLayoutGuide.length + self.bottomLayoutGuide.length) / 2;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    [self showTipForEditing:self.editing];
}

#pragma mark - IFAPresenter

- (void)sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                         data:(id)a_data shouldAnimateDismissal:(BOOL)a_shouldAnimateDismissal {

//    NSLog(@"sessionDidCompleteForViewController for %@", [self description]);

    [super sessionDidCompleteForViewController:a_viewController changesMade:a_changesMade data:a_data
                        shouldAnimateDismissal:a_shouldAnimateDismissal];


    if (self.IFA_childManagedObjectContextPushed) { // It should be only for persistent object creation at this stage

        IFAPersistenceManager *l_pm = [IFAPersistenceManager sharedInstance];

        // It is returning from an edit form
        if (self.editedManagedObjectId) {

            if (a_changesMade) {

                // Save changes in the main managed object context
                [l_pm saveMainManagedObjectContext];

            }

            // Reset the saved ID
            self.editedManagedObjectId = nil;

        }

        // Discard the temporary managed object context
        [l_pm popChildManagedObjectContext];
        self.IFA_childManagedObjectContextPushed = NO;

    }

    if (!self.fetchedResultsController && a_changesMade) {
        if (self.pagingContainerViewController) {
//            NSLog(@"  => calling refreshAndReloadChildData on container FOR SESSION COMPLETE...");
            [self.pagingContainerViewController refreshAndReloadChildData];
        }else {
//            NSLog(@"  => calling refreshAndReloadData on child FOR SESSION COMPLETE...");
            [self refreshAndReloadData];
        }
    }

}

- (void)didDismissViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                              data:(id)a_data {
    [super didDismissViewController:a_viewController changesMade:a_changesMade data:a_data];
    if (!self.ifa_changesMadeByPresentedViewController) { // If changes have been made by the presented view controller, then showTipForEditing will be called somewhere else
        [self showTipForEditing:self.editing];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.fetchedResultsController) {
        return [super numberOfSectionsInTableView:tableView];
    }else {
        return [self.sectionsWithRows count];
    }
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.fetchedResultsController) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }else {
        return [self.sectionsWithRows count] ? [(self.sectionsWithRows)[(NSUInteger) section] count] : 0;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.fetchedResultsController) {
        return [super tableView:tableView titleForHeaderInSection:section];
    }else{
        return [self.sectionHeaderTitles count] ? (self.sectionHeaderTitles)[(NSUInteger) section] : nil;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self cellForTableView:tableView];
	cell.textLabel.text = self.listGroupedBy ? [[self objectForIndexPath:indexPath] ifa_displayValue] : [[self objectForIndexPath:indexPath] ifa_longDisplayValue];
    [[self ifa_appearanceTheme] setAppearanceForView:cell.textLabel];
    return cell;
}

#pragma mark - IFASelectionManagerDelegate

- (NSObject*)selectionManagerObjectForIndexPath:(NSIndexPath*)a_indexPath{
    return [self objectForIndexPath:a_indexPath];
}

- (NSIndexPath*)selectionManagerIndexPathForObject:(NSObject*)a_object{
    return [self indexPathForObject:a_object];
}

- (UITableView*)selectionTableView{
	return self.tableView;
}

#pragma mark - IFAFetchedResultsTableViewControllerDataSource

- (NSFetchedResultsController *)
fetchedResultsControllerForFetchedResultsTableViewController:(IFAFetchedResultsTableViewController *)a_fetchedResultsTableViewController {
    NSFetchedResultsController *l_controller = nil;
    if (self.fetchingStrategy == IFAListViewControllerFetchingStrategyFetchedResultsController) {
        IFAPersistenceManager *l_persistentManager = [IFAPersistenceManager sharedInstance];
        NSFetchRequest *l_fetchRequest = [l_persistentManager findAllFetchRequest:self.entityName
                                                            includePendingChanges:NO];
        l_controller = [[NSFetchedResultsController alloc]
                initWithFetchRequest:l_fetchRequest
                managedObjectContext:l_persistentManager.currentManagedObjectContext
                  sectionNameKeyPath:[[[IFAPersistenceManager sharedInstance] entityConfig] listFetchedResultsControllerSectionNameKeyPathForEntity:self.entityName]
                           cacheName:nil];
    }
    return l_controller;
}

@end

