//
//  NSDateTest.m
//  Gusty
//
//  Created by Marcelo Schroeder on 1/11/10.
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

#import "NSDateTest.h"
#import "GustyLib.h"

@interface NSDateTest ()

- (NSDate*)testDate;

@end

@implementation NSDateTest

- (void) testLastMidnight {
	
	NSDate* lastMidnight = [[self testDate] ifa_lastMidnightForCalendar:[NSCalendar ifa_threadSafeCalendar]];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents* comps = [[NSCalendar ifa_threadSafeCalendar] components:unitFlags fromDate:lastMidnight];
	
	XCTAssertEqual([comps day], 26);
	XCTAssertEqual([comps month], 2);
	XCTAssertEqual([comps year], 1970);
	XCTAssertEqual([comps hour], 0);
	XCTAssertEqual([comps minute], 0);
	XCTAssertEqual([comps second], 0);
	
}

- (void) testNextMidnight {
	
	NSDate* lastMidnight = [[self testDate] ifa_nextMidnightForCalendar:[NSCalendar ifa_threadSafeCalendar]];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents* comps = [[NSCalendar ifa_threadSafeCalendar] components:unitFlags fromDate:lastMidnight];
	
	XCTAssertEqual([comps day], 27);
	XCTAssertEqual([comps month], 2);
	XCTAssertEqual([comps year], 1970);
	XCTAssertEqual([comps hour], 0);
	XCTAssertEqual([comps minute], 0);
	XCTAssertEqual([comps second], 0);
	
}

-(void)testIFA_isSameDay{
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:1];
        [l_date1Components setMinute:2];
        [l_date1Components setSecond:3];
        NSDate *l_date1 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:4];
        [l_date2Components setMinute:5];
        [l_date2Components setSecond:6];
        NSDate *l_date2 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        XCTAssertTrue([l_date1 ifa_isSameDay:l_date2 calendar:[NSCalendar ifa_threadSafeCalendar]]);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:1];
        [l_date1Components setMinute:2];
        [l_date1Components setSecond:3];
        NSDate *l_date1 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:9];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:4];
        [l_date2Components setMinute:5];
        [l_date2Components setSecond:6];
        NSDate *l_date2 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        XCTAssertFalse([l_date1 ifa_isSameDay:l_date2 calendar:[NSCalendar ifa_threadSafeCalendar]]);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:1];
        [l_date1Components setMinute:2];
        [l_date1Components setSecond:3];
        NSDate *l_date1 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:1];
        [l_date2Components setMinute:2];
        [l_date2Components setSecond:3];
        NSDate *l_date2 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        XCTAssertTrue([l_date1 ifa_isSameDay:l_date2 calendar:[NSCalendar ifa_threadSafeCalendar]]);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:1];
        [l_date1Components setMinute:2];
        [l_date1Components setSecond:3];
        NSDate *l_date1 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:9];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:1];
        [l_date2Components setMinute:2];
        [l_date2Components setSecond:3];
        NSDate *l_date2 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        XCTAssertFalse([l_date1 ifa_isSameDay:l_date2 calendar:[NSCalendar ifa_threadSafeCalendar]]);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:1];
        [l_date1Components setMinute:2];
        [l_date1Components setSecond:3];
        NSDate *l_date1 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2011];
        [l_date2Components setHour:1];
        [l_date2Components setMinute:2];
        [l_date2Components setSecond:3];
        NSDate *l_date2 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        XCTAssertFalse([l_date1 ifa_isSameDay:l_date2 calendar:[NSCalendar ifa_threadSafeCalendar]]);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:0];
        [l_date1Components setMinute:0];
        [l_date1Components setSecond:0];
        NSDate *l_date1 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:23];
        [l_date2Components setMinute:59];
        [l_date2Components setSecond:59];
        NSDate *l_date2 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        XCTAssertTrue([l_date1 ifa_isSameDay:l_date2 calendar:[NSCalendar ifa_threadSafeCalendar]]);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:0];
        [l_date1Components setMinute:0];
        [l_date1Components setSecond:0];
        NSDate *l_date1 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:17];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:0];
        [l_date2Components setMinute:0];
        [l_date2Components setSecond:0];
        NSDate *l_date2 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        XCTAssertFalse([l_date1 ifa_isSameDay:l_date2 calendar:[NSCalendar ifa_threadSafeCalendar]]);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:0];
        [l_date1Components setMinute:0];
        [l_date1Components setSecond:0];
        NSDate *l_date1 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:0];
        [l_date2Components setMinute:0];
        [l_date2Components setSecond:0];
        NSDate *l_date2 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        XCTAssertTrue([l_date1 ifa_isSameDay:l_date2 calendar:[NSCalendar ifa_threadSafeCalendar]]);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:23];
        [l_date1Components setMinute:23];
        [l_date1Components setSecond:59];
        NSDate *l_date1 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:23];
        [l_date2Components setMinute:59];
        [l_date2Components setSecond:59];
        NSDate *l_date2 = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        XCTAssertTrue([l_date1 ifa_isSameDay:l_date2 calendar:[NSCalendar ifa_threadSafeCalendar]]);
        
    }

}

#pragma mark -
#pragma mark Private

- (NSDate*)testDate{
	NSDateComponents* comps = [[NSDateComponents alloc] init];
	[comps setDay:26];
	[comps setMonth:2];
	[comps setYear:1970];
	[comps setHour:1];
	[comps setMinute:2];
	[comps setSecond:3];
	NSDate *date = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:comps];
	return date;
}

@end
