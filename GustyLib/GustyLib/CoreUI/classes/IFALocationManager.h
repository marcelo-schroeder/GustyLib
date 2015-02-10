//
// Created by Marcelo Schroeder on 9/09/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, IFALocationAuthorizationType){
    IFALocationAuthorizationTypeAlways,     // Permission to use location services whenever the app is running.
    IFALocationAuthorizationTypeWhenInUse,  // Permission to use location services while the app is in the foreground.
};

/**
* Convenience wrapper around CLLocationManager. Once instantiated, it also becomes the delegate for CLLocationManager;
* As a convenience, the IFANotificationLocationAuthorizationStatusChange notification will be sent out so that the app can track location authorization status changes.
* This class can be extended to provide extra functionality.
* This class is designed to be used as a singleton. Please use the sharedInstance method to obtain an instance.
*/
@interface IFALocationManager : NSObject <CLLocationManagerDelegate>

@property(nonatomic, strong, readonly) CLLocationManager *underlyingLocationManager;

/**
* Checks if the the location manager's authorisation status is in order. If it is not in order, it conveniently handles the various statuses providing the appropriate messages to the user.
* @param a_alertPresenterViewController View controller to be used for presenting any alerts from.
* @returns YES if the location manager's authorisation status is in order (i.e. either kCLAuthorizationStatusNotDetermined or kCLAuthorizationStatusAuthorized). Otherwise it returns NO.
*/
+ (BOOL)
performLocationServicesChecksWithAlertPresenterViewController:(UIViewController *)a_alertPresenterViewController;

/**
* Shows an alert with a standard message for when the user's location cannot be obtained.
* @param a_presenterViewController View controller to be used for presenting any alerts from.
*/
+ (void)showLocationServicesAlertWithPresenterViewController:(UIViewController *)a_presenterViewController;

/**
* Shows an alert with a standard message for when the user's location cannot be obtained. The suffix for the message can be provided.
* @param a_message String to be appended to the standard message.
* @param a_presenterViewController View controller to be used for presenting any alerts from.
*/
+ (void)showLocationServicesAlertWithMessage:(NSString *)a_message
                     presenterViewController:(UIViewController *)a_presenterViewController;

+ (instancetype)sharedInstance;

/**
* Call this method to handle a scenario where the user's location was not possible to obtain.
* This method will perform all authorization checks. If any of those fails, the appropriate alert will be displayed to the user.
* If the authorization checks succeed, then it is assumed that there is no connectivity. The appropriate alert for that scenario will also be displayed to the user.
* @param a_alertPresenterViewController View controller to be used for presenting any alerts from.
*/
+ (void)handleLocationFailureWithAlertPresenterViewController:(UIViewController *)a_alertPresenterViewController;

@end