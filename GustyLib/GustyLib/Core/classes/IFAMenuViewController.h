//
//  IFAMenuViewController.h
//  Gusty
//
//  Created by Marcelo Schroeder on 11/05/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

#import "IFAFetchedResultsTableViewController.h"
#import "IFAContextSwitchingManager.h"

@protocol IFAMenuViewControllerDataSource;

@interface IFAMenuViewController : IFATableViewController <IFAContextSwitchingManagerDelegate>

@property (nonatomic, weak) id<IFAMenuViewControllerDataSource> menuViewControllerDataSource;

@property (nonatomic, strong, readonly) NSMutableDictionary *indexPathToViewControllerDictionary;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

/**
* Determines whether the view controllers displayed by the menu will be cached or not.
* If set to YES then view controllers will be cached using NSCache and cache will be cleared in low memory situations and also when the app goes to the background.
* Setting this property to YES is useful on the iPad where the menu is a master view controller and the selected view controller is displayed as the detail view.
* Default = NO.
*/
@property (nonatomic) BOOL shouldCacheViewControllers;

-(void)highlightCurrentSelection;
-(void)restoreCurrentSelection;
-(UIViewController*)newViewControllerForIndexPath:(NSIndexPath*)a_indexPath;
-(UIResponder*)firstResponder;
-(UIViewController*)viewControllerForIndexPath:(NSIndexPath*)a_indexPath;
-(void)commitSelectionForIndexPath:(NSIndexPath*)a_indexPath;
-(void)selectMenuItemAtIndex:(NSUInteger)a_index;

+(IFAMenuViewController *)mainMenuViewController;

@end

@protocol IFAMenuViewControllerDataSource <NSObject>

/**
* Assists the menu view controller in determining the view controller selected by the user.
* @param a_indexPath Index path indicating the user selection.
* @param a_menuViewController The sender.
* @return ID of the view controller in the app's main storyboard to be instantiated and pushed onto the view when a given index path is selected by the user.
*/
-(NSString *)storyboardViewControllerIdForIndexPath:(NSIndexPath *)a_indexPath menuViewController:(IFAMenuViewController *)a_menuViewController;

@end
