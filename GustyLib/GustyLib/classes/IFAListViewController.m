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

#import "IFACommon.h"

@interface IFAListViewController (){
    
    @private
    NSMutableArray *v_savedToolbarItemEnabledStates;
    void (^v_sectionDataBlock)(NSString*, NSObject*, NSArray*, NSMutableArray*, NSMutableArray*);
    
}

@property (nonatomic, strong, readonly) NSMutableArray *IFA_savedToolbarItemEnabledStates;
@property (nonatomic, strong) dispatch_block_t refreshAndReloadDataAsyncBlock;
@property (nonatomic) BOOL refreshAndReloadDataAsyncRequested;
@property (nonatomic, strong) IFA_MBProgressHUD *IFA_hud;

@end

@implementation IFAListViewController {
    
}


#pragma mark - Private

- (void)IFA_refreshAndReloadDataAsyncWithContainerCoordination:(BOOL)a_withContainerCoordination{
//    NSLog(@" ");
//    NSLog(@"m_refreshAndReloadDataAsyncWithContainerCoordination for %@ - self.selectedViewControllerInPagingContainer: %u", [self description], self.selectedViewControllerInPagingContainer);
    
    IFAListViewController * __weak l_weakSelf = self;
    
    void (^l_completionBlock)(NSMutableArray*) = ^(NSMutableArray* a_managedObjectIds){
//        NSLog(@"completion block - start for %@", [l_weakSelf description]);
        @synchronized(l_weakSelf){
            l_weakSelf.entities = [[IFAPersistenceManager sharedInstance] managedObjectsForIds:a_managedObjectIds];
            if (l_weakSelf.pagingContainerViewController || [l_weakSelf.entities count]>0) {
                l_weakSelf.staleData = NO;
            }
        }
        [l_weakSelf refreshSectionsWithRows];
        [l_weakSelf reloadData];
        [l_weakSelf didRefreshAndReloadDataAsync];
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
    
    if (a_withContainerCoordination && self.pagingContainerViewController) {
        
//        NSLog(@"Container Coordination for child %@, block: %@", [self description], [l_block description]);
        
        self.refreshAndReloadDataAsyncBlock = l_block;
        self.pagingContainerViewController.childViewDidAppearCount++;
//        NSLog(@"  self.pagingContainerViewController.newChildViewControllerCount: %u", self.pagingContainerViewController.newChildViewControllerCount);
//        NSLog(@"  self.pagingContainerViewController.childViewDidAppearCount: %u", self.pagingContainerViewController.childViewDidAppearCount);
        if (self.pagingContainerViewController.newChildViewControllerCount ==self.pagingContainerViewController.childViewDidAppearCount) {
//            NSLog(@"  => calling refreshAndReloadChildData on container...");
            [self.pagingContainerViewController refreshAndReloadChildData];
        }
        
    }else{
        
//        NSLog(@"block dispatched for %@", [self description]);

        [self.ifa_asynchronousWorkManager dispatchSerialBlock:l_block progressIndicatorContainerView:self.view
                                         cancelPreviousBlocks:YES];
        
    }
    
}

-(void)IFA_onPersistenceChangeNotification:(NSNotification*)a_notification{
    
//    NSLog(@"m_onPersistenceChangeNotification for %@ in %@", [a_notification.object description], [self description]);

    self.staleData = YES;

}

-(void)showTipWithText:(NSString*)a_text{
    self.IFA_hud = [IFAUIUtils showHudWithText:a_text inView:self.tableView animated:YES];
}

#pragma mark - Public

- (id)initWithEntityName:(NSString *)anEntityName{

    if ((self = [super initWithStyle:[self tableViewStyle]])) {

		self.entityName = anEntityName;

    }

	return self;

}

- (NSArray*)findEntities {
	return [[IFAPersistenceManager sharedInstance] findAllForEntity:self.entityName];
}

- (void)refreshAndReloadDataAsync {
    [self willRefreshAndReloadDataAsync];
    [self IFA_refreshAndReloadDataAsyncWithContainerCoordination:NO];
}

- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
	
}

