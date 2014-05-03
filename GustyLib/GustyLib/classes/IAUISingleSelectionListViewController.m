//
//  IAUISingleSelectionListViewController.m
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

#import "IACommon.h"

@interface IAUISingleSelectionListViewController ()

@property (nonatomic) BOOL p_hasInitialLoadBeenDone;

@end

@implementation IAUISingleSelectionListViewController{
    
}

#pragma mark - Private

-(void)m_updateBackingPreference{
    IAPersistenceManager *l_pm = [IAPersistenceManager sharedInstance];
    NSString *l_backingPreferencesProperty = [l_pm.entityConfig backingPreferencesPropertyForEntity:self.entityName];
//    NSLog(@"l_backingPreferencesProperty: %@", l_backingPreferencesProperty);
    if (l_backingPreferencesProperty) {
        NSManagedObjectID *l_selectedMoId = ((NSManagedObject*)[selectionManager selectedObject]).objectID;
        [l_pm pushChildManagedObjectContext];
        NSManagedObject *l_selectedMo = [l_pm findById:l_selectedMoId];
        id l_preferences = [[IAPreferencesManager sharedInstance] preferences];
        [l_preferences setValue:l_selectedMo forKey:l_backingPreferencesProperty];
        [l_pm save];
        [l_pm saveMainManagedObjectContext];
        [l_pm popChildManagedObjectContext];
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	BOOL selected = [[selectionManager selectedIndexPath] isEqual:indexPath];
    cell.p_helpTargetId = [[self m_helpTargetIdForName:@"tableCell."] stringByAppendingString:selected?@"selected":@"unselected"];
	return [self decorateSelectionForCell:cell selected:selected targetObject:[selectionManager selectedObject]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[selectionManager handleSelectionForIndexPath:indexPath];
}

#pragma mark -
#pragma mark IAUISingleSelectionManagerDelegate

- (UITableViewCell*)decorateSelectionForCell:(UITableViewCell*)aCell selected:(BOOL)aSelectedFlag targetObject:(id)aTargetObject{
    aCell.accessoryView = nil;  // Reset the accessory view
	if (aSelectedFlag) {
        UIImage *l_imageNormal = self.p_selectedIconImageNormal ? self.p_selectedIconImageNormal : [UIImage imageNamed:[[IAUtils infoPList] valueForKey:@"IAUIThemeSingleSelectionListCheckmarkImageNameNormal"]];
        if (l_imageNormal) {
            UIImage *l_imageHighlighted = self.p_selectedIconImageHighlighted ? self.p_selectedIconImageHighlighted : [UIImage imageNamed:[[IAUtils infoPList] valueForKey:@"IAUIThemeSingleSelectionListCheckmarkImageNameHighlighted"]];
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

- (id) initWithManagedObject:(NSManagedObject *)aManagedObject propertyName:(NSString *)aPropertyName{
    if ((self = [super initWithManagedObject:aManagedObject propertyName:aPropertyName])){
		selectionManager = [[IAUISingleSelectionManager alloc] initWithSelectionManagerDelegate:self
                                                                                 selectedObject:[self.p_managedObject valueForKey:self.p_propertyName]];
    }
	return self;
}

- (void)onSelectNoneButtonTap:(id)sender {
	[super onSelectNoneButtonTap:sender];
	[selectionManager deselectAll];
	[self reloadData];
}

- (void)done{
	[super done];
	NSManagedObject *l_previousManagedObject = [self.p_managedObject valueForKey:self.p_propertyName];
	BOOL l_valueChanged = [selectionManager selectedObject]!=l_previousManagedObject && ![[selectionManager selectedObject] isEqual:l_previousManagedObject];
    [self.p_managedObject setValue:[selectionManager selectedObject] forProperty:self.p_propertyName];
    [self m_updateBackingPreference];
    if (l_valueChanged) {
        [[self p_presenter] m_changesMadeByViewController:self];
    }
    [self m_notifySessionCompletionWithChangesMade:l_valueChanged data:nil ];
}

- (void) updateUiState{
	[super updateUiState];
	self.p_selectNoneButtonItem.enabled = [selectionManager selectedObject] != NULL;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    if ([[IAPersistenceManager sharedInstance].entityConfig shouldShowAddButtonInSelectionForEntity:self.entityName]) {
        self.p_addBarButtonItem = [IAUIUtils barButtonItemForType:IA_UIBAR_BUTTON_ITEM_ADD target:self action:@selector(onAddButtonTap:)];
        [self m_addLeftBarButtonItem:self.p_addBarButtonItem];
    }
}

-(void)didRefreshAndReloadDataAsync {
    [super didRefreshAndReloadDataAsync];
    if (self.p_hasInitialLoadBeenDone) {
        [self showTipForEditing:NO];
    }else{
        if (self.p_entities.count==0) {
            [self showCreateManagedObjectForm];
        }
        self.p_hasInitialLoadBeenDone = YES;
    }
}

-(NSString *)editFormNameForCreateMode:(BOOL)aCreateMode{
    NSString *l_formName = [super editFormNameForCreateMode:aCreateMode];
    if (aCreateMode) {
        if ([[IAPersistenceManager sharedInstance].entityConfig containsForm:IA_ENTITY_CONFIG_FORM_NAME_CREATION_SHORTCUT forEntity:self.entityName]) {
            l_formName = IA_ENTITY_CONFIG_FORM_NAME_CREATION_SHORTCUT;
        }
    }
    return l_formName;
}

- (void)setP_disallowDeselection:(BOOL)p_disallowDeselection {
    _p_disallowDeselection = p_disallowDeselection;
    selectionManager.p_disallowDeselection = self.p_disallowDeselection;
}

#pragma mark - IAUIPresenter protocol

- (void)m_didDismissViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                              data:(id)a_data {
    
    // Make a note of the edited managed object ID before it gets reset by the superclass
    NSManagedObjectID *l_editedManagedObjectId = self.p_editedManagedObjectId;
    
    [super m_didDismissViewController:a_viewController changesMade:a_changesMade data:a_data];
    
    if (l_editedManagedObjectId) {
        
        __weak IAUISingleSelectionListViewController *l_weakSelf = self;
        
        // Using the serial queue here will guarantee that the data would have been loaded by the main thread
        [self.p_aom dispatchSerialBlock:^{

            [IAUtils m_dispatchAsyncMainThreadBlock:^{

                NSManagedObject *l_mo = [[IAPersistenceManager sharedInstance] findById:l_editedManagedObjectId];
                if (l_mo) { // If nil, it means the object has been discarded

                    NSUInteger l_selectedSection = NSNotFound;
                    NSUInteger l_selectedRow = NSNotFound;
                    NSUInteger l_section = 0;
                    for (NSArray *l_rows in l_weakSelf.p_sectionsWithRows) {
                        if ([l_rows containsObject:l_mo]) {
                            l_selectedSection = l_section;
                            l_selectedRow = [l_rows indexOfObject:l_mo];
                            break;
                        }
                        l_section++;
                    }
                    NSAssert(l_selectedSection != NSNotFound, @"l_selectedSection is NSNotFound");
                    NSAssert(l_selectedRow != NSNotFound, @"l_selectedRow is NSNotFound");
                    NSIndexPath *l_selectedIndexPath = [NSIndexPath indexPathForRow:l_selectedRow
                                                                          inSection:l_selectedSection];
                    [l_weakSelf.tableView selectRowAtIndexPath:l_selectedIndexPath animated:NO
                                                scrollPosition:UITableViewScrollPositionNone];
                    [selectionManager handleSelectionForIndexPath:l_selectedIndexPath];

                }

            }];

        }];
        
    }

}

@end
