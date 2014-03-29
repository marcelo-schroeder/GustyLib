//
// Created by Marcelo Schroeder on 6/12/2013.
// Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//


#import "IACurrentLocationManager.h"

static NSString *const k_LocationServiceDisableAlertMessage = @" Location Services are currently disabled for this app. Please enable them in the Privacy section in the Settings app.";

@interface IACurrentLocationManager ()
@property (nonatomic, strong) CLLocationManager *p_underlyingLocationManager;
@property (nonatomic, strong) void(^p_completionBlock)(CLLocation *);
@property(nonatomic) BOOL p_pendingCurrentLocationRequest;
@property(nonatomic) CLLocationAccuracy p_horizontalAccuracy;
@property(nonatomic) NSTimeInterval p_locationAgeThreshold;
@property(nonatomic, strong) CLLocation *p_lastLocationReceived;
@property(nonatomic, strong) NSTimer *p_timer;
@end

@implementation IACurrentLocationManager {

}

#pragma mark - Overrides

- (id)init {
    self = [super init];
    if (self) {
        [self m_initialiseUnderlyingLocationManager:[CLLocationManager new]];
    }
    return self;
}

#pragma mark - Private

- (void)m_initialiseUnderlyingLocationManager:(CLLocationManager *)a_locationManager {
    self.p_underlyingLocationManager = a_locationManager;
    self.p_underlyingLocationManager.delegate = self;
}

+ (void)m_showLocationServicesAlertWithMessageSuffix:(NSString *)a_messageSuffix{
    [IAUIUtils showAlertWithMessage:[NSString stringWithFormat:@"We are unable to locate your position.%@", a_messageSuffix] title:@"Location Services not available"];
}

+ (void)m_showLocationServicesAlert {
    if ([self m_performLocationServicesChecks]) {
        [self m_showLocationServicesAlertWithMessageSuffix:@""];
    }
}

- (void)m_handleCurrentLocationErrorWithAlert:(BOOL)a_shouldShowAlert {
    if (a_shouldShowAlert) {
        [self.class m_showLocationServicesAlert];
    }
    self.p_completionBlock(nil);
}

-(void)m_locationUpdatingTimedOut{
//    NSLog(@"timeout called");
    if(self.p_lastLocationReceived){
        self.p_completionBlock(self.p_lastLocationReceived);
    }else{
        [self locationManager:nil didFailWithError:nil];
    }
}

- (CLLocation *)m_retrieveValidLocationIfAvailable:(NSArray *)a_locations {

    CLLocation *l_validLocation = nil;

    if(a_locations.count > 0){
        CLLocation *l_recentLocation = a_locations[a_locations.count-1];
        self.p_lastLocationReceived = l_recentLocation;
        BOOL l_isWithinHorizontalAccuracyRange = (l_recentLocation.horizontalAccuracy <= self.p_horizontalAccuracy);
        BOOL l_isWithinTimeLapsedThreshold = (fabs(l_recentLocation.timestamp.timeIntervalSinceNow) <= self.p_locationAgeThreshold);
        if(l_isWithinHorizontalAccuracyRange && l_isWithinTimeLapsedThreshold){
            l_validLocation =  l_recentLocation;
        }
    }

    return l_validLocation;
}

#pragma mark - Public

- (void)m_currentLocationWithCompletionBlock:(CurrentLocationBlock)a_completionBlock {
    [self m_currentLocationWithHorizontalAccuracy:k_DefaultCurrentLocationHorizontalAccuracyThreshold
                             locationAgeThreshold:k_DefaultCurrentLocationAgeThreshold
                  locationUpdatesTimeoutThreshold:k_DefaultCurrentLocationUpdatesTimeoutThreshold
                                  completionBlock:a_completionBlock];
}

- (void)m_currentLocationWithHorizontalAccuracy:(CLLocationAccuracy)horizontalAccuracy
                           locationAgeThreshold:(NSTimeInterval)locationAgeThreshold
                locationUpdatesTimeoutThreshold:(NSTimeInterval)locationUpdatesTimeoutThreshold
                                completionBlock:(CurrentLocationBlock)a_completionBlock {

    self.p_completionBlock = a_completionBlock;
    if ([self.class m_performLocationServicesChecks]) {
        self.p_pendingCurrentLocationRequest = YES;
        self.p_horizontalAccuracy = horizontalAccuracy;
        self.p_locationAgeThreshold = locationAgeThreshold;
        self.p_lastLocationReceived = nil;
        self.p_timer = [NSTimer scheduledTimerWithTimeInterval:locationUpdatesTimeoutThreshold
                                                        target:self
                                                      selector:@selector(m_locationUpdatingTimedOut)
                                                      userInfo:nil
                                                       repeats:NO];
        [self.p_underlyingLocationManager startUpdatingLocation];
    }else{
        [self m_handleCurrentLocationErrorWithAlert:NO];
    }
}

+ (BOOL)m_performLocationServicesChecks {
    if (![CLLocationManager locationServicesEnabled]) {
        NSString *l_messageSuffix = [NSString stringWithFormat:@" Location Services are currently disabled. Please enable them in the Privacy section in the Settings app."];
        [self m_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
        return NO;
    }

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorized:
            return YES;
        case kCLAuthorizationStatusRestricted:
        {
            NSString *l_messageSuffix = @" Your device is not authorised to use Location Services";
            [self m_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
            return NO;
        }
        case kCLAuthorizationStatusDenied:
        {
            NSString *l_messageSuffix = [NSString stringWithFormat:k_LocationServiceDisableAlertMessage];
            [self m_showLocationServicesAlertWithMessageSuffix:l_messageSuffix];
            return NO;
        }
        default:
            NSAssert(NO, @"Unexpected authorisation status: %u", [CLLocationManager authorizationStatus]);
            return NO;
    }

}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *l_validMostRecentLocation = [self m_retrieveValidLocationIfAvailable:locations];

    if (self.p_pendingCurrentLocationRequest && l_validMostRecentLocation) {
        [self.p_underlyingLocationManager stopUpdatingLocation];
        [self.p_timer invalidate];
        self.p_pendingCurrentLocationRequest = NO;
        self.p_completionBlock(l_validMostRecentLocation);
    }else{
//        NSLog(@"didUpdateLocations: NOT handling");
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.p_underlyingLocationManager stopUpdatingLocation];
    [self.p_timer invalidate];
    if (self.p_pendingCurrentLocationRequest) {
//        NSLog(@"didFailWithError: handling");
        self.p_pendingCurrentLocationRequest = NO;
        [self m_handleCurrentLocationErrorWithAlert:YES];
    }else{
//        NSLog(@"didFailWithError: NOT handling");
    }
}

@end