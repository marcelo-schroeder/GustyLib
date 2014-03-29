//
//  Gusty - NSNumberFormatterTests.m
//  Copyright 2014 InfoAccent Pty Limited. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IACommonTests.h"
#import "NSNumberFormatter+IACategory.h"

@interface NSNumberFormatterTests : SenTestCase
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
