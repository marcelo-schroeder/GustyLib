//
//  IFANavigationListViewController.m
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

@interface IFANavigationListViewController ()

@end

@implementation IFANavigationListViewController {
    
}


#pragma mark - Private

-(void)IFA_updateLeftBarButtonItemsStates {
    if (!self.pagingContainerViewController || self.selectedViewControllerInPagingContainer) {
        [self ifa_addLeftBarButtonItem:self.addBarButtonItem];
    }
}

-(UITableViewCellAccessoryType)IFA_tableViewCellAccessoryType {
    return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)iFA_handleSelectionForEditingAtIndexPath:(NSIndexPath *)a_indexPath {
    [self showEditFormForManagedObject:(NSManagedObject *) [self objectForIndexPath:a_indexPath]];
}

#pragma mark - UITableViewDelegate Protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[[IFAPersistenceManager sharedInstance] entityConfig] disallowDetailDisclosureForEntity:self.entityName]) {
        [self iFA_handleSelectionForEditingAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self iFA_handleSelectionForEditingAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self tableView:tableView titleForHeaderInSection:section]) {
        return [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize * 1.5;
    }else {
        return 0;
    }
}

#pragma mark - UITableViewDataSource Protocol

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Persist deletion
		NSManagedObject	*mo = (NSManagedObject*) [self objectForIndexPath:indexPath];
		if (![[IFAPersistenceManager sharedInstance] deleteAndSaveObject:mo validationAlertPresenter:self]) {
			return;
		}

        if (!self.fetchedResultsController) {

            // Update the main entities array
            [self.entities removeObject:mo];

            // Update the "sections with rows" array
            NSMutableArray *l_sectionRows = (self.sectionsWithRows)[(NSUInteger) indexPath.section];
            if (self.listGroupedBy) {
                [l_sectionRows removeObjectAtIndex:(NSUInteger) indexPath.row];
                if ([l_sectionRows count]==0) {
                    [self.sectionsWithRows removeObjectAtIndex:(NSUInteger) indexPath.section];
                }
            }

            // Update the table view
            [self.tableView beginUpdates];
            [self.tableView ifa_deleteRowsAtIndexPaths:@[indexPath]];
            if (self.listGroupedBy && [l_sectionRows count]==0) {
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:(NSUInteger) indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            }
            [self.tableView endUpdates];

        }

        if (self.objects.count==0) {
            self.staleData = YES;
            if (self.editing) {
                [self setEditing:NO animated:YES];
            }
        }else{
            [self showEmptyListPlaceholder];
        }

    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[IFAPersistenceManager sharedInstance].entityConfig listReorderAllowedForEntity:self.entityName];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    
    if (![fromIndexPath isEqual:toIndexPath]) {
        
        //    NSLog(@"moveRowAtIndexPath: %u", fromIndexPath.row);
        //    NSLog(@"toIndexPath: %u", toIndexPath.row);
        NSManagedObject *fromManagedObject = (NSManagedObject *) [self objectForIndexPath:fromIndexPath];
        NSManagedObject *toManagedObject = (NSManagedObject *) [self objectForIndexPath:toIndexPath];
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
        [[IFAPersistenceManager sharedInstance] saveObject:fromManagedObject validationAlertPresenter:self];

        if (!self.fetchedResultsController) {

            // Re-order backing entity array
            //    NSLog(@"entities BEFORE sorting: %@", [self.entities description]);
            NSSortDescriptor *l_sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"seq" ascending:YES];
            [self.entities sortUsingDescriptors:@[l_sortDescriptor]];
            //    NSLog(@"entities AFTER sorting: %@", [self.entities description]);

        }

    }

//    if (!self.fetchedResultsController) {
//        [self reloadInvolvedSectionsAfterImplicitAnimationForRowMovedFromIndexPath:fromIndexPath
//                                                                       toIndexPath:toIndexPath];
//    }

}

#pragma mark - Overrides

-(UITableViewCell *)createReusableCellWithIdentifier:(NSString *)a_reuseIdentifier atIndexPath:(NSIndexPath *)a_indexPath{
	UITableViewCell *l_cell = [super createReusableCellWithIdentifier:a_reuseIdentifier atIndexPath:a_indexPath];
    if ([[[IFAPersistenceManager sharedInstance] entityConfig] disallowDetailDisclosureForEntity:self.entityName]) {
        l_cell.accessoryType = UITableViewCellAccessoryNone;
        l_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else {
        l_cell.accessoryType = [self IFA_tableViewCellAccessoryType];
    }
	l_cell.showsReorderControl = YES;
    [[self ifa_appearanceTheme] setAppearanceForView:l_cell.textLabel];
	return l_cell;
}

- (void)viewDidLoad {

    [super viewDidLoad];
	
    if (![[[IFAPersistenceManager sharedInstance] entityConfig] disallowUserAdditionForEntity:self.entityName]) {
        self.addBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeAdd target:self
                                                          action:@selector(onAddButtonTap:)];
    }

    self.editButtonItem.tag = IFABarItemTagEditButton;
    [self ifa_addRightBarButtonItem:self.editButtonItem];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self IFA_updateLeftBarButtonItemsStates];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [self showEmptyListPlaceholder];
//    UIButton *l_helpButton = (UIButton*)[self.navigationController.view viewWithTag:IFAViewTagHelpButton];
//    l_helpButton.enabled = !editing;
}

-(void)didRefreshAndReloadData {
    [super didRefreshAndReloadData];
    if (![self ifa_isReturningVisibleViewController] && self.editing) { // If it was left editing previously, reset it to non-editing mode.
        [self quitEditing];
    }else{
        [self showEmptyListPlaceholder];
    }
}

-(void)ifa_reset {
    [super ifa_reset];
    // If it was left editing previously, reset it to non-editing mode.
    if (![self ifa_isReturningVisibleViewController] && self.editing && !self.staleData) {  // If it's stale data, then quitEditing will be performed by the didRefreshAndReloadData method
        [self quitEditing];
    }
}

@end