- (UITableViewCell*)cellForTableView:(UITableView*)a_tableView{
    static NSString *CellIdentifier = @"Cell";
    return [self dequeueAndCreateReusableCellWithIdentifier:CellIdentifier atIndexPath:nil];
}

// to be overriden by subclasses
- (void)willRefreshAndReloadDataAsync {
//    NSLog(@"Disabling user interaction in %@", [self description]);
    // Disable user interaction while data is being refreshed asynchronously
    self.tableView.allowsSelection = NO;
    self.editButtonItem.enabled = NO;
    self.addBarButtonItem.enabled = NO;
}

// to be overriden by subclasses
- (void)didRefreshAndReloadDataAsync {

    //    NSLog(@"Restoring user interaction in %@", [self description]);

    self.lastRefreshAndReloadDate = [NSDate date];
    
    // Restore user interaction now that async work has been done
    self.tableView.allowsSelection = YES;
    self.editButtonItem.enabled = YES;
    self.addBarButtonItem.enabled = YES;

}

-(BOOL)shouldShowTipsForEditing:(BOOL)a_editing{
    return [self.entities count]==0 && [self.navigationItem.leftBarButtonItems containsObject:self.addBarButtonItem];
}

-(NSString*)tipTextForEditing:(BOOL)a_editing{
    NSString *l_textTemplate = @"Tap the '+' button to add %@ %@.";
    NSString *l_indefiniteArticle = [[IFAPersistenceManager sharedInstance].entityConfig indefiniteArticleForEntity:self.entityName];
    NSString *l_entityName = [[IFAPersistenceManager sharedInstance].entityConfig labelForEntity:self.entityName];
    return [NSString stringWithFormat:l_textTemplate, l_indefiniteArticle, l_entityName];
}

-(NSMutableArray *)IFA_savedToolbarItemEnabledStates {
    if (!v_savedToolbarItemEnabledStates) {
        v_savedToolbarItemEnabledStates = [NSMutableArray new];
    }
    return v_savedToolbarItemEnabledStates;
}

- (NSObject*)objectForIndexPath:(NSIndexPath*)a_indexPath{
    if (self.ifa_activeFetchedResultsController) {
        return [self.ifa_activeFetchedResultsController objectAtIndexPath:a_indexPath];
    }else{
        return [[self.sectionsWithRows objectAtIndex:a_indexPath.section] objectAtIndex:a_indexPath.row];
    }
}

- (NSIndexPath*)indexPathForObject:(NSObject*)a_object{
    for (NSUInteger l_section=0; l_section<[self.sectionsWithRows count]; l_section++) {
        NSUInteger l_row = [[self.sectionsWithRows objectAtIndex:l_section] indexOfObject:a_object];
        if(l_row!=NSNotFound){
            return [NSIndexPath indexPathForRow:l_row inSection:l_section];
        }
    }
    return nil;
}

-(void)refreshSectionsWithRows {
    
    [self.sectionHeaderTitles removeAllObjects];
    [self.sectionsWithRows removeAllObjects];
    
    if (self.listGroupedBy) {
        
        BOOL l_firstTime = YES;
        NSObject *l_previousSectionObject = nil;
        NSMutableArray *l_sectionRows = [NSMutableArray new];
        for (NSObject *l_object in self.entities) {
            //                NSLog(@"sortLabel: %@", [l_object valueForKey:@"sortLabel"]);
            @autoreleasepool {
                id l_groupedByValue = [l_object valueForKey:self.listGroupedBy];
                NSObject *l_currentSectionObject = l_groupedByValue!=nil ? l_groupedByValue : [NSNull null];
                if (l_firstTime || ![l_currentSectionObject isEqual:l_previousSectionObject]) {
                    if (l_firstTime) {
                        l_firstTime = NO;
                    }else {
                        v_sectionDataBlock(self.listGroupedBy, l_previousSectionObject, l_sectionRows, self.sectionHeaderTitles, self.sectionsWithRows);
                        l_sectionRows = [NSMutableArray new];
                    }
                    l_previousSectionObject = l_currentSectionObject;
                }
                [l_sectionRows addObject:l_object];
            }
        }
        if (!l_firstTime) {
            v_sectionDataBlock(self.listGroupedBy, l_previousSectionObject, l_sectionRows, self.sectionHeaderTitles, self.sectionsWithRows);
        }
        
    }else{
        [self.sectionsWithRows addObject:self.entities];
    }
    
}

