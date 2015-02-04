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

#import <Foundation/Foundation.h>

@interface NSDictionary (IFAFoundation)

/**
* Groups objects by a given path optionally sorting them with a given sort descriptor.
*
* @param a_objects Objects to group.
* @param a_pathToGroupBy Path to group by.
* @param a_sortDescriptor Sort descriptor used to sort the objects in each group. If nil, no sorting will be performed.
*
* @returns Dictionary where keys are distinct values for given path and values are arrays of objects grouped by the given path.
*/
+ (NSDictionary *)ifa_dictionaryFromObjects:(NSArray *)a_objects groupedByPath:(NSString *)a_pathToGroupBy
                             sortDescriptor:(NSSortDescriptor *)a_sortDescriptor;

@end