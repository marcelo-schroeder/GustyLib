//
// Created by Marcelo Schroeder on 6/12/2013.
// Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//


#import <Foundation/Foundation.h>

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