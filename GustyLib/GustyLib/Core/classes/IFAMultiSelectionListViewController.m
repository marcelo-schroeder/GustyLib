//
//  IFAMultiSelectionListViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 10/01/11.
//  Copyright 2011 InfoAccent Pty Limited. All rights reserved.
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

#import "GustyLib.h"

#ifdef IFA_AVAILABLE_Help
#import "UIViewController+IFAHelp.h"
#import "UIView+IFAHelp.h"
#endif

enum {
	
    ACTION_SHEET_TAG_SELECT_NONE	= 100,
    ACTION_SHEET_TAG_SELECT_ALL		= 101,
	
};

@interface IFAMultiSelectionListViewController ()

@property(nonatomic, strong) NSString *IFA_destinationEntityName;
@property(nonatomic, strong) NSArray *IFA_destinationEntities;
@property(nonatomic, strong) NSMutableArray *IFA_selectedDestinationEntities;
@property(nonatomic, strong) NSMutableArray *IFA_unselectedDestinationEntities;
@property(nonatomic, strong) NSString *IFA_originRelationshipName;
@property(nonatomic, strong) NSString *IFA_destinationRelationshipName;
@property(nonatomic, strong) UIBarButtonItem *IFA_selectAllButtonItem;
@property(nonatomic, strong) UIBarButtonItem *IFA_flexSpaceButtonItem;
@property(nonatomic, strong) NSMutableArray *IFA_originalSortedEntities;
@property(nonatomic) BOOL IFA_isJoinEntity;
@end

@implementation IFAMultiSelectionListViewController

#pragma mark - Private

- (BOOL)IFA_isSelectedOptionsSection:(NSInteger)a_section{
	NSInteger l_numberOfSections = [self numberOfSectionsInTableView:self.tableView];
	if (l_numberOfSections==2) {	// If both arrays (selected & unselected) are not empty, then the "selected" section is the first one
		return a_section==0;
	}else {	// otherwise, it is the "selected" section only if the selected array is not empty
		return a_section==0 && [self.IFA_selectedDestinationEntities count]>0;
	}
}

- (void)IFA_onSelectAllButtonTap:(id)sender{
	[IFAUIUtils showActionSheetWithMessage:@"Are you sure you want to select all options available?"
              destructiveButtonLabelSuffix:@"select all"
                            viewController:self
                             barButtonItem:nil
                                  delegate:self
                                       tag:ACTION_SHEET_TAG_SELECT_ALL];
}

- (void)IFA_selectNone {
    [self IFA_handleUserSelectionForManagedObjects:[NSArray arrayWithArray:self.IFA_selectedDestinationEntities] isAdding:NO];
}

- (void)IFA_selectAll {
    [self IFA_handleUserSelectionForManagedObjects:[NSArray arrayWithArray:self.IFA_unselectedDestinationEntities]
                                          isAdding:YES];
}

- (BOOL)IFA_hasValueChanged {
	
	if ([self.IFA_originalSortedEntities count]==[self.IFA_selectedDestinationEntities count]) {
		for (NSUInteger i = 0; i < [self.IFA_originalSortedEntities count]; i++) {
            @autoreleasepool {
                NSManagedObject *l_originalManagedObject = [self.IFA_originalSortedEntities objectAtIndex:i];
                NSManagedObject *l_selectedDestinationManagedObject = [self.IFA_selectedDestinationEntities objectAtIndex:i];
                NSManagedObject *l_originalDestinationManagedObject;
                if (self.IFA_isJoinEntity) {
                    l_originalDestinationManagedObject = [l_originalManagedObject valueForKey:self.IFA_destinationRelationshipName];
                }else {
                    l_originalDestinationManagedObject = l_originalManagedObject;
                }
                if (![l_originalDestinationManagedObject isEqual:l_selectedDestinationManagedObject]) {
                    //                NSLog(@"value DID change 1");
                    return YES;
                }
            }
		}
        //        NSLog(@"value did NOT change");
		return NO;
	}else {
        //        NSLog(@"value DID change 2");
		return YES;
	}
	
}

