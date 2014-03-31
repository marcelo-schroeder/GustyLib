//
//  IAUINavigationListViewController.m
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

@interface IAUINavigationListViewController()

@end

@implementation IAUINavigationListViewController{
    
}


#pragma mark - Private

-(void)m_updateLeftBarButtonItemsStates{
    if (!self.p_pagingContainerViewController || self.p_selectedViewControllerInPagingContainer) {
        [self m_addLeftBarButtonItem:self.p_addBarButtonItem];
    }
}

#pragma mark - UITableViewDelegate Protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[[IAPersistenceManager instance] entityConfig] disallowDetailDisclosureForEntity:self.entityName]) {
        [self tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if (![IAHelpManager m_instance].p_helpMode) {
        [self showEditFormForManagedObject:(NSManagedObject*)[self m_objectForIndexPath:indexPath]];
    }
}

#pragma mark - UITableViewDataSource Protocol

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Persist deletion
		NSManagedObject	*mo = (NSManagedObject*)[self m_objectForIndexPath:indexPath];
		if (![[IAPersistenceManager instance] m_deleteAndSave:mo]) {
			return;
		}

		// Update the main entities array
        [self.p_entities removeObject:mo];

        // Update the "sections with rows" array
        NSMutableArray *l_sectionRows = [self.p_sectionsWithRows objectAtIndex:indexPath.section];
        if (self.p_listGroupedBy) {
            [l_sectionRows removeObjectAtIndex:indexPath.row];
            if ([l_sectionRows count]==0) {
                [self.p_sectionsWithRows removeObjectAtIndex:indexPath.section];
            }
        }

        // Mark data as stale if required
        if ([self.p_entities count]==0) {
            self.p_staleData = YES;
        }

        // Update the table view
        [self.tableView beginUpdates];
        [self.tableView m_deleteRowsAtIndexPaths:@[indexPath]];
        if (self.p_listGroupedBy && [l_sectionRows count]==0) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView endUpdates];

        if ([self.p_entities count]==0) {
            NSAssert(self.editing, @"Unexpected editing state: %u", self.editing);
            [self setEditing:NO animated:YES];
        }else{
            [self showTipForEditing:YES];
        }

    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
	return [IAHelpManager m_instance].p_helpMode ? NO : [[IAPersistenceManager instance].entityConfig listReorderAllowedForEntity:self.entityName];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    
    if (![fromIndexPath isEqual:toIndexPath]) {
        
        //    NSLog(@"moveRowAtIndexPath: %u", fromIndexPath.row);
        //    NSLog(@"toIndexPath: %u", toIndexPath.row);
        NSManagedObject *fromManagedObject = [self.p_entities objectAtIndex:fromIndexPath.row];
        NSManagedObject *toManagedObject = [self.p_entities objectAtIndex:toIndexPath.row];
        //    NSLog(@"fromManagedObject: %u", [[fromManagedObject valueForKey:@"seq"] unsignedIntValue]);
        //    NSLog(@"toManagedObject: %u", [[toManagedObject valueForKey:@"seq"] unsignedIntValue]);
        
        // Determine new sequence
        uint seq = [[toManagedObject valueForKey:@"seq"] unsignedIntValue];
        if (fromIndexPath.row<toIndexPath.row) {
            seq++;
        }else{
            seq--;
        }
        //    NSLog(@"new fromManagedObject seq: %u", seq);
        [fromManagedObject setValue:@(seq) forKey:@"seq"];
        
        // Save changes
        [[IAPersistenceManager instance] save:fromManagedObject];
        
        // Re-order backing entity array
        //    NSLog(@"entities BEFORE sorting: %@", [self.p_entities description]);
        NSSortDescriptor *l_sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"seq" ascending:YES];
        [self.p_entities sortUsingDescriptors:@[l_sortDescriptor]];
        //    NSLog(@"entities AFTER sorting: %@", [self.p_entities description]);
        
    }
    
    [self m_reloadMovedCellAtIndexPath:toIndexPath];

}

#pragma mark - Overrides

-(UITableViewCellAccessoryType)m_tableViewCellAccessoryType{
    return UITableViewCellAccessoryDisclosureIndicator;
}

-(UITableViewCell *)m_initReusableCellWithIdentifier:(NSString *)a_reuseIdentifier atIndexPath:(NSIndexPath *)a_indexPath{
	UITableViewCell *l_cell = [super m_initReusableCellWithIdentifier:a_reuseIdentifier atIndexPath:a_indexPath];
    if ([[[IAPersistenceManager instance] entityConfig] disallowDetailDisclosureForEntity:self.entityName]) {
        l_cell.accessoryType = UITableViewCellAccessoryNone;
        l_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else {
        l_cell.accessoryType = [self m_tableViewCellAccessoryType];
    }
	l_cell.showsReorderControl = YES;
    [[self m_appearanceTheme] m_setAppearanceForView:l_cell.textLabel];
	return l_cell;
}

- (void)viewDidLoad {

    [super viewDidLoad];
	
    if (![[[IAPersistenceManager instance] entityConfig] disallowUserAdditionForEntity:self.entityName]) {
        self.p_addBarButtonItem = [IAUIUtils barButtonItemForType:IA_UIBAR_BUTTON_ITEM_ADD target:self action:@selector(onAddButtonTap:)];
    }

    self.editButtonItem.tag = IA_UIBAR_ITEM_TAG_EDIT_BUTTON;
    [self m_addRightBarButtonItem:self.editButtonItem];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self m_updateLeftBarButtonItemsStates];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [self showTipForEditing:editing];
//    UIButton *l_helpButton = (UIButton*)[self.navigationController.view viewWithTag:IA_UIVIEW_TAG_HELP_BUTTON];
//    l_helpButton.enabled = !editing;
}

-(void)m_didRefreshAndReloadDataAsync{
    [super m_didRefreshAndReloadDataAsync];
    if (![self m_isReturningVisibleViewController] && self.editing) { // If it was left editing previously, reset it to non-editing mode.
        [self quitEditing];
    }else{
        [self showTipForEditing:NO];
    }
}

-(void)m_reset{
    [super m_reset];
    // If it was left editing previously, reset it to non-editing mode.
    if (![self m_isReturningVisibleViewController] && self.editing && !self.p_staleData) {  // If it's stale data, then quitEditing will be performed by the m_didRefreshAndReloadDataAsync method
        [self quitEditing];
    }
}

@end
