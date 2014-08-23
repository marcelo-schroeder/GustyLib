//
//  IFAAbstractAppearanceTheme.m
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

#import "GustyLib.h"
#import "IFAFormTableViewCellContentView.h"

#ifdef IFA_AVAILABLE_Help
#import "UIView+IFAHelp.h"
#import "UIViewController+IFAHelp.h"

#endif

@interface IFAAbstractAppearanceTheme ()

@property (nonatomic, strong) IFAColorScheme *IFA_colorScheme;

@end

@implementation IFAAbstractAppearanceTheme {
    
}

#pragma mark - Private

-(void)IFA_setNavigationItemTitleViewForViewController:(UIViewController *)a_viewController interfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation{
    
    if (a_viewController.ifa_titleViewDefault && a_viewController.ifa_titleViewLandscapePhone) {
        
        // Determine which title view to use
        BOOL l_isIPhoneLandscape = ![IFAUIUtils isIPad] && UIInterfaceOrientationIsLandscape(a_interfaceOrientation);
//        NSLog(@"l_isIPhoneLandscape: %u", l_isIPhoneLandscape);
        UIView *l_titleView = l_isIPhoneLandscape ? a_viewController.ifa_titleViewLandscapePhone : a_viewController.ifa_titleViewDefault;
        
        // Resize the title view according to the greatest label width
        CGFloat l_greatestMaxWidth = 0;
        for (UIView *l_view in l_titleView.subviews) {
            if ([l_view isKindOfClass:[UILabel class]]) {
                UILabel *l_label = (UILabel*)l_view;
                CGFloat l_maxWidth = [l_label.text sizeWithAttributes:@{NSFontAttributeName:l_label.font}].width;
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

-(UIColor*)IFA_colorForInfoPlistKey:(NSString*)a_infoPlistKey{
    return [IFAUIUtils colorForInfoPlistKey:a_infoPlistKey];
}

- (IFATableViewCellSelectedBackgroundStyle)
IFA_tableViewCellSelectedBackgroundStyleForIndexPath:(NSIndexPath *)a_indexPath
                                 tableViewController:(IFATableViewController *)a_tableViewController {
    IFATableViewCellSelectedBackgroundStyle l_cellPosition = IFATableViewCellSelectedBackgroundStyleMiddle;
    if (![IFAUtils isIOS7OrGreater] && a_tableViewController.tableView.style == UITableViewStyleGrouped) {
        NSInteger l_rowCount = [a_tableViewController tableView:a_tableViewController.tableView
                                          numberOfRowsInSection:a_indexPath.section];
        l_cellPosition = IFATableViewCellSelectedBackgroundStyleBottom;
        if (a_indexPath.row == 0) {
            l_cellPosition = IFATableViewCellSelectedBackgroundStyleTop;
        } else {
            if (a_indexPath.row < l_rowCount - 1) {
                l_cellPosition = IFATableViewCellSelectedBackgroundStyleMiddle;
            }
        }
        if (l_rowCount == 1) {
            l_cellPosition = IFATableViewCellSelectedBackgroundStyleSingle;
        }
    }
    return l_cellPosition;
}

#pragma mark - IFAAppearanceTheme

-(void)setAppearance {
    
    // Navigation bar
    {
        NSString *l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeNavigationBarBackgroundImageName"];
        if (l_imageName) {
            [self.navigationBarAppearance setBackgroundImage:[UIImage imageNamed:l_imageName]
                                               forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    // Toolbar
    {
        NSString *l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeToolbarBackgroundImageName"];
        if (l_imageName) {
            [self.toolbarAppearance setBackgroundImage:[UIImage imageNamed:l_imageName]
                                    forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }
    
    // Tab bar
    {
        NSString *l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeTabBarBackgroundImageName"];
        if (l_imageName) {
            self.tabBarAppearance.backgroundImage = [UIImage imageNamed:l_imageName];
        }
    }
    
    // Bar button item
    [self setAppearanceForToolbarButtonItem:self.toolbarButtonItemAppearance];
    
    // Bar button item
    [self setAppearanceForBarButtonItem:self.barButtonItemAppearance viewController:nil important:NO ];
    
    // Back Bar button item
    {
        NSString *l_imageName = nil;
        
        l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeBackBarButtonItemBackgroundImageNormalDefaultImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
            [self.barButtonItemAppearance setBackButtonBackgroundImage:l_image forState:UIControlStateNormal
                                                            barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeBackBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
            [self.barButtonItemAppearance setBackButtonBackgroundImage:l_image forState:UIControlStateNormal
                                                            barMetrics:UIBarMetricsLandscapePhone];
        }
    }
    
    // Bar segmented control
    {
        NSString *l_imageName = nil;
        
        l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeBarButtonItemBackgroundImageNormalDefaultImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateNormal
                                                        barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateNormal
                                                        barMetrics:UIBarMetricsLandscapePhone];
        }
        
        l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeBarButtonItemBackgroundImageSelectedDefaultImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateSelected
                                                        barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeBarButtonItemBackgroundImageSelectedLandscapeIphoneImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateSelected
                                                        barMetrics:UIBarMetricsLandscapePhone];
        }
        
        l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeBarSegmentedControlDividerImageName"];
        if (l_imageName) {
            [self.barSegmentedControlAppearance setDividerImage:[UIImage imageNamed:l_imageName]
                                            forLeftSegmentState:UIControlStateNormal
                                              rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [self.barSegmentedControlAppearance setDividerImage:[UIImage imageNamed:l_imageName]
                                            forLeftSegmentState:UIControlStateNormal
                                              rightSegmentState:UIControlStateNormal
                                                     barMetrics:UIBarMetricsLandscapePhone];
        }
        
    }
    
    // Form segmented control
    {
        NSString *l_imageName = nil;
        
        l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeSegmentedControlBackgroundImageNormalImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            [self.segmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateNormal
                                                     barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeSegmentedControlBackgroundImageSelectedImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            [self.segmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateSelected
                                                     barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeSegmentedControlDividerImageName"];
        if (l_imageName) {
            [self.segmentedControlAppearance setDividerImage:[UIImage imageNamed:l_imageName]
                                         forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal
                                                  barMetrics:UIBarMetricsDefault];
        }
        
    }
    
    // Switch
    self.switchAppearance.onTintColor = [self IFA_colorForInfoPlistKey:@"IFAThemeSwitchOnTintColor"];
    
    // Slider
    self.sliderAppearance.minimumTrackTintColor = [self IFA_colorForInfoPlistKey:@"IFAThemeSliderMinimumTrackTintColor"];
    
    

}

-(void)setAppearanceOnViewDidLoadForViewController:(UIViewController*)a_viewController{

    a_viewController.ifa_titleViewDefault = [self navigationItemTitleViewForViewController:a_viewController
                                                                              barMetrics:UIBarMetricsDefault];
    a_viewController.ifa_titleViewLandscapePhone = [self navigationItemTitleViewForViewController:a_viewController
                                                                                     barMetrics:UIBarMetricsLandscapePhone];

    [self setOrientationDependentBackgroundImagesForViewController:a_viewController];
    if ([a_viewController isKindOfClass:[UITableViewController class]]) {
        UITableViewController *l_tableViewController = (UITableViewController*)a_viewController;
        if (l_tableViewController.tableView.style==UITableViewStyleGrouped) {
            l_tableViewController.tableView.separatorColor = [self IFA_colorForInfoPlistKey:@"IFAThemeGroupedTableSeparatorColor"];
        }
    }else if([a_viewController isKindOfClass:[IFAMasterDetailViewController class]]) {

        IFAMasterDetailViewController *l_viewController = (IFAMasterDetailViewController *) a_viewController;
        l_viewController.separatorView.backgroundColor = [self.class splitViewControllerDividerColour];

    }

}

-(void)setAppearanceOnViewWillAppearForViewController:(UIViewController*)a_viewController{
    
    // Navigation item title view titles and subtitle, if applicable
    a_viewController.ifa_titleViewDefault.titleLabel.text = a_viewController.title;
    a_viewController.ifa_titleViewDefault.subTitleLabel.text = a_viewController.ifa_subTitle;
    a_viewController.ifa_titleViewLandscapePhone.titleLabel.text = a_viewController.title;
    a_viewController.ifa_titleViewLandscapePhone.subTitleLabel.text = a_viewController.ifa_subTitle;

    [self IFA_setNavigationItemTitleViewForViewController:a_viewController
                                     interfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    if ([a_viewController isKindOfClass:[IFAAbstractFieldEditorViewController class]]) {
        NSString *l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeFieldEditorToolbarBackgroundImageName"];
        if (l_imageName) {
            [a_viewController.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:l_imageName] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }

#ifdef IFA_AVAILABLE_Help
    // Style help button
    UIColor *l_helpButtonTintColor = a_viewController.navigationController.navigationBar.tintColor;
    if (l_helpButtonTintColor) {
        UIButton *l_helpButton = (UIButton *) a_viewController.IFA_helpBarButtonItem.customView;
        UIImage *l_currentHelpButtonImage = [l_helpButton imageForState:UIControlStateNormal];
        UIImage *l_newHelpButtonImage = [l_currentHelpButtonImage ifa_imageWithOverlayColor:l_helpButtonTintColor];
        [l_helpButton setImage:l_newHelpButtonImage forState:UIControlStateNormal];
    }
#endif

}

-(void)setAppearanceOnWillRotateForViewController:(UIViewController *)a_viewController toInterfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation{
    [self IFA_setNavigationItemTitleViewForViewController:a_viewController
                                     interfaceOrientation:a_toInterfaceOrientation];
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

- (void)setAppearanceForCell:(UITableViewCell *)a_cell atIndexPath:(NSIndexPath *)a_indexPath
              viewController:(IFATableViewController *)a_tableViewController {

}

-(void)setAppearanceOnAwakeFromNibForView:(UIView*)a_view{
    if ([a_view isKindOfClass:[UITableViewCell class]]) {
        [self setLabelTextStyleForChildrenOfView:((UITableViewCell *) a_view).contentView];
    }
}

-(void)setAppearanceOnInitReusableCellForViewController:(UITableViewController *)a_tableViewController cell:(UITableViewCell*)a_cell{

    // Custom disclosure indicator
    if (![a_tableViewController isKindOfClass:[IFAMenuViewController class]] && ![a_tableViewController isKindOfClass:[IFAFormViewController class]]){
        [self setCustomDisclosureIndicatorForCell:a_cell tableViewController:a_tableViewController];
    }
    
    // Cell background color
    if (![a_tableViewController isKindOfClass:[IFAMenuViewController class]] && a_tableViewController.tableView.style==UITableViewStyleGrouped) {
        a_cell.backgroundColor = [self IFA_colorForInfoPlistKey:@"IFAThemeGroupedTableCellBackgroundColor"];
    }
    
    // Label text color
    [self setLabelTextStyleForChildrenOfView:a_cell.contentView];
    UIColor *l_formFieldLabelThemeColor = [self IFA_colorForInfoPlistKey:@"IFAThemeFormFieldLabelColor"];
    if (l_formFieldLabelThemeColor 
            && [a_tableViewController isKindOfClass:[IFAFormViewController class]] 
            && a_cell.detailTextLabel) {   // Is it a cell style that has text and detail?
        // textLabel here in this context refers to the form field label
        //  So, it is setting the form field label colour
        a_cell.textLabel.textColor = l_formFieldLabelThemeColor;
    }

}

-(void)setAppearanceOnWillDisplayCell:(UITableViewCell *)a_cell forRowAtIndexPath:(NSIndexPath *)a_indexPath
                       viewController:(IFATableViewController *)a_tableViewController{
    
    // Table cell text color
    if (![a_tableViewController isKindOfClass:[IFAFormViewController class]]) {
        UIColor *l_color = a_tableViewController.tableCellTextColor;
        if (l_color) {
            a_cell.textLabel.textColor = l_color;
            a_cell.detailTextLabel.textColor = l_color;
        }
    }

    // Set table cell background image
    if ([a_tableViewController isKindOfClass:[IFAListViewController class]]) {
        NSString *l_imageName = [[IFAUtils infoPList] objectForKey:@"IFAThemeListTableCellBackgroundImageName"];
        if (l_imageName) {
            a_cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:l_imageName]];
        }
    }
    
    // Custom disclosure indicator
    if ([a_tableViewController isKindOfClass:[IFAMenuViewController class]]){
        if ( ! ([a_tableViewController isKindOfClass:[IFAMenuViewController class]] && [a_tableViewController tableView:a_tableViewController.tableView heightForRowAtIndexPath:a_indexPath]==0) ) {   // This check is to avoid showing the custom disclose indicator for non-supported menu items
            [self setCustomDisclosureIndicatorForCell:a_cell tableViewController:a_tableViewController];
        }
    }
    
    // Cell background color
    if ([a_tableViewController isKindOfClass:[IFAMenuViewController class]] && a_tableViewController.tableView.style==UITableViewStyleGrouped) {
        a_cell.backgroundColor = [self IFA_colorForInfoPlistKey:@"IFAThemeGroupedTableCellBackgroundColor"];
    }
    
    // Set selected table cell background color
    UIColor *l_selectedTableCellBackgroundColor = [self selectedTableCellBackgroundColor];
    if (l_selectedTableCellBackgroundColor) {
        // Set the appropriate selected background view according to the cell position
        IFATableCellSelectedBackgroundView *l_selectedBackgroundView = [[IFATableCellSelectedBackgroundView alloc] initWithFrame:a_cell.frame];
        l_selectedBackgroundView.fillColor = l_selectedTableCellBackgroundColor;
        l_selectedBackgroundView.borderColor = [UIColor clearColor];
        l_selectedBackgroundView.style = ([self IFA_tableViewCellSelectedBackgroundStyleForIndexPath:a_indexPath
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
        l_imageNameDefault = [[IFAUtils infoPList] objectForKey:@"IFAThemeImportantBarButtonItemBackgroundImageNormalDefaultImageName"];
        l_imageNameLandscapeIphone = [[IFAUtils infoPList] objectForKey:@"IFAThemeImportantBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
    }else{
        l_imageNameDefault = [[IFAUtils infoPList] objectForKey:@"IFAThemeBarButtonItemBackgroundImageNormalDefaultImageName"];
        l_imageNameLandscapeIphone = [[IFAUtils infoPList] objectForKey:@"IFAThemeBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
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
    NSNumber *l_backgroundVerticalPositionAdjustmentDefault = [[IFAUtils infoPList] objectForKey:@"IFAThemeBarButtonItemBackgroundVerticalPositionAdjustmentDefault"];
    if (l_backgroundVerticalPositionAdjustmentDefault) {
        [a_barButtonItem setBackgroundVerticalPositionAdjustment:l_backgroundVerticalPositionAdjustmentDefault.floatValue forBarMetrics:UIBarMetricsDefault];
    }
    NSNumber *l_backgroundVerticalPositionAdjustmentLandscapeIphone = [[IFAUtils infoPList] objectForKey:@"IFAThemeBarButtonItemBackgroundVerticalPositionAdjustmentLandscapeIphone"];
    if (l_backgroundVerticalPositionAdjustmentLandscapeIphone) {
        [a_barButtonItem setBackgroundVerticalPositionAdjustment:l_backgroundVerticalPositionAdjustmentLandscapeIphone.floatValue forBarMetrics:UIBarMetricsLandscapePhone];
    }
}

-(void)setAppearanceForPopoverController:(UIPopoverController*)a_popoverController{
    if ([a_popoverController.contentViewController isKindOfClass:[UINavigationController class]]) {
        Class l_backgroundViewClass = NSClassFromString([IFAUtils infoPList][@"IFAPopoverControllerBackgroundViewClass"]);
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
    return [IFAAppearanceThemeManager bundleForThemeNamed:l_themeName];
}

-(NSString*)storyboardName {
    return [[IFAApplicationDelegate sharedInstance] storyboardName];
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
    return [self IFA_colorForInfoPlistKey:@"IFAThemeTableCellTextColor"];
}

// To be implemented by subclasses
-(UIFont*)tableCellTextFont {
    return nil;
}

-(UIButton*)newDetailDisclosureButton {
    UIButton *l_button = nil;
    NSString *l_imageNameNormal = [[IFAUtils infoPList] objectForKey:@"IFAThemeDetailDisclosureButtonImageNormal"];
    if (l_imageNameNormal) {
        UIImage *l_imageNormal = [UIImage imageNamed:l_imageNameNormal];
        UIImage *l_imageHighlighted = [UIImage imageNamed:[[IFAUtils infoPList] objectForKey:@"IFAThemeDetailDisclosureButtonImageHighlighted"]];
        l_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, l_imageNormal.size.width, l_imageNormal.size.height)];
        [l_button setImage:l_imageNormal forState:UIControlStateNormal];
        [l_button setImage:l_imageHighlighted forState:UIControlStateHighlighted];
    }
#ifdef IFA_AVAILABLE_Help
    l_button.helpTargetId = [IFAUIUtils helpTargetIdForName:@"detailDisclosureButton"];
#endif
    return l_button;
}

-(UIView*)newDisclosureIndicatorView {
    UIImageView *l_view = nil;
    NSString *l_imageNameNormal = [[IFAUtils infoPList] objectForKey:@"IFAThemeDisclosureIndicatorImageNormal"];
    if (l_imageNameNormal) {
        NSString *l_imageNameSelected = [[IFAUtils infoPList] objectForKey:@"IFAThemeDisclosureIndicatorImageSelected"];
        l_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:l_imageNameNormal] highlightedImage:[UIImage imageNamed:l_imageNameSelected]];
    }
    return l_view;
}

-(UIImage*)backgroundImageForViewController:(UIViewController*)a_viewController{
    
    // Determine the info plist's key
    NSString *l_infoPlistKey = nil;
    if ([a_viewController isKindOfClass:[IFAFormViewController class]]) {
        l_infoPlistKey = [IFAUIUtils isDeviceInLandscapeOrientation] ? @"IFAThemeFormBackgroundImageNameLandscape" : @"IFAThemeFormBackgroundImageNamePortrait";
    }else{
        l_infoPlistKey = [IFAUIUtils isDeviceInLandscapeOrientation] ? @"IFAThemeTableBackgroundImageNameLandscape" : @"IFAThemeTableBackgroundImageNamePortrait";
    }
    
    // Determine the image name
    NSString *l_imageName = [[IFAUtils infoPList] objectForKey:l_infoPlistKey];
    
    return [UIImage imageNamed:l_imageName];

}

-(void)setLabelTextStyleForChildrenOfView:(UIView*)a_view{
    UIFont *l_tableCellTextColor = [self tableCellTextFont];
    if (l_tableCellTextColor) {
        for (UIView *l_subView in a_view.subviews) {
            //            NSLog(@"  l_subView: %@", [l_subView description]);
            if ([l_subView isKindOfClass:[UILabel class]]) {
                UILabel *l_label = (UILabel*)l_subView;
                l_label.textColor = [self tableCellTextColor];
                UIFont *l_font = l_tableCellTextColor;
                if (l_font) {
                    l_label.font = l_font;
                }
            }else if ([l_subView isKindOfClass:[UITextField class]]){
                UITextField *l_textField = (UITextField*)l_subView;
                l_textField.textColor = [self tableCellTextColor];
                UIFont *l_font = l_tableCellTextColor;
                if (l_font) {
                    l_textField.font = l_font;
                }
            }
        }
    }
}

-(UIColor*)selectedTableCellBackgroundColor {
    return [self IFA_colorForInfoPlistKey:@"IFAThemeSelectedTableCellBackgroundColor"];
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

-(UIBarButtonItem*)spacingBarButtonItemForType:(IFASpacingBarButtonItemType)a_type viewController:(UIViewController*)a_viewController{
    return nil;
}

- (UIBarButtonItem *)doneBarButtonItemWithTarget:(id)a_target action:(SEL)a_action
                                  viewController:(UIViewController *)a_viewController {
    return [IFAUIUtils barButtonItemForType:IFABarButtonItemDone target:a_target action:a_action];
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
    IFAInternalWebBrowserViewController *l_viewController = [[IFAInternalWebBrowserViewController alloc] initWithURL:a_url completionBlock:a_completionBlock];
    return l_viewController;
}

- (Class)navigationControllerClass {
    return [IFANavigationController class];
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

-(IFANavigationItemTitleView *)navigationItemTitleViewForViewController:(UIViewController *)a_viewController barMetrics:(UIBarMetrics)a_barMetrics{
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

-(IFAColorScheme *)colorScheme {
    if (![self.IFA_colorScheme isEqual:[[IFAApplicationDelegate sharedInstance] colorScheme]]) {
        self.IFA_colorScheme = [[IFAApplicationDelegate sharedInstance] colorScheme];
    }
    return self.IFA_colorScheme;
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

- (UIColor *)groupStyleTableViewBackgroundColour {
    return [UIColor ifa_colorWithRed:239
                               green:239
                                blue:244];
}

+ (UIColor *)splitViewControllerDividerColour {
    return [UIColor ifa_colorWithRed:191 green:191 blue:191];
}

#pragma mark - Overrides

- (id)init{
    self = [super init];
    if (self) {
        self.navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.popoverNavigationBarAppearance = [UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], [self navigationControllerClass], nil];
        self.barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.navigationBarButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], [self navigationControllerClass], nil];
        self.toolbarButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], [self navigationControllerClass], nil];
        self.toolbarAppearance = [UIToolbar appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.popoverToolbarAppearance = [UIToolbar appearanceWhenContainedIn:[UIPopoverController class], [self navigationControllerClass], nil];
        self.tabBarAppearance = [UITabBar appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.tabBarItemAppearance = [UITabBarItem appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.searchBarAppearance = [UISearchBar appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.barSegmentedControlAppearance = [UISegmentedControl appearanceWhenContainedIn:[UIToolbar class], [self navigationControllerClass], nil];
        self.segmentedControlAppearance = [UISegmentedControl appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.switchAppearance = [UISwitch appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.sliderAppearance = [UISlider appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.activityIndicatorView = [UIActivityIndicatorView appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.pageControlAppearance = [UIPageControl appearanceWhenContainedIn:[self navigationControllerClass], nil];
        self.shadow = [NSShadow new];
    }
    return self;
}

@end
