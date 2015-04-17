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

#import <CoreLocation/CoreLocation.h>
#import "IFALocationManager.h"

static CLLocationAccuracy const IFADefaultCurrentLocationHorizontalAccuracyThreshold = 1000.0; //metres
static NSTimeInterval  const IFADefaultCurrentLocationAgeThreshold = 60.0; //seconds
static NSTimeInterval  const IFADefaultCurrentLocationUpdatesTimeoutThreshold = 10.0; //seconds

/**
* Completion block for current location requests.
* @param a_location Device's current location. If the location cannot be obtained, nil will be returned.
*/
typedef void (^IFACurrentLocationManagerCompletionBlock)(CLLocation *a_location);

/**
* Utility class with the sole purpose of providing the device's current location.
*/
@interface IFACurrentLocationManager : NSObject <CLLocationManagerDelegate>

/**
* Underlying CLLocationManager instance used for current location requests.
*/
@property (nonatomic, strong, readonly) CLLocationManager *underlyingLocationManager;

/**
* View controller to be used as the presenter for any location related alerts to the user.
* Optional.
*/
@property (nonatomic, weak) UIViewController *alertPresenterViewController;

/**
* Designated initializer.
* @param a_underlyingLocationManager Underlying location manager to be used.
*/
- (id)initWithUnderlyingLocationManager:(CLLocationManager *)a_underlyingLocationManager NS_DESIGNATED_INITIALIZER;

/**
* Requests the device's current location and returns it asynchronously.
*
* This is a convenience method that uses the following defaults:
*
* - Horizontal accuracy <= 1,000 m
* - Location age <= 60 sec
* - Location updates timeout = 10 sec
*
* @param a_completionBlock Completion block containing the location in the a_location block parameter. If the location cannot be obtained, nil will be returned.
*/
#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMethodInspection"
- (void)currentLocationWithCompletionBlock:(IFACurrentLocationManagerCompletionBlock)a_completionBlock;
#pragma clang diagnostic pop

/**
* Requests the device's current location and returns it asynchronously.
* @param a_horizontalAccuracy Maximum horizontal accuracy level accepted for the location fix in meters.
* @param a_locationAgeThreshold Maximum age (in seconds) accepted for the location fix.
* @param a_locationUpdatesTimeoutThreshold Timeout in seconds for the location request. If the request times out, then the location returned will be nil.
* @param a_completionBlock Completion block containing the location in the a_location block parameter. If the location cannot be obtained, nil will be returned.
*/
- (void)currentLocationWithHorizontalAccuracy:(CLLocationAccuracy)a_horizontalAccuracy
                         locationAgeThreshold:(NSTimeInterval)a_locationAgeThreshold
              locationUpdatesTimeoutThreshold:(NSTimeInterval)a_locationUpdatesTimeoutThreshold
                              completionBlock:(IFACurrentLocationManagerCompletionBlock)a_completionBlock;

/**
* Cancel a current location request in progress.
* @param a_completionBlock Block to be executed after the current location request has been cancelled.
*/
#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCUnusedMethodInspection"
- (void)cancelRequestWithCompletionBlock:(void (^)())a_completionBlock;
#pragma clang diagnostic pop

/**
* Executes a block that depends on the device's current location and displays the desired authorization prompt when the current authorization status is undetermined.
* @param a_locationAuthorizationType The type of location authorization required.
* @param a_block The block to be executed after the authorization status is determined.
*/
- (void)   withAuthorizationType:(IFALocationAuthorizationType)a_locationAuthorizationType
executeCurrentLocationBasedBlock:(void (^)(CLAuthorizationStatus))a_block;

@end