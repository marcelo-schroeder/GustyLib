//
//  GustyLib - IFACurrentLocationManagerTests.m
//  Copyright 2015 InfoAccent Pty Ltd. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IFACommonTests.h"
#import "GustyLibCoreUI.h"

//NOTE: these thresholds are relative to the default values defined in IFACurrentLocationManager.h
static NSTimeInterval const k_LocationAgeWithinThreshold = 30.0;
static NSTimeInterval const k_LocationAgeExceededThreshold = 70.0;
static CLLocationAccuracy const k_horizontalAccuracyWithinThreshold = 50.0;
static CLLocationAccuracy const k_horizontalAccuracyExceeded = 1001.0;

@interface IFACurrentLocationManager (Tests)
- (id)initWithUnderlyingLocationManager:(CLLocationManager *)a_underlyingLocationManager;
@end

@interface IFACurrentLocationManagerTests : XCTestCase
@property(nonatomic, strong) IFACurrentLocationManager *currentLocationManager;
@end

@implementation IFACurrentLocationManagerTests{
}

- (void)testCurrentLocationWithBlockShouldReturnLocationWhenSingleLocationProvided {
    // given
    CLLocation *expectedLocation = [[CLLocation alloc] initWithLatitude:1 longitude:2];
    [self.currentLocationManager currentLocationWithCompletionBlock:^(CLLocation *a_location) {
        // then
        assertThat(a_location, is(equalTo(expectedLocation)));
    }];

    // when
    [self.currentLocationManager locationManager:self.currentLocationManager.underlyingLocationManager
                              didUpdateLocations:@[expectedLocation]];
}

- (void)testCurrentLocationWithBlockShouldReturnMostRecentLocationWhenMultipleLocationsAreProvided {
    // given
    CLLocation *expectedLocation1 = [[CLLocation alloc] initWithLatitude:1 longitude:2];
    CLLocation *expectedLocation2 = [[CLLocation alloc] initWithLatitude:3 longitude:4];
    [self.currentLocationManager currentLocationWithCompletionBlock:^(CLLocation *a_location) {
        // then
        assertThat(a_location, is(equalTo(expectedLocation2)));
    }];

    // when
    [self.currentLocationManager locationManager:self.currentLocationManager.underlyingLocationManager
                              didUpdateLocations:@[expectedLocation1, expectedLocation2]];
}

- (void)testCurrentLocationWithBlockShouldReturnNilOnFailure {
    // given
    [self.currentLocationManager currentLocationWithCompletionBlock:^(CLLocation *a_location) {
        // then
        assertThat(a_location, is(nilValue()));
    }];
    id mockError = [OCMockObject mockForClass:[NSError class]];

    // when
    [self.currentLocationManager locationManager:self.currentLocationManager.underlyingLocationManager
                                didFailWithError:mockError];
}

-(void) testShouldDiscardLocationIfTheDefaultHorizontalAccuracyThresholdExceeded {
    //given
    id locationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];
    [[locationManager reject] stopUpdatingLocation];

    self.currentLocationManager = [[IFACurrentLocationManager alloc] initWithUnderlyingLocationManager:locationManager];
    CLLocation *expectedLocation1 = [self createLocationWithLatitude:1.0
                                                           longitude:2.0
                                                  horizontalAccuracy:k_horizontalAccuracyExceeded
                                                     secondsSinceNow:0];
    CLLocation *expectedLocation2 = [self createLocationWithLatitude:3.0
                                                           longitude:4.0
                                                  horizontalAccuracy:k_horizontalAccuracyExceeded
                                                     secondsSinceNow:10];

    //when
    [self.currentLocationManager currentLocationWithCompletionBlock:^(CLLocation *l) {
    }];
    [self.currentLocationManager locationManager:self.currentLocationManager.underlyingLocationManager
                              didUpdateLocations:@[expectedLocation1, expectedLocation2]];

    [locationManager verify];
}

