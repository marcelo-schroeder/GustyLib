//
//  NSDate+IACategory.h
//  Gusty
//
//  Created by Marcelo Schroeder on 20/09/10.
//  Copyright 2010 InfoAccent Pty Limited. All rights reserved.
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

@class IADateRange;

@interface NSDate (IACategory)

- (NSDate*)lastMidnightForCalendar:(NSCalendar*)a_calendar;
- (NSDate*)nextMidnightForCalendar:(NSCalendar*)a_calendar;
- (NSDate*)lastSecondForCalendar:(NSCalendar*)a_calendar;
- (BOOL)isSameDay:(NSDate*)anotherDate calendar:(NSCalendar*)a_calendar;
- (BOOL)isTodayForCalendar:(NSCalendar*)a_calendar;
- (BOOL)isBetweenDate:(NSDate*)aStartDate andDate:(NSDate*)anEndDate;
- (IADateRange*)fullDayRangeForCalendar:(NSCalendar*)a_calendar;
- (IADateRange*) dateRangeForUnit:(NSCalendarUnit)aUnit calendar:(NSCalendar*)a_calendar;
- (IADateRange*) dateRangeForUnit:(NSCalendarUnit)aUnit calendar:(NSCalendar*)a_calendar exclusiveEnd:(BOOL)anExclusiveEndFlag;
- (NSString*)formatAsDate;
- (NSString*)formatAsDateWithRelativeDateFormatting:(BOOL)a_doesRelativeDateFormating;
- (NSString*)formatAsTime;
- (NSString*)formatAsDateAndTime;
- (NSString*)formatAsDateAndTimeWithRelativeDateFormatting:(BOOL)a_doesRelativeDateFormating;
- (NSString*)descriptionWithCurrentLocale;
- (NSDate*)addDays:(NSInteger)a_days calendar:(NSCalendar*)a_calendar;
- (NSDate*)withSecondPrecision;

+ (NSDate*)dateWithSecondPrecision;
+ (NSDate*)lastMidnightForCalendar:(NSCalendar*)a_calendar;
+ (BOOL)isDate:(NSDate*)aDate betweenDate:(NSDate*)aStartDate andDate:(NSDate*)anEndDate;
+ (NSDateFormatter*)dateFormatter;
+ (NSDateFormatter*)timeFormatter;
+ (NSDateFormatter*)dateAndTimeFormatter;

@end
