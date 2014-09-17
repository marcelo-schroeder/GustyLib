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

//wip: review
//static const int k_tipLabelHorizontalMargin = 15;

@interface IFAListViewController ()

@property (nonatomic, strong) dispatch_block_t pagingContainerChildRefreshAndReloadDataAsynchronousBlock;
@property (nonatomic) BOOL refreshAndReloadDataRequested;
@property (nonatomic, strong) NSString *listGroupedBy;
@property(nonatomic, strong) void (^IFA_sectionDataBlock)(NSString *, NSObject *, NSArray *, NSMutableArray *, NSMutableArray *);
@property(nonatomic) BOOL IFA_childManagedObjectContextPushed;
//@property(nonatomic, strong) UILabel *tipLabel;   //wip: clean up
@property(nonatomic, strong) NSLayoutConstraint *IFA_noDataHelpViewCenterYConstraint;
@property (nonatomic, strong) UIView *IFA_noDataHelpAddHintView;
@property (nonatomic, strong) UIView *IFA_noDataHelpView;
@property(nonatomic, strong) UILabel *noDataHelpAddHintPrefixLabel;
@property(nonatomic, strong) UIButton *noDataHelpAddHintButton;
@property(nonatomic, strong) UILabel *noDataHelpAddHintSuffixLabel;
@property(nonatomic, strong) UILabel *noDataHelpTopHintLabel;
@property(nonatomic, strong) UILabel *noDataHelpBottomHintLabel;
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
    //wip: review - clean up
//    self.tipLabel.text = a_text;
//    self.tipLabel.hidden = NO;
    self.IFA_noDataHelpView.hidden = NO;
}

- (BOOL)IFA_shouldRefreshAndReloadDueToStaleDataOnViewAppearance {
    return self.staleData && ![self ifa_isReturningVisibleViewController];
}

//wip: rename "tip" things
- (void)IFA_configureNoDataHelpView {
    [self.tableView addSubview:self.IFA_noDataHelpView];
    [self.IFA_noDataHelpView.superview addConstraint:self.IFA_noDataHelpViewCenterYConstraint];
    UIView *noDataHelpView = self.IFA_noDataHelpView;
    NSDictionary *views = NSDictionaryOfVariableBindings(noDataHelpView);
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=15)-[noDataHelpView]-(>=15)-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:views];
    [noDataHelpView.superview addConstraints:horizontalConstraints];
    [noDataHelpView ifa_addLayoutConstraintToCenterInSuperviewHorizontally];
//wip: review this
//    self.tipLabel.preferredMaxLayoutWidth = self.view.bounds.size.width - k_tipLabelHorizontalMargin * 2;
}

- (NSLayoutConstraint *)IFA_noDataHelpViewCenterYConstraint {
    if (!_IFA_noDataHelpViewCenterYConstraint) {
        _IFA_noDataHelpViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.IFA_noDataHelpView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.IFA_noDataHelpView.superview
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0];
    }
    return _IFA_noDataHelpViewCenterYConstraint;
}

- (void)IFA_updatenoDataHelpViewLayout {
    UIViewController *modelViewController;
    if (!(modelViewController = self.pagingContainerViewController.selectedViewController)) {    // If this is a paging container child, then use the selected view controller to gather layout info from
        modelViewController = self;
    }
    self.IFA_noDataHelpViewCenterYConstraint.constant = -(modelViewController.topLayoutGuide.length + modelViewController.bottomLayoutGuide.length) / 2;
}

