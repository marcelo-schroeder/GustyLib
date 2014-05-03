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

- (NSDate*)IFA_lastMidnightForCalendar:(NSCalendar*)a_calendar;
- (NSDate*)IFA_nextMidnightForCalendar:(NSCalendar*)a_calendar;
- (NSDate*)IFA_lastSecondForCalendar:(NSCalendar*)a_calendar;
- (BOOL)IFA_isSameDay:(NSDate *)anotherDate calendar:(NSCalendar*)a_calendar;
- (BOOL)IFA_isTodayForCalendar:(NSCalendar*)a_calendar;
- (BOOL)IFA_isBetweenDate:(NSDate *)aStartDate andDate:(NSDate*)anEndDate;
- (IADateRange*)IFA_fullDayRangeForCalendar:(NSCalendar*)a_calendar;
- (IADateRange*)IFA_dateRangeForUnit:(NSCalendarUnit)aUnit calendar:(NSCalendar*)a_calendar;
- (IADateRange*)IFA_dateRangeForUnit:(NSCalendarUnit)aUnit calendar:(NSCalendar *)a_calendar exclusiveEnd:(BOOL)anExclusiveEndFlag;
- (NSString*)IFA_formatAsDate;
- (NSString*)IFA_formatAsDateWithRelativeDateFormatting:(BOOL)a_doesRelativeDateFormating;
- (NSString*)IFA_formatAsTime;
- (NSString*)IFA_formatAsDateAndTime;
- (NSString*)IFA_formatAsDateAndTimeWithRelativeDateFormatting:(BOOL)a_doesRelativeDateFormating;
- (NSString*)IFA_descriptionWithCurrentLocale;
- (NSDate*)IFA_addDays:(NSInteger)a_days calendar:(NSCalendar*)a_calendar;
- (NSDate*)IFA_withSecondPrecision;

+ (NSDate*)IFA_dateWithSecondPrecision;
+ (NSDate*)IFA_lastMidnightForCalendar:(NSCalendar*)a_calendar;
+ (BOOL)IFA_isDate:(NSDate *)aDate betweenDate:(NSDate *)aStartDate andDate:(NSDate*)anEndDate;
+ (NSDateFormatter*)IFA_dateFormatter;
+ (NSDateFormatter*)IFA_timeFormatter;
+ (NSDateFormatter*)IFA_dateAndTimeFormatter;

@end
