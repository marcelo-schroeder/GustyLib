//
// Created by Marcelo Schroeder on 6/04/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

#import <Foundation/Foundation.h>

@protocol IFATableViewControllerDynamicCellHeightDelegate;

@interface UITableViewController (IFADynamicCellHeight)

@property (nonatomic, weak) id<IFATableViewControllerDynamicCellHeightDelegate> ifa_dynamicCellHeightDelegate;

/**
* This dictionary contains cached heights per index path.
* Keys are NSIndexPath instances and values are NSNumber instances of floats representing cell heights.
* House keeping to release memory can be done at any time as this is a mutable dictionary.
* This property is useful in the tableView:estimatedHeightForRowAtIndexPath: method to avoid issues with reloadData.
*/
@property (nonatomic, strong, readonly) NSMutableDictionary *ifa_cachedCellHeights;

/**
* Calculates the height of a table view cell using auto layout.
* Only works if the IFATableViewControllerDynamicCellHeightDelegate protocol is implemented.
*
* @param a_indexPath Index path of cell to calculate the height of.
* @param a_tableView Parent table view.
*
* @returns Calculated cell height.
*/
- (CGFloat)ifa_heightForCellAtIndexPath:(NSIndexPath *)a_indexPath tableView:(UITableView *)a_tableView;

/**
* Sets the preferred maximum layout width for the multi-line UILabel instances in table view cell based on the prototype table view cell provided.
* This method requires the ifa_multiLineLabelKeyPathsForCellWithReuseIdentifier: method of the IFATableViewControllerDynamicCellHeightDelegate protocol to be implemented.
* Only the UILabel instances that match the key paths provided by the ifa_multiLineLabelKeyPathsForCellWithReuseIdentifier: will have their preferredMaxLayoutWidth property changed.
*
* @param a_cell Table view cell containing the UILabel instances that will have their preferredMaxLayoutWidth property changed.
* @param a_prototypeCell Prototype table view cell to provide the dimensions required for a_cell.
*/
- (void)ifa_setPreferredMaxLayoutWidthForMultiLineLabelsInCell:(UITableViewCell *)a_cell basedOnPrototypeCell:(UITableViewCell *)a_prototypeCell;

@end

@protocol IFATableViewControllerDynamicCellHeightDelegate <NSObject>

/**
* Provides the prototype table view cell to be used for height calculation.
*
* @param a_indexPath Index path of the prototype cell.
* @param a_tableView Parent table view of the prototype cell.
*
* @returns Prototype table view cell to be used for height calculation.
*/
- (UITableViewCell *)ifa_prototypeCellForIndexPath:(NSIndexPath *)a_indexPath tableView:(UITableView *)a_tableView;

/**
* Populates a table cell with data.
* This is used for height calculation but it can also be used for other purposes, such as set the cell data in cellForRowAtIndexPath method calls.
*
* @param a_cell Table view cell to populate with data.
* @param a_indexPath Index path of the prototype cell.
* @param a_tableView Parent table view of the prototype cell.
*/
- (void)ifa_populateCell:(UITableViewCell *)a_cell atIndexPath:(NSIndexPath *)a_indexPath
               tableView:(UITableView *)a_tableView;

@optional

/**
* A width constraint will be added to the content view before calculating the cell height.
* If this method is not implemented, then no width constraint will be added.
*
* @param a_prototypeCell A pre-populated prototype cell used to calculate the new height.
*
* returns The value for the width constraint.
*/
- (CGFloat)ifa_cellContentViewWidthForPrototypeCell:(UITableViewCell *)a_prototypeCell;

/**
* This method provides a hint as to which multi-line UILabel instances need to have their width adjusted as the cell width changes.
* Only UILabel instances where the 'numberOfLines' properties is not equal to 1 will be considered. Anything else will be ignored.
*
* @param a_cellReuseIdentifier Reuse identifier of the cell the UILabel instances belong to.
*
* @returns Array of key path NSString instances corresponding to the multi-line UILabel instances that require their width to adjust automatically as the cell width changes.
*/
- (NSArray *)ifa_multiLineLabelKeyPathsForCellWithReuseIdentifier:(NSString *)a_cellReuseIdentifier;

@end