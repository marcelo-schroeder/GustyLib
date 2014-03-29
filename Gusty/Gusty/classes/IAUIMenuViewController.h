//
//  IAUIMenuMasterViewController.h
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

#import "IAUIFetchedResultsTableViewController.h"

@interface IAUIMenuViewController : IAUIFetchedResultsTableViewController

@property (nonatomic, strong, readonly) NSMutableDictionary *p_indexPathToViewControllerDictionary;
@property (nonatomic, strong) NSIndexPath *p_selectedIndexPath;

-(void)m_highlightCurrentSelection;
-(void)m_restoreCurrentSelection;
-(UIViewController*)m_newViewControllerForIndexPath:(NSIndexPath*)a_indexPath;
-(UIResponder*)m_firstResponder;
-(UIViewController*)m_viewControllerForIndexPath:(NSIndexPath*)a_indexPath;
-(void)m_commitSelectionForIndexPath:(NSIndexPath*)a_indexPath;
-(void)m_selectMenuItemAtIndex:(NSUInteger)a_index;

+(IAUIMenuViewController*)m_mainMenuViewController;

@end
