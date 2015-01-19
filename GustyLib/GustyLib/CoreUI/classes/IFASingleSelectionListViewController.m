//
//  IFASingleSelectionListViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 28/07/10.
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

#import "GustyLibCoreUI.h"

@interface IFASingleSelectionListViewController ()

@property(nonatomic, strong) NSManagedObjectID *IFA_editedManagedObjectId;
@property(nonatomic, strong) IFASingleSelectionManager *IFA_selectionManager;

@end

@implementation IFASingleSelectionListViewController {
    
}

#pragma mark - Private

-(void)IFA_updateBackingPreference {
    IFAPersistenceManager *l_pm = [IFAPersistenceManager sharedInstance];
    NSString *l_backingPreferencesProperty = [l_pm.entityConfig backingPreferencesPropertyForEntity:self.entityName];
//    NSLog(@"l_backingPreferencesProperty: %@", l_backingPreferencesProperty);
    if (l_backingPreferencesProperty) {
        NSManagedObjectID *l_selectedMoId = ((NSManagedObject*)[self.IFA_selectionManager selectedObject]).objectID;
        [l_pm pushChildManagedObjectContext];
        NSManagedObject *l_selectedMo = [l_pm findById:l_selectedMoId];
        id l_preferences = [[IFAPreferencesManager sharedInstance] preferences];
        [l_preferences setValue:l_selectedMo forKey:l_backingPreferencesProperty];
        [l_pm save];
        [l_pm saveMainManagedObjectContext];
        [l_pm popChildManagedObjectContext];
    }
}

- (IFASingleSelectionListViewControllerHeaderView *)customHeaderView {
    if (!_customHeaderView) {
        [[NSBundle mainBundle] loadNibNamed:@"IFASingleSelectionListViewControllerHeaderView" owner:self options:nil];
        _customHeaderView.textLabel.text = @"Tap any entry below to select or deselect it";
    }
    return _customHeaderView;
}

- (void)IFA_updateTableHeaderView {
    UIView *view;
    if (self.shouldShowEmptyListPlaceholder) {
        view = nil;
    }else{
        view = self.customHeaderView;
        [self IFA_resizeTableHeaderView];
    }
    self.tableView.tableHeaderView = view;
}

- (void)IFA_resizeTableHeaderView {
    [self.ifa_appearanceTheme setTextAppearanceForSelectedContentSizeCategoryInObject:self.customHeaderView];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.customHeaderView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:self.view.bounds.size.width];
    [self.customHeaderView addConstraint:widthConstraint];
    CGSize sizeThatFits = [self.customHeaderView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [self.customHeaderView removeConstraint:widthConstraint];
    CGRect bounds = CGRectMake(0, 0, sizeThatFits.width, sizeThatFits.height);
    self.customHeaderView.bounds = bounds;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	BOOL selected = [[self.IFA_selectionManager selectedIndexPath] isEqual:indexPath];
	return [self decorateSelectionForCell:cell selected:selected targetObject:[self.IFA_selectionManager selectedObject]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.IFA_selectionManager handleSelectionForIndexPath:indexPath];
}

#pragma mark -
#pragma mark IFASingleSelectionManagerDelegate

