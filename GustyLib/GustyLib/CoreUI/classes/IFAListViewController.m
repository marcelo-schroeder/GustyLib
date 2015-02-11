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

#import "GustyLibCoreUI.h"

#ifdef IFA_AVAILABLE_Help
#import "IFAHelpManager.h"
#endif

@interface IFAListViewController ()

@property (nonatomic, strong) dispatch_block_t pagingContainerChildRefreshAndReloadDataAsynchronousBlock;
@property (nonatomic) BOOL refreshAndReloadDataRequested;
@property (nonatomic, strong) NSString *listGroupedBy;
@property(nonatomic, strong) void (^IFA_sectionDataBlock)(NSString *, NSObject *, NSArray *, NSMutableArray *, NSMutableArray *);
@property(nonatomic) BOOL IFA_childManagedObjectContextPushed;
@property(nonatomic, strong) NSLayoutConstraint *IFA_noDataPlaceholderViewCenterYConstraint;
@property (nonatomic, strong) UIView *IFA_noDataPlaceholderAddHintView;
@property (nonatomic, strong) UIView *IFA_noDataPlaceholderView;
@property(nonatomic, strong) UILabel *noDataPlaceholderAddHintPrefixLabel;
@property(nonatomic, strong) UIImageView *noDataPlaceholderAddHintImageView;
@property(nonatomic, strong) UILabel *noDataPlaceholderAddHintSuffixLabel;
@property(nonatomic, strong) UILabel *noDataPlaceholderDescriptionLabel;
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
            NSAssert(NO, @"Unexpected fetching strategy: %lu", (unsigned long)self.fetchingStrategy);
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
        [IFAUIUtils handleUnrecoverableError:l_error];
    };
}

- (void)IFA_refreshAndReloadDataWithFindEntitiesSynchronously {
    self.entities = [[self findEntities] mutableCopy];
}

