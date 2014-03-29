//
// Created by Marcelo Schroeder on 13/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumberFormatter (IACategory)
+ (NSString *)m_stringFromAustralianPhoneNumber:(NSNumber *)a_number;
+ (NSString *)m_stringFromAustralianPhoneNumberString:(NSString *)a_phoneNumberString;
@end