//
//  Gusty - NSStringTests.m
//  Copyright 2014 InfoAccent Pty Limited. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IACommonTests.h"

@interface NSStringTests : XCTestCase
@end

@implementation NSStringTests{
}

- (void)testCharacters {
    assertThat([@"Test me!" m_characters], contains(@"T", @"e", @"s", @"t", @" ", @"m", @"e", @"!", nil));
}

- (void)testStringWithNumbersOnly{
    assertThat([@"abcd" m_stringWithNumbersOnly], is(equalTo(@"")));
    assertThat([@"1234" m_stringWithNumbersOnly], is(equalTo(@"1234")));
    assertThat([@"1.4l5(0 12" m_stringWithNumbersOnly], is(equalTo(@"145012")));
}

@end
