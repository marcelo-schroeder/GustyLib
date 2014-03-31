//
//  IADateRangeTest.m
//  Gusty
//
//  Created by Marcelo Schroeder on 9/11/10.
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

#import "IADateRangeTest.h"
#import "IACommon.h"


@interface IADateRangeTest ()

- (NSDateComponents*)referenceDateComponents;
- (NSDateComponents*)nextReferenceDateComponents;

@end


@implementation IADateRangeTest

- (void)testDurationStringForStartDateWithFullFormat {
    
	NSDateComponents* comps;
	NSDate *startTimestamp;
	NSDate *endTimestamp;
	
	// 0s
	comps = [self referenceDateComponents];
	startTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"00:00:00");
	
	// 1s
	comps = [self referenceDateComponents];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"00:00:01");
	
	// 1m0s
	comps = [self referenceDateComponents];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"00:01:00");
	
	// 1m1s
	comps = [self referenceDateComponents];
	[comps setMinute:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"00:01:01");
	
	// 1h0m0s
	comps = [self referenceDateComponents];
	[comps setHour:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"01:00:00");
	
	// 1h0m1s
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"01:00:01");
	
	// 1h1m0s
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"01:01:00");
	
	// 1h1m1s
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setMinute:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"01:01:01");
	
	// 1d0h0m0s
	comps = [self nextReferenceDateComponents];
	[comps setDay:27];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"1d 00:00:00");
	
	// 1d0h0m1s
	comps = [self nextReferenceDateComponents];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"1d 00:00:01");
	
	// 1d0h1m0s
	comps = [self nextReferenceDateComponents];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"1d 00:01:00");
	
	// 1d0h1m1s
	comps = [self nextReferenceDateComponents];
	[comps setMinute:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"1d 00:01:01");
	
	// 1d1h0m0s
	comps = [self nextReferenceDateComponents];
	[comps setHour:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"1d 01:00:00");
	
	// 1d1h0m1s
	comps = [self nextReferenceDateComponents];
	[comps setHour:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"1d 01:00:01");
	
	// 1d1h1m0s
	comps = [self nextReferenceDateComponents];
	[comps setHour:1];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"1d 01:01:00");
	
	// 1d1h1m1s
	comps = [self nextReferenceDateComponents];
	[comps setHour:1];
	[comps setMinute:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_FULL calendar:[NSCalendar m_threadSafeCalendar]], @"1d 01:01:01");
    
}

- (void)testDurationStringForStartDateWithHoursMinutesSecondsFormat {
    
	NSDateComponents* comps;
	NSDate *startTimestamp;
	NSDate *endTimestamp;
	
	// 0s
	comps = [self referenceDateComponents];
	startTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"00:00:00");
	
	// 1s
	comps = [self referenceDateComponents];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"00:00:01");
	
	// 1m0s
	comps = [self referenceDateComponents];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"00:01:00");
	
	// 1m1s
	comps = [self referenceDateComponents];
	[comps setMinute:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"00:01:01");
	
	// 1h0m0s
	comps = [self referenceDateComponents];
	[comps setHour:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"01:00:00");
	
	// 1h0m1s
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"01:00:01");
	
	// 1h1m0s
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"01:01:00");
	
	// 1h1m1s
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setMinute:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"01:01:01");
	
	// 1d0h0m0s
	comps = [self nextReferenceDateComponents];
	[comps setDay:27];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"24:00:00");
	
	// 1d0h0m1s
	comps = [self nextReferenceDateComponents];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"24:00:01");
	
	// 1d0h1m0s
	comps = [self nextReferenceDateComponents];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"24:01:00");
	
	// 1d0h1m1s
	comps = [self nextReferenceDateComponents];
	[comps setMinute:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"24:01:01");
	
	// 1d1h0m0s
	comps = [self nextReferenceDateComponents];
	[comps setHour:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"25:00:00");
	
	// 1d1h0m1s
	comps = [self nextReferenceDateComponents];
	[comps setHour:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"25:00:01");
	
	// 1d1h1m0s
	comps = [self nextReferenceDateComponents];
	[comps setHour:1];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"25:01:00");
	
	// 1d1h1m1s
	comps = [self nextReferenceDateComponents];
	[comps setHour:1];
	[comps setMinute:1];
	[comps setSecond:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_SECONDS calendar:[NSCalendar m_threadSafeCalendar]], @"25:01:01");
    
}