- (UIView *)IFA_noDataHelpAddHintView {
    if (!_IFA_noDataHelpAddHintView) {
        _IFA_noDataHelpAddHintView = [UIView new];
//        _IFA_noDataHelpAddHintView.backgroundColor = [UIColor yellowColor];
        _IFA_noDataHelpAddHintView.translatesAutoresizingMaskIntoConstraints = NO;
        [_IFA_noDataHelpAddHintView addSubview:self.noDataHelpAddHintPrefixLabel];
        [_IFA_noDataHelpAddHintView addSubview:self.noDataHelpAddHintButton];
        [_IFA_noDataHelpAddHintView addSubview:self.noDataHelpAddHintSuffixLabel];
        id prefixLabel = self.noDataHelpAddHintPrefixLabel;
        id addButton = self.noDataHelpAddHintButton;
        id suffixLabel = self.noDataHelpAddHintSuffixLabel;
        NSDictionary *views = NSDictionaryOfVariableBindings(prefixLabel, addButton, suffixLabel);
        [_IFA_noDataHelpAddHintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[prefixLabel][addButton(21)][suffixLabel]|"
                                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                                           metrics:nil
                                                                                             views:views]];
//        [self.noDataHelpAddHintButton ifa_addLayoutConstraintsToFillSuperviewVertically]; //wip: clean up
        [_IFA_noDataHelpAddHintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[prefixLabel]-(>=0)-|"
                                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                                    metrics:nil
                                                                                      views:views]];
        [_IFA_noDataHelpAddHintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[addButton(21)]-(>=0)-|"
                                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                                    metrics:nil
                                                                                      views:views]];
        [_IFA_noDataHelpAddHintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[suffixLabel]-(>=0)-|"
                                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                                    metrics:nil
                                                                                      views:views]];
    }
    return _IFA_noDataHelpAddHintView;
}

- (UIView *)IFA_noDataHelpView {
    if (!_IFA_noDataHelpView) {
        _IFA_noDataHelpView = [UIView new];
//        _IFA_noDataHelpView.backgroundColor = [UIColor magentaColor];   //comment out colours
        _IFA_noDataHelpView.translatesAutoresizingMaskIntoConstraints = NO;
        [_IFA_noDataHelpView addSubview:self.noDataHelpTopHintLabel];
        [_IFA_noDataHelpView addSubview:self.IFA_noDataHelpAddHintView];
        [_IFA_noDataHelpView addSubview:self.noDataHelpBottomHintLabel];
        id topView = self.noDataHelpTopHintLabel;
        id centreView = self.IFA_noDataHelpAddHintView;
        id bottomView = self.noDataHelpBottomHintLabel;
        NSDictionary *views = NSDictionaryOfVariableBindings(topView, centreView, bottomView);
        [_IFA_noDataHelpView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView]-30-[centreView]-30-[bottomView]|"
                                                                                    options:NSLayoutFormatAlignAllCenterX
                                                                                    metrics:nil
                                                                                      views:views]];
        [_IFA_noDataHelpView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[topView]-(>=0)-|"
                                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                                    metrics:nil
                                                                                      views:views]];
        [_IFA_noDataHelpView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[centreView]-(>=0)-|"
                                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                                    metrics:nil
                                                                                      views:views]];
        [_IFA_noDataHelpView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=0)-[bottomView]-(>=0)-|"
                                                                                    options:NSLayoutFormatAlignAllCenterY
                                                                                    metrics:nil
                                                                                      views:views]];
    }
    return _IFA_noDataHelpView;
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
    return self.objects.count==0 && self.addBarButtonItem.enabled;
}

//wip: clean up
//-(NSString*)tipTextForEditing:(BOOL)a_editing{
//    NSString *l_textTemplate = @"Tap the '+' button to add %@ %@.";
//    NSString *l_indefiniteArticle = [[IFAPersistenceManager sharedInstance].entityConfig indefiniteArticleForEntity:self.entityName];
//    NSString *l_entityName = [[IFAPersistenceManager sharedInstance].entityConfig labelForEntity:self.entityName];
//    return [NSString stringWithFormat:l_textTemplate, l_indefiniteArticle, l_entityName];
//}

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
//    self.tipLabel.hidden = YES;   //wip: clean up
    self.IFA_noDataHelpView.hidden = YES;
    if ([self shouldShowTipsForEditing:a_editing]) {
//        NSLog(@"showTipWithText for %@", [self description]);
//        NSString *text = [self tipTextForEditing:a_editing];    //wip: review this
        [self IFA_showTipWithText:nil];    //wip: review this (it's sending a nil parameter)
    }
}

