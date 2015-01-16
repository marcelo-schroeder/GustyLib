//
//  IFAFetchedResultsTableViewController.h
//  Gusty
//
//  Created by Marcelo Schroeder on 8/03/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
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

#import "IFATableViewController.h"

@protocol IFAFetchedResultsTableViewControllerDataSource;

@interface IFAFetchedResultsTableViewController : IFATableViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) id<IFAFetchedResultsTableViewControllerDataSource> fetchedResultsTableViewControllerDataSource;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@end

@protocol IFAFetchedResultsTableViewControllerDataSource <NSObject>
@optional
/**
* Provides a NSFetchedResultsController instance to this view controller.
* Default NSFetchedResultsControllerDelegate functionality will be automatically provided (the NSFetchedResultsControllerDelegate will be set to self).
*/
- (NSFetchedResultsController *)fetchedResultsControllerForFetchedResultsTableViewController:(IFAFetchedResultsTableViewController *)a_fetchedResultsTableViewController;
@end