//
//  IAUIListViewController.m
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

#import "IACommon.h"

@interface IAUIListViewController (){
    
    @private
    NSMutableArray *v_savedToolbarItemEnabledStates;
    void (^v_sectionDataBlock)(NSString*, NSObject*, NSArray*, NSMutableArray*, NSMutableArray*);
    
}

@property (nonatomic, strong, readonly) NSMutableArray *p_savedToolbarItemEnabledStates;
@property (nonatomic, strong) dispatch_block_t p_refreshAndReloadDataAsyncBlock;
@property (nonatomic) BOOL p_refreshAndReloadDataAsyncRequested;
@property (nonatomic, strong) IA_MBProgressHUD *p_hud;

@end

@implementation IAUIListViewController{
    
}


#pragma mark - Private

- (void)m_refreshAndReloadDataAsyncWithContainerCoordination:(BOOL)a_withContainerCoordination{
//    NSLog(@" ");
//    NSLog(@"m_refreshAndReloadDataAsyncWithContainerCoordination for %@ - self.p_selectedViewControllerInPagingContainer: %u", [self description], self.p_selectedViewControllerInPagingContainer);
    
    IAUIListViewController * __weak l_weakSelf = self;
    
    void (^l_completionBlock)(NSMutableArray*) = ^(NSMutableArray* a_managedObjectIds){
//        NSLog(@"completion block - start for %@", [l_weakSelf description]);
        @synchronized(l_weakSelf){
            l_weakSelf.p_entities = [[IAPersistenceManager instance] managedObjectsForIds:a_managedObjectIds];
            if (l_weakSelf.p_pagingContainerViewController || [l_weakSelf.p_entities count]>0) {
                l_weakSelf.p_staleData = NO;
            }
        }
        [l_weakSelf m_refreshSectionsWithRows];
        [l_weakSelf reloadData];
        [l_weakSelf m_didRefreshAndReloadDataAsync];
//        NSLog(@"completion block - end");
    };
    
    dispatch_block_t l_block = [^{
        
        if (l_weakSelf.p_aom.p_areAllBlocksCancelled) {
            //            NSLog(@"all blocks cancelled - exiting block!");
            return;
        }
        
//        NSLog(@"block - start");
//        NSLog(@"going to sleep...");
//        [NSThread sleepForTimeInterval:5];
//        NSLog(@"woke up!");
//        if ([IAAsynchronousOperationManager instance].p_areAllBlocksCancelled) {
//            NSLog(@"all blocks cancelled - exiting block - after sleeping!");
//            return;
//        }
        
        __block NSMutableArray *l_entities = [NSMutableArray new];
        [[IAPersistenceManager instance] performBlockInPrivateQueueAndWait:^{
            l_entities = [IAPersistenceManager idsForManagedObjects:[[NSMutableArray alloc] initWithArray:[l_weakSelf m_findEntities]]];
        }];
        //        NSLog(@"find done");
        
        if (l_weakSelf.p_aom.p_areAllBlocksCancelled) {
            //            NSLog(@"all blocks cancelled - exiting block - after find!");
            return;
        }
        
        [IAUtils m_dispatchAsyncMainThreadBlock:^{l_completionBlock(l_entities);}];
        //        NSLog(@"block - end");
        
    } copy];
    
    if (a_withContainerCoordination && self.p_pagingContainerViewController) {
        
//        NSLog(@"Container Coordination for child %@, block: %@", [self description], [l_block description]);
        
        self.p_refreshAndReloadDataAsyncBlock = l_block;
        self.p_pagingContainerViewController.p_childViewDidAppearCount++;
//        NSLog(@"  self.p_pagingContainerViewController.p_newChildViewControllerCount: %u", self.p_pagingContainerViewController.p_newChildViewControllerCount);
//        NSLog(@"  self.p_pagingContainerViewController.p_childViewDidAppearCount: %u", self.p_pagingContainerViewController.p_childViewDidAppearCount);
        if (self.p_pagingContainerViewController.p_newChildViewControllerCount==self.p_pagingContainerViewController.p_childViewDidAppearCount) {
//            NSLog(@"  => calling m_refreshAndReloadChildData on container...");
            [self.p_pagingContainerViewController m_refreshAndReloadChildData];
        }
        
    }else{
        
//        NSLog(@"block dispatched for %@", [self description]);
        
        [self.p_aom m_dispatchSerialBlock:l_block progressIndicatorContainerView:self.view cancelPreviousBlocks:YES];
        
    }
    
}

-(void)m_onPersistenceChangeNotification:(NSNotification*)a_notification{
    
//    NSLog(@"m_onPersistenceChangeNotification for %@ in %@", [a_notification.object description], [self description]);

    self.p_staleData = YES;

}

