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
#import "IACommon.h"

@interface NSDateTest ()

- (NSDate*)testDate;

@end

@implementation NSDateTest

- (void) testLastMidnight {
	
	NSDate* lastMidnight = [[self testDate] lastMidnightForCalendar:[NSCalendar m_threadSafeCalendar]];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents* comps = [[NSCalendar m_threadSafeCalendar] components:unitFlags fromDate:lastMidnight];
	
	STAssertEquals([comps day], 26, nil);
	STAssertEquals([comps month], 2, nil);
	STAssertEquals([comps year], 1970, nil);
	STAssertEquals([comps hour], 0, nil);
	STAssertEquals([comps minute], 0, nil);
	STAssertEquals([comps second], 0, nil);
	
}

- (void) testNextMidnight {
	
	NSDate* lastMidnight = [[self testDate] nextMidnightForCalendar:[NSCalendar m_threadSafeCalendar]];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents* comps = [[NSCalendar m_threadSafeCalendar] components:unitFlags fromDate:lastMidnight];
	
	STAssertEquals([comps day], 27, nil);
	STAssertEquals([comps month], 2, nil);
	STAssertEquals([comps year], 1970, nil);
	STAssertEquals([comps hour], 0, nil);
	STAssertEquals([comps minute], 0, nil);
	STAssertEquals([comps second], 0, nil);
	
}

-(void)testIsSameDay{
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:1];
        [l_date1Components setMinute:2];
        [l_date1Components setSecond:3];
        NSDate *l_date1 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:4];
        [l_date2Components setMinute:5];
        [l_date2Components setSecond:6];
        NSDate *l_date2 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        STAssertTrue([l_date1 isSameDay:l_date2 calendar:[NSCalendar m_threadSafeCalendar]], nil);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:1];
        [l_date1Components setMinute:2];
        [l_date1Components setSecond:3];
        NSDate *l_date1 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:9];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:4];
        [l_date2Components setMinute:5];
        [l_date2Components setSecond:6];
        NSDate *l_date2 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        STAssertFalse([l_date1 isSameDay:l_date2 calendar:[NSCalendar m_threadSafeCalendar]], nil);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:1];
        [l_date1Components setMinute:2];
        [l_date1Components setSecond:3];
        NSDate *l_date1 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:1];
        [l_date2Components setMinute:2];
        [l_date2Components setSecond:3];
        NSDate *l_date2 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        STAssertTrue([l_date1 isSameDay:l_date2 calendar:[NSCalendar m_threadSafeCalendar]], nil);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:1];
        [l_date1Components setMinute:2];
        [l_date1Components setSecond:3];
        NSDate *l_date1 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:9];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:1];
        [l_date2Components setMinute:2];
        [l_date2Components setSecond:3];
        NSDate *l_date2 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        STAssertFalse([l_date1 isSameDay:l_date2 calendar:[NSCalendar m_threadSafeCalendar]], nil);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:1];
        [l_date1Components setMinute:2];
        [l_date1Components setSecond:3];
        NSDate *l_date1 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2011];
        [l_date2Components setHour:1];
        [l_date2Components setMinute:2];
        [l_date2Components setSecond:3];
        NSDate *l_date2 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        STAssertFalse([l_date1 isSameDay:l_date2 calendar:[NSCalendar m_threadSafeCalendar]], nil);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:0];
        [l_date1Components setMinute:0];
        [l_date1Components setSecond:0];
        NSDate *l_date1 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:23];
        [l_date2Components setMinute:59];
        [l_date2Components setSecond:59];
        NSDate *l_date2 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        STAssertTrue([l_date1 isSameDay:l_date2 calendar:[NSCalendar m_threadSafeCalendar]], nil);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:0];
        [l_date1Components setMinute:0];
        [l_date1Components setSecond:0];
        NSDate *l_date1 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:17];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:0];
        [l_date2Components setMinute:0];
        [l_date2Components setSecond:0];
        NSDate *l_date2 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        STAssertFalse([l_date1 isSameDay:l_date2 calendar:[NSCalendar m_threadSafeCalendar]], nil);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:0];
        [l_date1Components setMinute:0];
        [l_date1Components setSecond:0];
        NSDate *l_date1 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:0];
        [l_date2Components setMinute:0];
        [l_date2Components setSecond:0];
        NSDate *l_date2 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        STAssertTrue([l_date1 isSameDay:l_date2 calendar:[NSCalendar m_threadSafeCalendar]], nil);
        
    }
    
    {
        
        NSDateComponents* l_date1Components = [[NSDateComponents alloc] init];
        [l_date1Components setDay:16];
        [l_date1Components setMonth:10];
        [l_date1Components setYear:2012];
        [l_date1Components setHour:23];
        [l_date1Components setMinute:23];
        [l_date1Components setSecond:59];
        NSDate *l_date1 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date1Components];
        
        NSDateComponents* l_date2Components = [[NSDateComponents alloc] init];
        [l_date2Components setDay:16];
        [l_date2Components setMonth:10];
        [l_date2Components setYear:2012];
        [l_date2Components setHour:23];
        [l_date2Components setMinute:59];
        [l_date2Components setSecond:59];
        NSDate *l_date2 = [[NSCalendar m_threadSafeCalendar] dateFromComponents:l_date2Components];
        
        STAssertTrue([l_date1 isSameDay:l_date2 calendar:[NSCalendar m_threadSafeCalendar]], nil);
        
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
	NSDate *date = [[NSCalendar m_threadSafeCalendar] dateFromComponents:comps];
	return date;
}

@end