- (UITableViewCell*)decorateSelectionForCell:(UITableViewCell*)aCell selected:(BOOL)aSelectedFlag targetObject:(id)aTargetObject{
    aCell.accessoryView = nil;  // Reset the accessory view
	if (aSelectedFlag) {
        UIImage *l_imageNormal = self.selectedIconImageNormal ? self.selectedIconImageNormal : [UIImage imageNamed:[[IFAUtils infoPList] valueForKey:@"IFAThemeSingleSelectionListCheckmarkImageNameNormal"]];
        if (l_imageNormal) {
            UIImage *l_imageHighlighted = self.selectedIconImageHighlighted ? self.selectedIconImageHighlighted : [UIImage imageNamed:[[IFAUtils infoPList] valueForKey:@"IFAThemeSingleSelectionListCheckmarkImageNameHighlighted"]];
            aCell.accessoryView = [[UIImageView alloc] initWithImage:l_imageNormal highlightedImage:l_imageHighlighted];
        }else{
            aCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
	}else {
		aCell.accessoryType = UITableViewCellAccessoryNone;
	}
	return aCell;
}

- (void)onSelection:(id)aSelectedObject deselectedObject:(id)aDeselectedObject indexPath:(NSIndexPath*)anIndexPath userInfo:(NSDictionary *)aUserInfo{
    [self.tableView reloadRowsAtIndexPaths:@[anIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	[self updateUiState];
    [self done];
}

#pragma mark -
#pragma mark Overrides

- (id)initWithManagedObject:(NSManagedObject *)a_managedObject propertyName:(NSString *)a_propertyName
         formViewController:(IFAFormViewController *)a_formViewController {
    if ((self = [super initWithManagedObject:a_managedObject propertyName:a_propertyName
                          formViewController:a_formViewController])){
		self.IFA_selectionManager = [[IFASingleSelectionManager alloc] initWithSelectionManagerDelegate:self
                                                                                 selectedObject:[self.managedObject valueForKey:self.propertyName]];
    }
	return self;
}

- (void)onSelectNoneButtonTap:(id)sender {
	[super onSelectNoneButtonTap:sender];
	[self.IFA_selectionManager deselectAll];
	[self reloadData];
}

- (void)done{
	[super done];
	NSManagedObject *l_previousManagedObject = [self.managedObject valueForKey:self.propertyName];
	BOOL l_valueChanged = [self.IFA_selectionManager selectedObject]!=l_previousManagedObject && ![[self.IFA_selectionManager selectedObject] isEqual:l_previousManagedObject];
    [self.managedObject ifa_setValue:[self.IFA_selectionManager selectedObject] forProperty:self.propertyName];
    [self IFA_updateBackingPreference];
    if (l_valueChanged) {
        [[self ifa_presenter] changesMadeByViewController:self];
    }
    [self ifa_notifySessionCompletionWithChangesMade:l_valueChanged data:nil ];
}

- (void) updateUiState{
	[super updateUiState];
	self.selectNoneButtonItem.enabled = [self.IFA_selectionManager selectedObject] != NULL;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    if ([[IFAPersistenceManager sharedInstance].entityConfig shouldShowAddButtonInSelectionForEntity:self.entityName]) {
        self.addBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeAdd target:self
                                                          action:@selector(onAddButtonTap:)];
        [self ifa_addLeftBarButtonItem:self.addBarButtonItem];
    }
}

-(void)didRefreshAndReloadData {
    [super didRefreshAndReloadData];
    [self showEmptyListPlaceholder];
}

-(NSString *)editFormNameForCreateMode:(BOOL)aCreateMode{
    NSString *l_formName = [super editFormNameForCreateMode:aCreateMode];
    if (aCreateMode) {
        if ([[IFAPersistenceManager sharedInstance].entityConfig containsForm:IFAEntityConfigFormNameCreationShortcut
                                                                   forEntity:self.entityName]) {
            l_formName = IFAEntityConfigFormNameCreationShortcut;
        }
    }
    return l_formName;
}

- (void)setDisallowDeselection:(BOOL)disallowDeselection {
    _disallowDeselection = disallowDeselection;
    self.IFA_selectionManager.disallowDeselection = self.disallowDeselection;
}

- (void)      viewController:(UIViewController *)a_viewController
didChangeContentSizeCategory:(NSString *)a_contentSizeCategory {
    [self IFA_resizeTableHeaderView];
    [super viewController:a_viewController didChangeContentSizeCategory:a_contentSizeCategory];
}

- (void)showEmptyListPlaceholder {
    [super showEmptyListPlaceholder];
    [self IFA_updateTableHeaderView];
}

#pragma mark - IFAPresenter protocol

- (void)sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                       data:(id)a_data shouldAnimateDismissal:(BOOL)a_shouldAnimateDismissal {

    // Make a note of the edited managed object ID before it gets reset by the superclass
    self.IFA_editedManagedObjectId = self.editedManagedObjectId;

    [super sessionDidCompleteForViewController:a_viewController changesMade:a_changesMade data:a_data
                        shouldAnimateDismissal:a_shouldAnimateDismissal];

}

- (void)didDismissViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                              data:(id)a_data {

    [super didDismissViewController:a_viewController changesMade:a_changesMade data:a_data];

    if (self.IFA_editedManagedObjectId) {

        __weak IFASingleSelectionListViewController *l_weakSelf = self;

        // Using the serial queue here will guarantee that the data would have been loaded by the main thread
        [self.ifa_asynchronousWorkManager dispatchSerialBlock:^{

            [IFAUtils dispatchAsyncMainThreadBlock:^{

                NSManagedObject *l_mo = [[IFAPersistenceManager sharedInstance] findById:l_weakSelf.IFA_editedManagedObjectId];
                if (l_mo) { // If nil, it means the object has been discarded

                    NSIndexPath *l_selectedIndexPath = [l_weakSelf indexPathForObject:l_mo];
                    NSAssert(l_selectedIndexPath!= nil, @"Selected index path is nil");
                    [l_weakSelf.tableView selectRowAtIndexPath:l_selectedIndexPath animated:NO
                                                scrollPosition:UITableViewScrollPositionNone];
                    [l_weakSelf.IFA_selectionManager handleSelectionForIndexPath:l_selectedIndexPath];

                }

            }];

        }];

    }

}

@end