-(void) testShouldRetainLocationIfTheDefaultHorizontalAccuracyIsWithinThreshold {
    //given
    id locationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];
    [[locationManager expect] stopUpdatingLocation];

    self.currentLocationManager = [[IFACurrentLocationManager alloc] initWithUnderlyingLocationManager:locationManager];
    CLLocation *expectedLocation1 = [self createLocationWithLatitude:1.0
                                                           longitude:2.0
                                                  horizontalAccuracy:k_horizontalAccuracyWithinThreshold
                                                     secondsSinceNow:0];
    CLLocation *expectedLocation2 = [self createLocationWithLatitude:3.0
                                                           longitude:4.0
                                                  horizontalAccuracy:k_horizontalAccuracyWithinThreshold
                                                     secondsSinceNow:10];

    //when
    [self.currentLocationManager currentLocationWithCompletionBlock:^(CLLocation *l) {
    }];
    [self.currentLocationManager locationManager:self.currentLocationManager.underlyingLocationManager
                              didUpdateLocations:@[expectedLocation1, expectedLocation2]];

    [locationManager verify];
}

-(void) testShouldDiscardLocationIfTheLocationAgeThresholdHasExceeded{
    //given
    id locationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];
    [[locationManager reject] stopUpdatingLocation];

    self.currentLocationManager = [[IFACurrentLocationManager alloc] initWithUnderlyingLocationManager:locationManager];
    CLLocation *expectedLocation1 = [self createLocationWithLatitude:1.0
                                                           longitude:2.0
                                                  horizontalAccuracy:50.0
                                                     secondsSinceNow:k_LocationAgeExceededThreshold];
    CLLocation *expectedLocation2 = [self createLocationWithLatitude:3.0
                                                           longitude:4.0
                                                  horizontalAccuracy:50.0
                                                     secondsSinceNow:k_LocationAgeExceededThreshold];

    //when
    [self.currentLocationManager currentLocationWithCompletionBlock:^(CLLocation *l) {
    }];
    [self.currentLocationManager locationManager:self.currentLocationManager.underlyingLocationManager
                              didUpdateLocations:@[expectedLocation1, expectedLocation2]];

    [locationManager verify];
}

-(void) testShouldRetainLocationIfTheLocationAgeIsWithinThreshold{
    //given
    id locationManager = [OCMockObject niceMockForClass:[CLLocationManager class]];
    [[locationManager expect] stopUpdatingLocation];

    self.currentLocationManager = [[IFACurrentLocationManager alloc] initWithUnderlyingLocationManager:locationManager];
    CLLocation *expectedLocation1 = [self createLocationWithLatitude:1.0
                                                           longitude:2.0
                                                  horizontalAccuracy:50.0
                                                     secondsSinceNow:k_LocationAgeWithinThreshold];
    CLLocation *expectedLocation2 = [self createLocationWithLatitude:3.0
                                                           longitude:4.0
                                                  horizontalAccuracy:50.0
                                                     secondsSinceNow:k_LocationAgeWithinThreshold];

    //when
    [self.currentLocationManager currentLocationWithCompletionBlock:^(CLLocation *l) {
    }];
    [self.currentLocationManager locationManager:self.currentLocationManager.underlyingLocationManager
                              didUpdateLocations:@[expectedLocation1, expectedLocation2]];

    [locationManager verify];
}

#pragma mark - Override

- (void)setUp {

    // Current location manager
    id underlyingLocationManagerMock = [OCMockObject niceMockForClass:[CLLocationManager class]];
    self.currentLocationManager = [[IFACurrentLocationManager alloc] initWithUnderlyingLocationManager:underlyingLocationManagerMock];

    // GustyLib's location manager mock
    id locationManagerMock = OCMClassMock([IFALocationManager class]);
    [OCMStub([locationManagerMock performLocationServicesChecksWithAlertPresenterViewController:[OCMArg any]]) ifa_andReturnBool:YES];

}

#pragma mark - Private

-(CLLocation *)createLocationWithLatitude:(CLLocationDegrees)a_latitude
                                longitude:(CLLocationDegrees)a_longitude
                       horizontalAccuracy:(CLLocationAccuracy)a_horizontalAccuracy
                          secondsSinceNow:(NSTimeInterval)a_secondsSinceNow {
    return [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(a_latitude, a_longitude)
                                         altitude:0.0
                               horizontalAccuracy:a_horizontalAccuracy
                                 verticalAccuracy:0.0
                                        timestamp:[NSDate dateWithTimeIntervalSinceNow:a_secondsSinceNow]];
}

@end
