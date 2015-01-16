//
// Created by Marcelo Schroeder on 8/04/2014.
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

#import "NSIndexPath+IFACoreUI.h"


@implementation NSIndexPath (IFACoreUI)

#pragma mark - Public

+ (NSArray *)ifa_indexPathsForRowRange:(NSRange)a_rowRange section:(NSInteger)a_section {
    NSMutableArray *l_indexPaths = [@[] mutableCopy];
    for (NSUInteger l_row = a_rowRange.location; l_row < a_rowRange.location + a_rowRange.length; l_row++) {
        [l_indexPaths addObject:[NSIndexPath indexPathForRow:l_row inSection:a_section]];
    }
    return l_indexPaths;
}

- (NSIndexPath *)ifa_tableViewKey {
    NSIndexPath *key;
    if ([self isMemberOfClass:[NSIndexPath class]]) {
        key = self;
    }else{
        key= [NSIndexPath indexPathForRow:self.row inSection:self.section];
    }
    return key;
}

- (NSIndexPath *)ifa_collectionViewKey {
    NSIndexPath *key;
    if ([self isMemberOfClass:[NSIndexPath class]]) {
        key = self;
    }else{
        key= [NSIndexPath indexPathForRow:self.item inSection:self.section];
    }
    return key;
}

@end