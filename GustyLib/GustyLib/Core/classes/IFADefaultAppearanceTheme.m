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

#import "GustyLib.h"

@interface IFADefaultAppearanceTheme ()

// Status bar
@property (nonatomic) UIStatusBarStyle IFA_statusBarStyle;

// Navigation bar
@property (nonatomic, strong) UIImage *IFA_navigationBarBackgroundImageForDefaultBarMetrics;
@property (nonatomic, strong) UIImage *IFA_popoverNavigationBarBackgroundImageForDefaultBarMetrics;
@property (nonatomic) CGFloat IFA_navigationBarTitleVerticalPositionAdjustmentDefault;
@property (nonatomic) CGFloat IFA_navigationBarTitleVerticalPositionAdjustmentLandscapePhone;

// Navigation bar title text
@property (nonatomic, strong) NSDictionary *IFA_navigationBarTitleTextAttributes;

// Bar button items
@property (nonatomic, strong) UIColor *IFA_barButtonItemTintColor;
@property (nonatomic, strong) UIColor *IFA_navigationBarButtonItemTintColor;
@property (nonatomic, strong) UIColor *IFA_toolbarButtonItemTintColor;

// Toobar background
@property (nonatomic, strong) UIImage *IFA_toolbarBackgroundImageForDefaultBarMetrics;
@property (nonatomic, strong) UIImage *IFA_popoverToolbarBarBackgroundImageForDefaultBarMetrics;

// TabBar
@property (nonatomic, strong) UIImage *IFA_tabBarBackgroundImage;
@property (nonatomic, strong) UIColor *IFA_tabBarSelectedImageTintColor;

// TabBar Item
@property (nonatomic, strong) NSDictionary *IFA_tabBarItemTitleTextAttributesForNormalState;
@property (nonatomic, strong) NSDictionary *IFA_tabBarItemTitleTextAttributesForSelectedState;

// Search bar
@property (nonatomic, strong) UIImage *IFA_searchBarBackgroundImage;

// Segmented control
@property (nonatomic, strong) UIColor *IFA_segmentedControlTintColor;

@end

@implementation IFADefaultAppearanceTheme

#pragma mark - Overrides

- (id)init{
    self = [super init];
    if (self) {
        
        // Status bar
        self.IFA_statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        
        // Navigation bar
        self.IFA_navigationBarBackgroundImageForDefaultBarMetrics = [self.navigationBarAppearance backgroundImageForBarMetrics:UIBarMetricsDefault];
        self.IFA_popoverNavigationBarBackgroundImageForDefaultBarMetrics = [self.popoverNavigationBarAppearance backgroundImageForBarMetrics:UIBarMetricsDefault];
        self.IFA_navigationBarTitleTextAttributes = self.navigationBarAppearance.titleTextAttributes;
        self.IFA_navigationBarTitleVerticalPositionAdjustmentDefault = [self.navigationBarAppearance titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault];
        self.IFA_navigationBarTitleVerticalPositionAdjustmentLandscapePhone = [self.navigationBarAppearance titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsLandscapePhone];
        
        // Bar button items
        self.IFA_barButtonItemTintColor = self.barButtonItemAppearance.tintColor;
        self.IFA_navigationBarButtonItemTintColor = self.navigationBarButtonItemAppearance.tintColor;
        self.IFA_toolbarButtonItemTintColor = self.toolbarButtonItemAppearance.tintColor;
        
        // Toobar background
        self.IFA_toolbarBackgroundImageForDefaultBarMetrics = [self.toolbarAppearance backgroundImageForToolbarPosition:UIToolbarPositionAny
                                                                                                           barMetrics:UIBarMetricsDefault];
        self.IFA_popoverToolbarBarBackgroundImageForDefaultBarMetrics = [self.popoverToolbarAppearance backgroundImageForToolbarPosition:UIToolbarPositionAny
                                                                                                                            barMetrics:UIBarMetricsDefault];
        
        // TabBar
        self.IFA_tabBarBackgroundImage = self.tabBarAppearance.backgroundImage;
        self.IFA_tabBarSelectedImageTintColor = self.tabBarAppearance.selectedImageTintColor;
        
        // TabBar Item
        self.IFA_tabBarItemTitleTextAttributesForNormalState = [self.tabBarItemAppearance titleTextAttributesForState:UIControlStateNormal];
        self.IFA_tabBarItemTitleTextAttributesForSelectedState = [self.tabBarItemAppearance titleTextAttributesForState:UIControlStateSelected];
        
        // Search bar
        self.IFA_searchBarBackgroundImage = self.searchBarAppearance.backgroundImage;
        
        // Segmented control
        self.IFA_segmentedControlTintColor = self.segmentedControlAppearance.tintColor;

    }
    return self;
}

-(void)setAppearance {

    [super setAppearance];
    
    // Status bar
    [UIApplication sharedApplication].statusBarStyle = self.IFA_statusBarStyle;
    
    // Navigation bar
    [self.navigationBarAppearance setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.popoverNavigationBarAppearance setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationBarAppearance setTitleTextAttributes:nil];
    [self.popoverNavigationBarAppearance setTitleTextAttributes:nil];
    [self.navigationBarAppearance setTitleVerticalPositionAdjustment:self.IFA_navigationBarTitleVerticalPositionAdjustmentDefault
                                                       forBarMetrics:UIBarMetricsDefault];
    [self.navigationBarAppearance setTitleVerticalPositionAdjustment:self.IFA_navigationBarTitleVerticalPositionAdjustmentLandscapePhone
                                                       forBarMetrics:UIBarMetricsLandscapePhone];
    
    // Bar button items
    [self.barButtonItemAppearance setTintColor:self.IFA_barButtonItemTintColor];
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
    [self.navigationBarButtonItemAppearance setTintColor:self.IFA_navigationBarButtonItemTintColor];
    [self.toolbarButtonItemAppearance setTintColor:self.IFA_toolbarButtonItemTintColor];
    
    // Toobar background
    [self.toolbarAppearance setBackgroundImage:self.IFA_toolbarBackgroundImageForDefaultBarMetrics
                            forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [self.popoverToolbarAppearance setBackgroundImage:self.IFA_popoverToolbarBarBackgroundImageForDefaultBarMetrics
                                   forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    // TabBar
    [self.tabBarAppearance setBackgroundImage:self.IFA_tabBarBackgroundImage];
    [self.tabBarAppearance setSelectedImageTintColor:self.IFA_tabBarSelectedImageTintColor];
    
    // TabBar Item
    [self.tabBarItemAppearance setTitleTextAttributes:self.IFA_tabBarItemTitleTextAttributesForNormalState
                                             forState:UIControlStateNormal];
    [self.tabBarItemAppearance setTitleTextAttributes:self.IFA_tabBarItemTitleTextAttributesForSelectedState
                                             forState:UIControlStateSelected];
    
    // Search bar
    self.searchBarAppearance.backgroundImage = self.IFA_searchBarBackgroundImage;
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
    self.segmentedControlAppearance.tintColor = self.IFA_segmentedControlTintColor;
    
    // Slider
    self.sliderAppearance.minimumTrackTintColor = nil;
    self.sliderAppearance.maximumTrackTintColor = nil;
    
}

@end
