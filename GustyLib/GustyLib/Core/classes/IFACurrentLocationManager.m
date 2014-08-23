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


#import "GustyLibCore.h"

static NSString *const k_LocationServiceDisableAlertMessage = @" Location Services are currently disabled for this app. Please enable them in the Privacy section in the Settings app.";

@interface IFACurrentLocationManager ()
@property (nonatomic, strong) CLLocationManager *underlyingLocationManager;
@property (nonatomic, strong) void(^IFA_completionBlock)(CLLocation *);
@property(nonatomic) BOOL IFA_pendingCurrentLocationRequest;
@property(nonatomic) CLLocationAccuracy IFA_horizontalAccuracy;
@property(nonatomic) NSTimeInterval IFA_locationAgeThreshold;
@property(nonatomic, strong) CLLocation *IFA_lastLocationReceived;
@property(nonatomic, strong) NSTimer *IFA_timer;
@end

@implementation IFACurrentLocationManager {

}

#pragma mark - Overrides

- (id)init {
    self = [super init];
    if (self) {
        [self IFA_initialiseUnderlyingLocationManager:[CLLocationManager new]];
    }
    return self;
}

#pragma mark - Private

- (void)IFA_initialiseUnderlyingLocationManager:(CLLocationManager *)a_locationManager {
    self.underlyingLocationManager = a_locationManager;
    self.underlyingLocationManager.delegate = self;
}

+ (void)IFA_showLocationServicesAlertWithMessageSuffix:(NSString *)a_messageSuffix{
    [IFAUIUtils showAlertWithMessage:[NSString stringWithFormat:@"We are unable to locate your position.%@",
                                                                a_messageSuffix]
            title:@"Location Services not available"];
}

+ (void)IFA_showLocationServicesAlert {
    if ([self performLocationServicesChecks]) {
        [self IFA_showLocationServicesAlertWithMessageSuffix:@""];
    }
}

- (void)IFA_handleCurrentLocationErrorWithAlert:(BOOL)a_shouldShowAlert {
    if (a_shouldShowAlert) {
        [self.class IFA_showLocationServicesAlert];
    }
    self.IFA_completionBlock(nil);
}

-(void)IFA_locationUpdatingTimedOut {
//    NSLog(@"timeout called");
    if(self.IFA_lastLocationReceived){
        self.IFA_completionBlock(self.IFA_lastLocationReceived);
    }else{
        [self locationManager:nil didFailWithError:nil];
    }
}

- (CLLocation *)IFA_retrieveValidLocationIfAvailable:(NSArray *)a_locations {

    CLLocation *l_validLocation = nil;

    if(a_locations.count > 0){
        CLLocation *l_recentLocation = a_locations[a_locations.count-1];
        self.IFA_lastLocationReceived = l_recentLocation;
        BOOL l_isWithinHorizontalAccuracyRange = (l_recentLocation.horizontalAccuracy <= self.IFA_horizontalAccuracy);
        BOOL l_isWithinTimeLapsedThreshold = (fabs(l_recentLocation.timestamp.timeIntervalSinceNow) <= self.IFA_locationAgeThreshold);
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

    self.IFA_completionBlock = a_completionBlock;
    if ([self.class performLocationServicesChecks]) {
        self.IFA_pendingCurrentLocationRequest = YES;
        self.IFA_horizontalAccuracy = horizontalAccuracy;
        self.IFA_locationAgeThreshold = locationAgeThreshold;
        self.IFA_lastLocationReceived = nil;
        self.IFA_timer = [NSTimer scheduledTimerWithTimeInterval:locationUpdatesTimeoutThreshold
                                                        target:self
                                                      selector:@selector(IFA_locationUpdatingTimedOut)
                                                      userInfo:nil
                                                       repeats:NO];
        [self.underlyingLocationManager startUpdatingLocation];
    }else{
        [self IFA_handleCurrentLocationErrorWithAlert:NO];
    }
}

+ (BOOL)performLocationServicesChecks {
    if (![CLLocationManager locationServicesEnabled]) {
        NSString *l_messageSuffix = [NSString stringWithFormat:@" Location Services are currently disabled. Please enable them in the Privacy section in the Settings app."];
        [self IFA_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
        return NO;
    }

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorized:
            return YES;
        case kCLAuthorizationStatusRestricted:
        {
            NSString *l_messageSuffix = @" Your device is not authorised to use Location Services";
            [self IFA_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
            return NO;
        }
        case kCLAuthorizationStatusDenied:
        {
            NSString *l_messageSuffix = [NSString stringWithFormat:k_LocationServiceDisableAlertMessage];
            [self IFA_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
            return NO;
        }
        default:
            NSAssert(NO, @"Unexpected authorisation status: %u", [CLLocationManager authorizationStatus]);
            return NO;
    }

}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *l_validMostRecentLocation = [self IFA_retrieveValidLocationIfAvailable:locations];

    if (self.IFA_pendingCurrentLocationRequest && l_validMostRecentLocation) {
        [self.underlyingLocationManager stopUpdatingLocation];
        [self.IFA_timer invalidate];
        self.IFA_pendingCurrentLocationRequest = NO;
        self.IFA_completionBlock(l_validMostRecentLocation);
    }else{
//        NSLog(@"didUpdateLocations: NOT handling");
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.underlyingLocationManager stopUpdatingLocation];
    [self.IFA_timer invalidate];
    if (self.IFA_pendingCurrentLocationRequest) {
//        NSLog(@"didFailWithError: handling");
        self.IFA_pendingCurrentLocationRequest = NO;
        [self IFA_handleCurrentLocationErrorWithAlert:YES];
    }else{
//        NSLog(@"didFailWithError: NOT handling");
    }
}

@end