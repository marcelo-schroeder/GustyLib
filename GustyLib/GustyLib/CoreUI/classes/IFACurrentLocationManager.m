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


#import "GustyLibCoreUI.h"

@interface IFACurrentLocationManager ()
@property (nonatomic, strong) CLLocationManager *underlyingLocationManager;
@property (nonatomic, strong) void(^IFA_completionBlock)(CLLocation *);
@property(nonatomic) BOOL IFA_pendingCurrentLocationRequest;
@property(nonatomic) CLLocationAccuracy IFA_horizontalAccuracy;
@property(nonatomic) NSTimeInterval IFA_locationAgeThreshold;
@property(nonatomic, strong) CLLocation *IFA_lastLocationReceived;
@property(nonatomic, strong) NSTimer *IFA_timer;
@property(nonatomic, strong) void (^pendingCurrentLocationBasedBlock)(CLAuthorizationStatus);
@end

@implementation IFACurrentLocationManager {

}

#pragma mark - Overrides

- (id)init {
    return [self initWithUnderlyingLocationManager:[CLLocationManager new]];
}

- (void)dealloc {
    [self IFA_removeObservers];
}

#pragma mark - Private

- (void)IFA_handleCurrentLocationErrorWithAlert:(BOOL)a_shouldShowAlert {
    if (a_shouldShowAlert) {
        [IFALocationManager handleLocationFailureWithAlertPresenterViewController:self.alertPresenterViewController];
    }
    self.IFA_completionBlock(nil);
}

-(void)IFA_locationUpdatingTimedOut {
//    NSLog(@"timeout called");
    if(self.IFA_lastLocationReceived){
        [self IFA_handleLocationEventWithBlock:^{
            if (self.IFA_completionBlock) {
                self.IFA_completionBlock(self.IFA_lastLocationReceived);
            }
        }];
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

- (void)IFA_handleLocationEventWithBlock:(void(^)())a_block {
//    NSLog(@"  IFA_handleLocationEventWithBlock");
    if (self.IFA_pendingCurrentLocationRequest) {
        self.IFA_pendingCurrentLocationRequest = NO;
        [self.underlyingLocationManager stopUpdatingLocation];
        [self.IFA_timer invalidate];
        if (a_block) {
            a_block();
        }
//        NSLog(@"    HANDLED");
    } else {
//        NSLog(@"    NOT handled");
    }
}

- (void)IFA_addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onLocationAuthorizationStatusChange:)
                                                 name:IFANotificationLocationAuthorizationStatusChange
                                               object:nil];
}

- (void)IFA_removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationLocationAuthorizationStatusChange object:nil];
}

-(void)IFA_onLocationAuthorizationStatusChange:(NSNotification*)a_notification {
    if (self.pendingCurrentLocationBasedBlock) {
        CLAuthorizationStatus status = (CLAuthorizationStatus) ((NSNumber *) a_notification.userInfo[LocationManagerLocationAuthorizationStatusChangeNotificationUserInfoKeyStatus]).unsignedIntegerValue;
        self.pendingCurrentLocationBasedBlock(status);
        self.pendingCurrentLocationBasedBlock = nil;
    }
}

#pragma mark - Public

- (id)initWithUnderlyingLocationManager:(CLLocationManager *)a_underlyingLocationManager {
    self = [super init];
    if (self) {
        self.underlyingLocationManager = a_underlyingLocationManager;
        self.underlyingLocationManager.delegate = self;
        [self IFA_addObservers];
    }
    return self;
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMethodInspection"
- (void)currentLocationWithCompletionBlock:(IFACurrentLocationManagerCompletionBlock)a_completionBlock {
    [self currentLocationWithHorizontalAccuracy:IFADefaultCurrentLocationHorizontalAccuracyThreshold
                           locationAgeThreshold:IFADefaultCurrentLocationAgeThreshold
                locationUpdatesTimeoutThreshold:IFADefaultCurrentLocationUpdatesTimeoutThreshold
                                completionBlock:a_completionBlock];
}
#pragma clang diagnostic pop

- (void)currentLocationWithHorizontalAccuracy:(CLLocationAccuracy)a_horizontalAccuracy
                         locationAgeThreshold:(NSTimeInterval)a_locationAgeThreshold
              locationUpdatesTimeoutThreshold:(NSTimeInterval)a_locationUpdatesTimeoutThreshold
                              completionBlock:(IFACurrentLocationManagerCompletionBlock)a_completionBlock {

    self.IFA_completionBlock = a_completionBlock;
    if ([IFALocationManager performLocationServicesChecksWithAlertPresenterViewController:self.alertPresenterViewController]) {
        self.IFA_pendingCurrentLocationRequest = YES;
        self.IFA_horizontalAccuracy = a_horizontalAccuracy;
        self.IFA_locationAgeThreshold = a_locationAgeThreshold;
        self.IFA_lastLocationReceived = nil;
        self.IFA_timer = [NSTimer scheduledTimerWithTimeInterval:a_locationUpdatesTimeoutThreshold
                                                        target:self
                                                      selector:@selector(IFA_locationUpdatingTimedOut)
                                                      userInfo:nil
                                                       repeats:NO];
        [self.underlyingLocationManager startUpdatingLocation];
    }else{
        [self IFA_handleCurrentLocationErrorWithAlert:NO];
    }
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMethodInspection"
- (void)cancelRequestWithCompletionBlock:(void (^)())a_completionBlock {
    [self IFA_handleLocationEventWithBlock:a_completionBlock];
}
#pragma clang diagnostic pop

- (void)   withAuthorizationType:(IFALocationAuthorizationType)a_locationAuthorizationType
executeCurrentLocationBasedBlock:(void (^)(CLAuthorizationStatus))a_block {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined) {
        self.pendingCurrentLocationBasedBlock = a_block;
        CLLocationManager *locationManager = self.underlyingLocationManager;
        switch (a_locationAuthorizationType) {
            case IFALocationAuthorizationTypeAlways:
                [locationManager requestAlwaysAuthorization];
                break;
            case IFALocationAuthorizationTypeWhenInUse:
                [locationManager requestWhenInUseAuthorization];
                break;
        }
    } else {
        self.pendingCurrentLocationBasedBlock = nil;
        a_block(authorizationStatus);
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    NSLog(@"IFACurrentLocationManager - didUpdateLocations");
    CLLocation *l_validMostRecentLocation = [self IFA_retrieveValidLocationIfAvailable:locations];
    if (l_validMostRecentLocation) {
        [self IFA_handleLocationEventWithBlock:^{
            if (self.IFA_completionBlock) {
                self.IFA_completionBlock(l_validMostRecentLocation);
            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    NSLog(@"IFACurrentLocationManager - didFailWithError");
    [self IFA_handleLocationEventWithBlock:^{
        [self IFA_handleCurrentLocationErrorWithAlert:YES];
    }];
}

@end