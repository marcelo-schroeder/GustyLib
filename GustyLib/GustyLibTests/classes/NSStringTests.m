//
//  Gusty - NSStringTests.m
//  Copyright 2014 InfoAccent Pty Limited. All rights reserved.
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
#import "NSString+IACategory.h"

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
