//
//  IFADateRange.m
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

#import "GustyLibFoundation.h"

@implementation IFADateRange


- (id)initWithStartTimestamp:(NSDate*)aStartTimestamp endTimestamp:(NSDate*)anEndTimestamp{
	return [self initWithStartTimestamp:aStartTimestamp endTimestamp:anEndTimestamp exclusiveEnd:YES];
}

- (id)initWithStartTimestamp:(NSDate*)aStartTimestamp endTimestamp:(NSDate*)anEndTimestamp exclusiveEnd:(BOOL)anExclusiveEndFlag{
	
	if (self=[super init]) {
		
		self.startTimestamp = aStartTimestamp;
		self.endTimestamp = anEndTimestamp;
		self.exclusiveEnd = anExclusiveEndFlag;
		
	}
	
	return self;
	
}

- (NSTimeInterval)duration{
//    NSLog(@"self.startTimestamp: %@, self.endTimestamp: %@", self.startTimestamp, self.endTimestamp);
	return [self.endTimestamp timeIntervalSinceDate:self.startTimestamp];
}

- (NSString*)durationStringWithFormat:(IFADurationFormat)aFormat calendar:(NSCalendar*)a_calendar{
	return [IFADateRange durationStringForStartDate:self.startTimestamp endDate:self.endTimestamp format:aFormat
                                           calendar:a_calendar];
}

- (NSString*)ifa_displayValue {
	if (self.startTimestamp || self.endTimestamp) {
		NSString* fromString = self.startTimestamp ? [[NSDate ifa_dateAndTimeFormatter] stringFromDate:self.startTimestamp] : @"";
		NSString* toString = self.endTimestamp ? [([self.endTimestamp ifa_isSameDay:self.startTimestamp
                                                                           calendar:[NSCalendar ifa_threadSafeCalendar]]? [NSDate ifa_timeFormatter]: [NSDate ifa_dateAndTimeFormatter]) stringFromDate:self.endTimestamp] : @"";
		return [NSString stringWithFormat:@"%@ - %@", fromString, toString];
	}else {
		return @"";
	}
}

- (NSDate*) calculatedEndTimestamp{
	return self.isExclusiveEnd ? self.endTimestamp : [self.endTimestamp dateByAddingTimeInterval:1];
}

- (NSDecimalNumber*)decimalHoursForCalendar:(NSCalendar*)a_calendar{
    return [IFADateRange decimalHoursForStartDate:self.startTimestamp endDate:self.endTimestamp calendar:a_calendar];
}

- (NSString*)decimalHoursStringForCalendar:(NSCalendar*)a_calendar{
    return [IFADateRange decimalHoursStringForStartDate:self.startTimestamp endDate:self.endTimestamp
                                               calendar:a_calendar];
}

- (NSString*)formattedDecimalHoursForCalendar:(NSCalendar*)a_calendar{
    return [self.class formattedDecimalHours:[self decimalHoursForCalendar:a_calendar]];
}

#pragma mark -
#pragma mark Class Methods

