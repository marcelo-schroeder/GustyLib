//
// Created by Marcelo Schroeder on 9/09/2014.
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

#import "GustyLibCore.h"

static NSString *const k_LocationServiceDisableAlertMessage = @" Location Services are currently disabled for this app. Please enable them in the Privacy section in the Settings app.";

@interface IFALocationManager ()
@property(nonatomic, strong) CLLocationManager *underlyingLocationManager;
@end

@implementation IFALocationManager {

}

#pragma mark - Public

- (CLLocationManager *)underlyingLocationManager {
    if (!_underlyingLocationManager) {
        _underlyingLocationManager = [[CLLocationManager alloc] init];
        _underlyingLocationManager.delegate = self;
    }
    return _underlyingLocationManager;
}

+ (void)showLocationServicesAlertWithMessageSuffix:(NSString *)a_messageSuffix {
    [IFAUIUtils showAlertWithMessage:[NSString stringWithFormat:@"We are unable to locate your position.%@",
                                                                a_messageSuffix]
                               title:@"Location Services not available"];
}

+ (void)showLocationServicesAlert {
    if ([IFALocationManager performLocationServicesChecks]) {
        [self showLocationServicesAlertWithMessageSuffix:@""];
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static id c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

+ (BOOL)performLocationServicesChecks {
    if (![CLLocationManager locationServicesEnabled]) {
        NSString *l_messageSuffix = [NSString stringWithFormat:@" Location Services are currently disabled. Please enable them in the Privacy section in the Settings app."];
        [self showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
        return NO;
    }

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorized:
            return YES;
        case kCLAuthorizationStatusRestricted:
        {
            NSString *l_messageSuffix = @" Your device is not authorised to use Location Services";
            [self showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
            return NO;
        }
        case kCLAuthorizationStatusDenied:
        {
            NSString *l_messageSuffix = [NSString stringWithFormat:k_LocationServiceDisableAlertMessage];
            [self showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
            return NO;
        }
        default:
            NSAssert(NO, @"Unexpected authorisation status: %u", [CLLocationManager authorizationStatus]);
            return NO;
    }

}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
//    NSLog(@"didChangeAuthorizationStatus: %u", status);
    NSNotification *notification = [NSNotification notificationWithName:IFANotificationLocationAuthorizationStatusChange
                                                                 object:nil userInfo:@{@"status" : @(status)}];
    [[NSNotificationQueue defaultQueue] enqueueNotification:notification
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];
}

@end