//
//  NSDate+IFACategory.h
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

@class IFADateRange;

@interface NSDate (IFAFoundation)

- (NSDate*)ifa_lastMidnightForCalendar:(NSCalendar*)a_calendar;
- (NSDate*)ifa_nextMidnightForCalendar:(NSCalendar*)a_calendar;
- (NSDate*)ifa_lastSecondForCalendar:(NSCalendar*)a_calendar;
- (BOOL)ifa_isSameDay:(NSDate *)anotherDate calendar:(NSCalendar*)a_calendar;
- (BOOL)ifa_isTodayForCalendar:(NSCalendar*)a_calendar;
- (BOOL)ifa_isBetweenDate:(NSDate *)aStartDate andDate:(NSDate*)anEndDate;
- (IFADateRange *)ifa_fullDayRangeForCalendar:(NSCalendar*)a_calendar;
- (IFADateRange *)ifa_dateRangeForUnit:(NSCalendarUnit)aUnit calendar:(NSCalendar*)a_calendar;
- (IFADateRange *)ifa_dateRangeForUnit:(NSCalendarUnit)aUnit calendar:(NSCalendar *)a_calendar exclusiveEnd:(BOOL)anExclusiveEndFlag;
- (NSString*)ifa_formatAsDate;
- (NSString*)ifa_formatAsDateWithRelativeDateFormatting:(BOOL)a_doesRelativeDateFormating;
- (NSString*)ifa_formatAsTime;
- (NSString*)ifa_formatAsDateAndTime;
- (NSString*)ifa_formatAsDateAndTimeWithRelativeDateFormatting:(BOOL)a_doesRelativeDateFormating;
- (NSString*)ifa_descriptionWithCurrentLocale;
- (NSDate*)ifa_addDays:(NSInteger)a_days calendar:(NSCalendar*)a_calendar;
- (NSDate*)ifa_withSecondPrecision;

+ (NSDate*)ifa_dateWithSecondPrecision;
+ (NSDate*)ifa_lastMidnightForCalendar:(NSCalendar*)a_calendar;
+ (BOOL)ifa_isDate:(NSDate *)aDate betweenDate:(NSDate *)aStartDate andDate:(NSDate*)anEndDate;
+ (NSDateFormatter*)ifa_dateFormatter;
+ (NSDateFormatter*)ifa_timeFormatter;
+ (NSDateFormatter*)ifa_dateAndTimeFormatter;

@end
