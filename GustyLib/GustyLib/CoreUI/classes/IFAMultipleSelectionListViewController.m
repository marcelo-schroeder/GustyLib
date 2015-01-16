//
//  IFAMultipleSelectionListViewController.m
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

#import "GustyLibCoreUI.h"
#import "NSMutableArray+IFACoreUI.h"

static NSString *const k_cellReuseId = @"cell";

static const NSUInteger k_sectionSelectedObjects = 0;

@interface IFAMultipleSelectionListViewController ()

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

@implementation IFAMultipleSelectionListViewController

#pragma mark - Private

- (void)IFA_onSelectAllButtonTap:(id)sender{
    [self IFA_selectAll];
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
                NSManagedObject *l_originalManagedObject = (self.IFA_originalSortedEntities)[i];
                NSManagedObject *l_selectedDestinationManagedObject = (self.IFA_selectedDestinationEntities)[i];
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

	// Determine index paths to delete
	NSMutableArray *l_indexPathsToDelete = [NSMutableArray array];
	for (NSManagedObject *l_managedObject in a_managedObjects) {
		@autoreleasepool {
			NSIndexPath *l_indexPathToDelete;
			if (a_isAdding) {	// Is it adding to the selection list?
				l_indexPathToDelete = [NSIndexPath indexPathForRow:[self.IFA_unselectedDestinationEntities indexOfObject:l_managedObject]
														 inSection:1];
				[self.IFA_selectedDestinationEntities addObject:l_managedObject];
			}else {	// no, then it must be deleting from the selection list
				l_indexPathToDelete = [NSIndexPath indexPathForRow:[self.IFA_selectedDestinationEntities indexOfObject:l_managedObject]
														 inSection:0];
				[self.IFA_unselectedDestinationEntities addObject:l_managedObject];
			}
			[l_indexPathsToDelete addObject:l_indexPathToDelete];
		}
	}

    // Update model
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
														 inSection:1];
			}
			[l_indexPathsToInsert addObject:l_indexPathToInsert];
		}
	}

    // Schedule table view row updates
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{

        // Update cell state after the move (e.g. the remove button needs to turn into an add button (or vice-versa), cell separators may be incorrect after the move, so this fix them up)
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]
                      withRowAnimation:UITableViewRowAnimationNone];

        BOOL l_shouldScrollToTop = !self.IFA_selectedDestinationEntities.count || !self.IFA_unselectedDestinationEntities.count;
        if (l_shouldScrollToTop) {
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1)
                                       animated:YES];
        }

		// Workaround for Apple bug report #19289969
		self.editing = NO;
		self.editing = YES;


	}];
    [self.tableView beginUpdates];
    for (NSUInteger i = 0; i < a_managedObjects.count; ++i) {
        NSIndexPath *l_fromIndexPath = l_indexPathsToDelete[i];
        NSIndexPath *l_toIndexPath = l_indexPathsToInsert[i];
        [self.tableView moveRowAtIndexPath:l_fromIndexPath toIndexPath:l_toIndexPath];
    }
    [self.tableView endUpdates];
    [CATransaction commit];

    [self IFA_updateModel];
    [self updateUiState];

}

-(void)IFA_updateModel {

    if (self.IFA_isJoinEntity) {

        //            NSLog(@"IS join entity");

        // Firstly, delete the managed objects in the original set
        for (NSManagedObject *l_managedObject in self.IFA_originalSortedEntities) {
//            NSLog(@"deleting managed object: %@", l_managedObject);
            [l_managedObject ifa_deleteWithValidationAlertPresenter:self];
        }

        //            NSLog(@"hasChanges1: %u", [IFAPersistenceManager sharedInstance].managedObjectContext.hasChanges);

        // Secondly, add the managed objects in the new set
        [self.IFA_originalSortedEntities removeAllObjects];
        NSUInteger l_seq = 0;
        for (NSManagedObject *l_selectedDestinationManagedObject in self.IFA_selectedDestinationEntities) {
            NSManagedObject *l_managedObject = [[IFAPersistenceManager sharedInstance] instantiate:self.entityName];
            [l_managedObject setValue:self.managedObject forKey:self.IFA_originRelationshipName];
            [l_managedObject setValue:l_selectedDestinationManagedObject forKey:self.IFA_destinationRelationshipName];
            [l_managedObject setValue:@(l_seq++) forKey:@"seq"];
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

- (id)initWithManagedObject:(NSManagedObject *)a_managedObject propertyName:(NSString *)a_propertyName
         formViewController:(IFAFormViewController *)a_formViewController {

	if((self= [super initWithManagedObject:a_managedObject propertyName:a_propertyName
                        formViewController:a_formViewController])){

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

		self.IFA_flexSpaceButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeFlexibleSpace target:self
                                                                 action:nil];
		self.IFA_selectAllButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeSelectAll target:self
                                                                 action:@selector(IFA_onSelectAllButtonTap:)];
		self.editing = YES;

	}

	return self;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"IFAMultipleSelectionListViewCell" bundle:nil]
         forCellReuseIdentifier:k_cellReuseId];
	self.shouldReloadTableViewDataAfterQuittingEditing = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
}

