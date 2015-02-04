//
// Created by Marcelo Schroeder on 28/08/2014.
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

#import "NSMutableArray+IFACoreUI.h"


@implementation NSMutableArray (IFACoreUI)

#pragma mark - Public

- (void)ifa_moveObjectFromIndex:(NSUInteger)a_fromIndex toIndex:(NSUInteger)a_toIndex {
    id l_object = self[a_fromIndex];
    [self removeObjectAtIndex:a_fromIndex];
    [self insertObject:l_object atIndex:a_toIndex];
}

@end