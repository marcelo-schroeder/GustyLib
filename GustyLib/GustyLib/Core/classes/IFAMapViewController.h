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

#import <Foundation/Foundation.h>
#import "IFAViewController.h"
#import "IFALocationManager.h"
#import <MapKit/MapKit.h>

@class MKMapView;

/**
* This class encapsulates functionality and data normally required when implementing a view controller that displays a map.
* Once the view has loaded, an instance of this class also becomes the delegate for mapView.
*/
@interface IFAMapViewController : IFAViewController <MKMapViewDelegate>

/**
* Bar button used to center the user's location on the map.
*/
@property(nonatomic, strong, readonly) UIBarButtonItem *userLocationBarButtonItem;

/**
* Bar button used to show the map settings view.
*/
@property(nonatomic, strong, readonly) UIBarButtonItem *mapSettingsBarButtonItem;

/**
* Map view instance. Must be instantiated either by Interface Builder or programmatically.
*/
@property (nonatomic, strong) IBOutlet MKMapView *mapView;

/**
* Determines the authorisation type to be requested before the user location can be shown on the map.
* Default: IFALocationAuthorizationTypeAlways.
*/
@property (nonatomic) IFALocationAuthorizationType locationAuthorizationType;

@end