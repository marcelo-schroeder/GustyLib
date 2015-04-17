//
//  GustyLib - NSMutableArrayTests.m
//  Copyright 2014 InfoAccent Pty Ltd. All rights reserved.
//
//  Created by: Marcelo Schroeder
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

#import "IFACommonTests.h"
#import "NSMutableArray+IFACoreUI.h"
#import "IFACoreUITestCase.h"

@interface NSMutableArrayTests : IFACoreUITestCase
@property(nonatomic, strong) NSMutableArray *p_mutableArray;
@end

@implementation NSMutableArrayTests{
}

- (void)setUp {
    [super setUp];
    self.p_mutableArray = [@[@(1), @(2), @(3), @(4)] mutableCopy];
}

- (void)testMoveFromLowerIndexToHigherIndex{
    // when
    [self.p_mutableArray ifa_moveObjectFromIndex:0 toIndex:2];
    // then
    assertThat(self.p_mutableArray, contains(@(2), @(3), @(1), @(4), nil));
}

- (void)testMoveFromHigherIndexToLowerIndex{
    // when
    [self.p_mutableArray ifa_moveObjectFromIndex:3 toIndex:1];
    // then
    assertThat(self.p_mutableArray, contains(@(1), @(4), @(2), @(3), nil));
}

- (void)testMoveFromAndToSameIndex{
    // when
    [self.p_mutableArray ifa_moveObjectFromIndex:1 toIndex:1];
    // then
    assertThat(self.p_mutableArray, contains(@(1), @(2), @(3), @(4), nil));
}

@end