- (NSString *)listGroupedBy {
    if (!_listGroupedBy) {
        _listGroupedBy = [[[IFAPersistenceManager sharedInstance] entityConfig] listGroupedByForEntity:self.entityName];
    }
    return _listGroupedBy;
}

//wip: clean up
//- (UILabel *)tipLabel {
//    if (!_tipLabel) {
//        _tipLabel = [UILabel new];
//        _tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        _tipLabel.textAlignment = NSTextAlignmentCenter;
//        _tipLabel.numberOfLines = 0;
//    }
//    return _tipLabel;
//}

- (UILabel *)noDataHelpAddHintPrefixLabel {
    if (!_noDataHelpAddHintPrefixLabel) {
        _noDataHelpAddHintPrefixLabel = [UILabel new];
//        _noDataHelpAddHintPrefixLabel.backgroundColor = [UIColor orangeColor];
        _noDataHelpAddHintPrefixLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noDataHelpAddHintPrefixLabel.text = @"Tap ";
    }
    return _noDataHelpAddHintPrefixLabel;
}

- (UILabel *)noDataHelpAddHintSuffixLabel {
    if (!_noDataHelpAddHintSuffixLabel) {
        _noDataHelpAddHintSuffixLabel = [UILabel new];
//        _noDataHelpAddHintSuffixLabel.backgroundColor = [UIColor orangeColor];
        _noDataHelpAddHintSuffixLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSString *l_textTemplate = @" to add %@ %@";
        NSString *l_indefiniteArticle = [[IFAPersistenceManager sharedInstance].entityConfig indefiniteArticleForEntity:self.entityName];
        NSString *l_entityName = [[IFAPersistenceManager sharedInstance].entityConfig labelForEntity:self.entityName];
        _noDataHelpAddHintSuffixLabel.text = [NSString stringWithFormat:l_textTemplate, l_indefiniteArticle, l_entityName];
    }
    return _noDataHelpAddHintSuffixLabel;
}

- (UIButton *)noDataHelpAddHintButton {
    if (!_noDataHelpAddHintButton) {
        _noDataHelpAddHintButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _noDataHelpAddHintButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_noDataHelpAddHintButton setImage:[UIImage imageNamed:@"IFA_Icon_Add"] forState:UIControlStateNormal];
//        [_noDataHelpAddHintButton ifa_addLayoutConstraintsForSize:CGSizeMake(21, 21)];    //wip: clean up
        [_noDataHelpAddHintButton addTarget:self action:@selector(onAddButtonTap:)
                           forControlEvents:UIControlEventTouchUpInside];
    }
    return _noDataHelpAddHintButton;
}

- (UILabel *)noDataHelpTopHintLabel {
    if (!_noDataHelpTopHintLabel) {
        _noDataHelpTopHintLabel = [UILabel new];
        _noDataHelpTopHintLabel.numberOfLines = 0;
        _noDataHelpTopHintLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noDataHelpTopHintLabel.textAlignment = NSTextAlignmentCenter;
        _noDataHelpTopHintLabel.text = @"This is the top label and let's make it very, very long.\nAnd this is the second line.";   //wip: change me
    }
    return _noDataHelpTopHintLabel;
}

- (UILabel *)noDataHelpBottomHintLabel {
    if (!_noDataHelpBottomHintLabel) {
        _noDataHelpBottomHintLabel = [UILabel new];
        _noDataHelpBottomHintLabel.numberOfLines = 0;
        _noDataHelpBottomHintLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noDataHelpBottomHintLabel.textAlignment = NSTextAlignmentCenter;
        _noDataHelpBottomHintLabel.text = @"This is the bottom label.";   //wip: change me
    }
    return _noDataHelpBottomHintLabel;
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

    [self IFA_configureNoDataHelpView];

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
    [self IFA_updatenoDataHelpViewLayout];
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

