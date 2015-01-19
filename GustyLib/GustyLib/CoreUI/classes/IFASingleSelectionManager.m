//
//  IFASingleSelectionManager.m
//  Gusty
//
//  Created by Marcelo Schroeder on 18/10/10.
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


@implementation IFASingleSelectionManager

#pragma mark - Public
	
- (id)initWithSelectionManagerDelegate:(id<IFASelectionManagerDelegate>)aDelegate selectedObject:(id)aSelectedObject{
    NSMutableArray *l_selectedObjects = [NSMutableArray array];
    if (aSelectedObject) {
        [l_selectedObjects addObject:aSelectedObject];
    }
	return [super initWithSelectionManagerDelegate:aDelegate selectedObjects:l_selectedObjects];
}

- (id)initWithSelectionManagerDelegate:(id<IFASelectionManagerDelegate>)aDelegate{
    return [super initWithSelectionManagerDelegate:aDelegate];
}

- (id)selectedObject{
    if ([self.selectedObjects count]==0) {
        return nil;
    }else{
        NSAssert([self.selectedObjects count]==1, @"Unexpected array size: %lu, array: %@", (unsigned long)[self.selectedObjects count], [self.selectedObjects description]);
        return [self.selectedObjects objectAtIndex:0];
    }
}

- (void)setSelectedObject:(id)a_object{
    NSAssert([self.selectedObjects count]<=1, @"Unexpected array size: %lu", (unsigned long)[self.selectedObjects count]);
    [self.selectedObjects removeAllObjects];
    if (a_object) {
        [self.selectedObjects addObject:a_object];
    }
}

- (NSIndexPath*)selectedIndexPath{
    if ([self.selectedIndexPaths count]==0) {
        return nil;
    }else{
        NSAssert([self.selectedIndexPaths count]==1, @"Unexpected array size: %lu", (unsigned long)[self.selectedIndexPaths count]);
        return [self.selectedIndexPaths objectAtIndex:0];
    }
}

@end
