//
//  IAUIAppearanceTheme.h
//  Gusty
//
//  Created by Marcelo Schroeder on 12/07/12.
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

typedef enum {
    IAUISpacingBarButtonItemTypeLeft,
    IAUISpacingBarButtonItemTypeMiddle,
    IAUISpacingBarButtonItemTypeRight,
} IAUISpacingBarButtonItemType;

@class IAUITableViewController;
@class GADBannerView;
@class IAUICollectionViewCell;

@protocol IAUIAppearanceTheme <NSObject>

@property (nonatomic, strong, readonly) UINavigationBar *p_navigationBarAppearance;
@property (nonatomic, strong, readonly) UINavigationBar *p_popoverNavigationBarAppearance;
@property (nonatomic, strong, readonly) UIBarButtonItem *p_barButtonItemAppearance;
@property (nonatomic, strong, readonly) UIBarButtonItem *p_navigationBarButtonItemAppearance;
@property (nonatomic, strong, readonly) UIBarButtonItem *p_toolbarButtonItemAppearance;
@property (nonatomic, strong, readonly) UIToolbar *p_toolbarAppearance;
@property (nonatomic, strong, readonly) UIToolbar *p_popoverToolbarAppearance;
@property (nonatomic, strong, readonly) UITabBar *p_tabBarAppearance;
@property (nonatomic, strong, readonly) UITabBarItem *p_tabBarItemAppearance;
@property (nonatomic, strong, readonly) UISearchBar *p_searchBarAppearance;
@property (nonatomic, strong, readonly) UISegmentedControl *p_barSegmentedControlAppearance;
@property (nonatomic, strong, readonly) UISegmentedControl *p_segmentedControlAppearance;
@property (nonatomic, strong, readonly) UISwitch *p_switchAppearance;
@property (nonatomic, strong, readonly) UISlider *p_sliderAppearance;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *p_activityIndicatorView;
@property (nonatomic, strong, readonly) UIPageControl *p_pageControlAppearance;

@property (nonatomic, strong) NSShadow *p_shadow;

-(void)setAppearance;
-(void)setAppearanceForView:(UIView*)a_view;
-(void)setAppearanceForBarButtonItem:(UIBarButtonItem*)a_barButtonItem;
-(void)setAppearanceForBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                      viewController:(UIViewController *)a_viewController important:(BOOL)a_important;
-(void)setAppearanceForToolbarButtonItem:(UIBarButtonItem*)a_barButtonItem;
-(void)setAppearanceForPopoverController:(UIPopoverController*)a_popoverController;

-(void)setLabelTextStyleForChildrenOfView:(UIView*)a_view;

-(NSString*)themeName;
-(NSString*)fallbackThemeName;
-(NSBundle*)bundle;
-(NSString*)storyboardName;
-(UIStoryboard*)storyboard;
-(UIImage*)imageNamed:(NSString*)a_imageName;
-(NSString*)nameSpacedResourceName:(NSString*)a_resourceName;

-(UIColor*)barButtonItemTintColor;
-(UIColor*)importantBarButtonItemTintColor;
-(UIColor*)tableCellTextColor;
-(UIFont*)tableCellTextFont;

-(UIButton*)newDetailDisclosureButton;
-(UIView*)newDisclosureIndicatorView;
- (void)setCustomDisclosureIndicatorForCell:(UITableViewCell *)a_cell
                        tableViewController:(UITableViewController *)a_tableViewController;
-(UIImage*)backgroundImageForViewController:(UIViewController*)a_viewController;

-(UIColor*)selectedTableCellBackgroundColor;

// Google ads styling
-(NSDictionary*)gadAdditionalParameters;

-(UIBarButtonItem*)backBarButtonItem;
-(UIBarButtonItem*)backBarButtonItemForViewController:(UIViewController *)a_viewController;
-(UIBarButtonItem*)splitViewControllerBarButtonItem;
-(UIBarButtonItem*)slidingMenuBarButtonItem;
-(UIBarButtonItem*)slidingMenuBarButtonItemForViewController:(UIViewController *)a_viewController;

- (UIBarButtonItem *)doneBarButtonItemWithTarget:(id)a_target action:(SEL)a_action
                                  viewController:(UIViewController *)a_viewController;

- (UIBarButtonItem *)cancelBarButtonItemWithTarget:(id)a_target
                                            action:(SEL)a_action
                                    viewController:(UIViewController *)a_viewController;
