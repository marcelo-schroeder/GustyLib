//
//  GustyLib - IFACurrentLocationManagerTests.m
//  Copyright 2015 InfoAccent Pty Ltd. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IFACommonTests.h"
#import "GustyLibCoreUI.h"
#import "IFACoreUITestCase.h"

//NOTE: these thresholds are relative to the default values defined in IFACurrentLocationManager.h
static NSTimeInterval const k_LocationAgeWithinThreshold = 30.0;
static NSTimeInterval const k_LocationAgeExceededThreshold = 70.0;
static CLLocationAccuracy const k_horizontalAccuracyWithinThreshold = 50.0;
static CLLocationAccuracy const k_horizontalAccuracyExceeded = 1001.0;

@interface IFACurrentLocationManagerTests : IFACoreUITestCase
@property(nonatomic, strong) IFACurrentLocationManager *currentLocationManager;
@property(nonatomic, strong) id underlyingLocationManagerMock;
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
    [[self.underlyingLocationManagerMock reject] stopUpdatingLocation];
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

    [self.underlyingLocationManagerMock verify];
}

-(void) testShouldRetainLocationIfTheDefaultHorizontalAccuracyIsWithinThreshold {
    //given
    [[self.underlyingLocationManagerMock expect] stopUpdatingLocation];
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

    [self.underlyingLocationManagerMock verify];
}

-(void) testShouldDiscardLocationIfTheLocationAgeThresholdHasExceeded{
    //given
    [[self.underlyingLocationManagerMock reject] stopUpdatingLocation];
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

    [self.underlyingLocationManagerMock verify];
}

-(void) testShouldRetainLocationIfTheLocationAgeIsWithinThreshold{
    //given
    [[self.underlyingLocationManagerMock expect] stopUpdatingLocation];
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

    [self.underlyingLocationManagerMock verify];
}

- (void)testWithAuthorizationTypeExecuteCurrentLocationBasedBlockWithAlwaysAuthorizationTypeWhenCurrentAuthorizationStatusIsNotDetermined {
    OCMExpect([self.underlyingLocationManagerMock requestAlwaysAuthorization]).andDo(^(NSInvocation *a_invocation) {
        [IFALocationManager sendLocationAuthorizationStatusChangeNotificationWithStatus:kCLAuthorizationStatusAuthorizedAlways];
    });
    [self arrangeActAndAssertWithAuthorizationTypeExecuteCurrentLocationBasedBlockWithAuthorizationType:IFALocationAuthorizationTypeAlways
                                                                             currentAuthorizationStatus:kCLAuthorizationStatusNotDetermined
                                                                                 newAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways];
}

- (void)testWithAuthorizationTypeExecuteCurrentLocationBasedBlockWithWhenInUseAuthorizationTypeWhenCurrentAuthorizationStatusIsNotDetermined {
    OCMExpect([self.underlyingLocationManagerMock requestWhenInUseAuthorization]).andDo(^(NSInvocation *a_invocation) {
        [IFALocationManager sendLocationAuthorizationStatusChangeNotificationWithStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
    });
    [self arrangeActAndAssertWithAuthorizationTypeExecuteCurrentLocationBasedBlockWithAuthorizationType:IFALocationAuthorizationTypeWhenInUse
                                                                             currentAuthorizationStatus:kCLAuthorizationStatusNotDetermined
                                                                                 newAuthorizationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
}

- (void)testWithAuthorizationTypeExecuteCurrentLocationBasedBlockWithAlwaysAuthorizationTypeWhenCurrentAuthorizationStatusIsAlways {
    [[self.underlyingLocationManagerMock reject] requestAlwaysAuthorization];
    [self arrangeActAndAssertWithAuthorizationTypeExecuteCurrentLocationBasedBlockWithAuthorizationType:IFALocationAuthorizationTypeAlways
                                                                             currentAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways
                                                                                 newAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways];
}

#pragma mark - Override

- (void)setUp {

    // Current location manager
    self.underlyingLocationManagerMock = [OCMockObject niceMockForClass:[CLLocationManager class]];
    self.currentLocationManager = [[IFACurrentLocationManager alloc] initWithUnderlyingLocationManager:self.underlyingLocationManagerMock];

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

- (void)arrangeActAndAssertWithAuthorizationTypeExecuteCurrentLocationBasedBlockWithAuthorizationType:(IFALocationAuthorizationType)a_locationAuthorizationType
                                                                           currentAuthorizationStatus:(CLAuthorizationStatus)a_currentAuthorizationStatus
                                                                               newAuthorizationStatus:(CLAuthorizationStatus)a_newAuthorizationStatus {
    //given
    XCTestExpectation *expectation = [self expectationWithDescription:@"Block called"];
    [[[self.underlyingLocationManagerMock expect] ifa_andReturnUnsignedInteger:a_currentAuthorizationStatus] authorizationStatus];
    void (^currentLocationBasedBlock)(CLAuthorizationStatus) = ^(CLAuthorizationStatus status) {
        assertThatUnsignedInteger(status, is(equalToUnsignedInteger(a_newAuthorizationStatus)));
        [expectation fulfill];
    };
    //when
    [self.currentLocationManager withAuthorizationType:a_locationAuthorizationType
                      executeCurrentLocationBasedBlock:currentLocationBasedBlock];
    //then
    [self waitForExpectationsWithTimeout:1
                                 handler:nil];
    OCMVerifyAll(self.underlyingLocationManagerMock);
}

@end
