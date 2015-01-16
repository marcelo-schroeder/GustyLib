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

static CLLocationAccuracy const IFADefaultCurrentLocationHorizontalAccuracyThreshold = 1000.0; //metres
static NSTimeInterval  const IFADefaultCurrentLocationAgeThreshold = 60.0; //seconds
static NSTimeInterval  const IFADefaultCurrentLocationUpdatesTimeoutThreshold = 10.0; //seconds

typedef void (^CurrentLocationBlock)(CLLocation *a_location);

@interface IFACurrentLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong, readonly) CLLocationManager *underlyingLocationManager;

/**
* View controller to be used as the presenter for any location related alerts to the user.
* Optional.
*/
@property (nonatomic, weak) UIViewController *alertPresenterViewController;

- (void)currentLocationWithCompletionBlock:(CurrentLocationBlock)a_completionBlock;

- (void)currentLocationWithHorizontalAccuracy:(CLLocationAccuracy)horizontalAccuracy
                         locationAgeThreshold:(NSTimeInterval)locationAgeThreshold
              locationUpdatesTimeoutThreshold:(NSTimeInterval)locationUpdatesTimeoutThreshold
                              completionBlock:(CurrentLocationBlock)a_completionBlock;

@end