-(void)showTipWithText:(NSString*)a_text{
    self.p_hud = [IAUIUtils showHudWithText:a_text inView:self.tableView animated:YES];
}

#pragma mark - Public

- (id)initWithEntityName:(NSString *)anEntityName{

    if ((self = [super initWithStyle:[self m_tableViewStyle]])) {

		self.entityName = anEntityName;

    }

	return self;

}

- (NSArray*) m_findEntities{
	return [[IAPersistenceManager instance] findAllForEntity:self.entityName];
}

- (void)m_refreshAndReloadDataAsync{
    [self m_willRefreshAndReloadDataAsync];
    [self m_refreshAndReloadDataAsyncWithContainerCoordination:NO];
}

- (UITableViewStyle) m_tableViewStyle {
	return UITableViewStylePlain;
	
}

- (UITableViewCell*) m_cellForTableView:(UITableView*)a_tableView{
    static NSString *CellIdentifier = @"Cell";
    return [self m_dequeueAndInitReusableCellWithIdentifier:CellIdentifier atIndexPath:nil];
}

// to be overriden by subclasses
- (void)m_willRefreshAndReloadDataAsync{
//    NSLog(@"Disabling user interaction in %@", [self description]);
    // Disable user interaction while data is being refreshed asynchronously
    self.tableView.allowsSelection = NO;
    self.editButtonItem.enabled = NO;
    self.p_addBarButtonItem.enabled = NO;
}

// to be overriden by subclasses
- (void)m_didRefreshAndReloadDataAsync{

    //    NSLog(@"Restoring user interaction in %@", [self description]);

    self.p_lastRefreshAndReloadDate = [NSDate date];
    
    // Restore user interaction now that async work has been done
    self.tableView.allowsSelection = YES;
    self.editButtonItem.enabled = YES;
    self.p_addBarButtonItem.enabled = YES;

}

-(BOOL)shouldShowTipsForEditing:(BOOL)a_editing{
    return [self.p_entities count]==0 && [self.navigationItem.leftBarButtonItems containsObject:self.p_addBarButtonItem];
}

-(NSString*)tipTextForEditing:(BOOL)a_editing{
    NSString *l_textTemplate = @"Tap the '+' button to add %@ %@.";
    NSString *l_indefiniteArticle = [[IAPersistenceManager instance].entityConfig indefiniteArticleForEntity:self.entityName];
    NSString *l_entityName = [[IAPersistenceManager instance].entityConfig labelForEntity:self.entityName];
    return [NSString stringWithFormat:l_textTemplate, l_indefiniteArticle, l_entityName];
}

-(NSMutableArray *)p_savedToolbarItemEnabledStates{
    if (!v_savedToolbarItemEnabledStates) {
        v_savedToolbarItemEnabledStates = [NSMutableArray new];
    }
    return v_savedToolbarItemEnabledStates;
}

- (NSObject*)m_objectForIndexPath:(NSIndexPath*)a_indexPath{
    if (self.p_fetchedResultsController) {
        return [self.p_fetchedResultsController objectAtIndexPath:a_indexPath];
    }else{
        return [[self.p_sectionsWithRows objectAtIndex:a_indexPath.section] objectAtIndex:a_indexPath.row];
    }
}

- (NSIndexPath*)m_indexPathForObject:(NSObject*)a_object{
    for (NSUInteger l_section=0; l_section<[self.p_sectionsWithRows count]; l_section++) {
        NSUInteger l_row = [[self.p_sectionsWithRows objectAtIndex:l_section] indexOfObject:a_object];
        if(l_row!=NSNotFound){
            return [NSIndexPath indexPathForRow:l_row inSection:l_section];
        }
    }
    return nil;
}

-(void)m_refreshSectionsWithRows{
    
    [self.p_sectionHeaderTitles removeAllObjects];
    [self.p_sectionsWithRows removeAllObjects];
    
    if (self.p_listGroupedBy) {
        
        BOOL l_firstTime = YES;
        NSObject *l_previousSectionObject = nil;
        NSMutableArray *l_sectionRows = [NSMutableArray new];
        for (NSObject *l_object in self.p_entities) {
            //                NSLog(@"sortLabel: %@", [l_object valueForKey:@"sortLabel"]);
            @autoreleasepool {
                id l_groupedByValue = [l_object valueForKey:self.p_listGroupedBy];
                NSObject *l_currentSectionObject = l_groupedByValue!=nil ? l_groupedByValue : [NSNull null];
                if (l_firstTime || ![l_currentSectionObject isEqual:l_previousSectionObject]) {
                    if (l_firstTime) {
                        l_firstTime = NO;
                    }else {
                        v_sectionDataBlock(self.p_listGroupedBy, l_previousSectionObject, l_sectionRows, self.p_sectionHeaderTitles, self.p_sectionsWithRows);
                        l_sectionRows = [NSMutableArray new];
                    }
                    l_previousSectionObject = l_currentSectionObject;
                }
                [l_sectionRows addObject:l_object];
            }
        }
        if (!l_firstTime) {
            v_sectionDataBlock(self.p_listGroupedBy, l_previousSectionObject, l_sectionRows, self.p_sectionHeaderTitles, self.p_sectionsWithRows);
        }
        
    }else{
        [self.p_sectionsWithRows addObject:self.p_entities];
    }
    
}

