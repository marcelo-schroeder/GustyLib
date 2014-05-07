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


#import "IFACommon.h"

static NSString *const k_LocationServiceDisableAlertMessage = @" Location Services are currently disabled for this app. Please enable them in the Privacy section in the Settings app.";

@interface IFACurrentLocationManager ()
@property (nonatomic, strong) CLLocationManager *underlyingLocationManager;
@property (nonatomic, strong) void(^XYZ_completionBlock)(CLLocation *);
@property(nonatomic) BOOL XYZ_pendingCurrentLocationRequest;
@property(nonatomic) CLLocationAccuracy XYZ_horizontalAccuracy;
@property(nonatomic) NSTimeInterval XYZ_locationAgeThreshold;
@property(nonatomic, strong) CLLocation *XYZ_lastLocationReceived;
@property(nonatomic, strong) NSTimer *XYZ_timer;
@end

@implementation IFACurrentLocationManager {

}

#pragma mark - Overrides

- (id)init {
    self = [super init];
    if (self) {
        [self XYZ_initialiseUnderlyingLocationManager:[CLLocationManager new]];
    }
    return self;
}

#pragma mark - Private

- (void)XYZ_initialiseUnderlyingLocationManager:(CLLocationManager *)a_locationManager {
    self.underlyingLocationManager = a_locationManager;
    self.underlyingLocationManager.delegate = self;
}

+ (void)XYZ_showLocationServicesAlertWithMessageSuffix:(NSString *)a_messageSuffix{
    [IFAUIUtils showAlertWithMessage:[NSString stringWithFormat:@"We are unable to locate your position.%@",
                                                                a_messageSuffix]
            title:@"Location Services not available"];
}

+ (void)XYZ_showLocationServicesAlert {
    if ([self performLocationServicesChecks]) {
        [self XYZ_showLocationServicesAlertWithMessageSuffix:@""];
    }
}

- (void)XYZ_handleCurrentLocationErrorWithAlert:(BOOL)a_shouldShowAlert {
    if (a_shouldShowAlert) {
        [self.class XYZ_showLocationServicesAlert];
    }
    self.XYZ_completionBlock(nil);
}

-(void)XYZ_locationUpdatingTimedOut {
//    NSLog(@"timeout called");
    if(self.XYZ_lastLocationReceived){
        self.XYZ_completionBlock(self.XYZ_lastLocationReceived);
    }else{
        [self locationManager:nil didFailWithError:nil];
    }
}

- (CLLocation *)XYZ_retrieveValidLocationIfAvailable:(NSArray *)a_locations {

    CLLocation *l_validLocation = nil;

    if(a_locations.count > 0){
        CLLocation *l_recentLocation = a_locations[a_locations.count-1];
        self.XYZ_lastLocationReceived = l_recentLocation;
        BOOL l_isWithinHorizontalAccuracyRange = (l_recentLocation.horizontalAccuracy <= self.XYZ_horizontalAccuracy);
        BOOL l_isWithinTimeLapsedThreshold = (fabs(l_recentLocation.timestamp.timeIntervalSinceNow) <= self.XYZ_locationAgeThreshold);
        if(l_isWithinHorizontalAccuracyRange && l_isWithinTimeLapsedThreshold){
            l_validLocation =  l_recentLocation;
        }
    }

    return l_validLocation;
}

#pragma mark - Public

- (void)currentLocationWithCompletionBlock:(CurrentLocationBlock)a_completionBlock {
    [self currentLocationWithHorizontalAccuracy:IFADefaultCurrentLocationHorizontalAccuracyThreshold
                           locationAgeThreshold:IFADefaultCurrentLocationAgeThreshold
                locationUpdatesTimeoutThreshold:IFADefaultCurrentLocationUpdatesTimeoutThreshold
                                completionBlock:a_completionBlock];
}

- (void)currentLocationWithHorizontalAccuracy:(CLLocationAccuracy)horizontalAccuracy
                         locationAgeThreshold:(NSTimeInterval)locationAgeThreshold
              locationUpdatesTimeoutThreshold:(NSTimeInterval)locationUpdatesTimeoutThreshold
                              completionBlock:(CurrentLocationBlock)a_completionBlock {

    self.XYZ_completionBlock = a_completionBlock;
    if ([self.class performLocationServicesChecks]) {
        self.XYZ_pendingCurrentLocationRequest = YES;
        self.XYZ_horizontalAccuracy = horizontalAccuracy;
        self.XYZ_locationAgeThreshold = locationAgeThreshold;
        self.XYZ_lastLocationReceived = nil;
        self.XYZ_timer = [NSTimer scheduledTimerWithTimeInterval:locationUpdatesTimeoutThreshold
                                                        target:self
                                                      selector:@selector(XYZ_locationUpdatingTimedOut)
                                                      userInfo:nil
                                                       repeats:NO];
        [self.underlyingLocationManager startUpdatingLocation];
    }else{
        [self XYZ_handleCurrentLocationErrorWithAlert:NO];
    }
}

+ (BOOL)performLocationServicesChecks {
    if (![CLLocationManager locationServicesEnabled]) {
        NSString *l_messageSuffix = [NSString stringWithFormat:@" Location Services are currently disabled. Please enable them in the Privacy section in the Settings app."];
        [self XYZ_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
        return NO;
    }

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorized:
            return YES;
        case kCLAuthorizationStatusRestricted:
        {
            NSString *l_messageSuffix = @" Your device is not authorised to use Location Services";
            [self XYZ_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
            return NO;
        }
        case kCLAuthorizationStatusDenied:
        {
            NSString *l_messageSuffix = [NSString stringWithFormat:k_LocationServiceDisableAlertMessage];
            [self XYZ_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
            return NO;
        }
        default:
            NSAssert(NO, @"Unexpected authorisation status: %u", [CLLocationManager authorizationStatus]);
            return NO;
    }

}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *l_validMostRecentLocation = [self XYZ_retrieveValidLocationIfAvailable:locations];

    if (self.XYZ_pendingCurrentLocationRequest && l_validMostRecentLocation) {
        [self.underlyingLocationManager stopUpdatingLocation];
        [self.XYZ_timer invalidate];
        self.XYZ_pendingCurrentLocationRequest = NO;
        self.XYZ_completionBlock(l_validMostRecentLocation);
    }else{
//        NSLog(@"didUpdateLocations: NOT handling");
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.underlyingLocationManager stopUpdatingLocation];
    [self.XYZ_timer invalidate];
    if (self.XYZ_pendingCurrentLocationRequest) {
//        NSLog(@"didFailWithError: handling");
        self.XYZ_pendingCurrentLocationRequest = NO;
        [self XYZ_handleCurrentLocationErrorWithAlert:YES];
    }else{
//        NSLog(@"didFailWithError: NOT handling");
    }
}

@end