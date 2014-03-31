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

-(void)m_setAppearance;
-(void)m_setAppearanceForView:(UIView*)a_view;
-(void)m_setAppearanceForBarButtonItem:(UIBarButtonItem*)a_barButtonItem;
-(void)m_setAppearanceForBarButtonItem:(UIBarButtonItem *)a_barButtonItem viewController:(UIViewController *)a_viewController important:(BOOL)a_important;
-(void)m_setAppearanceForToolbarButtonItem:(UIBarButtonItem*)a_barButtonItem;
-(void)m_setAppearanceForPopoverController:(UIPopoverController*)a_popoverController;

-(void)m_setLabelTextStyleForChildrenOfView:(UIView*)a_view;

-(NSString*)m_themeName;
-(NSString*)m_fallbackThemeName;
-(NSBundle*)m_bundle;
-(NSString*)m_storyboardName;
-(UIStoryboard*)m_storyboard;
-(UIImage*)m_imageNamed:(NSString*)a_imageName;
-(NSString*)m_nameSpacedResourceName:(NSString*)a_resourceName;

-(UIColor*)m_barButtonItemTintColor;
-(UIColor*)m_importantBarButtonItemTintColor;
-(UIColor*)m_tableCellTextColor;
-(UIFont*)m_tableCellTextFont;

-(UIButton*)m_newDetailDisclosureButton;
-(UIView*)m_newDisclosureIndicatorView;
- (void)m_setCustomDisclosureIndicatorForCell:(UITableViewCell *)a_cell
                          tableViewController:(UITableViewController *)a_tableViewController;
-(UIImage*)m_backgroundImageForViewController:(UIViewController*)a_viewController;

-(UIColor*)m_selectedTableCellBackgroundColor;

// Google ads styling
-(NSDictionary*)m_gadAdditionalParameters;

-(UIBarButtonItem*)m_backBarButtonItem;
-(UIBarButtonItem*)m_backBarButtonItemForViewController:(UIViewController *)a_viewController;
-(UIBarButtonItem*)m_splitViewControllerBarButtonItem;
-(UIBarButtonItem*)m_slidingMenuBarButtonItem;
-(UIBarButtonItem*)m_slidingMenuBarButtonItemForViewController:(UIViewController *)a_viewController;

- (UIBarButtonItem *)m_doneBarButtonItemWithTarget:(id)a_target action:(SEL)a_action
                                    viewController:(UIViewController *)a_viewController;

- (UIBarButtonItem *)m_cancelBarButtonItemWithTarget:(id)a_target
                                              action:(SEL)a_action
                                      viewController:(UIViewController *)a_viewController;
- (UIBarButtonItem *)m_cancelBarButtonItemWithTarget:(id)a_target
                                              action:(SEL)a_action;

// Bar button item spacing automation
-(BOOL)m_shouldAutomateBarButtonItemSpacingForViewController:(UIViewController*)a_viewController;
-(UIBarButtonItem*)m_spacingBarButtonItemForType:(IAUISpacingBarButtonItemType)a_type viewController:(UIViewController*)a_viewController;

- (UIViewController *)m_newInternalWebBrowserViewControllerWithUrl:(NSURL *)a_url;
- (UIViewController *)m_newInternalWebBrowserViewControllerWithUrl:(NSURL *)a_url completionBlock:(void(^)(void))a_completionBlock;

-(Class)m_navigationControllerClass;

/*
    Some of these have been moved to the more specific protocols below.
    Ideally these would be deprecated one day.
*/
-(void)m_setAppearanceOnViewDidLoadForViewController:(UIViewController*)a_viewController;
-(void)m_setAppearanceOnViewWillAppearForViewController:(UIViewController*)a_viewController;
-(void)m_setAppearanceOnWillRotateForViewController:(UIViewController*)a_viewController toInterfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation;
-(void)m_setAppearanceOnWillAnimateRotationForViewController:(UIViewController*)a_viewController interfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation;
-(void)m_setAppearanceOnInitReusableCellForViewController:(UITableViewController*)a_tableViewController cell:(UITableViewCell*)a_cell;
-(void)m_setAppearanceOnWillDisplayCell:(UITableViewCell*)a_cell forRowAtIndexPath:(NSIndexPath*)a_indexPath viewController:(IAUITableViewController*)a_tableViewController;
-(void)m_setAppearanceForCell:(UITableViewCell*)a_cell atIndexPath:(NSIndexPath*)a_indexPath viewController:(IAUITableViewController*)a_tableViewController;
-(void)m_setAppearanceOnAwakeFromNibForView:(UIView*)a_view;
-(void)m_setAppearanceOnInitForView:(UIView*)a_view;
- (void)m_setAppearanceOnSetHighlightedForCell:(UITableViewCell *)a_cell animated:(BOOL)a_shouldAnimate;
- (void)m_setAppearanceOnSetSelectedForCell:(UITableViewCell *)a_cell animated:(BOOL)a_shouldAnimate;
-(void)m_setAppearanceOnPrepareForReuseForCell:(UITableViewCell *)a_cell;

@optional
-(void)m_willReloadUi;
-(void)m_setAppearanceForAdBannerView:(GADBannerView *)a_adBannerView;
-(void)m_setAppearanceForCollectionViewCell:(UICollectionViewCell*)a_cell atIndexPath:(NSIndexPath*)a_indexPath viewController:(IAUICollectionViewCell*)a_collectionViewController;

@end

@protocol IAUIViewControllerAppearance <NSObject>
@optional
-(void)m_setAppearanceOnViewDidLoadForViewController:(UIViewController*)a_viewController;
-(void)m_setAppearanceOnViewWillAppearForViewController:(UIViewController*)a_viewController;
-(void)m_setAppearanceOnWillRotateForViewController:(UIViewController*)a_viewController toInterfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation;
-(void)m_setAppearanceOnWillAnimateRotationForViewController:(UIViewController*)a_viewController interfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation;
@end

@protocol IAUITableViewControllerAppearance <IAUIViewControllerAppearance>
@optional
-(void)m_setAppearanceOnInitReusableCellForViewController:(UITableViewController*)a_tableViewController cell:(UITableViewCell*)a_cell;
-(void)m_setAppearanceOnWillDisplayCell:(UITableViewCell*)a_cell forRowAtIndexPath:(NSIndexPath*)a_indexPath viewController:(IAUITableViewController*)a_tableViewController;
-(void)m_setAppearanceForCell:(UITableViewCell*)a_cell atIndexPath:(NSIndexPath*)a_indexPath viewController:(IAUITableViewController*)a_tableViewController;
@end

@protocol IAUIViewAppearance <NSObject>
@optional
-(void)m_setAppearanceOnAwakeFromNibForView:(UIView*)a_view;
-(void)m_setAppearanceOnInitForView:(UIView*)a_view;
@end

@protocol IAUITableViewCellAppearance <IAUIViewAppearance>
@optional
-(void)m_setAppearanceOnSetHighlightedForCell:(UITableViewCell *)a_cell;
@end