- (void)IFA_handleUserSelectionForManagedObjects:(NSArray *)a_managedObjects isAdding:(BOOL)a_isAdding{
	
	BOOL l_selectedSectionVisibleBefore = [self.IFA_selectedDestinationEntities count]>0;
	BOOL l_unselectedSectionVisibleBefore = [self.IFA_unselectedDestinationEntities count]>0;
	BOOL l_selectedSectionVisibleAfter;
	BOOL l_unselectedSectionVisibleAfter;
	
	// Determine index paths to delete
	NSMutableArray *l_indexPathsToDelete = [NSMutableArray array];
	for (NSManagedObject *l_managedObject in a_managedObjects) {
        
		@autoreleasepool {
            
			NSIndexPath *l_indexPathToDelete;
			if (a_isAdding) {	// Is it adding to the selection list?
				l_indexPathToDelete = [NSIndexPath indexPathForRow:[self.IFA_unselectedDestinationEntities indexOfObject:l_managedObject] 
														 inSection:l_selectedSectionVisibleBefore?1:0];
				[self.IFA_selectedDestinationEntities addObject:l_managedObject];
			}else {	// no, then it must be deleting from the selection list
				l_indexPathToDelete = [NSIndexPath indexPathForRow:[self.IFA_selectedDestinationEntities indexOfObject:l_managedObject] 
														 inSection:0];
				[self.IFA_unselectedDestinationEntities addObject:l_managedObject];
			}
			
			[l_indexPathsToDelete addObject:l_indexPathToDelete];
            
		}
        
	}
	
	if (a_isAdding) {
        
		// Delete selected objects in the target array
		[self.IFA_unselectedDestinationEntities removeObjectsInArray:a_managedObjects];
		
		// Re-order array with inserted objects
		if(!self.IFA_isJoinEntity){
			// Re-order array of selected managed objects
			NSArray *l_sortDescriptors = [[IFAPersistenceManager sharedInstance] listSortDescriptorsForEntity:self.IFA_destinationEntityName];
			NSArray *sortedArray = [self.IFA_selectedDestinationEntities sortedArrayUsingDescriptors:l_sortDescriptors];
			NSMutableArray *l_newSelectedDestinationEntities = [NSMutableArray arrayWithArray:sortedArray];
			self.IFA_selectedDestinationEntities = l_newSelectedDestinationEntities;
		}
		
	}else {
		
		// Delete selected objects in the target array
		[self.IFA_selectedDestinationEntities removeObjectsInArray:a_managedObjects];
		
		// Re-order array with inserted objects
		NSArray *l_sortDescriptors = [[IFAPersistenceManager sharedInstance] listSortDescriptorsForEntity:self.IFA_destinationEntityName];
		NSArray *sortedArray = [self.IFA_unselectedDestinationEntities sortedArrayUsingDescriptors:l_sortDescriptors];
		NSMutableArray *l_newUnselectedDestinationEntities = [NSMutableArray arrayWithArray:sortedArray];
		self.IFA_unselectedDestinationEntities = l_newUnselectedDestinationEntities;
        
	}
	
	// Update visibility flags
	l_selectedSectionVisibleAfter = [self.IFA_selectedDestinationEntities count]>0;
	l_unselectedSectionVisibleAfter = [self.IFA_unselectedDestinationEntities count]>0;
	
	// Determine index paths to insert
	NSMutableArray *l_indexPathsToInsert = [NSMutableArray array];
	for (NSManagedObject *l_managedObject in a_managedObjects) {
		@autoreleasepool {
			NSIndexPath *l_indexPathToInsert;
			if (a_isAdding) {
				l_indexPathToInsert = [NSIndexPath indexPathForRow:[self.IFA_selectedDestinationEntities indexOfObject:l_managedObject] 
														 inSection:0];
			}else {
				l_indexPathToInsert = [NSIndexPath indexPathForRow:[self.IFA_unselectedDestinationEntities indexOfObject:l_managedObject] 
														 inSection:l_selectedSectionVisibleAfter?1:0];
			}
			[l_indexPathsToInsert addObject:l_indexPathToInsert];
		}
	}
	
	[self.tableView beginUpdates];
	
	// Perform table view delete's - this is done with original indexes
	//NSLog(@"l_indexPathsToDelete count: %lu", (unsigned long)[l_indexPathsToDelete count]);
	[self.tableView deleteRowsAtIndexPaths:l_indexPathsToDelete 
						  withRowAnimation:UITableViewRowAnimationAutomatic];
	if (l_selectedSectionVisibleBefore && !l_selectedSectionVisibleAfter) {
		//NSLog(@"Deleting section 0");
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] 
					  withRowAnimation:UITableViewRowAnimationAutomatic];
	}else if (l_unselectedSectionVisibleBefore && !l_unselectedSectionVisibleAfter) {
		//NSLog(@"Deleting section 1");
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:l_selectedSectionVisibleBefore?1:0] 
					  withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	
	// Perform table view insert's - this is done with updated indexes
	//NSLog(@"l_indexPathsToInsert count: %lu", (unsigned long)[l_indexPathsToInsert count]);
	[self.tableView insertRowsAtIndexPaths:l_indexPathsToInsert 
						  withRowAnimation:UITableViewRowAnimationAutomatic];
	if (!l_selectedSectionVisibleBefore && l_selectedSectionVisibleAfter) {
		//NSLog(@"Inserting section 0");
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] 
					  withRowAnimation:UITableViewRowAnimationAutomatic];
	}else if (!l_unselectedSectionVisibleBefore && l_unselectedSectionVisibleAfter) {
		//NSLog(@"Inserting section 1");
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:l_selectedSectionVisibleAfter?1:0] 
					  withRowAnimation:UITableViewRowAnimationAutomatic];
	}
	
	[self.tableView endUpdates];

    [self IFA_updateModel];
	[self updateUiState];
	
}

