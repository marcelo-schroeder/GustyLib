//
//  IAUIAbstractAppearanceTheme.m
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

#import "IACommon.h"

@interface IAUIAbstractAppearanceTheme()

@property (nonatomic, strong) UINavigationBar *p_navigationBarAppearance;
@property (nonatomic, strong) UINavigationBar *p_popoverNavigationBarAppearance;
@property (nonatomic, strong) UIBarButtonItem *p_barButtonItemAppearance;
@property (nonatomic, strong) UIBarButtonItem *p_navigationBarButtonItemAppearance;
@property (nonatomic, strong) UIBarButtonItem *p_toolbarButtonItemAppearance;
@property (nonatomic, strong) UIToolbar *p_toolbarAppearance;
@property (nonatomic, strong) UIToolbar *p_popoverToolbarAppearance;
@property (nonatomic, strong) UITabBar *p_tabBarAppearance;
@property (nonatomic, strong) UITabBarItem *p_tabBarItemAppearance;
@property (nonatomic, strong) UISearchBar *p_searchBarAppearance;
@property (nonatomic, strong) UISegmentedControl *p_barSegmentedControlAppearance;
@property (nonatomic, strong) UISegmentedControl *p_segmentedControlAppearance;
@property (nonatomic, strong) UISwitch *p_switchAppearance;
@property (nonatomic, strong) UISlider *p_sliderAppearance;
@property (nonatomic, strong) IAUIColorScheme *p_colorScheme;
@property (nonatomic, strong) UIActivityIndicatorView *p_activityIndicatorView;
@property (nonatomic, strong) UIPageControl *p_pageControlAppearance;

@end

@implementation IAUIAbstractAppearanceTheme{
    
}

@synthesize p_shadow;

#pragma mark - Private

-(void)m_setNavigationItemTitleViewForViewController:(UIViewController*)a_viewController interfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation{
    
    if (a_viewController.p_titleViewDefault && a_viewController.p_titleViewLandscapePhone) {
        
        // Determine which title view to use
        BOOL l_isIPhoneLandscape = ![IAUIUtils m_isIPad] && UIInterfaceOrientationIsLandscape(a_interfaceOrientation);
//        NSLog(@"l_isIPhoneLandscape: %u", l_isIPhoneLandscape);
        UIView *l_titleView = l_isIPhoneLandscape ? a_viewController.p_titleViewLandscapePhone : a_viewController.p_titleViewDefault;
        
        // Resize the title view according to the greatest label width
        CGFloat l_greatestMaxWidth = 0;
        for (UIView *l_view in l_titleView.subviews) {
            if ([l_view isKindOfClass:[UILabel class]]) {
                UILabel *l_label = (UILabel*)l_view;
                CGFloat l_maxWidth = [l_label.text sizeWithFont:l_label.font].width;
                if (l_maxWidth>l_greatestMaxWidth) {
                    l_greatestMaxWidth = l_maxWidth;
                }
//                NSLog(@"l_maxWidth: %f", l_maxWidth);
            }
        }
//        NSLog(@"l_greatestMaxWidth: %f", l_greatestMaxWidth);
        l_titleView.frame = CGRectMake(0, 0, l_greatestMaxWidth, l_titleView.frame.size.height);
        
        // Set it in the navigation item
        [self titleViewNavigationItemForViewViewController:a_viewController].titleView = l_titleView;
        
    }
}

-(UIColor*)m_colorForInfoPlistKey:(NSString*)a_infoPlistKey{
    return [IAUIUtils m_colorForInfoPlistKey:a_infoPlistKey];
}

- (IAUITableViewCellSelectedBackgroundStyle)
m_tableViewCellSelectedBackgroundStyleForIndexPath:(NSIndexPath *)a_indexPath
                               tableViewController:(IAUITableViewController *)a_tableViewController {
    IAUITableViewCellSelectedBackgroundStyle l_cellPosition = IAUITableViewCellSelectedBackgroundStyleMiddle;
    if (![IAUtils m_isIOS7OrGreater] && a_tableViewController.tableView.style == UITableViewStyleGrouped) {
        NSInteger l_rowCount = [a_tableViewController tableView:a_tableViewController.tableView
                                          numberOfRowsInSection:a_indexPath.section];
        l_cellPosition = IAUITableViewCellSelectedBackgroundStyleBottom;
        if (a_indexPath.row == 0) {
            l_cellPosition = IAUITableViewCellSelectedBackgroundStyleTop;
        } else {
            if (a_indexPath.row < l_rowCount - 1) {
                l_cellPosition = IAUITableViewCellSelectedBackgroundStyleMiddle;
            }
        }
        if (l_rowCount == 1) {
            l_cellPosition = IAUITableViewCellSelectedBackgroundStyleSingle;
        }
    }
    return l_cellPosition;
}