/*
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

        [self.ifa_asynchronousWorkManager dispatchSerialBlock:l_block progressIndicatorContainerViewController:self
                                         cancelPreviousBlocks:YES];

    }

}

- (void)IFA_didCompleteFindEntities {
    [self refreshSectionsWithRows];
    [self reloadData];
    [self IFA_updateLayoutForDynamicFont];
    [self didRefreshAndReloadData];
}

// Workaround for dynamic type issue: forces table view to recalculate cell heights so they are correct.
// I have submitted bug 19170676 to Apple re this on 08/12/2014.
- (void)IFA_updateLayoutForDynamicFont {
    [self.view layoutIfNeeded];
    [self reloadData];
}

-(void)IFA_onPersistenceChangeNotification:(NSNotification*)a_notification{
    
//    NSLog(@"m_onPersistenceChangeNotification for %@ in %@", [a_notification.object description], [self description]);

    self.staleData = YES;

}

- (BOOL)IFA_shouldRefreshAndReloadDueToStaleDataOnViewAppearance {
    return self.staleData && ![self ifa_isReturningVisibleViewController];
}

- (void)IFA_configureNoDataPlaceholderView {
    [self.tableView addSubview:self.IFA_noDataPlaceholderView];
    [self.IFA_noDataPlaceholderView.superview addConstraint:self.IFA_noDataPlaceholderViewCenterYConstraint];
    UIView *noDataPlaceholderView = self.IFA_noDataPlaceholderView;
    NSDictionary *views = NSDictionaryOfVariableBindings(noDataPlaceholderView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=15)-[noDataPlaceholderView]-(>=15)-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:views];
    [noDataPlaceholderView.superview addConstraints:horizontalConstraints];
    [noDataPlaceholderView ifa_addLayoutConstraintToCenterInSuperviewHorizontally];
}

- (NSLayoutConstraint *)IFA_noDataPlaceholderViewCenterYConstraint {
    if (!_IFA_noDataPlaceholderViewCenterYConstraint) {
        _IFA_noDataPlaceholderViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.IFA_noDataPlaceholderView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.IFA_noDataPlaceholderView.superview
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0];
    }
    return _IFA_noDataPlaceholderViewCenterYConstraint;
}

- (void)IFA_updatenoDataPlaceholderViewLayout {
    UIViewController *modelViewController;
    if (!(modelViewController = self.pagingContainerViewController.selectedViewController)) {    // If this is a paging container child, then use the selected view controller to gather layout info from
        modelViewController = self;
    }
    self.IFA_noDataPlaceholderViewCenterYConstraint.constant = -(modelViewController.topLayoutGuide.length + modelViewController.bottomLayoutGuide.length) / 2;
}

- (UIView *)IFA_noDataPlaceholderAddHintView {
    if (!_IFA_noDataPlaceholderAddHintView) {
        _IFA_noDataPlaceholderAddHintView = [UIView new];
//        _IFA_noDataPlaceholderAddHintView.backgroundColor = [UIColor yellowColor];
        _IFA_noDataPlaceholderAddHintView.translatesAutoresizingMaskIntoConstraints = NO;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(showCreateManagedObjectForm)];
        [_IFA_noDataPlaceholderAddHintView addGestureRecognizer:tapGestureRecognizer];
        [_IFA_noDataPlaceholderAddHintView addSubview:self.noDataPlaceholderAddHintPrefixLabel];
        [_IFA_noDataPlaceholderAddHintView addSubview:self.noDataPlaceholderAddHintImageView];
        [_IFA_noDataPlaceholderAddHintView addSubview:self.noDataPlaceholderAddHintSuffixLabel];
        id prefixLabel = self.noDataPlaceholderAddHintPrefixLabel;
        id addButton = self.noDataPlaceholderAddHintImageView;
        id suffixLabel = self.noDataPlaceholderAddHintSuffixLabel;
        NSDictionary *views = NSDictionaryOfVariableBindings(prefixLabel, addButton, suffixLabel);
        [_IFA_noDataPlaceholderAddHintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[prefixLabel][addButton(21)][suffixLabel]|"
                                                                                                  options:NSLayoutFormatAlignAllCenterY
                                                                                                  metrics:nil
                                                                                                    views:views]];
        [_IFA_noDataPlaceholderAddHintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[prefixLabel]-(>=0)-|"
                                                                                                  options:NSLayoutFormatAlignAllCenterY
                                                                                                  metrics:nil
                                                                                                    views:views]];
        [_IFA_noDataPlaceholderAddHintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[addButton(21)]-(>=0)-|"
                                                                                                  options:NSLayoutFormatAlignAllCenterY
                                                                                                  metrics:nil
                                                                                                    views:views]];
        [_IFA_noDataPlaceholderAddHintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[suffixLabel]-(>=0)-|"
                                                                                                  options:NSLayoutFormatAlignAllCenterY
                                                                                                  metrics:nil
                                                                                                    views:views]];
    }
    return _IFA_noDataPlaceholderAddHintView;
}

- (UIView *)IFA_noDataPlaceholderView {
    if (!_IFA_noDataPlaceholderView) {
        _IFA_noDataPlaceholderView = [UIView new];
//        _IFA_noDataPlaceholderView.backgroundColor = [UIColor magentaColor];
        _IFA_noDataPlaceholderView.hidden = YES;
        _IFA_noDataPlaceholderView.translatesAutoresizingMaskIntoConstraints = NO;
        BOOL shouldAddTopView = self.IFA_noDataPlaceholderAddHintView !=nil;
        if ([self.listViewControllerDataSource respondsToSelector:@selector(shouldShowNoDataPlaceholderAddHintViewForListViewController:)]) {
            shouldAddTopView = [self.listViewControllerDataSource shouldShowNoDataPlaceholderAddHintViewForListViewController:self];
        }
        BOOL shouldAddBottomView = self.noDataPlaceholderDescriptionLabel.text && !self.noDataPlaceholderDescriptionLabel.text.ifa_isEmpty;
        id topView = self.IFA_noDataPlaceholderAddHintView;
        id bottomView = self.noDataPlaceholderDescriptionLabel;
        if (shouldAddTopView) {
            [_IFA_noDataPlaceholderView addSubview:self.IFA_noDataPlaceholderAddHintView];
            [_IFA_noDataPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=15)-[topView]-(>=15)-|"
                                                                                               options:NSLayoutFormatAlignAllCenterY
                                                                                               metrics:nil
                                                                                                 views:NSDictionaryOfVariableBindings(topView)]];
        }
        if (shouldAddBottomView) {
            [_IFA_noDataPlaceholderView addSubview:self.noDataPlaceholderDescriptionLabel];
            [_IFA_noDataPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=15)-[bottomView]-(>=15)-|"
                                                                                               options:NSLayoutFormatAlignAllCenterY
                                                                                               metrics:nil
                                                                                                 views:NSDictionaryOfVariableBindings(bottomView)]];
        }
        if (shouldAddTopView && shouldAddBottomView) {
            NSDictionary *views = NSDictionaryOfVariableBindings(topView, bottomView);
            [_IFA_noDataPlaceholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView]-30-[bottomView]|"
                                                                                               options:NSLayoutFormatAlignAllCenterX
                                                                                               metrics:nil
                                                                                                 views:views]];
        }else if(shouldAddTopView || shouldAddBottomView){
            UIView *view = shouldAddTopView ? self.IFA_noDataPlaceholderAddHintView : self.noDataPlaceholderDescriptionLabel;
            [view ifa_addLayoutConstraintsToFillSuperviewVertically];
        }
    }
    return _IFA_noDataPlaceholderView;
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

- (BOOL)shouldShowEmptyListPlaceholder {
    return self.objects.count==0 && self.addBarButtonItem.enabled;
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

- (void)showCreateManagedObjectForm {
    // The check below prevents the "Add" button from capturing taps multiple times while a view controller's pop transition
    // is in place as a result of the user tapping the back button on a view controller that had been previously been pushed.
    // Without this check, the app would crash as a result of inconsistent state.
    if (!self.ifa_isReturningVisibleViewController) {
        [self showEditFormForManagedObject:nil];
    }
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

- (void)showEmptyListPlaceholder {
    self.IFA_noDataPlaceholderView.hidden = YES;
    if ([self shouldShowEmptyListPlaceholder]) {
        self.IFA_noDataPlaceholderView.hidden = NO;
    }
}

- (NSString *)listGroupedBy {
    if (!_listGroupedBy) {
        _listGroupedBy = [[[IFAPersistenceManager sharedInstance] entityConfig] listGroupedByForEntity:self.entityName];
    }
    return _listGroupedBy;
}

- (UILabel *)noDataPlaceholderAddHintPrefixLabel {
    if (!_noDataPlaceholderAddHintPrefixLabel) {
        _noDataPlaceholderAddHintPrefixLabel = [UILabel new];
//        _noDataPlaceholderAddHintPrefixLabel.backgroundColor = [UIColor orangeColor];
        _noDataPlaceholderAddHintPrefixLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noDataPlaceholderAddHintPrefixLabel.text = @"Tap ";
    }
    return _noDataPlaceholderAddHintPrefixLabel;
}

- (UILabel *)noDataPlaceholderAddHintSuffixLabel {
    if (!_noDataPlaceholderAddHintSuffixLabel) {
        _noDataPlaceholderAddHintSuffixLabel = [UILabel new];
//        _noDataPlaceholderAddHintSuffixLabel.backgroundColor = [UIColor orangeColor];
        _noDataPlaceholderAddHintSuffixLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSString *l_textTemplate = @" to add %@ %@";
        NSString *l_indefiniteArticle = [[IFAPersistenceManager sharedInstance].entityConfig indefiniteArticleForEntity:self.entityName];
        NSString *l_entityName = [[IFAPersistenceManager sharedInstance].entityConfig labelForEntity:self.entityName].lowercaseString;
        _noDataPlaceholderAddHintSuffixLabel.text = [NSString stringWithFormat:l_textTemplate, l_indefiniteArticle, l_entityName];
    }
    return _noDataPlaceholderAddHintSuffixLabel;
}

- (UIImageView *)noDataPlaceholderAddHintImageView {
    if (!_noDataPlaceholderAddHintImageView) {
        _noDataPlaceholderAddHintImageView = [UIImageView new];
//        _noDataPlaceholderAddHintImageView.backgroundColor = [UIColor blueColor];
        _noDataPlaceholderAddHintImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _noDataPlaceholderAddHintImageView.image = [UIImage imageNamed:@"IFA_Icon_Add"];
    }
    return _noDataPlaceholderAddHintImageView;
}

- (UILabel *)noDataPlaceholderDescriptionLabel {
    if (!_noDataPlaceholderDescriptionLabel) {
        _noDataPlaceholderDescriptionLabel = [UILabel new];
        _noDataPlaceholderDescriptionLabel.numberOfLines = 0;
        _noDataPlaceholderDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noDataPlaceholderDescriptionLabel.textAlignment = NSTextAlignmentCenter;
        if ([self.listViewControllerDataSource respondsToSelector:@selector(noDataPlaceholderDescriptionForListViewController:)]) {
            _noDataPlaceholderDescriptionLabel.text = [self.listViewControllerDataSource noDataPlaceholderDescriptionForListViewController:self];
        }else{
#ifdef IFA_AVAILABLE_Help
            _noDataPlaceholderDescriptionLabel.text = [[IFAHelpManager sharedInstance] emptyListHelpForEntityName:self.entityName];
#endif
        }
    }
    return _noDataPlaceholderDescriptionLabel;
}

#pragma mark - Overrides

-(void)viewDidLoad{

    self.ifa_delegate = self;

    [super viewDidLoad];

    self.shouldReloadTableViewDataAfterQuittingEditing = YES;

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

    [self IFA_configureNoDataPlaceholderView];

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
    [self IFA_updatenoDataPlaceholderViewLayout];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    [self showEmptyListPlaceholder];
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
    if (!self.ifa_changesMadeByPresentedViewController) { // If changes have been made by the presented view controller, then showEmptyListPlaceholder will be called somewhere else
        [self showEmptyListPlaceholder];
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
    cell.textLabel.numberOfLines = 0;   // For dynamic type
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

#ifdef IFA_AVAILABLE_Help

#pragma mark - IFAHelpTarget

- (NSString *)helpTargetId {
    return [[IFAHelpManager sharedInstance] helpTargetIdForEntityNamed:self.entityName];
}

#endif

#pragma mark - IFAViewControllerDelegate

- (void)viewController:(UIViewController *)a_viewController didChangeContentSizeCategory:(NSString *)a_contentSizeCategory {
    [self.ifa_appearanceTheme setTextAppearanceForSelectedContentSizeCategoryInObject:self];
    [self IFA_updateLayoutForDynamicFont];
}

@end