- (void)testDurationStringForStartDateWithHoursMinutesFormat {
    
	NSDateComponents* comps;
	NSDate *startTimestamp;
	NSDate *endTimestamp;
	
	// 0m
	comps = [self referenceDateComponents];
	startTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES calendar:[NSCalendar m_threadSafeCalendar]], @"00:00");
	
	// 1m
	comps = [self referenceDateComponents];
	startTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	[comps setHour:0];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES calendar:[NSCalendar m_threadSafeCalendar]], @"00:01");
	
	// 2m
	comps = [self referenceDateComponents];
	[comps setHour:0];
	[comps setMinute:2];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES calendar:[NSCalendar m_threadSafeCalendar]], @"00:02");
	
	// 1h
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setMinute:0];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES calendar:[NSCalendar m_threadSafeCalendar]], @"01:00");
	
	// 2h
	comps = [self referenceDateComponents];
	[comps setHour:2];
	[comps setMinute:0];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES calendar:[NSCalendar m_threadSafeCalendar]], @"02:00");
	
	// 1h 1m
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES calendar:[NSCalendar m_threadSafeCalendar]], @"01:01");
	
	// 1h 2m
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setMinute:2];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES calendar:[NSCalendar m_threadSafeCalendar]], @"01:02");
	
	// 2h 1m
	comps = [self referenceDateComponents];
	[comps setHour:2];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES calendar:[NSCalendar m_threadSafeCalendar]], @"02:01");
	
	// 2h 2m
	comps = [self referenceDateComponents];
	[comps setHour:2];
	[comps setMinute:2];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES calendar:[NSCalendar m_threadSafeCalendar]], @"02:02");
    
}

- (void)testDurationStringForStartDateWithHoursMinutesLongFormat {
    
	NSDateComponents* comps;
	NSDate *startTimestamp;
	NSDate *endTimestamp;
	
	// 0 minutes
	comps = [self referenceDateComponents];
	startTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_LONG calendar:[NSCalendar m_threadSafeCalendar]], @"0 minutes");
	
	// 1 minute
	comps = [self referenceDateComponents];
	startTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	[comps setHour:0];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_LONG calendar:[NSCalendar m_threadSafeCalendar]], @"1 minute");
	
	// 2 minutes
	comps = [self referenceDateComponents];
	[comps setHour:0];
	[comps setMinute:2];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_LONG calendar:[NSCalendar m_threadSafeCalendar]], @"2 minutes");
	
	// 1 hour
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setMinute:0];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_LONG calendar:[NSCalendar m_threadSafeCalendar]], @"1 hour");
	
	// 2 hours
	comps = [self referenceDateComponents];
	[comps setHour:2];
	[comps setMinute:0];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_LONG calendar:[NSCalendar m_threadSafeCalendar]], @"2 hours");
	
	// 1 hour, 1 minute
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_LONG calendar:[NSCalendar m_threadSafeCalendar]], @"1 hour, 1 minute");
	
	// 1 hour, 2 minutes
	comps = [self referenceDateComponents];
	[comps setHour:1];
	[comps setMinute:2];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_LONG calendar:[NSCalendar m_threadSafeCalendar]], @"1 hour, 2 minutes");
	
	// 2 hours, 1 minute
	comps = [self referenceDateComponents];
	[comps setHour:2];
	[comps setMinute:1];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_LONG calendar:[NSCalendar m_threadSafeCalendar]], @"2 hours, 1 minute");
	
	// 2 hours, 2 minutes
	comps = [self referenceDateComponents];
	[comps setHour:2];
	[comps setMinute:2];
	endTimestamp = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	XCTAssertEqualObjects([IADateRange durationStringForStartDate:startTimestamp endDate:endTimestamp format:IA_DURATION_FORMAT_HOURS_MINUTES_LONG calendar:[NSCalendar m_threadSafeCalendar]], @"2 hours, 2 minutes");
    
}

#pragma mark -
#pragma mark Private

- (NSDateComponents*)referenceDateComponents{
	NSDateComponents* comps = [[NSDateComponents alloc] init];
	[comps setDay:26];
	[comps setMonth:2];
	[comps setYear:1970];
	[comps setHour:0];
	[comps setMinute:0];
	[comps setSecond:0];
	return comps;
}

- (NSDateComponents*)nextReferenceDateComponents{
	NSDateComponents* comps = [self referenceDateComponents];
	[comps setDay:27];
	return comps;
}

@end
