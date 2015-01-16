//
//  IFASelectionManager.m
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

#import "GustyLibCoreUI.h"

@implementation IFASelectionManager

#pragma mark - Public

- (id)initWithSelectionManagerDelegate:(id<IFASelectionManagerDelegate>)a_delegate{
    NSMutableArray *l_selectedObjects = [[NSMutableArray alloc] init];
	return [self initWithSelectionManagerDelegate:a_delegate selectedObjects:l_selectedObjects];
}

- (id)initWithSelectionManagerDelegate:(id<IFASelectionManagerDelegate>)a_delegate selectedObjects:(NSArray *)a_selectedObjects{
	if ((self=[super init])) {
		self.delegate = a_delegate;
        self.allowMultipleSelection = NO;
		self.selectedObjects = [NSMutableArray arrayWithArray:a_selectedObjects];
	}
	return self;
}

- (void)handleSelectionForIndexPath:(NSIndexPath*)a_indexPath{
    [self handleSelectionForIndexPath:a_indexPath userInfo:nil];
}

- (void)handleSelectionForIndexPath:(NSIndexPath*)a_indexPath userInfo:(NSDictionary*)a_userInfo{
    
//    NSLog(@"handleSelectionForIndexPath: %@", [a_indexPath description]);
//    NSLog(@"self.selectedIndexPaths: %@", [self.selectedIndexPaths description]);
    
    NSIndexPath *l_previousSelectedIndexPath = nil;
	id l_previousSelectedObject = nil;
	id l_selectedObject = nil;
    if (self.allowMultipleSelection) {
        id l_targetObject = [self.delegate selectionManagerObjectForIndexPath:a_indexPath];
        if ([self.selectedObjects containsObject:l_targetObject]) {
            l_previousSelectedIndexPath = a_indexPath;
            l_previousSelectedObject = l_targetObject;
        }else{
            l_selectedObject = l_targetObject;
        }
    }else{
        if ([self.selectedIndexPaths count]>0) {
            l_previousSelectedIndexPath = [self.selectedIndexPaths objectAtIndex:0];
            l_previousSelectedObject = [self.selectedObjects objectAtIndex:0];
        }
        if ([self.selectedIndexPaths count]==0 || ![l_previousSelectedIndexPath isEqual:a_indexPath]) {
            l_selectedObject = [self.delegate selectionManagerObjectForIndexPath:a_indexPath];
        }
        if (self.disallowDeselection && [l_previousSelectedIndexPath compare:a_indexPath] == NSOrderedSame) {
            // Run delegate's handler
            [self.delegate onSelection:l_selectedObject deselectedObject:l_previousSelectedObject indexPath:a_indexPath
                              userInfo:a_userInfo];
            // Deselect row (UITableView's default visual indication only)
            [[self.delegate selectionTableView] deselectRowAtIndexPath:a_indexPath animated:YES];
            return;
        }
    }
//    NSLog(@"l_previousSelectedObject: %@", [l_previousSelectedObject description]);
//    NSLog(@"l_selectedObject: %@", [l_selectedObject description]);

    // Old cell
	if (l_previousSelectedObject) {
//        NSLog(@"l_previousSelectedIndex: %u", l_previousSelectedIndex);
		NSIndexPath *oldIndexPath = l_previousSelectedIndexPath;
//        NSLog(@"oldIndexPath: %u", oldIndexPath.row);
		UITableViewCell *oldCell = [[self.delegate selectionTableView] cellForRowAtIndexPath:oldIndexPath];
		[self.delegate decorateSelectionForCell:oldCell selected:NO targetObject:l_previousSelectedObject];
	}

	// New cell
	if (l_selectedObject) {
		UITableViewCell *newCell = [[self.delegate selectionTableView] cellForRowAtIndexPath:a_indexPath];
		[self.delegate decorateSelectionForCell:newCell selected:YES targetObject:l_selectedObject];
        [self.selectedObjects addObject:[self.delegate selectionManagerObjectForIndexPath:a_indexPath]];
	}

    // Remove previous selection
    [self.selectedObjects removeObject:l_previousSelectedObject];
	
    // Run delegate's handler
	[self.delegate onSelection:l_selectedObject deselectedObject:l_previousSelectedObject indexPath:a_indexPath
                      userInfo:a_userInfo];
	
    // Deselect row (UITableView's default visual indication only)
	[[self.delegate selectionTableView] deselectRowAtIndexPath:a_indexPath animated:YES];

}

-(void)deselectAll{
    [self deselectAllWithUserInfo:nil];
}

- (void)deselectAllWithUserInfo:(NSDictionary *)a_userInfo{
    for (NSIndexPath *l_selectedIndexPath in self.selectedIndexPaths) {
		[self handleSelectionForIndexPath:l_selectedIndexPath userInfo:a_userInfo];
    }
}

- (NSArray*)selectedIndexPaths {
    NSMutableArray *l_selectedIndexPaths = [[NSMutableArray alloc] init];
    for (id l_selectedObject in self.selectedObjects) {
        NSIndexPath *l_selectedIndexPath = [self.delegate selectionManagerIndexPathForObject:l_selectedObject];
        if (l_selectedIndexPath) {
            [l_selectedIndexPaths addObject:l_selectedIndexPath];
        }
    }
	return l_selectedIndexPaths;
}

- (void)notifyDeletionForObject:(id)a_deletedObject{
//    NSLog(@"notifyDeletionForIndexPath - size before: %u", [self.selectedObjects count]);
    [self.selectedObjects removeObject:a_deletedObject];
//    NSLog(@"notifyDeletionForIndexPath - size after: %u", [self.selectedObjects count]);
}

#pragma mark - Overrides


@end