- (IFAFormViewController *)formViewControllerForManagedObject:(NSManagedObject *)aManagedObject createMode:(BOOL)aCreateMode{
    Class l_formViewControllerClass = [[IFAPersistenceManager sharedInstance].entityConfig formViewControllerClassForEntity:[aManagedObject ifa_entityName]];
    if (!l_formViewControllerClass) {
        l_formViewControllerClass = NSClassFromString(@"IFAFormViewController");
    }
    NSString *l_formName = [self editFormNameForCreateMode:aCreateMode];
	//TODO: does this need to be optimised? e.g. instantiate only once and then re-use? (if changing anything, check overrides too)
	return [[l_formViewControllerClass alloc] initWithObject:aManagedObject createMode:aCreateMode inForm:l_formName isSubForm:NO];
}

- (void)showEditFormForManagedObject:(NSManagedObject *)aManagedObject{

    BOOL l_isCreateMode = aManagedObject==nil;
    self.editedManagedObjectId = aManagedObject.objectID;
    
    IFAPersistenceManager *l_pm = [IFAPersistenceManager sharedInstance];
    
    // Push new child managed object context
    [l_pm pushChildManagedObjectContext];
    
    NSManagedObject *l_mo;
    if(l_isCreateMode){
        
        self.editing = NO;
        
        // Create new object
        l_mo = [self newManagedobject];
        self.editedManagedObjectId = l_mo.objectID;
        
    }else{
        
        l_mo = [l_pm findById:self.editedManagedObjectId];
        
    }
    
    // Present form view controller
    UIViewController *l_viewController = [self formViewControllerForManagedObject:l_mo createMode:l_isCreateMode];
    [self ifa_presentModalFormViewController:l_viewController];

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
    [IFAUIUtils hideHud:self.IFA_hud animated:NO];
    if ([self shouldShowTipsForEditing:a_editing]) {
        //        NSLog(@"showTipWithText for %@", [self description]);
        [self showTipWithText:[self tipTextForEditing:a_editing]];
    }
}

#pragma mark - Overrides

-(void)viewDidLoad{

    [super viewDidLoad];

//    NSLog(@"self.entityName: %@", self.entityName);
    if (!self.title) {
        self.title = [[IFAPersistenceManager sharedInstance].entityConfig listLabelForEntity:self.entityName];
    }

    self.staleData = YES;
//    NSLog(@"self.staleData = YES in viewDidLoad");

    self.sectionHeaderTitles = [NSMutableArray new];
    self.sectionsWithRows = [NSMutableArray new];
    
    // Instantiate block that will provide table section data
    NSString *l_entityName = self.entityName;
    v_sectionDataBlock = ^(NSString *a_sectionGroupedBy, NSObject *a_sectionObject, NSArray *a_sectionRows, NSMutableArray *a_sectionHeaderTitles, NSMutableArray *a_sectionsWithRows){
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
    
    self.listGroupedBy = [[[IFAPersistenceManager sharedInstance] entityConfig] listGroupedByForEntity:self.entityName];
    
    // Observe persistence notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onPersistenceChangeNotification:)
                                                 name:IFANotificationPersistentEntityChange
                                               object:nil];
//    NSLog(@"OBSERVER ADDED IN viewDidLoad for %@", [self description]);
    //    NSLog(@"  %@", [NSThread callStackSymbols]);

}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if( !self.ifa_activeFetchedResultsController && self.staleData && ![self ifa_isReturningVisibleViewController] ){
        [self willRefreshAndReloadDataAsync];
    }

}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];

    if( !self.ifa_activeFetchedResultsController && self.staleData && ![self ifa_isReturningVisibleViewController] ){
        [self IFA_refreshAndReloadDataAsyncWithContainerCoordination:YES];
        self.refreshAndReloadDataAsyncRequested = YES;
    }else{
        self.refreshAndReloadDataAsyncRequested = NO;
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IFAUIUtils hideHud:self.IFA_hud animated:NO];
    self.IFA_hud = nil;
}