-(void)IFA_updateModel {
    
    if (self.IFA_isJoinEntity) {
        
        //            NSLog(@"IS join entity");
        
        // Firstly, delete the managed objects in the original set
        for (NSManagedObject *l_managedObject in self.IFA_originalSortedEntities) {
//            NSLog(@"deleting managed object: %@", l_managedObject);
            [l_managedObject ifa_delete];
        }
        
        //            NSLog(@"hasChanges1: %u", [IFAPersistenceManager sharedInstance].managedObjectContext.hasChanges);
        
        // Secondly, add the managed objects in the new set
        [self.IFA_originalSortedEntities removeAllObjects];
        NSUInteger l_seq = 0;
        for (NSManagedObject *l_selectedDestinationManagedObject in self.IFA_selectedDestinationEntities) {
            NSManagedObject *l_managedObject = [[IFAPersistenceManager sharedInstance] instantiate:self.entityName];
            [l_managedObject setValue:self.managedObject forKey:self.IFA_originRelationshipName];
            [l_managedObject setValue:l_selectedDestinationManagedObject forKey:self.IFA_destinationRelationshipName];
            [l_managedObject setValue:[NSNumber numberWithInt:l_seq++] forKey:@"seq"];
            [self.IFA_originalSortedEntities addObject:l_managedObject];
//            NSLog(@"inserted managed object: %@", l_managedObject);
        }
        
        // Mark object being edited as dirty
        [IFAPersistenceManager sharedInstance].isCurrentManagedObjectDirty = YES;
        
        //            NSLog(@"hasChanges2: %u", [IFAPersistenceManager sharedInstance].managedObjectContext.hasChanges);
        
    }else {
        
        //            NSLog(@"is NOT join entity");
        
        // Firstly, empty the set
        //			NSLog(@"propertyName: %@", propertyName);
        NSMutableSet *l_set = [self.managedObject mutableSetValueForKey:self.propertyName];
        [l_set removeAllObjects];
        
        // Secondly, add the managed objects in the new set
        [l_set addObjectsFromArray:self.IFA_selectedDestinationEntities];
        
        // Mark object being edited as dirty
        [IFAPersistenceManager sharedInstance].isCurrentManagedObjectDirty = YES;
        
    }

    [[self ifa_presenter] changesMadeByViewController:self];
    
}

#pragma mark -
#pragma mark Overrides

