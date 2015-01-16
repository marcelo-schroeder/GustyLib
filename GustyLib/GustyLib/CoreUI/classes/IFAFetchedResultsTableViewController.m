//
//  IFAFetchedResultsTableViewController.m
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

#import "GustyLibCoreUI.h"

@interface IFAFetchedResultsTableViewController ()
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation IFAFetchedResultsTableViewController {
    
}

#pragma mark - Public

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        if ([self.fetchedResultsTableViewControllerDataSource respondsToSelector:@selector(fetchedResultsControllerForFetchedResultsTableViewController:)]) {
            _fetchedResultsController = [self.fetchedResultsTableViewControllerDataSource fetchedResultsControllerForFetchedResultsTableViewController:self];
            _fetchedResultsController.delegate = self;
        }
    }
    return _fetchedResultsController;
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> l_sectionInfo = [self.fetchedResultsController sections][(NSUInteger) section];
    return [l_sectionInfo numberOfObjects];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> l_sectionInfo = [self.fetchedResultsController sections][(NSUInteger) section];
    return [l_sectionInfo name];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {

//    NSLog(@"NSFetchedResultsController section changed detected for controller: %@", [controller description]);
//    NSLog(@"  didChangeSection: %@", [sectionInfo name]);
//    NSLog(@"           atIndex: %u", sectionIndex);

    UITableViewRowAnimation l_animation = self.IFA_tableViewRowAnimation;

    switch(type) {

        case NSFetchedResultsChangeInsert:
//            NSLog(@"    forChangeType: insert");
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:l_animation];
            break;
            
        case NSFetchedResultsChangeDelete:
//            NSLog(@"    forChangeType: delete");
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:l_animation];
            break;
            
        default:
            NSAssert(NO, @"Unexpected section change type: %lu", (unsigned long)type);
            break;

    }

}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
//    NSLog(@"NSFetchedResultsController cell changed detected for controller: %@", [controller description]);
//    NSLog(@"  didChangeObject: %@", [anObject description]);
//    NSLog(@"      atIndexPath: %@", [indexPath description]);
//    NSLog(@"     newIndexPath: %@", [newIndexPath description]);

    UITableViewRowAnimation l_animation = self.IFA_tableViewRowAnimation;

    switch(type) {
            
        case NSFetchedResultsChangeInsert:
//            NSLog(@"    forChangeType: insert");
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:l_animation];
            break;
            
        case NSFetchedResultsChangeDelete:
//            NSLog(@"    forChangeType: delete");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:l_animation];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            NSLog(@"    forChangeType: update");
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:l_animation];
            break;
            
        case NSFetchedResultsChangeMove:
//            NSLog(@"    forChangeType: move");
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:l_animation];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:l_animation];
            break;

        default:
            NSAssert(NO, @"Unexpected object change type: %lu", (unsigned long)type);
            break;

    }
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Private

- (UITableViewRowAnimation)IFA_tableViewRowAnimation {
    UITableViewRowAnimation l_animation;
    if (self.navigationController.visibleViewController==self) {
        // Visible, then use a nice animation
        l_animation = UITableViewRowAnimationFade;
    }else{
        // Not visible, so update UI state straight away to avoid issues with delayed animations after popping a view controller via swipe back gesture, for instance
        l_animation = UITableViewRowAnimationNone;
    }
    return l_animation;
}

@end