- (IAUIFormViewController*)formViewControllerForManagedObject:(NSManagedObject *)aManagedObject createMode:(BOOL)aCreateMode{
    Class l_formViewControllerClass = [[IAPersistenceManager instance].entityConfig formViewControllerClassForEntity:[aManagedObject entityName]];
    if (!l_formViewControllerClass) {
        l_formViewControllerClass = NSClassFromString(@"IAUIFormViewController");
    }
    NSString *l_formName = [self editFormNameForCreateMode:aCreateMode];
	//TODO: does this need to be optimised? e.g. instantiate only once and then re-use? (if changing anything, check overrides too)
	return [[l_formViewControllerClass alloc] initWithObject:aManagedObject createMode:aCreateMode inForm:l_formName isSubForm:NO];
}

- (void)showEditFormForManagedObject:(NSManagedObject *)aManagedObject{

    BOOL l_isCreateMode = aManagedObject==nil;
    self.p_editedManagedObjectId = aManagedObject.objectID;
    
    IAPersistenceManager *l_pm = [IAPersistenceManager instance];
    
    // Push new child managed object context
    [l_pm pushChildManagedObjectContext];
    
    NSManagedObject *l_mo;
    if(l_isCreateMode){
        
        self.editing = NO;
        
        // Create new object
        l_mo = [self newManagedobject];
        self.p_editedManagedObjectId = l_mo.objectID;
        
    }else{
        
        l_mo = [l_pm findById:self.p_editedManagedObjectId];
        
    }
    
    // Present form view controller
    UIViewController *l_viewController = [self formViewControllerForManagedObject:l_mo createMode:l_isCreateMode];
    [self m_presentModalFormViewController:l_viewController];

}

- (void)showCreateManagedObjectForm{
    [self showEditFormForManagedObject:nil];
}

- (NSManagedObject*)newManagedobject{
	return [[IAPersistenceManager instance] m_instantiate:self.entityName];
}

- (void)onAddButtonTap:(id)sender {
    [self showCreateManagedObjectForm];
}

- (NSString*)editFormNameForCreateMode:(BOOL)aCreateMode{
    return IA_ENTITY_CONFIG_FORM_NAME_DEFAULT;
}

-(void)showTipForEditing:(BOOL)a_editing{
    //    NSLog(@"showTipForEditing");
    [IAUIUtils hideHud:self.p_hud animated:NO];
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
        self.title = [[IAPersistenceManager instance].entityConfig listLabelForEntity:self.entityName];
    }

    self.p_staleData = YES;
//    NSLog(@"self.p_staleData = YES in viewDidLoad");

    self.p_sectionHeaderTitles = [NSMutableArray new];
    self.p_sectionsWithRows = [NSMutableArray new];
    
    // Instantiate block that will provide table section data
    NSString *l_entityName = self.entityName;
    v_sectionDataBlock = ^(NSString *a_sectionGroupedBy, NSObject *a_sectionObject, NSArray *a_sectionRows, NSMutableArray *a_sectionHeaderTitles, NSMutableArray *a_sectionsWithRows){
        NSString *l_sectionHeaderTitle = nil;
        if (a_sectionObject == [NSNull null]) {
            NSString *l_relatedEntityName = [[IAPersistenceManager instance].entityConfig entityNameForProperty:a_sectionGroupedBy inEntity:l_entityName];
            l_sectionHeaderTitle = [NSClassFromString(l_relatedEntityName) displayValueForNil];
        }else{
            l_sectionHeaderTitle = [a_sectionObject longDisplayValue];
        }
        [a_sectionHeaderTitles addObject:l_sectionHeaderTitle];
        [a_sectionsWithRows addObject:a_sectionRows];
    };
    
    self.p_listGroupedBy = [[[IAPersistenceManager instance] entityConfig] listGroupedByForEntity:self.entityName];
    
    // Observe persistence notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onPersistenceChangeNotification:)
                                                 name:IA_NOTIFICATION_PERSISTENT_ENTITY_CHANGE 
                                               object:nil];
