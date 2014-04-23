//
//  Gusty - NSNumberFormatterTests.m
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
#import "NSNumberFormatter+IACategory.h"

@interface NSNumberFormatterTests : XCTestCase
@end

@implementation NSNumberFormatterTests {
}

- (void)testStringFromAustralianPhoneNumber  {

    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumber:@(92345678)], is(equalTo(@"9234 5678")));
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumber:@(292345678)], is(equalTo(@"02 9234 5678")));
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumber:@(412345678)], is(equalTo(@"0412 345 678")));
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumber:@(1300268926)], is(equalTo(@"1300 268 926")));
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumber:@(1800268926)], is(equalTo(@"1800 268 926")));
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumber:@(1234)], is(equalTo(@"1234")));    // does not fall in any of the usual ranges above

}

- (void)testStringFromAustralianPhoneNumberString{
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumberString:@"(02) 9234-5678"], is(equalTo(@"02 9234 5678")));
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumberString:@"0292345678"], is(equalTo(@"02 9234 5678")));
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumberString:@"Phone: 02 92345678"], is(equalTo(@"02 9234 5678")));
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumberString:@"abcd"], is(equalTo(@"abcd")));
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumberString:@""], is(equalTo(@"")));
    assertThat([NSNumberFormatter m_stringFromAustralianPhoneNumberString:nil], is(equalTo(nil)));
}

@end