-(id) initWithManagedObject:(NSManagedObject *)aManagedObject propertyName:(NSString *)aPropertyName{
	
	if((self=[super initWithManagedObject:aManagedObject propertyName:aPropertyName])){
		
		// First determine whether this controller is managing a pure many-to-many relationship or one which uses a join table
		NSDictionary *l_parentRelationshipDictionary = [[IFAPersistenceManager sharedInstance].entityConfig relationshipDictionaryForEntity:[self.managedObject ifa_entityName]];
		NSRelationshipDescription *l_parentRelationship = [l_parentRelationshipDictionary valueForKey:self.propertyName];
		self.IFA_isJoinEntity = ! [[l_parentRelationship inverseRelationship] isToMany];

		if (self.IFA_isJoinEntity) {
			
			// Determine destination entity in the many-to-many relationship
			NSDictionary *l_relationshipDictionary = [[IFAPersistenceManager sharedInstance].entityConfig relationshipDictionaryForEntity:self.entityName];
			NSArray *l_relationshipNames = [l_relationshipDictionary allKeys];
			for (NSString *l_relationshipName in l_relationshipNames) {
				@autoreleasepool {
					NSRelationshipDescription *l_relationship = [l_relationshipDictionary valueForKey:l_relationshipName];
					NSEntityDescription *l_destinationEntity = [l_relationship destinationEntity];
					if ([[self.managedObject ifa_entityName] isEqualToString:[l_destinationEntity name]]) {
						self.IFA_originRelationshipName = l_relationshipName;
					}else {
						// Assume that there is only one destination to-many relationship for the moment
						self.IFA_destinationRelationshipName = l_relationshipName;
						self.IFA_destinationEntityName = [l_destinationEntity name];
					}
				}
			}

		}else {

			self.IFA_originRelationshipName = nil;	// not used in this case
			self.IFA_destinationRelationshipName = nil;	// not used in this case
			self.IFA_destinationEntityName = self.entityName;
			
		}
		
		// Retrieve destination entity instances
		self.IFA_destinationEntities = [[IFAPersistenceManager sharedInstance] findAllForEntity:self.IFA_destinationEntityName];
		
		// All destination entity instances become unselected instances to start with
		self.IFA_unselectedDestinationEntities = [NSMutableArray arrayWithArray:self.IFA_destinationEntities];
		self.IFA_selectedDestinationEntities = [NSMutableArray array];
		
		// Now load the selected entity instances
		NSArray *l_sortDescriptors = [[IFAPersistenceManager sharedInstance] listSortDescriptorsForEntity:self.entityName];
		self.IFA_originalSortedEntities = [NSMutableArray arrayWithArray:[[((NSSet*) [self.managedObject valueForKey:self.propertyName]) allObjects] sortedArrayUsingDescriptors:l_sortDescriptors]];
		for (NSManagedObject *l_managedObject in self.IFA_originalSortedEntities) {
			@autoreleasepool {
				NSManagedObject *l_destinationManagedObject;
				if (self.IFA_isJoinEntity) {
					l_destinationManagedObject = [l_managedObject valueForKey:self.IFA_destinationRelationshipName];
				}else {
					l_destinationManagedObject = l_managedObject;
				}
				[self.IFA_selectedDestinationEntities addObject:l_destinationManagedObject];
				[self.IFA_unselectedDestinationEntities removeObject:l_destinationManagedObject];
			}
		}
		
		self.IFA_flexSpaceButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemFlexibleSpace target:self
                                                          action:nil];
		self.IFA_selectAllButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemSelectAll target:self
                                                          action:@selector(IFA_onSelectAllButtonTap:)];
		self.editing = YES;
		
	}
	
	return self;
	
}

- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
	
}

-(void)IFA_onDeleteButtonAction:(UIButton*)a_button{
    UITableViewCell *l_cell = (UITableViewCell*)a_button.superview;
    [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[self.tableView indexPathForCell:l_cell]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * const k_cellId = @"Cell";
    static NSUInteger const k_deleteButtonTag = 1;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:k_cellId];
    if (cell == nil) {

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:k_cellId];

        // See cell appearance
        [[self ifa_appearanceTheme] setAppearanceForView:cell.textLabel];

        // Add custom delete button (hidden for now)
        UIButton *l_deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *l_deleteButtonImageName = @"deleteButton_normal";
        UIImage *l_deleteButtonImage = [UIImage imageNamed:l_deleteButtonImageName];
        [l_deleteButton setImage:l_deleteButtonImage forState:UIControlStateNormal];
        [l_deleteButton setImage:l_deleteButtonImage forState:UIControlStateHighlighted];
        [l_deleteButton addTarget:self action:@selector(IFA_onDeleteButtonAction:)
                 forControlEvents:UIControlEventTouchUpInside];
        l_deleteButton.frame = CGRectMake(7, 9, l_deleteButtonImage.size.width, l_deleteButtonImage.size.height);
        l_deleteButton.hidden = YES;
        l_deleteButton.tag = k_deleteButtonTag;
        [cell addSubview:l_deleteButton];

    }
    
    // Set up the cell...
	NSManagedObject *managedObject;
    UIView *l_deleteButtonView = [cell viewWithTag:k_deleteButtonTag];
	if ([self IFA_isSelectedOptionsSection:indexPath.section]) {
		managedObject = [self.IFA_selectedDestinationEntities objectAtIndex:(NSUInteger) indexPath.row];
        l_deleteButtonView.hidden = NO;
	}else {
		managedObject = [self.IFA_unselectedDestinationEntities objectAtIndex:(NSUInteger) indexPath.row];
        l_deleteButtonView.hidden = YES;
	}
	cell.textLabel.text = [managedObject ifa_longDisplayValue];
