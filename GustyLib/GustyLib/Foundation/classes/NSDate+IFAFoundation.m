//
//  NSDate+IFACategory.m
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

#import "GustyLibFoundation.h"

@implementation NSDate (IFAFoundation)

#pragma mark - Private

- (NSDateComponents*)dayDateComponentsForDate:(NSDate*)aDate calendar:(NSCalendar*)a_calendar{
	unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
	return [a_calendar components:unitFlags fromDate:aDate];
}

- (NSDateComponents*)dayDateComponentsForCalendar:(NSCalendar*)a_calendar{
	return [self dayDateComponentsForDate:self calendar:a_calendar];
}

#pragma mark - Public

- (NSDate*)ifa_lastMidnightForCalendar:(NSCalendar*)a_calendar{
	return [a_calendar dateFromComponents:[self dayDateComponentsForCalendar:a_calendar]];
}

- (NSDate*)ifa_nextMidnightForCalendar:(NSCalendar*)a_calendar{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:1];
	NSDate *date = [a_calendar dateByAddingComponents:comps toDate:[self ifa_lastMidnightForCalendar:a_calendar] options:0];
	return date;
}

- (NSDate*)ifa_lastSecondForCalendar:(NSCalendar*)a_calendar{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setSecond:-1];
	NSDate *date = [a_calendar dateByAddingComponents:comps toDate:[self ifa_nextMidnightForCalendar:a_calendar] options:0];
	return date;
}

- (BOOL)ifa_isSameDay:(NSDate *)anotherDate calendar:(NSCalendar*)a_calendar{
	NSDateComponents *l_myDayComponents = [self dayDateComponentsForCalendar:a_calendar];
	NSDateComponents *l_theOtherDayComponents = [self dayDateComponentsForDate:anotherDate calendar:a_calendar];
    NSDate *l_myDateFromComponents = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_myDayComponents];
    NSDate *l_theOtherDateFromComponents = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_theOtherDayComponents];
    return [l_myDateFromComponents isEqualToDate:l_theOtherDateFromComponents];
}

- (BOOL)ifa_isTodayForCalendar:(NSCalendar*)a_calendar{
	return [self ifa_isSameDay:[NSDate ifa_lastMidnightForCalendar:a_calendar] calendar:a_calendar];
}

- (BOOL)ifa_isBetweenDate:(NSDate *)aStartDate andDate:(NSDate*)anEndDate{
	return [NSDate ifa_isDate:self betweenDate:aStartDate andDate:anEndDate];
}

- (IFADateRange *)ifa_fullDayRangeForCalendar:(NSCalendar*)a_calendar{
	return [[IFADateRange alloc] initWithStartTimestamp:[self ifa_lastMidnightForCalendar:a_calendar] endTimestamp:[self ifa_nextMidnightForCalendar:a_calendar]];
}

- (IFADateRange *)ifa_dateRangeForUnit:(NSCalendarUnit)aUnit calendar:(NSCalendar *)a_calendar exclusiveEnd:(BOOL)anExclusiveEndFlag{
	NSDate *startTimestamp, *endTimestamp;
	NSTimeInterval interval;
	[a_calendar rangeOfUnit:aUnit startDate:&startTimestamp interval:&interval forDate:self];
	if (!anExclusiveEndFlag) {
		interval--;
	}
	endTimestamp = [startTimestamp dateByAddingTimeInterval:interval];
	return [[IFADateRange alloc] initWithStartTimestamp:startTimestamp endTimestamp:endTimestamp];
}

- (IFADateRange *)ifa_dateRangeForUnit:(NSCalendarUnit)aUnit calendar:(NSCalendar*)a_calendar{
	return [self ifa_dateRangeForUnit:aUnit calendar:a_calendar exclusiveEnd:YES];
}

- (NSString*)ifa_formatAsDate {
    return [self ifa_formatAsDateWithRelativeDateFormatting:YES];
}

- (NSString*)ifa_formatAsDateWithRelativeDateFormatting:(BOOL)a_doesRelativeDateFormating{
    NSDateFormatter *l_dateFormatter = [NSDate ifa_dateFormatter];
    l_dateFormatter.doesRelativeDateFormatting = a_doesRelativeDateFormating;
    return [l_dateFormatter stringFromDate:self];
}

