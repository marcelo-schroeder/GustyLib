//
// Created by Marcelo Schroeder on 4/06/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import "IFACrashlyticsSupportManager.h"
#import "IFAUtils.h"
#import "Crashlytics.h"
#import "NSDate+IFACategory.h"
#import "IFASystemEntity.h"
#import "NSString+IFACategory.h"
#import "NSManagedObject+IFACategory.h"

@implementation IFACrashlyticsSupportManager {

}

#pragma mark - Public

-(void)configureCrashReportingWithUserInfo:(NSDictionary*)a_userInfo{

//    NSLog(@"configureCrashReportingWithUserInfo: %@", [a_userInfo description]);

    NSLog(@"Configuring crash reporting...");

    NSString *l_apiKey = [[IFAUtils infoPList] valueForKey:@"IFACrashlyticsApiKey"];
    NSAssert(l_apiKey, @"IFACrashlyticsApiKey not found");

    NSString *l_vendorDeviceId = [UIDevice currentDevice].identifierForVendor.UUIDString;

    // Configure crash reporting API
    [Crashlytics startWithAPIKey:l_apiKey];
    [Crashlytics setUserIdentifier:l_vendorDeviceId];

    // Bundle version
    // Crashlytics should derive this automatically from the app bundle, but it is not at the moment. I'm adding this info here so it does not get lost.
    NSString *l_bundleVersion = [IFAUtils infoPList][@"CFBundleVersion"];
    [Crashlytics setObjectValue:l_bundleVersion forKey:@"IFA_bundle_version"];

    // Locale info
    [Crashlytics setObjectValue:[self IFA_formatCrashReportValue:l_vendorDeviceId] forKey:@"IFA_vendor_Device_Id"];
    [Crashlytics setObjectValue:[self IFA_formatCrashReportValue:[NSLocale systemLocale]] forKey:@"IFA_system_Locale"];
    [Crashlytics setObjectValue:[self IFA_formatCrashReportValue:[NSLocale currentLocale]] forKey:@"IFA_current_Locale"];
    [Crashlytics setObjectValue:[self IFA_formatCrashReportValue:[NSLocale preferredLanguages]] forKey:@"IFA_preferred_Languages"];

    // User info
    for (NSString *l_key in a_userInfo.allKeys) {
        [Crashlytics setObjectValue:a_userInfo[l_key] forKey:l_key];
    }

    NSLog(@"Crash reporting configured");

}

+ (instancetype)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IFACrashlyticsSupportManager *c_instance;
    void (^instanceBlock)(void) = ^(void) {
        c_instance = [self new];
    };
    dispatch_once(&c_dispatchOncePredicate, instanceBlock);
    return c_instance;
}

#pragma mark - Private

-(NSString*)IFA_formatCrashReportValue:(id)a_value{

//    NSLog(@"formatCrashReportValue: %@", [a_value description]);

    if (a_value) {

        if ([a_value isKindOfClass:[NSDate class]]) {

            return [a_value ifa_descriptionWithCurrentLocale];

        }else{

            id l_displayValue = a_value;
            if ([a_value isKindOfClass:[NSManagedObject class]]) {
                if ([a_value isKindOfClass:[IFASystemEntity class]]) {
                    l_displayValue = ((IFASystemEntity *)a_value).systemEntityId;
                }else{
                    l_displayValue = ((NSManagedObject*)a_value).ifa_stringId;
                }
            }else if ([a_value isKindOfClass:[NSLocale class]]){
                l_displayValue = ((NSLocale*)a_value).localeIdentifier;
            }

            // Unformatted string
            NSString *l_unformattedString = [l_displayValue description];
//            NSLog(@"  l_unformattedString: %@", l_unformattedString);
            // Remove new line characters
            NSString *l_formattedString = [l_unformattedString ifa_stringByRemovingNewLineCharacters];
            // Remove double quotes to avoid issues with displaying the values on the Crashlytics web site
            l_formattedString = [l_formattedString stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
//            NSLog(@"  l_formattedString: %@", l_formattedString);
            return l_formattedString;

        }

    }else{
//        NSLog(@"  NIL");
        return @"NIL";
    }

}

@end