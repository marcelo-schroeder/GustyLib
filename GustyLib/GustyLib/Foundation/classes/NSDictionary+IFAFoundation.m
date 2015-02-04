//
// Created by Marcelo Schroeder on 1/05/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import "GustyLibFoundation.h"


@implementation NSDictionary (IFAFoundation)

#pragma mark - Public

+ (NSDictionary *)ifa_dictionaryFromObjects:(NSArray *)a_objects groupedByPath:(NSString *)a_pathToGroupBy
                             sortDescriptor:(NSSortDescriptor *)a_sortDescriptor {
    NSMutableDictionary *l_dictionary = [@{} mutableCopy];
    NSString *l_arrayOperationPath = [NSString stringWithFormat:@"@distinctUnionOfObjects.%@", a_pathToGroupBy];
    NSArray *l_keys = [a_objects valueForKeyPath:l_arrayOperationPath];
    for (NSString *l_key in l_keys) {
        @autoreleasepool {
            NSString *l_predicateFormat = [NSString stringWithFormat:@"%@ = %%@", a_pathToGroupBy];
            NSPredicate *l_predicate = [NSPredicate predicateWithFormat:l_predicateFormat, l_key];
            NSArray *l_groupedObjects = [a_objects filteredArrayUsingPredicate:l_predicate];
            if (a_sortDescriptor) {
                l_groupedObjects = [l_groupedObjects sortedArrayUsingDescriptors:@[a_sortDescriptor]];
            }
            l_dictionary[l_key] = l_groupedObjects;
        }
    }
    return l_dictionary;
}

@end