- (NSString*)ifa_formatAsTime {
    return [[NSDate ifa_timeFormatter] stringFromDate:self];
}

- (NSString*)ifa_formatAsDateAndTime {
    return [self ifa_formatAsDateAndTimeWithRelativeDateFormatting:YES];
}

- (NSString*)ifa_formatAsDateAndTimeWithRelativeDateFormatting:(BOOL)a_doesRelativeDateFormating{
    NSDateFormatter *l_dateFormatter = [NSDate ifa_dateAndTimeFormatter];
    l_dateFormatter.doesRelativeDateFormatting = a_doesRelativeDateFormating;
    return [l_dateFormatter stringFromDate:self];
}

-(NSString *)ifa_descriptionWithCurrentLocale {
    return [self descriptionWithLocale:[NSLocale currentLocale]];
}

- (NSDate*)ifa_addDays:(NSInteger)a_days calendar:(NSCalendar*)a_calendar{
	NSDateComponents *comps = [[NSDateComponents alloc] init];
	[comps setDay:a_days];
	return [a_calendar dateByAddingComponents:comps toDate:self options:0];
}

-(NSDate *)ifa_withSecondPrecision {
    NSTimeInterval l_timeInterval = [self timeIntervalSinceReferenceDate];
    //    NSLog(@"l_timeInterval: %f", l_timeInterval);
    NSDecimalNumber *l_decimalNumber = [[NSDecimalNumber alloc] initWithDouble:l_timeInterval];
    //    NSLog(@"l_decimalNumber: %@", [l_decimalNumber description]);
    NSDecimalNumberHandler *l_decimalNumberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:YES raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES];
    NSDecimalNumber *l_roundedDecimalNumber = [l_decimalNumber decimalNumberByRoundingAccordingToBehavior:l_decimalNumberHandler];
    //    NSLog(@"l_roundedDecimalNumber: %@", [l_roundedDecimalNumber description]);
    NSDate *l_date = [NSDate dateWithTimeIntervalSinceReferenceDate:l_roundedDecimalNumber.doubleValue];
    //    NSLog(@"l_date: %@", [l_date ifa_descriptionWithCurrentLocale]);
    return l_date;
}

+ (NSDate*)ifa_dateWithSecondPrecision {
    return [[NSDate date] ifa_withSecondPrecision];
}

+ (NSDate*)ifa_lastMidnightForCalendar:(NSCalendar*)a_calendar{
	return [[NSDate date] ifa_lastMidnightForCalendar:a_calendar];
}

+ (BOOL)ifa_isDate:(NSDate *)aDate betweenDate:(NSDate *)aStartDate andDate:(NSDate*)anEndDate{
	if (aStartDate && anEndDate) {
		NSTimeInterval startInterval = [aDate timeIntervalSinceDate:aStartDate];
		NSTimeInterval endInterval = [anEndDate timeIntervalSinceDate:aDate];
		return startInterval>=0 && endInterval>=0;
	}else{
		return NO;
	}
}

+ (NSDateFormatter*)ifa_dateAndTimeFormatter {
	static NSDateFormatter *dateAndTimeFormatter;
	if (!dateAndTimeFormatter) {
		dateAndTimeFormatter = [[NSDateFormatter alloc] init];
		[dateAndTimeFormatter setDoesRelativeDateFormatting:YES];
		[dateAndTimeFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateAndTimeFormatter setTimeStyle:NSDateFormatterMediumStyle];
	}
	return dateAndTimeFormatter;
}

+ (NSDateFormatter*)ifa_dateFormatter {
	static NSDateFormatter *dateFormatter;
	if (!dateFormatter) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDoesRelativeDateFormatting:YES];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	}
	return dateFormatter;
}

+ (NSDateFormatter*)ifa_timeFormatter {
	static NSDateFormatter *timeFormatter;
	if (!timeFormatter) {
		timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setDateStyle:NSDateFormatterNoStyle];
		[timeFormatter setTimeStyle:NSDateFormatterMediumStyle];
	}
	return timeFormatter;
}

@end
