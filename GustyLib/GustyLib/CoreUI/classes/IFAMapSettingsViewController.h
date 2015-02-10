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

/**
* This class encapsulates functionality and data normally required when implementing a view controller that manages the settings of a map.
*/
@interface IFAMapSettingsViewController : IFAViewController

/**
* If set, changes to settings can be automatically reflected in the map (e.g. map type set by user).
*/
@property(nonatomic, weak) MKMapView *mapView;

/**
* Segmented control that allows the user to change the map type. It is automatically set by Interface Builder.
*/
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapTypeSegmentedControl;

/**
* Action handler for the map type segmented control. It is automatically connected by Interface Builder.
* @param sender Target of the user action.
*/
- (IBAction)onMapTypeSegmentedControlValueChanged:(UISegmentedControl *)sender;

@end