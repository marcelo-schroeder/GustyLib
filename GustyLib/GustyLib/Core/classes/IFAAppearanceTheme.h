//
//  IFAAppearanceTheme.h
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
    IFABarButtonItemSpacingPositionLeft,
    IFABarButtonItemSpacingPositionMiddle,
    IFABarButtonItemSpacingPositionRight,
} IFABarButtonItemPositionType;

typedef enum {
    IFABarButtonItemSpacingBarTypeNavigationBar,
    IFABarButtonItemSpacingBarTypeToolbar,
} IFABarButtonItemSpacingBarType;

@class IFATableViewController;
@class IFACollectionViewCell;

@protocol IFAAppearanceTheme <NSObject>

@property (nonatomic, strong, readonly) UINavigationBar *navigationBarAppearance;
@property (nonatomic, strong, readonly) UINavigationBar *popoverNavigationBarAppearance;
@property (nonatomic, strong, readonly) UIBarButtonItem *barButtonItemAppearance;
@property (nonatomic, strong, readonly) UIBarButtonItem *navigationBarButtonItemAppearance;
@property (nonatomic, strong, readonly) UIBarButtonItem *toolbarButtonItemAppearance;
@property (nonatomic, strong, readonly) UIToolbar *toolbarAppearance;
@property (nonatomic, strong, readonly) UIToolbar *popoverToolbarAppearance;
@property (nonatomic, strong, readonly) UITabBar *tabBarAppearance;
@property (nonatomic, strong, readonly) UITabBarItem *tabBarItemAppearance;
@property (nonatomic, strong, readonly) UISearchBar *searchBarAppearance;
@property (nonatomic, strong, readonly) UISegmentedControl *barSegmentedControlAppearance;
@property (nonatomic, strong, readonly) UISegmentedControl *segmentedControlAppearance;
@property (nonatomic, strong, readonly) UISwitch *switchAppearance;
@property (nonatomic, strong, readonly) UISlider *sliderAppearance;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong, readonly) UIPageControl *pageControlAppearance;
@property (nonatomic, strong) NSShadow *shadow;

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

/**
* Enables automation of bar button item spacing.
* The amount of space is to be automatically added is determined by the width value returned by the method.
* @param a_position Position of the spacing to be provided: left, middle (i.e. between bar button items) or right.
* @param a_barType Type of bar the automated spacing applies to.
* @param a_viewController View controller the bar belongs to.
* @returns Width (float wrapped by an NSNumber instance) of the space to be provided. Return nil if bar button item spacing automation is not required.
*/
- (NSNumber *)spaceBarButtonItemWidthForPosition:(IFABarButtonItemPositionType)a_position
                                         barType:(IFABarButtonItemSpacingBarType)a_barType
                                  viewController:(UIViewController *)a_viewController;

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
                       viewController:(IFATableViewController *)a_tableViewController;
-(void)setAppearanceForCell:(UITableViewCell *)a_cell atIndexPath:(NSIndexPath *)a_indexPath viewController:(IFATableViewController *)a_tableViewController;
-(void)setAppearanceOnAwakeFromNibForView:(UIView*)a_view;
-(void)setAppearanceOnInitForView:(UIView*)a_view;
- (void)setAppearanceOnSetHighlightedForCell:(UITableViewCell *)a_cell animated:(BOOL)a_shouldAnimate;
- (void)setAppearanceOnSetSelectedForCell:(UITableViewCell *)a_cell animated:(BOOL)a_shouldAnimate;
-(void)setAppearanceOnPrepareForReuseForCell:(UITableViewCell *)a_cell;

@optional
-(void)willReloadUi;
-(void)setAppearanceForCollectionViewCell:(UICollectionViewCell *)a_cell atIndexPath:(NSIndexPath *)a_indexPath
                           viewController:(IFACollectionViewCell *)a_collectionViewController;
-(void)setAppearanceForTableViewCell:(UITableViewCell *)a_cell onWillTransitionToState:(UITableViewCellStateMask)a_state;
-(void)setAppearanceForTableViewCell:(UITableViewCell *)a_cell onDidTransitionToState:(UITableViewCellStateMask)a_state;

@end

@protocol IFAViewControllerAppearance <NSObject>
@optional
-(void)setAppearanceOnViewDidLoadForViewController:(UIViewController*)a_viewController;
-(void)setAppearanceOnViewWillAppearForViewController:(UIViewController*)a_viewController;
-(void)setAppearanceOnWillRotateForViewController:(UIViewController *)a_viewController toInterfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation;
-(void)setAppearanceOnWillAnimateRotationForViewController:(UIViewController *)a_viewController interfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation;
@end

@protocol IFATableViewControllerAppearance <IFAViewControllerAppearance>
@optional
-(void)setAppearanceOnInitReusableCellForViewController:(UITableViewController *)a_tableViewController cell:(UITableViewCell*)a_cell;
-(void)setAppearanceOnWillDisplayCell:(UITableViewCell *)a_cell forRowAtIndexPath:(NSIndexPath *)a_indexPath
                       viewController:(IFATableViewController *)a_tableViewController;
-(void)setAppearanceForCell:(UITableViewCell *)a_cell atIndexPath:(NSIndexPath *)a_indexPath viewController:(IFATableViewController *)a_tableViewController;
@end

@protocol IFAViewAppearance <NSObject>
@optional
-(void)setAppearanceOnAwakeFromNibForView:(UIView*)a_view;
-(void)setAppearanceOnInitForView:(UIView*)a_view;
@end

@protocol IFATableViewCellAppearance <IFAViewAppearance>
@optional
-(void)setAppearanceOnSetHighlightedForCell:(UITableViewCell *)a_cell;
@end
