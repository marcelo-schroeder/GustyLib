//
//  IFADefaultAppearanceTheme.h
//  Gusty
//
//  Created by Marcelo Schroeder on 29/06/12.
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

#import "IFAAppearanceTheme.h"

@class IFANavigationItemTitleView;
@class IFAColorScheme;
@class IFAFormTableViewCell;
@class IFAHudView;

@interface IFADefaultAppearanceTheme : NSObject <IFAAppearanceTheme>

@property (nonatomic, strong) UINavigationBar *navigationBarAppearance;
@property (nonatomic, strong) UINavigationBar *popoverNavigationBarAppearance;
@property (nonatomic, strong) UIBarButtonItem *barButtonItemAppearance;
@property (nonatomic, strong) UIBarButtonItem *navigationBarButtonItemAppearance;
@property (nonatomic, strong) UIBarButtonItem *toolbarButtonItemAppearance;
@property (nonatomic, strong) UIToolbar *toolbarAppearance;
@property (nonatomic, strong) UIToolbar *popoverToolbarAppearance;
@property (nonatomic, strong) UITabBar *tabBarAppearance;
@property (nonatomic, strong) UITabBarItem *tabBarItemAppearance;
@property (nonatomic, strong) UISearchBar *searchBarAppearance;
@property (nonatomic, strong) UISegmentedControl *barSegmentedControlAppearance;
@property (nonatomic, strong) UISegmentedControl *segmentedControlAppearance;
@property (nonatomic, strong) UISwitch *switchAppearance;
@property (nonatomic, strong) UISlider *sliderAppearance;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIPageControl *pageControlAppearance;
@property (nonatomic, strong) NSShadow *shadow;

-(void)setOrientationDependentBackgroundImagesForViewController:(UIViewController*)a_viewController;
-(IFANavigationItemTitleView *)navigationItemTitleViewForViewController:(UIViewController *)a_viewController barMetrics:(UIBarMetrics)a_barMetrics;
-(UINavigationItem*)titleViewNavigationItemForViewViewController:(UIViewController*)a_viewController;
- (void)setCustomDisclosureIndicatorForCell:(UITableViewCell *)a_cell
                        tableViewController:(UITableViewController *)a_tableViewController;
-(IFAColorScheme *)colorScheme;
-(UIColor*)colorWithIndex:(NSUInteger)a_colorIndex;
-(void)setCustomAccessoryViewAppearanceForFormTableViewCell:(IFAFormTableViewCell *)a_cell;

/**
* Returns the background colour of group style table views.
* Current as of iOS 7.
* @returns Group style table view's background colour.
*/
- (UIColor *)groupStyleTableViewBackgroundColour;

/**
* Determines the default values for <IFAHudView>'s appearance properties.
* @param a_hudView HUD view instance to return the appearance property default values for.
* @returns Dictionary containing <IFAHudView> property names as keys and their corresponding values as values.
*/
+ (NSDictionary *)defaultAppearancePropertiesForHudView:(IFAHudView *)a_hudView;

+ (UIColor *)splitViewControllerDividerColour;

@end
