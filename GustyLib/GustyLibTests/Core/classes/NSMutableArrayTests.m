//
//  GustyLib - NSMutableArrayTests.m
//  Copyright 2014 InfoAccent Pty Ltd. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IFACommonTests.h"
#import "NSMutableArray+IFACategory.h"

@interface NSMutableArrayTests : XCTestCase
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
