//
// Created by Marcelo Schroeder on 6/12/2013.
// Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
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


#import "IACommon.h"

static NSString *const k_LocationServiceDisableAlertMessage = @" Location Services are currently disabled for this app. Please enable them in the Privacy section in the Settings app.";

@interface IACurrentLocationManager ()
@property (nonatomic, strong) CLLocationManager *underlyingLocationManager;
@property (nonatomic, strong) void(^ifa_completionBlock)(CLLocation *);
@property(nonatomic) BOOL ifa_pendingCurrentLocationRequest;
@property(nonatomic) CLLocationAccuracy ifa_horizontalAccuracy;
@property(nonatomic) NSTimeInterval ifa_locationAgeThreshold;
@property(nonatomic, strong) CLLocation *ifa_lastLocationReceived;
@property(nonatomic, strong) NSTimer *ifa_timer;
@end

@implementation IACurrentLocationManager {

}

#pragma mark - Overrides

- (id)init {
    self = [super init];
    if (self) {
        [self ifa_initialiseUnderlyingLocationManager:[CLLocationManager new]];
    }
    return self;
}

#pragma mark - Private

- (void)ifa_initialiseUnderlyingLocationManager:(CLLocationManager *)a_locationManager {
    self.underlyingLocationManager = a_locationManager;
    self.underlyingLocationManager.delegate = self;
}

+ (void)ifa_showLocationServicesAlertWithMessageSuffix:(NSString *)a_messageSuffix{
    [IAUIUtils showAlertWithMessage:[NSString stringWithFormat:@"We are unable to locate your position.%@", a_messageSuffix] title:@"Location Services not available"];
}

+ (void)ifa_showLocationServicesAlert {
    if ([self performLocationServicesChecks]) {
        [self ifa_showLocationServicesAlertWithMessageSuffix:@""];
    }
}

- (void)ifa_handleCurrentLocationErrorWithAlert:(BOOL)a_shouldShowAlert {
    if (a_shouldShowAlert) {
        [self.class ifa_showLocationServicesAlert];
    }
    self.ifa_completionBlock(nil);
}

-(void)ifa_locationUpdatingTimedOut {
//    NSLog(@"timeout called");
    if(self.ifa_lastLocationReceived){
        self.ifa_completionBlock(self.ifa_lastLocationReceived);
    }else{
        [self locationManager:nil didFailWithError:nil];
    }
}

- (CLLocation *)ifa_retrieveValidLocationIfAvailable:(NSArray *)a_locations {

    CLLocation *l_validLocation = nil;

    if(a_locations.count > 0){
        CLLocation *l_recentLocation = a_locations[a_locations.count-1];
        self.ifa_lastLocationReceived = l_recentLocation;
        BOOL l_isWithinHorizontalAccuracyRange = (l_recentLocation.horizontalAccuracy <= self.ifa_horizontalAccuracy);
        BOOL l_isWithinTimeLapsedThreshold = (fabs(l_recentLocation.timestamp.timeIntervalSinceNow) <= self.ifa_locationAgeThreshold);
        if(l_isWithinHorizontalAccuracyRange && l_isWithinTimeLapsedThreshold){
            l_validLocation =  l_recentLocation;
        }
    }

    return l_validLocation;
}

#pragma mark - Public

- (void)currentLocationWithCompletionBlock:(CurrentLocationBlock)a_completionBlock {
    [self currentLocationWithHorizontalAccuracy:k_DefaultCurrentLocationHorizontalAccuracyThreshold
                           locationAgeThreshold:k_DefaultCurrentLocationAgeThreshold
                locationUpdatesTimeoutThreshold:k_DefaultCurrentLocationUpdatesTimeoutThreshold
                                completionBlock:a_completionBlock];
}

- (void)currentLocationWithHorizontalAccuracy:(CLLocationAccuracy)horizontalAccuracy
                         locationAgeThreshold:(NSTimeInterval)locationAgeThreshold
              locationUpdatesTimeoutThreshold:(NSTimeInterval)locationUpdatesTimeoutThreshold
                              completionBlock:(CurrentLocationBlock)a_completionBlock {

    self.ifa_completionBlock = a_completionBlock;
    if ([self.class performLocationServicesChecks]) {
        self.ifa_pendingCurrentLocationRequest = YES;
        self.ifa_horizontalAccuracy = horizontalAccuracy;
        self.ifa_locationAgeThreshold = locationAgeThreshold;
        self.ifa_lastLocationReceived = nil;
        self.ifa_timer = [NSTimer scheduledTimerWithTimeInterval:locationUpdatesTimeoutThreshold
                                                        target:self
                                                      selector:@selector(ifa_locationUpdatingTimedOut)
                                                      userInfo:nil
                                                       repeats:NO];
        [self.underlyingLocationManager startUpdatingLocation];
    }else{
        [self ifa_handleCurrentLocationErrorWithAlert:NO];
    }
}

+ (BOOL)performLocationServicesChecks {
    if (![CLLocationManager locationServicesEnabled]) {
        NSString *l_messageSuffix = [NSString stringWithFormat:@" Location Services are currently disabled. Please enable them in the Privacy section in the Settings app."];
        [self ifa_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
        return NO;
    }

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorized:
            return YES;
        case kCLAuthorizationStatusRestricted:
        {
            NSString *l_messageSuffix = @" Your device is not authorised to use Location Services";
            [self ifa_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
            return NO;
        }
        case kCLAuthorizationStatusDenied:
        {
            NSString *l_messageSuffix = [NSString stringWithFormat:k_LocationServiceDisableAlertMessage];
            [self ifa_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
            return NO;
        }
        default:
            NSAssert(NO, @"Unexpected authorisation status: %u", [CLLocationManager authorizationStatus]);
            return NO;
    }

}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *l_validMostRecentLocation = [self ifa_retrieveValidLocationIfAvailable:locations];

    if (self.ifa_pendingCurrentLocationRequest && l_validMostRecentLocation) {
        [self.underlyingLocationManager stopUpdatingLocation];
        [self.ifa_timer invalidate];
        self.ifa_pendingCurrentLocationRequest = NO;
        self.ifa_completionBlock(l_validMostRecentLocation);
    }else{
//        NSLog(@"didUpdateLocations: NOT handling");
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.underlyingLocationManager stopUpdatingLocation];
    [self.ifa_timer invalidate];
    if (self.ifa_pendingCurrentLocationRequest) {
//        NSLog(@"didFailWithError: handling");
        self.ifa_pendingCurrentLocationRequest = NO;
        [self ifa_handleCurrentLocationErrorWithAlert:YES];
    }else{
//        NSLog(@"didFailWithError: NOT handling");
    }
}

@end