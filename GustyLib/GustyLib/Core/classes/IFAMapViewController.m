//
// Created by Marcelo Schroeder on 8/09/2014.
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

#import "GustyLibCore.h"

//wip: when making a change that does not improve the situation (e.g. from being disabled for the app to being disabled overall) it didn't change the map when returning to foreground - should it?
@interface IFAMapViewController ()
@property(nonatomic, strong) UIBarButtonItem *userLocationBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *mapSettingsBarButtonItem;
@property(nonatomic, strong) IFAWorkInProgressModalViewManager *IFA_progressViewManager;
@property(nonatomic) BOOL IFA_initialUserLocationRequestCompleted;
@end

@implementation IFAMapViewController {

}

#pragma mark - Public

- (UIBarButtonItem *)userLocationBarButtonItem {
    if (!_userLocationBarButtonItem) {
        _userLocationBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeUserLocation
                                                               target:self
                                                               action:@selector(IFA_onUserLocationButtonTap:)];
    }
    return _userLocationBarButtonItem;
}

- (UIBarButtonItem *)mapSettingsBarButtonItem {
    if (!_mapSettingsBarButtonItem) {
        _mapSettingsBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeInfo target:self
                                                              action:@selector(IFA_onMapSettingsButtonTap:)];
    }
    return _mapSettingsBarButtonItem;
}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Add observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onLocationAuthorizationStatusChange:)
                                                 name:IFANotificationLocationAuthorizationStatusChange
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated{

    if (!self.ifa_hasViewAppeared) {
        [self IFA_showUserLocation];
    }

    [super viewDidAppear:animated];

}

-(void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];

    // Remover observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationLocationAuthorizationStatusChange object:nil];

}

- (NSArray *)ifa_nonEditModeToolbarItems {
    UIBarButtonItem *l_flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                  target:nil
                                                                                                  action:nil];
    return @[self.userLocationBarButtonItem, l_flexibleSpaceBarButtonItem, self.mapSettingsBarButtonItem];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
//    NSLog(@" ");
//    NSLog(@"didUpdateUserLocation");
//    NSLog(@" ");

    if (!self.IFA_initialUserLocationRequestCompleted && self.IFA_progressViewManager) {
        [self IFA_hideProgressView];
        self.IFA_initialUserLocationRequestCompleted = YES;
        if ([self.mapViewControllerDelegate respondsToSelector:@selector(mapViewController:didCompleteInitialUserLocationRequestWithSuccess:)]) {
            [self.mapViewControllerDelegate mapViewController:self
             didCompleteInitialUserLocationRequestWithSuccess:YES];
        }
    }

}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    NSLog(@" ");
    NSLog(@"didFailToLocateUserWithError - error code: %ld", (long)[error code]);
    NSLog(@" ");

    if (!self.IFA_initialUserLocationRequestCompleted && self.IFA_progressViewManager) {
        [self IFA_hideProgressView];
        [IFALocationManager handleLocationFailureWithAlertPresenterViewController:self];
        self.IFA_initialUserLocationRequestCompleted = YES;
        if ([self.mapViewControllerDelegate respondsToSelector:@selector(mapViewController:didCompleteInitialUserLocationRequestWithSuccess:)]) {
            [self.mapViewControllerDelegate mapViewController:self
             didCompleteInitialUserLocationRequestWithSuccess:NO];
        }
    }
}

#pragma mark - Private

- (void)IFA_onUserLocationButtonTap:(UIBarButtonItem *)a_barButtonItem {
    MKUserLocation *userLocation = self.mapView.userLocation;
    if (userLocation.location) {
        [self.mapView showAnnotations:@[userLocation] animated:YES];
    }else{
        [IFALocationManager handleLocationFailureWithAlertPresenterViewController:self];
    }
}

- (void)IFA_onMapSettingsButtonTap:(UIBarButtonItem *)a_barButtonItem {
    IFAMapSettingsViewController *l_mapSettingsViewController = [IFAMapSettingsViewController ifa_instantiateFromStoryboard];
    l_mapSettingsViewController.mapView = self.mapView;
    [self ifa_presentModalSelectionViewController:l_mapSettingsViewController
                                fromBarButtonItem:a_barButtonItem];
}

-(void)IFA_hideProgressView {
    // Remove modal WIP view
    [self.IFA_progressViewManager removeView];
}

- (IFAWorkInProgressModalViewManager *)IFA_progressViewManager {
    if (!_IFA_progressViewManager) {
        _IFA_progressViewManager = [[IFAWorkInProgressModalViewManager alloc] initWithCancellationCallbackReceiver:self
                                                                                    cancellationCallbackSelector:@selector(IFA_onUserLocationProgressViewCancelled)
                                                                                    cancellationCallbackArgument:nil
                                                                                                         message:@"Locating..."];
    }
    return _IFA_progressViewManager;
}

- (void)IFA_onUserLocationProgressViewCancelled {
    self.mapView.showsUserLocation = NO;
    [self IFA_hideProgressView];
}

-(void)IFA_showUserLocation {
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined) {
        CLLocationManager *locationManager = [IFALocationManager sharedInstance].underlyingLocationManager;
        switch (self.locationAuthorizationType){
            case IFALocationAuthorizationTypeAlways:
                [locationManager requestAlwaysAuthorization];
                break;
            case IFALocationAuthorizationTypeWhenInUse:
                [locationManager requestWhenInUseAuthorization];
                break;
        }
    }else{
        self.IFA_initialUserLocationRequestCompleted = NO;
        [self.IFA_progressViewManager showView];
        self.mapView.showsUserLocation = YES;
    }
}

-(void)IFA_onLocationAuthorizationStatusChange:(NSNotification*)a_notification{

    // If the user has just authorised the use of his/her current location, then we attempt to show the user location again
    if ([a_notification.userInfo[@"status"] intValue]==kCLAuthorizationStatusAuthorizedAlways || [a_notification.userInfo[@"status"] intValue]==kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self IFA_hideProgressView];  // In case the authorisation status changed while the user location was being obtained (i.e. first time user acceptance)
        [self IFA_showUserLocation];
    }

}

@end