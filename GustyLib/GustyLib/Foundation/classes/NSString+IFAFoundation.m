//
//  NSString+IFACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 24/11/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

@implementation NSString (IFAFoundation)

#pragma mark - Public

-(NSString*)ifa_stringByKeepingCharactersInSet:(NSCharacterSet*)a_characterSet{
    NSCharacterSet *l_charactersToRemove = [a_characterSet invertedSet];
    return [[self componentsSeparatedByCharactersInSet:l_charactersToRemove] componentsJoinedByString:@""];
}

-(NSString*)ifa_stringByRemovingNewLineCharacters {
    return [[self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
}

-(NSString*)ifa_stringByTrimming {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(BOOL)ifa_isEmpty {
    return [[self ifa_stringByTrimming] isEqualToString:@""];
}

-(BOOL)ifa_validateEmailAddress {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

-(NSString *)ifa_stringByReplacingOccurrencesOfRegexPattern:(NSString *)a_regexPattern usingBlock:(NSString * (^)(NSString *a_matchedString))a_block{
    NSString *l_inputString = self;
    NSMutableString *l_outputString = [@"" mutableCopy];
    NSRegularExpression *l_regex = [NSRegularExpression
            regularExpressionWithPattern:a_regexPattern
                                 options:NSRegularExpressionCaseInsensitive
                                   error:nil];
    __block NSUInteger l_previousEndLocation = 0;
    [l_regex enumerateMatchesInString:l_inputString
                              options:0
                                range:NSMakeRange(0, [l_inputString length])
                           usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                               NSRange l_previousUnmodifiedRange = {
                                       .location = l_previousEndLocation,
                                       .length = match.range.location - l_previousEndLocation
                               };
                               [l_outputString appendString:[l_inputString substringWithRange:l_previousUnmodifiedRange]];
                               NSString *l_matchedString = [l_inputString substringWithRange:match.range];
                               [l_outputString appendString:a_block(l_matchedString)];
                               l_previousEndLocation = match.range.location + match.range.length;
                           }];

    NSRange l_previousUnmodifiedRange = {
            .location = l_previousEndLocation,
            .length = [l_inputString length] - l_previousEndLocation
    };
    [l_outputString appendString:[l_inputString substringWithRange:l_previousUnmodifiedRange]];
    return l_outputString;
}

+ (instancetype)ifa_stringWithFormat:(NSString *)a_format array:(NSArray *)a_arguments {
    NSMutableString *string = a_format.mutableCopy;
    for (NSString *currentReplacement in a_arguments) {
        [string replaceCharactersInRange:[string rangeOfString:@"%@"] withString:currentReplacement];
    }
    return string;
}

- (NSArray *)ifa_characters {
    NSMutableArray *l_characters = [@[] mutableCopy];
    for (NSUInteger i = 0; i < self.length; i++) {
        [l_characters addObject:[self substringWithRange:NSMakeRange(i, 1)]];
    }
    return l_characters;
}

- (NSString *)ifa_stringMatchingSet:(NSCharacterSet *)a_characterSet{
    NSScanner *l_scanner = [NSScanner scannerWithString:self];
    NSMutableString *l_result = [@"" mutableCopy];
    while (![l_scanner isAtEnd]) {
        NSString *l_buffer;
        if ([l_scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&l_buffer]) {
            [l_result appendString:l_buffer];
        } else {
            [l_scanner setScanLocation:([l_scanner scanLocation] + 1)];
        }
    }
    return l_result;
}

- (NSString *)ifa_stringWithNumbersOnly {
    NSCharacterSet *l_numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    return [self ifa_stringMatchingSet:l_numbers];
}

@end
