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

#import "GustyLibCoreUI.h"


@interface IFAMapSettingsViewController ()
@property (nonatomic) MKMapType IFA_selectedMapType;
@end

@implementation IFAMapSettingsViewController {

}

#pragma Public

- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    [self view];    // Make sure view is loaded
    self.IFA_selectedMapType = self.mapView.mapType;
}

- (IBAction)onMapTypeSegmentedControlValueChanged:(UISegmentedControl *)sender {
    self.mapView.mapType = self.IFA_selectedMapType;
    [self ifa_notifySessionCompletionWithChangesMade:YES data:nil];
}

#pragma mark - Overrides

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self IFA_configureView];
}

-(BOOL)ifa_hasFixedSize {
    return YES;
}

#pragma mark - Private

- (NSInteger)IFA_segmentIndexFromMapType:(MKMapType)a_mapType{
    NSInteger l_segmentIndex;
    switch (a_mapType){
        case MKMapTypeStandard:
            l_segmentIndex = 0;
            break;
        case MKMapTypeHybrid:
            l_segmentIndex = 1;
            break;
        default:
            l_segmentIndex = 2;
    }
    return l_segmentIndex;
}

- (MKMapType)IFA_mapTypeFromSelectedSegmentIndex:(NSInteger)a_selectedSegmentIndex {
    MKMapType l_mapType;
    switch (a_selectedSegmentIndex){
        case 0:
            l_mapType = MKMapTypeStandard;
            break;
        case 1:
            l_mapType = MKMapTypeHybrid;
            break;
        default:
            l_mapType = MKMapTypeSatellite;
    }
    return l_mapType;
}

- (void)IFA_configureView {
    // Fixed size for modal presentation
    CGSize l_size = [self.view systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    CGRect l_frame = self.view.frame;
    l_frame.size = l_size;
    self.view.frame = l_frame;
}

- (MKMapType)IFA_selectedMapType {
    return [self IFA_mapTypeFromSelectedSegmentIndex:self.mapTypeSegmentedControl.selectedSegmentIndex];
}

- (void)setIFA_selectedMapType:(MKMapType)a_selectedMapType {
    self.mapTypeSegmentedControl.selectedSegmentIndex = [self IFA_segmentIndexFromMapType:a_selectedMapType];
}

@end