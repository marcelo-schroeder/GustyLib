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

#import "IFACommon.h"

#ifdef IFA_AVAILABLE_Help
#import "UIViewController+IFAHelp.h"
#import "UIView+IFAHelp.h"
#endif

@interface IFASingleSelectionListViewController ()

@property (nonatomic) BOOL IFA_hasInitialLoadBeenDone;

@end

@implementation IFASingleSelectionListViewController {
    
}

#pragma mark - Private

-(void)IFA_updateBackingPreference {
    IFAPersistenceManager *l_pm = [IFAPersistenceManager sharedInstance];
    NSString *l_backingPreferencesProperty = [l_pm.entityConfig backingPreferencesPropertyForEntity:self.entityName];
//    NSLog(@"l_backingPreferencesProperty: %@", l_backingPreferencesProperty);
    if (l_backingPreferencesProperty) {
        NSManagedObjectID *l_selectedMoId = ((NSManagedObject*)[selectionManager selectedObject]).objectID;
        [l_pm pushChildManagedObjectContext];
        NSManagedObject *l_selectedMo = [l_pm findById:l_selectedMoId];
        id l_preferences = [[IFAPreferencesManager sharedInstance] preferences];
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
#ifdef IFA_AVAILABLE_Help
    cell.helpTargetId = [[self ifa_helpTargetIdForName:@"tableCell."] stringByAppendingString:selected?@"selected":@"unselected"];
#endif
	return [self decorateSelectionForCell:cell selected:selected targetObject:[selectionManager selectedObject]];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[selectionManager handleSelectionForIndexPath:indexPath];
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

- (id) initWithManagedObject:(NSManagedObject *)aManagedObject propertyName:(NSString *)aPropertyName{
    if ((self = [super initWithManagedObject:aManagedObject propertyName:aPropertyName])){
		selectionManager = [[IFASingleSelectionManager alloc] initWithSelectionManagerDelegate:self
                                                                                 selectedObject:[self.managedObject valueForKey:self.propertyName]];
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
	NSManagedObject *l_previousManagedObject = [self.managedObject valueForKey:self.propertyName];
	BOOL l_valueChanged = [selectionManager selectedObject]!=l_previousManagedObject && ![[selectionManager selectedObject] isEqual:l_previousManagedObject];
    [self.managedObject ifa_setValue:[selectionManager selectedObject] forProperty:self.propertyName];
    [self IFA_updateBackingPreference];
    if (l_valueChanged) {
        [[self ifa_presenter] changesMadeByViewController:self];
    }
    [self ifa_notifySessionCompletionWithChangesMade:l_valueChanged data:nil ];
}

- (void) updateUiState{
	[super updateUiState];
	self.selectNoneButtonItem.enabled = [selectionManager selectedObject] != NULL;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    if ([[IFAPersistenceManager sharedInstance].entityConfig shouldShowAddButtonInSelectionForEntity:self.entityName]) {
        self.addBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemAdd target:self
                                                          action:@selector(onAddButtonTap:)];
        [self ifa_addLeftBarButtonItem:self.addBarButtonItem];
    }
}

-(void)didRefreshAndReloadDataAsync {
    [super didRefreshAndReloadDataAsync];
    if (self.IFA_hasInitialLoadBeenDone) {
        [self showTipForEditing:NO];
    }else{
        if (self.entities.count==0) {
            [self showCreateManagedObjectForm];
        }
        self.IFA_hasInitialLoadBeenDone = YES;
    }
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
    selectionManager.disallowDeselection = self.disallowDeselection;
}

#pragma mark - IFAPresenter protocol

- (void)didDismissViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                              data:(id)a_data {
    
    // Make a note of the edited managed object ID before it gets reset by the superclass
    NSManagedObjectID *l_editedManagedObjectId = self.editedManagedObjectId;

    [super didDismissViewController:a_viewController changesMade:a_changesMade data:a_data];
    
    if (l_editedManagedObjectId) {
        
        __weak IFASingleSelectionListViewController *l_weakSelf = self;
        
        // Using the serial queue here will guarantee that the data would have been loaded by the main thread
        [self.ifa_asynchronousWorkManager dispatchSerialBlock:^{

            [IFAUtils dispatchAsyncMainThreadBlock:^{

                NSManagedObject *l_mo = [[IFAPersistenceManager sharedInstance] findById:l_editedManagedObjectId];
                if (l_mo) { // If nil, it means the object has been discarded

                    NSUInteger l_selectedSection = NSNotFound;
                    NSUInteger l_selectedRow = NSNotFound;
                    NSUInteger l_section = 0;
                    for (NSArray *l_rows in l_weakSelf.sectionsWithRows) {
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