#ifdef IFA_AVAILABLE_Help
    cell.helpTargetId = [[self ifa_helpTargetIdForName:@"tableCell."] stringByAppendingString:indexPath.section==0?@"selected":@"unselected"];
#endif

    return cell;

}

- (NSArray*)ifa_editModeToolbarItems {
	return @[self.selectNoneButtonItem, self.IFA_flexSpaceButtonItem, self.IFA_selectAllButtonItem];
}

-(void)done{
	
    BOOL l_valueChanged = [self IFA_hasValueChanged];
    [self ifa_notifySessionCompletionWithChangesMade:l_valueChanged data:nil ];

}

- (void)onSelectNoneButtonTap:(id)sender {
	[IFAUIUtils showActionSheetWithMessage:@"Are you sure you want to deselect your choices?"
              destructiveButtonLabelSuffix:@"deselect"
                            viewController:self
                             barButtonItem:nil
                                  delegate:self
                                       tag:ACTION_SHEET_TAG_SELECT_NONE];
}

- (void) updateUiState{
	[super updateUiState];
	self.selectNoneButtonItem.enabled = [self.IFA_selectedDestinationEntities count]>0;
	self.IFA_selectAllButtonItem.enabled = [self.IFA_unselectedDestinationEntities count]>0;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    // Disable user interaction while data is being refreshed asynchronously
    self.IFA_selectAllButtonItem.enabled = NO;
    
}

#pragma mark -
#pragma mark UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	if ([self IFA_isSelectedOptionsSection:indexPath.section]) {
		return UITableViewCellEditingStyleNone;
	}else {
		return UITableViewCellEditingStyleInsert;
	}
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    if (proposedDestinationIndexPath.section==1) {
        // Prevent user from dropping the cell in the "unselected" section
        return [NSIndexPath indexPathForRow:[self tableView:self.tableView numberOfRowsInSection:0]-1 inSection:0];
    }else{
        return proposedDestinationIndexPath;
    }
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
	NSInteger l_numberOfSections = 0;
	if ([self.IFA_selectedDestinationEntities count]>0) {
		l_numberOfSections++;
	}
	if ([self.IFA_unselectedDestinationEntities count]>0) {
		l_numberOfSections++;
	}
	return l_numberOfSections;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if ([self IFA_isSelectedOptionsSection:section]) {
		return [self.IFA_selectedDestinationEntities count];
	}else {
		return [self.IFA_unselectedDestinationEntities count];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	NSArray *l_managedObjects;
	if (editingStyle==UITableViewCellEditingStyleInsert) {
		l_managedObjects = @[[self.IFA_unselectedDestinationEntities objectAtIndex:(NSUInteger) indexPath.row]];
	}else {
		l_managedObjects = @[[self.IFA_selectedDestinationEntities objectAtIndex:(NSUInteger) indexPath.row]];
	}
    [self IFA_handleUserSelectionForManagedObjects:l_managedObjects
                                          isAdding:editingStyle == UITableViewCellEditingStyleInsert];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
	return self.IFA_isJoinEntity && [self IFA_isSelectedOptionsSection:indexPath.section];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{

	NSManagedObject *fromManagedObject = [self.IFA_selectedDestinationEntities objectAtIndex:(NSUInteger) fromIndexPath.row];
	NSManagedObject *toManagedObject = [self.IFA_selectedDestinationEntities objectAtIndex:(NSUInteger) toIndexPath.row];
    [self.IFA_selectedDestinationEntities replaceObjectAtIndex:(NSUInteger) toIndexPath.row withObject:fromManagedObject];
    [self.IFA_selectedDestinationEntities replaceObjectAtIndex:(NSUInteger) fromIndexPath.row withObject:toManagedObject];
    [self IFA_updateModel];

    [self reloadMovedCellAtIndexPath:toIndexPath];

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [self IFA_isSelectedOptionsSection:section] ? @"Selected entries" : @"Available entries";
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch (actionSheet.tag) {
		case ACTION_SHEET_TAG_SELECT_NONE:
			if(buttonIndex==0){
                [self IFA_selectNone];
			}
			break;
		case ACTION_SHEET_TAG_SELECT_ALL:
			if(buttonIndex==0){
                [self IFA_selectAll];
			}
			break;
		default:
			NSAssert(NO, @"Unexpected action sheet tag: %u", actionSheet.tag);
			break;
	}
}

@end