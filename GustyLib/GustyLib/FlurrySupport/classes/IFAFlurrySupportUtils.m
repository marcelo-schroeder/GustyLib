//
//  IFAFlurrySupportUtils.m
//  Gusty
//
//  Created by Marcelo Schroeder on 22/02/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
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

#import "GustyLibFlurrySupport.h"

@implementation IFAFlurrySupportUtils {
    
}

#pragma mark - Public

+ (void)configureAnalytics {

    NSLog(@"Configuring analytics...");

    NSString *l_apiKey = [[IFAUtils infoPList] valueForKey:@"IFAAnalyticsApiKey"];
    NSAssert(l_apiKey, @"IFAAnalyticsApiKey not found");

    [Flurry startSession:l_apiKey];

    NSLog(@"Analytics configured...");

}

+ (void)logEntryForScreenName:(NSString*)a_screenName{
    [Flurry logEvent:@"screenEntry" withParameters:@{@"name":a_screenName}];
}

@end