#pragma mark - IAUIAppearanceTheme

-(void)setAppearance {
    
    // Navigation bar
    {
        NSString *l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeNavigationBarBackgroundImageName"];
        if (l_imageName) {
            [self.p_navigationBarAppearance setBackgroundImage:[UIImage imageNamed:l_imageName] forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    // Toolbar
    {
        NSString *l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeToolbarBackgroundImageName"];
        if (l_imageName) {
            [self.p_toolbarAppearance setBackgroundImage:[UIImage imageNamed:l_imageName] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }
    
    // Tab bar
    {
        NSString *l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeTabBarBackgroundImageName"];
        if (l_imageName) {
            self.p_tabBarAppearance.backgroundImage = [UIImage imageNamed:l_imageName];
        }
    }
    
    // Bar button item
    [self setAppearanceForToolbarButtonItem:self.p_toolbarButtonItemAppearance];
    
    // Bar button item
    [self setAppearanceForBarButtonItem:self.p_barButtonItemAppearance viewController:nil important:NO ];
    
    // Back Bar button item
    {
        NSString *l_imageName = nil;
        
        l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeBackBarButtonItemBackgroundImageNormalDefaultImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
            [self.p_barButtonItemAppearance setBackButtonBackgroundImage:l_image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeBackBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
            [self.p_barButtonItemAppearance setBackButtonBackgroundImage:l_image forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        }
    }
    
    // Bar segmented control
    {
        NSString *l_imageName = nil;
        
        l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeBarButtonItemBackgroundImageNormalDefaultImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.p_barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.p_barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        }
        
        l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeBarButtonItemBackgroundImageSelectedDefaultImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.p_barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeBarButtonItemBackgroundImageSelectedLandscapeIphoneImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.p_barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateSelected barMetrics:UIBarMetricsLandscapePhone];
        }
        
        l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeBarSegmentedControlDividerImageName"];
        if (l_imageName) {
            [self.p_barSegmentedControlAppearance setDividerImage:[UIImage imageNamed:l_imageName] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [self.p_barSegmentedControlAppearance setDividerImage:[UIImage imageNamed:l_imageName] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        }
        
    }
    
    // Form segmented control
    {
        NSString *l_imageName = nil;
        
        l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeSegmentedControlBackgroundImageNormalImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            [self.p_segmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeSegmentedControlBackgroundImageSelectedImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            [self.p_segmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeSegmentedControlDividerImageName"];
        if (l_imageName) {
            [self.p_segmentedControlAppearance setDividerImage:[UIImage imageNamed:l_imageName] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        }
        
    }
    
    // Switch
    self.p_switchAppearance.onTintColor = [self m_colorForInfoPlistKey:@"IAUIThemeSwitchOnTintColor"];
    
    // Slider
    self.p_sliderAppearance.minimumTrackTintColor = [self m_colorForInfoPlistKey:@"IAUIThemeSliderMinimumTrackTintColor"];
    
    

}

-(void)setAppearanceOnViewDidLoadForViewController:(UIViewController*)a_viewController{
    a_viewController.p_titleViewDefault = [self navigationItemTitleViewForViewController:a_viewController
                                                                              barMetrics:UIBarMetricsDefault];
    a_viewController.p_titleViewLandscapePhone = [self navigationItemTitleViewForViewController:a_viewController
                                                                                     barMetrics:UIBarMetricsLandscapePhone];
    [self setOrientationDependentBackgroundImagesForViewController:a_viewController];
    if ([a_viewController isKindOfClass:[UITableViewController class]]) {
        UITableViewController *l_tableViewController = (UITableViewController*)a_viewController;
        if (l_tableViewController.tableView.style==UITableViewStyleGrouped) {
            l_tableViewController.tableView.separatorColor = [self m_colorForInfoPlistKey:@"IAUIThemeGroupedTableSeparatorColor"];
        }
    }else if([a_viewController isKindOfClass:[IAUIMasterDetailViewController class]]) {

        IAUIMasterDetailViewController *l_viewController = (IAUIMasterDetailViewController *) a_viewController;
        l_viewController.p_separatorView.backgroundColor = [self.class splitViewControllerDividerColour];

    }
}

-(void)setAppearanceOnViewWillAppearForViewController:(UIViewController*)a_viewController{
    
    // Navigation item title view titles and subtitle, if applicable
    a_viewController.p_titleViewDefault.p_titleLabel.text = a_viewController.title;
    a_viewController.p_titleViewDefault.p_subTitleLabel.text = a_viewController.p_subTitle;
    a_viewController.p_titleViewLandscapePhone.p_titleLabel.text = a_viewController.title;
    a_viewController.p_titleViewLandscapePhone.p_subTitleLabel.text = a_viewController.p_subTitle;

    [self m_setNavigationItemTitleViewForViewController:a_viewController interfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    if ([a_viewController isKindOfClass:[IAUIAbstractFieldEditorViewController class]]) {
        NSString *l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeFieldEditorToolbarBackgroundImageName"];
        if (l_imageName) {
            [a_viewController.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:l_imageName] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }

}

-(void)setAppearanceOnWillRotateForViewController:(UIViewController *)a_viewController toInterfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation{
    [self m_setNavigationItemTitleViewForViewController:a_viewController interfaceOrientation:a_toInterfaceOrientation];
}

-(void)setAppearanceOnWillAnimateRotationForViewController:(UIViewController *)a_viewController interfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation{
    [self setOrientationDependentBackgroundImagesForViewController:a_viewController];
}

-(void)setAppearanceOnInitForView:(UIView*)a_view{
}

- (void)setAppearanceOnSetHighlightedForCell:(UITableViewCell *)a_cell animated:(BOOL)a_shouldAnimate {
}

- (void)setAppearanceOnSetSelectedForCell:(UITableViewCell *)a_cell animated:(BOOL)a_shouldAnimate {
}

-(void)setAppearanceOnAwakeFromNibForView:(UIView*)a_view{
    if ([a_view isKindOfClass:[UITableViewCell class]]) {
        [self setLabelTextStyleForChildrenOfView:((UITableViewCell *) a_view).contentView];
    }
}

-(void)setAppearanceOnInitReusableCellForViewController:(UITableViewController *)a_tableViewController cell:(UITableViewCell*)a_cell{

    // Custom disclosure indicator
    if (![a_tableViewController isKindOfClass:[IAUIMenuViewController class]] && ![a_tableViewController isKindOfClass:[IAUIFormViewController class]]){
        [self setCustomDisclosureIndicatorForCell:a_cell tableViewController:a_tableViewController];
    }
    
    // Cell background color
    if (![a_tableViewController isKindOfClass:[IAUIMenuViewController class]] && a_tableViewController.tableView.style==UITableViewStyleGrouped) {
        a_cell.backgroundColor = [self m_colorForInfoPlistKey:@"IAUIThemeGroupedTableCellBackgroundColor"];
    }
    
    // Label text color
    [self setLabelTextStyleForChildrenOfView:a_cell.contentView];
    if ([a_tableViewController isKindOfClass:[IAUIFormViewController class]]) {
        if (a_cell.detailTextLabel) {   // Is it a cell style that has text and detail?
            // textLabel here in this context refers to the form field label
            //  So, it is setting the form field label colour
            a_cell.textLabel.textColor = [self m_colorForInfoPlistKey:@"IAUIThemeFormFieldLabelColor"];
        }
    }
    
}

-(void)setAppearanceOnWillDisplayCell:(UITableViewCell *)a_cell forRowAtIndexPath:(NSIndexPath *)a_indexPath
                       viewController:(IAUITableViewController*)a_tableViewController{
    
    // Table cell text color
    if (![a_tableViewController isKindOfClass:[IAUIFormViewController class]]) {
        UIColor *l_color = a_tableViewController.p_tableCellTextColor;
        if (l_color) {
            a_cell.textLabel.textColor = l_color;
            a_cell.detailTextLabel.textColor = l_color;
        }
    }

    // Set table cell background image
    if ([a_tableViewController isKindOfClass:[IAUIListViewController class]]) {
        NSString *l_imageName = [[IAUtils infoPList] objectForKey:@"IAUIThemeListTableCellBackgroundImageName"];
        if (l_imageName) {
            a_cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:l_imageName]];
        }
    }
    
    // Custom disclosure indicator
    if ([a_tableViewController isKindOfClass:[IAUIMenuViewController class]]){
        if ( ! ([a_tableViewController isKindOfClass:[IAUIMenuViewController class]] && [a_tableViewController tableView:a_tableViewController.tableView heightForRowAtIndexPath:a_indexPath]==0) ) {   // This check is to avoid showing the custom disclose indicator for non-supported menu items
            [self setCustomDisclosureIndicatorForCell:a_cell tableViewController:a_tableViewController];
        }
    }
    
    // Cell background color
    if ([a_tableViewController isKindOfClass:[IAUIMenuViewController class]] && a_tableViewController.tableView.style==UITableViewStyleGrouped) {
        a_cell.backgroundColor = [self m_colorForInfoPlistKey:@"IAUIThemeGroupedTableCellBackgroundColor"];
    }
    
    // Set selected table cell background color
    UIColor *l_selectedTableCellBackgroundColor = [self selectedTableCellBackgroundColor];
    if (l_selectedTableCellBackgroundColor) {
        // Set the appropriate selected background view according to the cell position
        IAUITableCellSelectedBackgroundView *l_selectedBackgroundView = [[IAUITableCellSelectedBackgroundView alloc] initWithFrame:a_cell.frame];
        l_selectedBackgroundView.p_fillColor = l_selectedTableCellBackgroundColor;
        l_selectedBackgroundView.p_borderColor = [UIColor clearColor];
        l_selectedBackgroundView.p_style = ([self m_tableViewCellSelectedBackgroundStyleForIndexPath:a_indexPath
                                                                                 tableViewController:a_tableViewController]);
        a_cell.selectedBackgroundView = l_selectedBackgroundView;
    }

}

-(void)setAppearanceForView:(UIView*)a_view{
}

-(void)setAppearanceForBarButtonItem:(UIBarButtonItem*)a_barButtonItem{
    [self setAppearanceForBarButtonItem:a_barButtonItem viewController:nil important:NO ];
}

- (void)setAppearanceForBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                       viewController:(UIViewController *)a_viewController important:(BOOL)a_important {

    // Set background images if required
    NSString *l_imageNameDefault = nil;
    NSString *l_imageNameLandscapeIphone = nil;
    if (a_important) {
        l_imageNameDefault = [[IAUtils infoPList] objectForKey:@"IAUIThemeImportantBarButtonItemBackgroundImageNormalDefaultImageName"];
        l_imageNameLandscapeIphone = [[IAUtils infoPList] objectForKey:@"IAUIThemeImportantBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
    }else{
        l_imageNameDefault = [[IAUtils infoPList] objectForKey:@"IAUIThemeBarButtonItemBackgroundImageNormalDefaultImageName"];
        l_imageNameLandscapeIphone = [[IAUtils infoPList] objectForKey:@"IAUIThemeBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
    }
    if (l_imageNameDefault) {
        UIImage *l_image = [[UIImage imageNamed:l_imageNameDefault] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [a_barButtonItem setBackgroundImage:l_image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
    if (l_imageNameLandscapeIphone) {
        UIImage *l_image = [[UIImage imageNamed:l_imageNameLandscapeIphone] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [a_barButtonItem setBackgroundImage:l_image forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
    }

}

-(void)setAppearanceForToolbarButtonItem:(UIBarButtonItem*)a_barButtonItem{
    NSNumber *l_backgroundVerticalPositionAdjustmentDefault = [[IAUtils infoPList] objectForKey:@"IAUIThemeBarButtonItemBackgroundVerticalPositionAdjustmentDefault"];
    if (l_backgroundVerticalPositionAdjustmentDefault) {
        [a_barButtonItem setBackgroundVerticalPositionAdjustment:l_backgroundVerticalPositionAdjustmentDefault.floatValue forBarMetrics:UIBarMetricsDefault];
    }
    NSNumber *l_backgroundVerticalPositionAdjustmentLandscapeIphone = [[IAUtils infoPList] objectForKey:@"IAUIThemeBarButtonItemBackgroundVerticalPositionAdjustmentLandscapeIphone"];
    if (l_backgroundVerticalPositionAdjustmentLandscapeIphone) {
        [a_barButtonItem setBackgroundVerticalPositionAdjustment:l_backgroundVerticalPositionAdjustmentLandscapeIphone.floatValue forBarMetrics:UIBarMetricsLandscapePhone];
    }
}

-(void)setAppearanceForPopoverController:(UIPopoverController*)a_popoverController{
    if ([a_popoverController.contentViewController isKindOfClass:[UINavigationController class]]) {
        Class l_backgroundViewClass = NSClassFromString([IAUtils infoPList][@"IAUIPopoverControllerBackgroundViewClass"]);
        if (l_backgroundViewClass) {
            a_popoverController.popoverBackgroundViewClass = l_backgroundViewClass;
        }
    }
}

- (void)setAppearanceOnPrepareForReuseForCell:(UITableViewCell *)a_cell {
    // to be implemented by subclasses, if required
}

-(NSString *)themeName {
    return [[self.class description] substringToIndex:[[self.class description] rangeOfString:@"AppearanceTheme"].location];
}

// To be overriden by subclasses
-(NSString*)fallbackThemeName {
    return nil;
}

-(NSBundle*)bundle {
    NSString *l_themeName = [self themeName];
    return [IAUIAppearanceThemeManager bundleForThemeNamed:l_themeName];
}

-(NSString*)storyboardName {
    return [[IAUIApplicationDelegate sharedInstance] storyboardName];
}

-(UIStoryboard*)storyboard {
    return [UIStoryboard storyboardWithName:[self storyboardName] bundle:[self bundle]];
}

-(UIColor*)barButtonItemTintColor {
    return nil;
}

-(UIColor*)importantBarButtonItemTintColor {
    return nil;
}

-(UIColor*)tableCellTextColor {
    return [self m_colorForInfoPlistKey:@"IAUIThemeTableCellTextColor"];
}

// To be implemented by subclasses
-(UIFont*)tableCellTextFont {
    return nil;
}

-(UIButton*)newDetailDisclosureButton {
    UIButton *l_button = nil;
    NSString *l_imageNameNormal = [[IAUtils infoPList] objectForKey:@"IAUIThemeDetailDisclosureButtonImageNormal"];
    if (l_imageNameNormal) {
        UIImage *l_imageNormal = [UIImage imageNamed:l_imageNameNormal];
        UIImage *l_imageHighlighted = [UIImage imageNamed:[[IAUtils infoPList] objectForKey:@"IAUIThemeDetailDisclosureButtonImageHighlighted"]];
        l_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, l_imageNormal.size.width, l_imageNormal.size.height)];
        [l_button setImage:l_imageNormal forState:UIControlStateNormal];
        [l_button setImage:l_imageHighlighted forState:UIControlStateHighlighted];
    }
    l_button.p_helpTargetId = [IAUIUtils m_helpTargetIdForName:@"detailDisclosureButton"];
    return l_button;
}

-(UIView*)newDisclosureIndicatorView {
    UIImageView *l_view = nil;
    NSString *l_imageNameNormal = [[IAUtils infoPList] objectForKey:@"IAUIThemeDisclosureIndicatorImageNormal"];
    if (l_imageNameNormal) {
        NSString *l_imageNameSelected = [[IAUtils infoPList] objectForKey:@"IAUIThemeDisclosureIndicatorImageSelected"];
        l_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:l_imageNameNormal] highlightedImage:[UIImage imageNamed:l_imageNameSelected]];
    }
    return l_view;
}

-(UIImage*)backgroundImageForViewController:(UIViewController*)a_viewController{
    
    // Determine the info plist's key
    NSString *l_infoPlistKey = nil;
    if ([a_viewController isKindOfClass:[IAUIFormViewController class]]) {
        l_infoPlistKey = [IAUIUtils isDeviceInLandscapeOrientation] ? @"IAUIThemeFormBackgroundImageNameLandscape" : @"IAUIThemeFormBackgroundImageNamePortrait";
    }else{
        l_infoPlistKey = [IAUIUtils isDeviceInLandscapeOrientation] ? @"IAUIThemeTableBackgroundImageNameLandscape" : @"IAUIThemeTableBackgroundImageNamePortrait";
    }
    
    // Determine the image name
    NSString *l_imageName = [[IAUtils infoPList] objectForKey:l_infoPlistKey];
    
    return [UIImage imageNamed:l_imageName];

}

-(void)setLabelTextStyleForChildrenOfView:(UIView*)a_view{
    for (UIView *l_subView in a_view.subviews) {
        //            NSLog(@"  l_subView: %@", [l_subView description]);
        if ([l_subView isKindOfClass:[UILabel class]]) {
            UILabel *l_label = (UILabel*)l_subView;
            l_label.textColor = [self tableCellTextColor];
            UIFont *l_font = [self tableCellTextFont];
            if (l_font) {
                l_label.font = l_font;
            }
        }else if ([l_subView isKindOfClass:[UITextField class]]){
            UITextField *l_textField = (UITextField*)l_subView;
            l_textField.textColor = [self tableCellTextColor];
            UIFont *l_font = [self tableCellTextFont];
            if (l_font) {
                l_textField.font = l_font;
            }
        }
    }
}

// To be overriden by subclasses
-(NSDictionary*)gadAdditionalParameters {
    return nil;
}

-(UIColor*)selectedTableCellBackgroundColor {
    return [self m_colorForInfoPlistKey:@"IAUIThemeSelectedTableCellBackgroundColor"];
}

-(UIBarButtonItem*)backBarButtonItem {
    return [self backBarButtonItemForViewController:nil];
}

-(UIBarButtonItem*)backBarButtonItemForViewController:(UIViewController *)a_viewController{
    return nil;
}

-(UIBarButtonItem*)splitViewControllerBarButtonItem {
    return nil;
}

- (UIBarButtonItem *)slidingMenuBarButtonItem {
    return [self slidingMenuBarButtonItemForViewController:nil];
}

-(UIBarButtonItem*)slidingMenuBarButtonItemForViewController:(UIViewController *)a_viewController{
    return nil;
}

-(BOOL)shouldAutomateBarButtonItemSpacingForViewController:(UIViewController*)a_viewController{
    return NO;
}

-(UIBarButtonItem*)spacingBarButtonItemForType:(IAUISpacingBarButtonItemType)a_type viewController:(UIViewController*)a_viewController{
    return nil;
}

- (UIBarButtonItem *)doneBarButtonItemWithTarget:(id)a_target action:(SEL)a_action
                                  viewController:(UIViewController *)a_viewController {
    return [IAUIUtils barButtonItemForType:IA_UIBAR_BUTTON_ITEM_DONE target:a_target action:a_action];
}

- (UIBarButtonItem *)cancelBarButtonItemWithTarget:(id)a_target
                                            action:(SEL)a_action {
    return [self cancelBarButtonItemWithTarget:a_target action:a_action
                                viewController:nil];
}

- (UIBarButtonItem *)cancelBarButtonItemWithTarget:(id)a_target
                                            action:(SEL)a_action
                                    viewController:(UIViewController *)a_viewController {
    return nil;
}

- (UIViewController *)newInternalWebBrowserViewControllerWithUrl:(NSURL *)a_url{
    return [self newInternalWebBrowserViewControllerWithUrl:a_url completionBlock:nil];
}

- (UIViewController *)newInternalWebBrowserViewControllerWithUrl:(NSURL *)a_url completionBlock:(void(^)(void))a_completionBlock{
    IAUIInternalWebBrowserViewController *l_viewController = [[IAUIInternalWebBrowserViewController alloc] initWithURL:a_url completionBlock:a_completionBlock];
    return l_viewController;
}

- (Class)navigationControllerClass {
    return [IAUINavigationController class];
}

#pragma mark - Public

-(void)setOrientationDependentBackgroundImagesForViewController:(UIViewController*)a_viewController{
    
    if ([a_viewController isKindOfClass:[UITableViewController class]]) {
        
        // Determine the image name
        UIImage *l_image = [self backgroundImageForViewController:a_viewController];

        // Set the background image in the table view controller
        if (l_image) {
            UITableViewController *l_tableViewController = (UITableViewController*)a_viewController;
            UIView *l_backgroundView = [[UIImageView alloc] initWithImage:l_image];
            l_tableViewController.tableView.backgroundView = l_backgroundView;
        }

    }

}

-(IAUINavigationItemTitleView*)navigationItemTitleViewForViewController:(UIViewController *)a_viewController barMetrics:(UIBarMetrics)a_barMetrics{
    return nil;
}

-(UINavigationItem*)titleViewNavigationItemForViewViewController:(UIViewController*)a_viewController{
    return a_viewController.navigationItem;
}

-(UIImage*)imageNamed:(NSString*)a_imageName{
    UIImage *l_image = [UIImage imageNamed:[self nameSpacedResourceName:a_imageName]];
    return l_image;
}

-(NSString*)nameSpacedResourceName:(NSString*)a_resourceName{
    NSString *l_themeName = [self themeName];
    if ([l_themeName isEqualToString:@""]) {
        return a_resourceName;
    }else{
        return [NSString stringWithFormat:@"%@.bundle/%@", l_themeName, a_resourceName];
    }
}

- (void)setCustomDisclosureIndicatorForCell:(UITableViewCell *)a_cell
                        tableViewController:(UITableViewController *)a_tableViewController {
    if (a_cell.accessoryType==UITableViewCellAccessoryDisclosureIndicator && a_cell.accessoryView==nil) {
        a_cell.accessoryView = [self newDisclosureIndicatorView];
    }
    if (a_cell.editingAccessoryType==UITableViewCellAccessoryDisclosureIndicator && a_cell.editingAccessoryView==nil) {
        a_cell.editingAccessoryView = [self newDisclosureIndicatorView];
    }
}

-(IAUIColorScheme*)colorScheme {
    if (![self.p_colorScheme isEqual:[[IAUIApplicationDelegate sharedInstance] colorScheme]]) {
        self.p_colorScheme = [[IAUIApplicationDelegate sharedInstance] colorScheme];
    }
    return self.p_colorScheme;
}

-(UIColor*)colorWithIndex:(NSUInteger)a_colorIndex{

    // The code block below is used only during DEVELOPMENT
    /*
    {
        switch (a_colorIndex) {
            case 0:
                return [UIColor m_colorWithRed:0 green:33 blue:94];
            case 1:
                return [UIColor m_colorWithRed:0 green:75 blue:42];
            case 2:
                return [UIColor m_colorWithRed:0 green:0 blue:100];
            case 3:
                return [UIColor m_colorWithRed:0 green:92 blue:55];
            case 4:
                return [UIColor m_colorWithRed:0 green:68 blue:50];
            case 5:
                return [UIColor m_colorWithRed:0 green:10 blue:92];
            case 6:
                return [UIColor m_colorWithRed:0 green:10 blue:87];
            case 7:
                return [UIColor m_colorWithRed:0 green:85 blue:86];
            case 8:
                return [UIColor m_colorWithRed:0 green:0 blue:0];
            case 9:
                return [UIColor m_colorWithRed:0 green:68 blue:87];
            case 10:
                return [UIColor m_colorWithRed:0 green:23 blue:94];
            case 11:
                return [UIColor m_colorWithRed:0 green:29 blue:16];
            case 12:
                return [UIColor m_colorWithRed:0 green:0 blue:88];
            case 13:
                return [UIColor m_colorWithRed:0 green:0 blue:42];
            default:
                NSAssert(NO, @"Unexpected colour index: %u", a_colorIndex);
                break;
        }
    }
    */

    return [[self colorScheme] colorAtIndex:a_colorIndex];
}

+ (UIColor *)splitViewControllerDividerColour {
    return [UIColor m_colorWithRed:191 green:191 blue:191];
}


#pragma mark - Overrides

- (id)init{
    self = [super init];
    if (self) {
        self.p_navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_popoverNavigationBarAppearance = [UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], [self navigationControllerClass], nil];
        self.p_barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_navigationBarButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], [self navigationControllerClass], nil];
        self.p_toolbarButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], [self navigationControllerClass], nil];
        self.p_toolbarAppearance = [UIToolbar appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_popoverToolbarAppearance = [UIToolbar appearanceWhenContainedIn:[UIPopoverController class], [self navigationControllerClass], nil];
        self.p_tabBarAppearance = [UITabBar appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_tabBarItemAppearance = [UITabBarItem appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_searchBarAppearance = [UISearchBar appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_barSegmentedControlAppearance = [UISegmentedControl appearanceWhenContainedIn:[UIToolbar class], [self navigationControllerClass], nil];
        self.p_segmentedControlAppearance = [UISegmentedControl appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_switchAppearance = [UISwitch appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_sliderAppearance = [UISlider appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_activityIndicatorView = [UIActivityIndicatorView appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_pageControlAppearance = [UIPageControl appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.p_shadow = [NSShadow new];
    }
    return self;
}

@end
