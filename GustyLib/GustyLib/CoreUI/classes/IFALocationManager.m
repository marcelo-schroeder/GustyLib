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

#import "GustyLibCoreUI.h"

static NSString *const k_alertMessageLocationServicesDisabledOverall = @"Location Services are currently disabled. Please enable them in the Privacy section in the Settings app.";
static NSString *const k_alertMessageLocationServicesDisabledForThisApp = @"Location Services are currently disabled for this app. Please enable them in the Privacy section of the app Settings pane. To access the Settings pane tap Settings below.";
static NSString *const k_alertMessageLocationServicesRestricted = @"Your device is not authorised to use Location Services.";
static NSString *const k_alertMessageLocationServicesNoConnectivity = @"Please check if your device has Internet connectivity.";

static NSString *const k_alertTitle = @"Unable to obtain your location";

@interface IFALocationManager ()
@property(nonatomic, strong) CLLocationManager *underlyingLocationManager;
@end

@implementation IFALocationManager {

}

#pragma mark - Public

- (CLLocationManager *)underlyingLocationManager {
    if (!_underlyingLocationManager) {
        _underlyingLocationManager = [[CLLocationManager alloc] init];
        _underlyingLocationManager.delegate = self;
    }
    return _underlyingLocationManager;
}

+ (void)showLocationServicesAlertWithMessage:(NSString *)a_message
                          showSettingsOption:(BOOL)a_shouldShowSettingsOption
                     presenterViewController:(UIViewController *)a_presenterViewController {
    NSString *message = a_message;
    NSString *title = k_alertTitle;
    NSMutableArray *l_alertActions = [NSMutableArray new];
    if (a_shouldShowSettingsOption) {
        [l_alertActions addObject:[UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil]];
        void (^settingsHandlerBlock)(UIAlertAction *) = ^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        };
        [l_alertActions addObject:[UIAlertAction actionWithTitle:@"Settings"
                                                           style:UIAlertActionStyleDefault
                                                         handler:settingsHandlerBlock]];
    } else {
        [l_alertActions addObject:[UIAlertAction actionWithTitle:@"Continue"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]];
    }
    void (^l_presentationBlock)() = ^{
        [a_presenterViewController ifa_presentAlertControllerWithTitle:title
                                                               message:message
                                                                 style:UIAlertControllerStyleAlert
                                                               actions:l_alertActions
                                                            completion:nil];
    };
    if (a_presenterViewController.presentedViewController) {
        if ([a_presenterViewController.presentedViewController isKindOfClass:[UIAlertController class]]) {
            [a_presenterViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                  completion:l_presentationBlock];
        }
    }else{
        l_presentationBlock();
    }
}

+ (void)showLocationServicesAlertWithMessage:(NSString *)a_message
                     presenterViewController:(UIViewController *)a_presenterViewController {
    [self showLocationServicesAlertWithMessage:a_message showSettingsOption:NO
                       presenterViewController:a_presenterViewController];
}

+ (void)showLocationServicesAlertWithPresenterViewController:(UIViewController *)a_presenterViewController {
    [self showLocationServicesAlertWithMessage:@"" presenterViewController:a_presenterViewController];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static id c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

+ (void)handleLocationFailureWithAlertPresenterViewController:(UIViewController *)a_alertPresenterViewController {
    if ([self performLocationServicesChecksWithAlertPresenterViewController:a_alertPresenterViewController]) {
        [self showLocationServicesAlertWithMessage:k_alertMessageLocationServicesNoConnectivity
                           presenterViewController:a_alertPresenterViewController];
    }
}

+ (BOOL)
performLocationServicesChecksWithAlertPresenterViewController:(UIViewController *)a_alertPresenterViewController {
    if (![CLLocationManager locationServicesEnabled]) {
        [self showLocationServicesAlertWithMessage:k_alertMessageLocationServicesDisabledOverall
                           presenterViewController:a_alertPresenterViewController];
        return NO;
    }

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return YES;
        case kCLAuthorizationStatusRestricted:
        {
            NSString *message = k_alertMessageLocationServicesRestricted;
            [self showLocationServicesAlertWithMessage:message
                               presenterViewController:a_alertPresenterViewController];
            return NO;
        }
        case kCLAuthorizationStatusDenied:
        {
            NSString *message = k_alertMessageLocationServicesDisabledForThisApp;
            [self showLocationServicesAlertWithMessage:message showSettingsOption:YES
                               presenterViewController:a_alertPresenterViewController];
            return NO;
        }
        default:
            NSAssert(NO, @"Unexpected authorisation status: %u", [CLLocationManager authorizationStatus]);
            return NO;
    }

}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
//    NSLog(@"didChangeAuthorizationStatus: %u", status);
    NSNotification *notification = [NSNotification notificationWithName:IFANotificationLocationAuthorizationStatusChange
                                                                 object:nil userInfo:@{@"status" : @(status)}];
    [[NSNotificationQueue defaultQueue] enqueueNotification:notification
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];
}

@end