//
//  IFADefaultAppearanceTheme.m
//  Gusty
//
//  Created by Marcelo Schroeder on 2/08/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

#import "IFACommon.h"

@interface IFADefaultAppearanceTheme ()

// Status bar
@property (nonatomic) UIStatusBarStyle ifa_statusBarStyle;

// Navigation bar
@property (nonatomic, strong) UIImage *ifa_navigationBarBackgroundImageForDefaultBarMetrics;
@property (nonatomic, strong) UIImage *ifa_popoverNavigationBarBackgroundImageForDefaultBarMetrics;
@property (nonatomic) CGFloat ifa_navigationBarTitleVerticalPositionAdjustmentDefault;
@property (nonatomic) CGFloat ifa_navigationBarTitleVerticalPositionAdjustmentLandscapePhone;

// Navigation bar title text
@property (nonatomic, strong) NSDictionary *ifa_navigationBarTitleTextAttributes;

// Bar button items
@property (nonatomic, strong) UIColor *ifa_barButtonItemTintColor;
@property (nonatomic, strong) UIColor *ifa_navigationBarButtonItemTintColor;
@property (nonatomic, strong) UIColor *ifa_toolbarButtonItemTintColor;

// Toobar background
@property (nonatomic, strong) UIImage *ifa_toolbarBackgroundImageForDefaultBarMetrics;
@property (nonatomic, strong) UIImage *ifa_popoverToolbarBarBackgroundImageForDefaultBarMetrics;

// TabBar
@property (nonatomic, strong) UIImage *ifa_tabBarBackgroundImage;
@property (nonatomic, strong) UIColor *ifa_tabBarSelectedImageTintColor;

// TabBar Item
@property (nonatomic, strong) NSDictionary *ifa_tabBarItemTitleTextAttributesForNormalState;
@property (nonatomic, strong) NSDictionary *ifa_tabBarItemTitleTextAttributesForSelectedState;

// Search bar
@property (nonatomic, strong) UIImage *ifa_searchBarBackgroundImage;

// Segmented control
@property (nonatomic, strong) UIColor *ifa_segmentedControlTintColor;

@end

@implementation IFADefaultAppearanceTheme

#pragma mark - Overrides

- (id)init{
    self = [super init];
    if (self) {
        
        // Status bar
        self.ifa_statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        
        // Navigation bar
        self.ifa_navigationBarBackgroundImageForDefaultBarMetrics = [self.navigationBarAppearance backgroundImageForBarMetrics:UIBarMetricsDefault];
        self.ifa_popoverNavigationBarBackgroundImageForDefaultBarMetrics = [self.popoverNavigationBarAppearance backgroundImageForBarMetrics:UIBarMetricsDefault];
        self.ifa_navigationBarTitleTextAttributes = self.navigationBarAppearance.titleTextAttributes;
        self.ifa_navigationBarTitleVerticalPositionAdjustmentDefault = [self.navigationBarAppearance titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault];
        self.ifa_navigationBarTitleVerticalPositionAdjustmentLandscapePhone = [self.navigationBarAppearance titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsLandscapePhone];
        
        // Bar button items
        self.ifa_barButtonItemTintColor = self.barButtonItemAppearance.tintColor;
        self.ifa_navigationBarButtonItemTintColor = self.navigationBarButtonItemAppearance.tintColor;
        self.ifa_toolbarButtonItemTintColor = self.toolbarButtonItemAppearance.tintColor;
        
        // Toobar background
        self.ifa_toolbarBackgroundImageForDefaultBarMetrics = [self.toolbarAppearance backgroundImageForToolbarPosition:UIToolbarPositionAny
                                                                                                           barMetrics:UIBarMetricsDefault];
        self.ifa_popoverToolbarBarBackgroundImageForDefaultBarMetrics = [self.popoverToolbarAppearance backgroundImageForToolbarPosition:UIToolbarPositionAny
                                                                                                                            barMetrics:UIBarMetricsDefault];
        
        // TabBar
        self.ifa_tabBarBackgroundImage = self.tabBarAppearance.backgroundImage;
        self.ifa_tabBarSelectedImageTintColor = self.tabBarAppearance.selectedImageTintColor;
        
        // TabBar Item
        self.ifa_tabBarItemTitleTextAttributesForNormalState = [self.tabBarItemAppearance titleTextAttributesForState:UIControlStateNormal];
        self.ifa_tabBarItemTitleTextAttributesForSelectedState = [self.tabBarItemAppearance titleTextAttributesForState:UIControlStateSelected];
        
        // Search bar
        self.ifa_searchBarBackgroundImage = self.searchBarAppearance.backgroundImage;
        
        // Segmented control
        self.ifa_segmentedControlTintColor = self.segmentedControlAppearance.tintColor;

    }
    return self;
}

