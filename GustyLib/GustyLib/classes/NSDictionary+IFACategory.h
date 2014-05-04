//
// Created by Marcelo Schroeder on 1/05/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (IFACategory)

/**
* Groups objects by a given path optionally sorting them with a given sort descriptor.
*
* @param a_objects Objects to group.
* @param a_pathToGroupBy Path to group by.
* @param a_sortDescriptor Sort descriptor used to sort the objects in each group. If nil, no sorting will be performed.
*
* @returns Dictionary where keys are distinct values for given path and values are arrays of objects grouped by the given path.
*/
+ (NSDictionary *)IFA_dictionaryFromObjects:(NSArray *)a_objects groupedByPath:(NSString *)a_pathToGroupBy
                             sortDescriptor:(NSSortDescriptor *)a_sortDescriptor;

@end