+ (NSString*)durationStringForStartDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate format:(IFADurationFormat)aFormat calendar:(NSCalendar*)a_calendar{
    
//	NSLog(@"durationStringForStartDate: %@", [aStartDate descriptionWithLocale:[NSLocale currentLocale]]);
//	NSLog(@"                   endDate: %@", [anEndDate descriptionWithLocale:[NSLocale currentLocale]]);

	if (anEndDate==nil) {
		return @"?";
	}

    if (aFormat== IFADurationFormatDecimalHours) {

        return [IFADateRange decimalHoursStringForStartDate:aStartDate endDate:anEndDate calendar:a_calendar];

    }else{
        
        //	NSUInteger unitFlags = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSUInteger unitFlags = NSCalendarUnitHour;
        
        BOOL dayUnitAdded = NO;
        BOOL secondUnitAdded = NO;
        BOOL l_longFormat = aFormat== IFADurationFormatHoursMinutesLong || aFormat== IFADurationFormatHoursMinutesSecondsLong || aFormat== IFADurationFormatFullLong;
        switch (aFormat) {
            case IFADurationFormatFull:
            case IFADurationFormatFullLong:
                unitFlags = unitFlags | NSCalendarUnitDay;
                dayUnitAdded = YES;
            case IFADurationFormatHoursMinutesSeconds:
            case IFADurationFormatHoursMinutesSecondsLong:
                unitFlags = unitFlags | NSCalendarUnitSecond;
                secondUnitAdded = YES;
            case IFADurationFormatHoursMinutes:
            case IFADurationFormatHoursMinutesLong:
                unitFlags = unitFlags | NSCalendarUnitMinute;
                break;
            default:
                NSAssert1(NO, @"Unexpected duration format: %ld", (long)aFormat);
        }
        
        BOOL l_secondsIncluded = YES;
        if (aFormat== IFADurationFormatHoursMinutes || aFormat== IFADurationFormatHoursMinutesLong) {
            l_secondsIncluded = NO;
        }
        
        NSInteger days = 0;
        NSInteger hours = 0;
        NSInteger minutes = 0;
        NSInteger seconds = 0;
        if ([aStartDate compare:anEndDate]==NSOrderedAscending) {
            NSDateComponents *components = [a_calendar components:unitFlags fromDate:aStartDate toDate:anEndDate options:0];
            days = dayUnitAdded ? [components day] : 0;
            hours = [components hour];
            minutes = [components minute];
            seconds = secondUnitAdded ? [components second] : 0;
        }
        //    NSLog(@"%i / %i / %i / %i", days, hours, minutes, seconds);

        if (aFormat== IFADurationFormatFull || aFormat== IFADurationFormatHoursMinutesSeconds || aFormat== IFADurationFormatHoursMinutes) {
            
            NSNumberFormatter *l_timeFormatter = [NSNumberFormatter new];
            l_timeFormatter.minimumIntegerDigits = 2;
            
            NSNumberFormatter *l_dayFormatter = [NSNumberFormatter new];
            
            NSString *l_formattedDays = [l_dayFormatter stringFromNumber:@(days)];
            NSString *l_formattedHours = [l_timeFormatter stringFromNumber:@(hours)];
            NSString *l_formattedMinutes = [l_timeFormatter stringFromNumber:@(minutes)];
            NSString *l_formattedSeconds = [l_timeFormatter stringFromNumber:@(seconds)];
            
            NSString *l_durationString = nil;
            switch (aFormat) {
                case IFADurationFormatFull:
                    if (days>0) {
                        l_durationString = [NSString stringWithFormat:@"%@d %@:%@:%@", l_formattedDays, l_formattedHours, l_formattedMinutes, l_formattedSeconds];
                        break;
                    }
                case IFADurationFormatHoursMinutesSeconds:
                    l_durationString = [NSString stringWithFormat:@"%@:%@:%@", l_formattedHours, l_formattedMinutes, l_formattedSeconds];
                    break;
                case IFADurationFormatHoursMinutes:
                    l_durationString = [NSString stringWithFormat:@"%@:%@", l_formattedHours, l_formattedMinutes];
                    break;
                default:
                    NSAssert1(NO, @"Unexpected duration format: %ld", (long)aFormat);
            }

            return l_durationString;
            
        }else{
            
            NSMutableString *duration = [[NSMutableString alloc] init];

            BOOL showDay = (days!=0);
            BOOL showHour = (hours!=0) || (showDay && (minutes+seconds!=0));
            BOOL showMinute = (minutes!=0) || ((showDay || showHour) && seconds!=0) || (!l_secondsIncluded && !showDay && !showHour);
            BOOL showSecond = ((showDay || showHour || showMinute) && seconds!=0) || !(showDay || showHour || showMinute);
            BOOL l_mostSignificantShown = NO;
            NSString *l_separator = l_longFormat ? @", " : @":";
            if (showDay) {
                NSString *l_stringFormat = nil;
                if (l_longFormat) {
                    l_stringFormat = days==1?@"%ld day":@"%ld days";
                }else{
                    l_stringFormat = @"%ldd";
                }
                [duration appendFormat:l_stringFormat, days];
                l_mostSignificantShown = YES;
            }
            if (showHour) {
                if (l_mostSignificantShown) {
                    [duration appendString:l_separator];
                }
                NSString *l_stringFormat = nil;
                if (l_longFormat) {
                    l_stringFormat = hours==1?@"%ld hour":@"%ld hours";
                }else{
                    l_stringFormat = @"%ld";
                }
                [duration appendFormat:l_stringFormat, hours];
                l_mostSignificantShown = YES;
            }
            if (showMinute) {
                if (l_mostSignificantShown) {
                    [duration appendString:l_separator];
                }
                NSString *l_stringFormat = nil;
                if (l_longFormat) {
                    l_stringFormat = minutes==1?@"%ld minute":@"%ld minutes";
                }else{
                    l_stringFormat = @"%ld";
                }
                [duration appendFormat:l_stringFormat, minutes];
                l_mostSignificantShown = YES;
            }
            if (showSecond) {
                if (l_mostSignificantShown) {
                    [duration appendString:l_separator];
                }
                NSString *l_stringFormat = nil;
                if (l_longFormat) {
                    l_stringFormat = seconds==1?@"%ld second":@"%ld seconds";
                }else{
                    l_stringFormat = @"%ld";
                }
                [duration appendFormat:l_stringFormat, seconds];
            }
            
            return duration;

        }

    }

}

