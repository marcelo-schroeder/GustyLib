//
//  IFADateRange.h
//  Gusty
//
//  Created by Marcelo Schroeder on 3/11/10.
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

#import "IFAFoundationConstants.h"

@interface IFADateRange : NSObject {

}

@property (nonatomic, strong) NSDate* startTimestamp;
@property (nonatomic, strong) NSDate* endTimestamp;
@property (nonatomic, getter=isExclusiveEnd) BOOL exclusiveEnd;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (weak, nonatomic, readonly) NSDate* calculatedEndTimestamp;

- (id)initWithStartTimestamp:(NSDate*)aStartTimestamp endTimestamp:(NSDate*)anEndTimestamp;
- (id)initWithStartTimestamp:(NSDate*)aStartTimestamp endTimestamp:(NSDate*)anEndTimestamp exclusiveEnd:(BOOL)anExclusiveEndFlag;

- (NSString*)durationStringWithFormat:(IFADurationFormat)aFormat calendar:(NSCalendar*)a_calendar;

- (NSDecimalNumber*)decimalHoursForCalendar:(NSCalendar*)a_calendar;
- (NSString*)decimalHoursStringForCalendar:(NSCalendar*)a_calendar;
- (NSString*)formattedDecimalHoursForCalendar:(NSCalendar*)a_calendar;

+ (NSString*)durationStringForStartDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate format:(IFADurationFormat)aFormat calendar:(NSCalendar*)a_calendar;
+ (NSString*)durationStringForInterval:(NSTimeInterval)anInterval format:(IFADurationFormat)aFormat calendar:(NSCalendar*)a_calendar;
+ (NSDecimalNumber*)decimalHoursForStartDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate calendar:(NSCalendar*)a_calendar;
+ (NSDecimalNumber*)decimalHoursForInterval:(NSTimeInterval)anInterval calendar:(NSCalendar*)a_calendar;
+ (NSString*)decimalHoursStringForStartDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate calendar:(NSCalendar*)a_calendar;
+ (NSString*)formattedDecimalHours:(NSNumber*)a_decimalHours;
+ (NSString*)formattedDecimalHoursForInterval:(NSTimeInterval)anInterval calendar:(NSCalendar*)a_calendar;

@end