- (UITableViewStyle)tableViewStyle {
	return UITableViewStyleGrouped;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    IFAMultipleSelectionListViewCell *l_cell = [tableView dequeueReusableCellWithIdentifier:k_cellReuseId forIndexPath:indexPath];
    l_cell.addToSelectionImageView.hidden = YES;
    l_cell.removeFromSelectionImageView.hidden = YES;

	NSManagedObject *l_managedObject = nil;
	if (indexPath.section==k_sectionSelectedObjects) {
        if (self.IFA_selectedDestinationEntities.count) {
            l_managedObject = (self.IFA_selectedDestinationEntities)[(NSUInteger) indexPath.row];
            l_cell.removeFromSelectionImageView.hidden = NO;
        }
	}else {
        if (self.IFA_unselectedDestinationEntities.count) {
            l_managedObject = (self.IFA_unselectedDestinationEntities)[(NSUInteger) indexPath.row];
            l_cell.addToSelectionImageView.hidden = NO;
        }
	}
    l_cell.label.text = [l_managedObject ifa_longDisplayValue];
    return l_cell;

}

- (NSArray*)ifa_editModeToolbarItems {
	return @[self.selectNoneButtonItem, self.IFA_flexSpaceButtonItem, self.IFA_selectAllButtonItem];
}

-(void)done{
	
    BOOL l_valueChanged = [self IFA_hasValueChanged];
    [self ifa_notifySessionCompletionWithChangesMade:l_valueChanged data:nil ];

}

- (void)onSelectNoneButtonTap:(id)sender {
    [self IFA_selectNone];
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
    return UITableViewCellEditingStyleNone;
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    if (proposedDestinationIndexPath.section==1) {
        // Prevent user from dropping the cell in the "unselected" section
        return [NSIndexPath indexPathForRow:[self tableView:self.tableView numberOfRowsInSection:0]-1 inSection:0];
    }else{
        return proposedDestinationIndexPath;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *l_managedObjects;
    BOOL l_isSelectedOptionsSection = indexPath.section==k_sectionSelectedObjects;
    if (l_isSelectedOptionsSection) {
        l_managedObjects = @[(self.IFA_selectedDestinationEntities)[(NSUInteger) indexPath.row]];
    }else {
        l_managedObjects = @[(self.IFA_unselectedDestinationEntities)[(NSUInteger) indexPath.row]];
    }
    [self IFA_handleUserSelectionForManagedObjects:l_managedObjects
                                          isAdding:!l_isSelectedOptionsSection];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (section==k_sectionSelectedObjects) {
		return [self.IFA_selectedDestinationEntities count];
	}else {
		return [self.IFA_unselectedDestinationEntities count];
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
	return self.IFA_isJoinEntity && indexPath.section==k_sectionSelectedObjects;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    [self.IFA_selectedDestinationEntities ifa_moveObjectFromIndex:(NSUInteger) fromIndexPath.row
                                                          toIndex:(NSUInteger) toIndexPath.row];
    [self IFA_updateModel];
//    [self reloadInvolvedSectionsAfterImplicitAnimationForRowMovedFromIndexPath:fromIndexPath
//                                                                   toIndexPath:toIndexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return section==k_sectionSelectedObjects ? @"Selected" : @"Available for selection";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == k_sectionSelectedObjects) {
		return [self.IFA_selectedDestinationEntities count] ? nil : @"No selected entries";
	}
	else {
		return [self.IFA_unselectedDestinationEntities count] ? nil : @"No entries available for selection";
	}
}

@end