//    NSLog(@"OBSERVER ADDED IN viewDidLoad for %@", [self description]);
    //    NSLog(@"  %@", [NSThread callStackSymbols]);

}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    if( !self.p_fetchedResultsController && self.p_staleData && ![self m_isReturningVisibleViewController] ){
        [self m_willRefreshAndReloadDataAsync];
    }

}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];

    if( !self.p_fetchedResultsController && self.p_staleData && ![self m_isReturningVisibleViewController] ){
        [self m_refreshAndReloadDataAsyncWithContainerCoordination:YES];
        self.p_refreshAndReloadDataAsyncRequested = YES;
    }else{
        self.p_refreshAndReloadDataAsyncRequested = NO;
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IAUIUtils hideHud:self.p_hud animated:NO];
    self.p_hud = nil;
}

-(void)dealloc{
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IA_NOTIFICATION_PERSISTENT_ENTITY_CHANGE object:nil];
//    NSLog(@"OBSERVER REMOVED IN dealloc for %@", [self description]);

}

#pragma mark - IAUIPresenter

- (void)m_sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                         data:(id)a_data {

//    NSLog(@"m_sessionDidCompleteForViewController for %@", [self description]);

    [super m_sessionDidCompleteForViewController:a_viewController changesMade:a_changesMade data:a_data];
    
    // It is returning from an edit form
    if (self.p_editedManagedObjectId) {

        IAPersistenceManager *l_pm = [IAPersistenceManager instance];
        if (a_changesMade) {

            // Save changes in the main managed object context
            [l_pm saveMainManagedObjectContext];
            
        }
        
        // Discard the temporary managed object context
        [l_pm popChildManagedObjectContext];

    }

    if (!self.p_fetchedResultsController && a_changesMade) {
        if (self.p_pagingContainerViewController) {
//            NSLog(@"  => calling m_refreshAndReloadChildData on container FOR SESSION COMPLETE...");
            [self.p_pagingContainerViewController m_refreshAndReloadChildData];
        }else {
//            NSLog(@"  => calling m_refreshAndReloadDataAsync on child FOR SESSION COMPLETE...");
            [self m_refreshAndReloadDataAsync];
        }
    }

}

- (void)m_didDismissViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                              data:(id)a_data {
    [super m_didDismissViewController:a_viewController changesMade:a_changesMade data:a_data];
    if (!self.p_changesMadeByPresentedViewController) { // If changes have been made by the presented view controller, then showTipForEditing will be called somewhere else
        [self showTipForEditing:self.editing];
    }
    self.p_editedManagedObjectId = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.p_fetchedResultsController) {
        return [super numberOfSectionsInTableView:tableView];
    }else {
        return [self.p_sectionsWithRows count];
    }
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.p_fetchedResultsController) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }else {
        return [self.p_sectionsWithRows count] ? [[self.p_sectionsWithRows objectAtIndex:section] count] : 0;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (self.p_fetchedResultsController) {
        return [super tableView:tableView titleForHeaderInSection:section];
    }else{
        return [self.p_sectionHeaderTitles count] ? [self.p_sectionHeaderTitles objectAtIndex:section] : nil;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self m_cellForTableView:tableView];
	cell.textLabel.text = self.p_listGroupedBy ? [[self m_objectForIndexPath:indexPath] displayValue] : [[self m_objectForIndexPath:indexPath] longDisplayValue];
    [[self m_appearanceTheme] m_setAppearanceForView:cell.textLabel];
    return cell;
}

#pragma mark - UITableViewDelegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    IAUITableSectionHeaderView *l_view = nil;
    NSString *l_title = [self tableView:tableView titleForHeaderInSection:section];
    if (l_title) {
        NSString *l_xibName = [[IAUtils infoPList] objectForKey:@"IAUIThemeListSectionHeaderViewXib"];
        if (l_xibName) {
            l_view = [[NSBundle mainBundle] loadNibNamed:l_xibName owner:self options:nil][0];
            l_view.p_titleLabel.text = l_title;
        }
    }
    return l_view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSString *l_title = [self tableView:tableView titleForHeaderInSection:section];
    return l_title ? IA_TABLE_SECTION_HEADER_DEFAULT_HEIGHT : 0;
}

#pragma mark - IAUISelectionManagerDelegate

- (NSObject*)selectionManagerObjectForIndexPath:(NSIndexPath*)a_indexPath{
    return [self m_objectForIndexPath:a_indexPath];
}

- (NSIndexPath*)selectionManagerIndexPathForObject:(NSObject*)a_object{
    return [self m_indexPathForObject:a_object];
}

- (UITableView*)selectionTableView{
	return self.tableView;
}

#pragma mark - IAHelpTargetContainer

-(void)m_willEnterHelpMode{
    [IAUIUtils hideHud:self.p_hud animated:NO];
}

-(void)m_didExitHelpMode{
    [self showTipForEditing:self.editing];
}

@end

