//
// Created by Marcelo Schroeder on 13/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "NSNumberFormatter+IACategory.h"


@implementation NSNumberFormatter (IACategory)

static NSNumberFormatter *c_australianPhoneNumberFormatterLandLineWithoutAreaCode = nil;
static NSNumberFormatter *c_australianPhoneNumberFormatterLandLineWithAreaCode = nil;
static NSNumberFormatter *c_australianPhoneNumberFormatterMobileAndSpecialWithoutGrouping = nil;

#pragma mark - Private

+ (void)m_configureAustralianPhoneNumberFormatter:(NSNumberFormatter *)a_numberFormatter{
    a_numberFormatter.groupingSeparator = @" ";
}

+ (void)m_createAustralianPhoneNumberFormattersIfRequired {

    static dispatch_once_t c_dispatchOncePredicate;
    dispatch_once(&c_dispatchOncePredicate, ^{

        c_australianPhoneNumberFormatterLandLineWithoutAreaCode = [[NSNumberFormatter alloc] init];
        c_australianPhoneNumberFormatterLandLineWithoutAreaCode.positiveFormat = @"0000,0000";
        [self m_configureAustralianPhoneNumberFormatter:c_australianPhoneNumberFormatterLandLineWithoutAreaCode];

        c_australianPhoneNumberFormatterLandLineWithAreaCode = [[NSNumberFormatter alloc] init];
        c_australianPhoneNumberFormatterLandLineWithAreaCode.positiveFormat = @"00,0000,0000";
        [self m_configureAustralianPhoneNumberFormatter:c_australianPhoneNumberFormatterLandLineWithAreaCode];

        c_australianPhoneNumberFormatterMobileAndSpecialWithoutGrouping = [[NSNumberFormatter alloc] init];
        c_australianPhoneNumberFormatterMobileAndSpecialWithoutGrouping.positiveFormat = @"0000000000";
        [self m_configureAustralianPhoneNumberFormatter:c_australianPhoneNumberFormatterMobileAndSpecialWithoutGrouping];

    });

}

#pragma mark - Public

+ (NSString *)m_stringFromAustralianPhoneNumber:(NSNumber *)a_number{
    [self m_createAustralianPhoneNumberFormattersIfRequired];
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

+ (NSString *)m_stringFromAustralianPhoneNumberString:(NSString *)a_phoneNumberString {
    NSString *l_normalisedPhoneNumberString = [a_phoneNumberString m_stringWithNumbersOnly];
    NSInteger l_phoneNumberInteger = l_normalisedPhoneNumberString.integerValue;
    if (l_phoneNumberInteger) {
        return [NSNumberFormatter m_stringFromAustralianPhoneNumber:@(l_phoneNumberInteger)];
    }else{  // Not possible to format
        return a_phoneNumberString;
    }
}

@end