//
// Created by Marcelo Schroeder on 28/08/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import "NSMutableArray+IFACategory.h"


@implementation NSMutableArray (IFACategory)

#pragma mark - Public

- (void)ifa_moveObjectFromIndex:(NSUInteger)a_fromIndex toIndex:(NSUInteger)a_toIndex {
    id l_object = self[a_fromIndex];
    [self removeObjectAtIndex:a_fromIndex];
    [self insertObject:l_object atIndex:a_toIndex];
}

@end