-(void)setAppearance {

    [super setAppearance];
    
    // Status bar
    [UIApplication sharedApplication].statusBarStyle = self.ifa_statusBarStyle;
    
    // Navigation bar
    [self.navigationBarAppearance setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.popoverNavigationBarAppearance setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationBarAppearance setTitleTextAttributes:nil];
    [self.popoverNavigationBarAppearance setTitleTextAttributes:nil];
    [self.navigationBarAppearance setTitleVerticalPositionAdjustment:self.ifa_navigationBarTitleVerticalPositionAdjustmentDefault
                                                       forBarMetrics:UIBarMetricsDefault];
    [self.navigationBarAppearance setTitleVerticalPositionAdjustment:self.ifa_navigationBarTitleVerticalPositionAdjustmentLandscapePhone
                                                       forBarMetrics:UIBarMetricsLandscapePhone];
    
    // Bar button items
    [self.barButtonItemAppearance setTintColor:self.ifa_barButtonItemTintColor];
    [self.barButtonItemAppearance setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.barButtonItemAppearance setBackgroundImage:nil forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsLandscapePhone];
    [self.barButtonItemAppearance setBackgroundImage:nil forState:UIControlStateHighlighted
                                          barMetrics:UIBarMetricsDefault];
    [self.barButtonItemAppearance setBackgroundImage:nil forState:UIControlStateHighlighted
                                          barMetrics:UIBarMetricsLandscapePhone];
    [self.barButtonItemAppearance setBackButtonBackgroundImage:nil forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [self.barButtonItemAppearance setBackButtonBackgroundImage:nil forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsLandscapePhone];
    [self.barButtonItemAppearance setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];
    [self.barButtonItemAppearance setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsLandscapePhone];
    [self.barButtonItemAppearance setTitleTextAttributes:nil forState:UIControlStateNormal];
    [self.barButtonItemAppearance setTitleTextAttributes:nil forState:UIControlStateHighlighted];
    [self.navigationBarButtonItemAppearance setTintColor:self.ifa_navigationBarButtonItemTintColor];
    [self.toolbarButtonItemAppearance setTintColor:self.ifa_toolbarButtonItemTintColor];
    
    // Toobar background
    [self.toolbarAppearance setBackgroundImage:self.ifa_toolbarBackgroundImageForDefaultBarMetrics
                            forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.popoverToolbarAppearance setBackgroundImage:self.ifa_popoverToolbarBarBackgroundImageForDefaultBarMetrics
                                   forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    // TabBar
    [self.tabBarAppearance setBackgroundImage:self.ifa_tabBarBackgroundImage];
    [self.tabBarAppearance setSelectedImageTintColor:self.ifa_tabBarSelectedImageTintColor];
    
    // TabBar Item
    [self.tabBarItemAppearance setTitleTextAttributes:self.ifa_tabBarItemTitleTextAttributesForNormalState
                                             forState:UIControlStateNormal];
    [self.tabBarItemAppearance setTitleTextAttributes:self.ifa_tabBarItemTitleTextAttributesForSelectedState
                                             forState:UIControlStateSelected];
    
    // Search bar
    self.searchBarAppearance.backgroundImage = self.ifa_searchBarBackgroundImage;
    [self.searchBarAppearance setImage:nil forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    // Segmented control
    [self.segmentedControlAppearance setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedControlAppearance setBackgroundImage:nil forState:UIControlStateSelected
                                             barMetrics:UIBarMetricsDefault];
    [self.segmentedControlAppearance setDividerImage:nil forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedControlAppearance setDividerImage:nil forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.segmentedControlAppearance setDividerImage:nil forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedControlAppearance setTitleTextAttributes:nil forState:UIControlStateNormal];
    [self.segmentedControlAppearance setTitleTextAttributes:nil forState:UIControlStateSelected];
    self.segmentedControlAppearance.tintColor = self.ifa_segmentedControlTintColor;
    
    // Slider
    self.sliderAppearance.minimumTrackTintColor = nil;
    self.sliderAppearance.maximumTrackTintColor = nil;
    
}

@end
