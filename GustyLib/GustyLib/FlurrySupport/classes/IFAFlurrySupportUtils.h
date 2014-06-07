//
//  IFAFlurrySupportUtils.h
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

#import <Foundation/Foundation.h>

@interface IFAFlurrySupportUtils : NSObject

/**
* Configures Flurry analytics.
* The API key most be provided in the app's main plist with the 'IFAAnalyticsApiKey' key.
*/
+ (void)configureAnalytics;

/**
* Logs a custom analytics event indicating the entry on a given screen.
* @param a_screenName Name of the screen to log the entry event for.
*/
+ (void)logEntryForScreenName:(NSString*)a_screenName;

@end