-(void)dealloc{
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationPersistentEntityChange
                                                  object:nil];
//    NSLog(@"OBSERVER REMOVED IN dealloc for %@", [self description]);

}

#pragma mark - IFAPresenter

- (void)sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                         data:(id)a_data {

//    NSLog(@"sessionDidCompleteForViewController for %@", [self description]);

    [super sessionDidCompleteForViewController:a_viewController changesMade:a_changesMade data:a_data];
    
    // It is returning from an edit form
    if (self.editedManagedObjectId) {

        IFAPersistenceManager *l_pm = [IFAPersistenceManager sharedInstance];
        if (a_changesMade) {

            // Save changes in the main managed object context
            [l_pm saveMainManagedObjectContext];
            
        }
        
        // Discard the temporary managed object context
        [l_pm popChildManagedObjectContext];

    }

    if (!self.ifa_activeFetchedResultsController && a_changesMade) {
        if (self.pagingContainerViewController) {
//            NSLog(@"  => calling refreshAndReloadChildData on container FOR SESSION COMPLETE...");
            [self.pagingContainerViewController refreshAndReloadChildData];
        }else {
//            NSLog(@"  => calling refreshAndReloadDataAsync on child FOR SESSION COMPLETE...");
            [self refreshAndReloadDataAsync];
        }
    }

}

- (void)didDismissViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                              data:(id)a_data {
    [super didDismissViewController:a_viewController changesMade:a_changesMade data:a_data];
    if (!self.ifa_changesMadeByPresentedViewController) { // If changes have been made by the presented view controller, then showTipForEditing will be called somewhere else
        [self showTipForEditing:self.editing];
    }
    self.editedManagedObjectId = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.ifa_activeFetchedResultsController) {
        return [super numberOfSectionsInTableView:tableView];
    }else {
        return [self.sectionsWithRows count];
    }
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.ifa_activeFetchedResultsController) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }else {
        return [self.sectionsWithRows count] ? [[self.sectionsWithRows objectAtIndex:section] count] : 0;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.ifa_activeFetchedResultsController) {
        return [super tableView:tableView titleForHeaderInSection:section];
    }else{
        return [self.sectionHeaderTitles count] ? [self.sectionHeaderTitles objectAtIndex:section] : nil;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self cellForTableView:tableView];
	cell.textLabel.text = self.listGroupedBy ? [[self objectForIndexPath:indexPath] ifa_displayValue] : [[self objectForIndexPath:indexPath] ifa_longDisplayValue];
    [[self ifa_appearanceTheme] setAppearanceForView:cell.textLabel];
    return cell;
}

#pragma mark - UITableViewDelegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    IFATableSectionHeaderView *l_view = nil;
    NSString *l_title = [self tableView:tableView titleForHeaderInSection:section];
    if (l_title) {
        NSString *l_xibName = [[IFAUtils infoPList] objectForKey:@"IFAThemeListSectionHeaderViewXib"];
        if (l_xibName) {
            l_view = [[NSBundle mainBundle] loadNibNamed:l_xibName owner:self options:nil][0];
            l_view.titleLabel.text = l_title;
        }
    }
    return l_view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSString *l_title = [self tableView:tableView titleForHeaderInSection:section];
    return l_title ? IFATableSectionHeaderDefaultHeight : 0;
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

#pragma mark - IFAHelpTargetContainer

-(void)willEnterHelpMode{
    [IFAUIUtils hideHud:self.IFA_hud animated:NO];
}

-(void)didExitHelpMode{
    [self showTipForEditing:self.editing];
}

@end

