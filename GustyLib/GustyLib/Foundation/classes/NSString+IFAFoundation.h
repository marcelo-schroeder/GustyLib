//
//  NSString+IFACategory.h
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

#import <Foundation/Foundation.h>

@interface NSString (IFAFoundation)

-(NSString*)ifa_stringByKeepingCharactersInSet:(NSCharacterSet*)a_characterSet;
-(NSString*)ifa_stringByRemovingNewLineCharacters;
-(NSString*)ifa_stringByTrimming;
-(BOOL)ifa_isEmpty;

-(BOOL)ifa_validateEmailAddress;

- (NSString *)ifa_stringByReplacingOccurrencesOfRegexPattern:(NSString *)a_regexPattern
                                                  usingBlock:(NSString * (^)(NSString *a_matchedString))a_block;

- (NSArray *)ifa_characters;

- (NSString *)ifa_stringMatchingSet:(NSCharacterSet *)a_characterSet;

- (NSString *)ifa_stringWithNumbersOnly;

+ (instancetype)ifa_stringWithFormat:(NSString *)a_format array:(NSArray*)a_arguments;

@end