- (UIBarButtonItem *)cancelBarButtonItemWithTarget:(id)a_target
                                            action:(SEL)a_action;

// Bar button item spacing automation
-(BOOL)shouldAutomateBarButtonItemSpacingForViewController:(UIViewController*)a_viewController;
-(UIBarButtonItem*)spacingBarButtonItemForType:(IAUISpacingBarButtonItemType)a_type viewController:(UIViewController*)a_viewController;

- (UIViewController *)newInternalWebBrowserViewControllerWithUrl:(NSURL *)a_url;
- (UIViewController *)newInternalWebBrowserViewControllerWithUrl:(NSURL *)a_url completionBlock:(void(^)(void))a_completionBlock;

-(Class)navigationControllerClass;

/*
    Some of these have been moved to the more specific protocols below.
    Ideally these would be deprecated one day.
*/
-(void)setAppearanceOnViewDidLoadForViewController:(UIViewController*)a_viewController;
-(void)setAppearanceOnViewWillAppearForViewController:(UIViewController*)a_viewController;
-(void)setAppearanceOnWillRotateForViewController:(UIViewController *)a_viewController toInterfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation;
-(void)setAppearanceOnWillAnimateRotationForViewController:(UIViewController *)a_viewController interfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation;
-(void)setAppearanceOnInitReusableCellForViewController:(UITableViewController *)a_tableViewController cell:(UITableViewCell*)a_cell;
-(void)setAppearanceOnWillDisplayCell:(UITableViewCell *)a_cell forRowAtIndexPath:(NSIndexPath *)a_indexPath
                       viewController:(IAUITableViewController*)a_tableViewController;
-(void)setAppearanceForCell:(UITableViewCell *)a_cell atIndexPath:(NSIndexPath *)a_indexPath viewController:(IAUITableViewController*)a_tableViewController;
-(void)setAppearanceOnAwakeFromNibForView:(UIView*)a_view;
-(void)setAppearanceOnInitForView:(UIView*)a_view;
- (void)setAppearanceOnSetHighlightedForCell:(UITableViewCell *)a_cell animated:(BOOL)a_shouldAnimate;
- (void)setAppearanceOnSetSelectedForCell:(UITableViewCell *)a_cell animated:(BOOL)a_shouldAnimate;
-(void)setAppearanceOnPrepareForReuseForCell:(UITableViewCell *)a_cell;

@optional
-(void)willReloadUi;
-(void)setAppearanceForAdBannerView:(GADBannerView *)a_adBannerView;
-(void)setAppearanceForCollectionViewCell:(UICollectionViewCell *)a_cell atIndexPath:(NSIndexPath *)a_indexPath
                           viewController:(IAUICollectionViewCell*)a_collectionViewController;

@end

@protocol IAUIViewControllerAppearance <NSObject>
@optional
-(void)setAppearanceOnViewDidLoadForViewController:(UIViewController*)a_viewController;
-(void)setAppearanceOnViewWillAppearForViewController:(UIViewController*)a_viewController;
-(void)setAppearanceOnWillRotateForViewController:(UIViewController *)a_viewController toInterfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation;
-(void)setAppearanceOnWillAnimateRotationForViewController:(UIViewController *)a_viewController interfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation;
@end

@protocol IAUITableViewControllerAppearance <IAUIViewControllerAppearance>
@optional
-(void)setAppearanceOnInitReusableCellForViewController:(UITableViewController *)a_tableViewController cell:(UITableViewCell*)a_cell;
-(void)setAppearanceOnWillDisplayCell:(UITableViewCell *)a_cell forRowAtIndexPath:(NSIndexPath *)a_indexPath
                       viewController:(IAUITableViewController*)a_tableViewController;
-(void)setAppearanceForCell:(UITableViewCell *)a_cell atIndexPath:(NSIndexPath *)a_indexPath viewController:(IAUITableViewController*)a_tableViewController;
@end

@protocol IAUIViewAppearance <NSObject>
@optional
-(void)setAppearanceOnAwakeFromNibForView:(UIView*)a_view;
-(void)setAppearanceOnInitForView:(UIView*)a_view;
@end

@protocol IAUITableViewCellAppearance <IAUIViewAppearance>
@optional
-(void)setAppearanceOnSetHighlightedForCell:(UITableViewCell *)a_cell;
@end
