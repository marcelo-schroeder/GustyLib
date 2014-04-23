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

static CLLocationAccuracy const k_DefaultCurrentLocationHorizontalAccuracyThreshold = 1000.0; //metres
static NSTimeInterval  const k_DefaultCurrentLocationAgeThreshold = 60.0; //seconds
static NSTimeInterval  const k_DefaultCurrentLocationUpdatesTimeoutThreshold = 10.0; //seconds

typedef void (^CurrentLocationBlock)(CLLocation *a_location);

@interface IACurrentLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong, readonly) CLLocationManager *p_underlyingLocationManager;

- (void)m_currentLocationWithCompletionBlock:(CurrentLocationBlock)a_completionBlock;

- (void)m_currentLocationWithHorizontalAccuracy:(CLLocationAccuracy)horizontalAccuracy
                           locationAgeThreshold:(NSTimeInterval)locationAgeThreshold
                locationUpdatesTimeoutThreshold:(NSTimeInterval)locationUpdatesTimeoutThreshold
                                completionBlock:(CurrentLocationBlock)a_completionBlock;

+ (BOOL)m_performLocationServicesChecks;
@end