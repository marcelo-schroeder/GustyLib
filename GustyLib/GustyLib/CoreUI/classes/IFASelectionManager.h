//
//  IFASelectionManager.h
//  Gusty
//
//  Created by Marcelo Schroeder on 14/07/11.
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

@protocol IFASelectionManagerDataSource;
@protocol IFASelectionManagerDelegate;

/**
* This class manages the state of single or multiple object selection, and it offers optional integration with a table view controller for managing associated view state.
*/
@interface IFASelectionManager : NSObject

/**
* Currently selected objects.
*/
@property (nonatomic, strong) NSMutableArray *selectedObjects;

/**
* Currently selected index paths.
*/
@property (weak, nonatomic, readonly) NSArray *selectedIndexPaths;

/**
* Set to YES to allow multiple object selection.
* Default: NO.
*/
@property (nonatomic) BOOL allowMultipleSelection;

/**
* Set to YES to disallow deselection (ignored if <allowMultipleSelection> is set to YES).
* Default: NO.
*/
@property(nonatomic) BOOL disallowDeselection;

/**
* Selection manager's data source (required).
*/
@property(nonatomic, weak, readonly) id <IFASelectionManagerDataSource> dataSource;

/**
* Selection manager's delegate (optional).
*/
@property(nonatomic, weak) id <IFASelectionManagerDelegate> delegate;

/**
* Call this method to request handling of selection on the UI.
* @param a_indexPath Index path of selected object.
*/
- (void)handleSelectionForIndexPath:(NSIndexPath*)a_indexPath;

/**
* Call this method to request handling of selection on the UI and optionally pass a user info dictionary.
* @param a_indexPath Index path of selected object.
* @param a_userInfo Optional user info dictionary to be passed back in delegate call backs.
*/
- (void)handleSelectionForIndexPath:(NSIndexPath*)a_indexPath userInfo:(NSDictionary*)a_userInfo;

/**
* Call this method to request handling of the deselection of all objects on the UI.
*/
- (void)deselectAll;

/**
* Call this method to request handling of the deselection of all objects on the UI and optionally pass a user info dictionary.
* @param a_userInfo Optional user info dictionary to be passed back in delegate call backs.
*/
- (void)deselectAllWithUserInfo:(NSDictionary*)a_userInfo;

/**
* Designated initialiser.
* @param a_dataSource The selection manager's data source (required).
* @param a_selectedObjects Any previously selected objects (optional).
*/
- (id)initWithSelectionManagerDataSource:(id<IFASelectionManagerDataSource>)a_dataSource selectedObjects:(NSArray*)a_selectedObjects NS_DESIGNATED_INITIALIZER;

/**
* Convenience initialiser.
* @param a_dataSource The selection manager's data source (required).
*/
- (id)initWithSelectionManagerDataSource:(id<IFASelectionManagerDataSource>)a_dataSource;

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMethodInspection"

/**
* Call this method to notify the selection manager of the deletion of an object on the UI.
* @param a_deletedObject The object deleted on the UI.
*/
- (void)notifyDeletionForObject:(id)a_deletedObject;
#pragma clang diagnostic pop

@end

@protocol IFASelectionManagerDataSource <NSObject>

@required

/**
* @param a_selectionManager The sender.
* @param a_indexPath Index path of the object being requested by the selection manager.
* @returns The object at the index path provided.
*/
- (NSObject *)selectionManager:(IFASelectionManager *)a_selectionManager
             objectAtIndexPath:(NSIndexPath *)a_indexPath;

/**
* @param a_selectionManager The sender.
* @param a_object The object associated with the index path being requested by the selection manager.
* @returns Index path associated with the object provided.
*/
- (NSIndexPath *)selectionManager:(IFASelectionManager *)a_selectionManager
               indexPathForObject:(NSObject *)a_object;

@optional

/**
* Implementing this method allows the selection manager to automatically deselect the table view associated with a user selection or deselection action.
* @param a_selectionManager The sender.
* @returns The table view whose row selection state must be kept in sync with the selection state managed by the sender.
*/
- (UITableView *)tableViewForSelectionManager:(IFASelectionManager *)a_selectionManager;

@end

@protocol IFASelectionManagerDelegate <NSObject>

@optional

/**
* Called by the selection manager to indicate that a selection or deselection action has been performed.
*
* This call allows the delegate to keep other associated state in sync with selection and deselection actions.
* @param a_selectionManager The sender.
* @param a_selectedObject The selected object, or nil if no object has been selected.
* @param a_deselectedObject The deselected object, or nil if no object has been deselected.
* @param a_indexPath The index path associated with the user action.
* @param a_userInfo A dictionary optionally provided when <[IFASelectionManager handleSelectionForIndexPath:userInfo:]> was called.
*/
- (void)selectionManager:(IFASelectionManager *)a_selectionManager
         didSelectObject:(id)a_selectedObject
        deselectedObject:(id)a_deselectedObject
               indexPath:(NSIndexPath *)a_indexPath
                userInfo:(NSDictionary *)a_userInfo;

/**
* Called by the selection manager to request the UI decoration of the table view cell associated with the selection or deselection action performed.
* When implementing this method, the <[IFASelectionManagerDataSource tableViewForSelectionManager:]> method must also be implemented.
*
* This call gives the UI a chance to update the state of the table view cell provided in order to reflect the selection or deselection performed by the user.
* @param a_selectionManager The sender.
* @param a_cell The table view cell the decoration is being requested for.
* @param a_selected YES if the associated user action has resulted in the selection of an object. NO if the associated user action has resulted in the deselection of an object.
* @param a_object The object being selected or deselected.
*/
- (UITableViewCell *)selectionManager:(IFASelectionManager *)a_selectionManager
          didRequestDecorationForCell:(UITableViewCell *)a_cell
                             selected:(BOOL)a_selected
                               object:(id)a_object;

@end