+ (NSString*)durationStringForInterval:(NSTimeInterval)anInterval format:(IFADurationFormat)aFormat calendar:(NSCalendar*)a_calendar{
	NSDate *startDate = [NSDate date];
	NSDate *endDate = [[NSDate alloc] initWithTimeInterval:anInterval sinceDate:startDate];
	return [self durationStringForStartDate:startDate endDate:endDate format:aFormat calendar:a_calendar];
}

+ (NSDecimalNumber*)decimalHoursForStartDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate calendar:(NSCalendar*)a_calendar{    

    if ([aStartDate compare:anEndDate]!=NSOrderedAscending) {
        return [NSDecimalNumber zero];
    }

	NSUInteger unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
	NSDateComponents *components = [a_calendar components:unitFlags fromDate:aStartDate toDate:anEndDate options:0];
	NSInteger hours = [components hour];
	NSInteger minutes = [components minute];
	NSInteger seconds = [components second];

    NSDecimalNumber *l_100 = [[NSDecimalNumber alloc] initWithInt:100];
    NSDecimalNumber *l_60 = [[NSDecimalNumber alloc] initWithInt:60];

    NSDecimalNumber *decimalHours = [[NSDecimalNumber alloc] initWithInteger:hours];
    NSDecimalNumber *decimalMinutes = [[NSDecimalNumber alloc] initWithInteger:minutes];
    NSDecimalNumber *decimalSeconds = [[NSDecimalNumber alloc] initWithInteger:seconds];

    decimalSeconds = [decimalSeconds decimalNumberByDividingBy:l_60];
    decimalSeconds = [decimalSeconds decimalNumberByDividingBy:l_100];

    decimalMinutes = [decimalMinutes decimalNumberByDividingBy:l_60];

    decimalHours = [decimalHours decimalNumberByAdding:decimalMinutes];
    decimalHours = [decimalHours decimalNumberByAdding:decimalSeconds]; // add seconds to minimise precision loss
    
    return decimalHours;

}

+ (NSDecimalNumber*)decimalHoursForInterval:(NSTimeInterval)anInterval calendar:(NSCalendar*)a_calendar{
	NSDate *startDate = [NSDate date];
	NSDate *endDate = [[NSDate alloc] initWithTimeInterval:anInterval sinceDate:startDate];
    return [self decimalHoursForStartDate:startDate endDate:endDate calendar:a_calendar];
}

+ (NSString*)decimalHoursStringForStartDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate calendar:(NSCalendar*)a_calendar{
    NSDecimalNumber *decimalHours = [self decimalHoursForStartDate:aStartDate endDate:anEndDate calendar:a_calendar];
    NSString *l_format = @"%@ h";
    return [NSString stringWithFormat:l_format, [self formattedDecimalHours:decimalHours]];
}

+ (NSString*)formattedDecimalHours:(NSNumber*)a_decimalHours{

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.minimumFractionDigits = 2;
    numberFormatter.maximumFractionDigits = 2;
    
    NSString *decimalHoursString = [numberFormatter stringFromNumber:a_decimalHours];
    
    
    return decimalHoursString;
    
}

+ (NSString*)formattedDecimalHoursForInterval:(NSTimeInterval)anInterval calendar:(NSCalendar*)a_calendar{
    return [self formattedDecimalHours:[self decimalHoursForInterval:anInterval calendar:a_calendar]];
}

@end
