//
//  IAUIDefaultAppearanceTheme.m
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

#import "IACommon.h"

@interface IAUIDefaultAppearanceTheme ()

// Status bar
@property (nonatomic) UIStatusBarStyle p_statusBarStyle;

// Navigation bar
@property (nonatomic, strong) UIImage *p_navigationBarBackgroundImageForDefaultBarMetrics;
@property (nonatomic, strong) UIImage *p_popoverNavigationBarBackgroundImageForDefaultBarMetrics;
@property (nonatomic) CGFloat p_navigationBarTitleVerticalPositionAdjustmentDefault;
@property (nonatomic) CGFloat p_navigationBarTitleVerticalPositionAdjustmentLandscapePhone;

// Navigation bar title text
@property (nonatomic, strong) NSDictionary *p_navigationBarTitleTextAttributes;

// Bar button items
@property (nonatomic, strong) UIColor *p_barButtonItemTintColor;
@property (nonatomic, strong) UIColor *p_navigationBarButtonItemTintColor;
@property (nonatomic, strong) UIColor *p_toolbarButtonItemTintColor;

// Toobar background
@property (nonatomic, strong) UIImage *p_toolbarBackgroundImageForDefaultBarMetrics;
@property (nonatomic, strong) UIImage *p_popoverToolbarBarBackgroundImageForDefaultBarMetrics;

// TabBar
@property (nonatomic, strong) UIImage *p_tabBarBackgroundImage;
@property (nonatomic, strong) UIColor *p_tabBarSelectedImageTintColor;

// TabBar Item
@property (nonatomic, strong) NSDictionary *p_tabBarItemTitleTextAttributesForNormalState;
@property (nonatomic, strong) NSDictionary *p_tabBarItemTitleTextAttributesForSelectedState;

// Search bar
@property (nonatomic, strong) UIImage *p_searchBarBackgroundImage;

// Segmented control
@property (nonatomic, strong) UIColor *p_segmentedControlTintColor;

@end

@implementation IAUIDefaultAppearanceTheme

#pragma mark - Overrides

- (id)init{
    self = [super init];
    if (self) {
        
        // Status bar
        self.p_statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        
        // Navigation bar
        self.p_navigationBarBackgroundImageForDefaultBarMetrics = [self.navigationBarAppearance backgroundImageForBarMetrics:UIBarMetricsDefault];
        self.p_popoverNavigationBarBackgroundImageForDefaultBarMetrics = [self.popoverNavigationBarAppearance backgroundImageForBarMetrics:UIBarMetricsDefault];
        self.p_navigationBarTitleTextAttributes = self.navigationBarAppearance.titleTextAttributes;
        self.p_navigationBarTitleVerticalPositionAdjustmentDefault = [self.navigationBarAppearance titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault];
        self.p_navigationBarTitleVerticalPositionAdjustmentLandscapePhone = [self.navigationBarAppearance titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsLandscapePhone];
        
        // Bar button items
        self.p_barButtonItemTintColor = self.barButtonItemAppearance.tintColor;
        self.p_navigationBarButtonItemTintColor = self.navigationBarButtonItemAppearance.tintColor;
        self.p_toolbarButtonItemTintColor = self.toolbarButtonItemAppearance.tintColor;
        
        // Toobar background
        self.p_toolbarBackgroundImageForDefaultBarMetrics = [self.toolbarAppearance backgroundImageForToolbarPosition:UIToolbarPositionAny
                                                                                                           barMetrics:UIBarMetricsDefault];
        self.p_popoverToolbarBarBackgroundImageForDefaultBarMetrics = [self.popoverToolbarAppearance backgroundImageForToolbarPosition:UIToolbarPositionAny
                                                                                                                            barMetrics:UIBarMetricsDefault];
        
        // TabBar
        self.p_tabBarBackgroundImage = self.tabBarAppearance.backgroundImage;
        self.p_tabBarSelectedImageTintColor = self.tabBarAppearance.selectedImageTintColor;
        
        // TabBar Item
        self.p_tabBarItemTitleTextAttributesForNormalState = [self.tabBarItemAppearance titleTextAttributesForState:UIControlStateNormal];
        self.p_tabBarItemTitleTextAttributesForSelectedState = [self.tabBarItemAppearance titleTextAttributesForState:UIControlStateSelected];
        
        // Search bar
        self.p_searchBarBackgroundImage = self.searchBarAppearance.backgroundImage;
        
        // Segmented control
        self.p_segmentedControlTintColor = self.segmentedControlAppearance.tintColor;

    }
    return self;
}

-(void)setAppearance {

    [super setAppearance];
    
    // Status bar
    [UIApplication sharedApplication].statusBarStyle = self.p_statusBarStyle;
    
    // Navigation bar
    [self.navigationBarAppearance setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.popoverNavigationBarAppearance setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationBarAppearance setTitleTextAttributes:nil];
    [self.popoverNavigationBarAppearance setTitleTextAttributes:nil];
    [self.navigationBarAppearance setTitleVerticalPositionAdjustment:self.p_navigationBarTitleVerticalPositionAdjustmentDefault
                                                       forBarMetrics:UIBarMetricsDefault];
    [self.navigationBarAppearance setTitleVerticalPositionAdjustment:self.p_navigationBarTitleVerticalPositionAdjustmentLandscapePhone
                                                       forBarMetrics:UIBarMetricsLandscapePhone];
    
    // Bar button items
    [self.barButtonItemAppearance setTintColor:self.p_barButtonItemTintColor];
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
    [self.navigationBarButtonItemAppearance setTintColor:self.p_navigationBarButtonItemTintColor];
    [self.toolbarButtonItemAppearance setTintColor:self.p_toolbarButtonItemTintColor];
    
    // Toobar background
    [self.toolbarAppearance setBackgroundImage:self.p_toolbarBackgroundImageForDefaultBarMetrics
                            forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.popoverToolbarAppearance setBackgroundImage:self.p_popoverToolbarBarBackgroundImageForDefaultBarMetrics
                                   forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    // TabBar
    [self.tabBarAppearance setBackgroundImage:self.p_tabBarBackgroundImage];
    [self.tabBarAppearance setSelectedImageTintColor:self.p_tabBarSelectedImageTintColor];
    
    // TabBar Item
    [self.tabBarItemAppearance setTitleTextAttributes:self.p_tabBarItemTitleTextAttributesForNormalState
                                             forState:UIControlStateNormal];
    [self.tabBarItemAppearance setTitleTextAttributes:self.p_tabBarItemTitleTextAttributesForSelectedState
                                             forState:UIControlStateSelected];
    
    // Search bar
    self.searchBarAppearance.backgroundImage = self.p_searchBarBackgroundImage;
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
    self.segmentedControlAppearance.tintColor = self.p_segmentedControlTintColor;
    
    // Slider
    self.sliderAppearance.minimumTrackTintColor = nil;
    self.sliderAppearance.maximumTrackTintColor = nil;
    
}

@end
