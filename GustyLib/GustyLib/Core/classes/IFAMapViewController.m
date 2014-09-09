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


@interface IFAMapViewController ()
@property(nonatomic, strong) UIBarButtonItem *userLocationBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *mapSettingsBarButtonItem;
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

- (NSArray *)ifa_nonEditModeToolbarItems {
    UIBarButtonItem *l_flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                                  target:nil
                                                                                                  action:nil];
    return @[self.userLocationBarButtonItem, l_flexibleSpaceBarButtonItem, self.mapSettingsBarButtonItem];
}

#pragma mark - Private

- (void)IFA_onUserLocationButtonTap:(UIBarButtonItem *)a_barButtonItem {
    if ([IFALocationManager performLocationServicesChecks]) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    }
}

- (void)IFA_onMapSettingsButtonTap:(UIBarButtonItem *)a_barButtonItem {
    IFAMapSettingsViewController *l_mapSettingsViewController = [IFAMapSettingsViewController ifa_instantiateFromStoryboard];
    l_mapSettingsViewController.mapView = self.mapView;
    [self ifa_presentModalSelectionViewController:l_mapSettingsViewController
                                fromBarButtonItem:a_barButtonItem];
}

@end