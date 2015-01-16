//
// Created by Marcelo Schroeder on 13/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

#import "GustyLibFoundation.h"

@implementation NSNumberFormatter (IFAFoundation)

static NSNumberFormatter *c_australianPhoneNumberFormatterLandLineWithoutAreaCode = nil;
static NSNumberFormatter *c_australianPhoneNumberFormatterLandLineWithAreaCode = nil;
static NSNumberFormatter *c_australianPhoneNumberFormatterMobileAndSpecialWithoutGrouping = nil;

#pragma mark - Private

+ (void)IFA_configureAustralianPhoneNumberFormatter:(NSNumberFormatter *)a_numberFormatter{
    a_numberFormatter.groupingSeparator = @" ";
}

+ (void)IFA_createAustralianPhoneNumberFormattersIfRequired {

    static dispatch_once_t c_dispatchOncePredicate;
    dispatch_once(&c_dispatchOncePredicate, ^{

        c_australianPhoneNumberFormatterLandLineWithoutAreaCode = [[NSNumberFormatter alloc] init];
        c_australianPhoneNumberFormatterLandLineWithoutAreaCode.positiveFormat = @"0000,0000";
        [self IFA_configureAustralianPhoneNumberFormatter:c_australianPhoneNumberFormatterLandLineWithoutAreaCode];

        c_australianPhoneNumberFormatterLandLineWithAreaCode = [[NSNumberFormatter alloc] init];
        c_australianPhoneNumberFormatterLandLineWithAreaCode.positiveFormat = @"00,0000,0000";
        [self IFA_configureAustralianPhoneNumberFormatter:c_australianPhoneNumberFormatterLandLineWithAreaCode];

        c_australianPhoneNumberFormatterMobileAndSpecialWithoutGrouping = [[NSNumberFormatter alloc] init];
        c_australianPhoneNumberFormatterMobileAndSpecialWithoutGrouping.positiveFormat = @"0000000000";
        [self IFA_configureAustralianPhoneNumberFormatter:c_australianPhoneNumberFormatterMobileAndSpecialWithoutGrouping];

    });

}

#pragma mark - Public

+ (NSString *)ifa_stringFromAustralianPhoneNumber:(NSNumber *)a_number{
    [self IFA_createAustralianPhoneNumberFormattersIfRequired];
    CGFloat l_number = a_number.floatValue;
    NSString *l_numberString = a_number.stringValue;
    if (l_number>=10000000 && l_number<=99999999) {
        return [c_australianPhoneNumberFormatterLandLineWithoutAreaCode stringFromNumber:a_number];
    }else if(l_number>=100000000 && l_number<=9999999999) {
        BOOL l_isMobileRange = l_number>=400000000 && l_number<=599999999;
        BOOL l_isSpecialRange = l_number>=1000000000 && l_number<=1999999999; // e.g. 1300 and 1800 numbers
        if (l_isMobileRange || l_isSpecialRange) {
            NSString *l_formattedNumberWithoutGrouping = [c_australianPhoneNumberFormatterMobileAndSpecialWithoutGrouping stringFromNumber:a_number];
            NSString *l_group1 = [l_formattedNumberWithoutGrouping substringWithRange:NSMakeRange(0, 4)];
            NSString *l_group2 = [l_formattedNumberWithoutGrouping substringWithRange:NSMakeRange(4, 3)];
            NSString *l_group3 = [l_formattedNumberWithoutGrouping substringWithRange:NSMakeRange(7, 3)];
            return [NSString stringWithFormat:@"%@ %@ %@", l_group1, l_group2, l_group3];
        }else{
            return [c_australianPhoneNumberFormatterLandLineWithAreaCode stringFromNumber:a_number];
        }
    } else {
        // No formatting possible
        return l_numberString;
    }
}

+ (NSString *)ifa_stringFromAustralianPhoneNumberString:(NSString *)a_phoneNumberString {
    NSString *l_normalisedPhoneNumberString = [a_phoneNumberString ifa_stringWithNumbersOnly];
    NSInteger l_phoneNumberInteger = l_normalisedPhoneNumberString.integerValue;
    if (l_phoneNumberInteger) {
        return [NSNumberFormatter ifa_stringFromAustralianPhoneNumber:@(l_phoneNumberInteger)];
    }else{  // Not possible to format
        return a_phoneNumberString;
    }
}

@end