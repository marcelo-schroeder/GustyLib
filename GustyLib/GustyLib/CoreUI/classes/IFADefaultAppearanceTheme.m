//
//  IFADefaultAppearanceTheme.m
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

#import "GustyLibCoreUI.h"
#import "IFASingleSelectionListViewControllerHeaderView.h"
#import "IFAHudView.h"

#ifdef IFA_AVAILABLE_Help
#import "GustyLibHelp.h"
#endif

@interface IFADefaultAppearanceTheme ()

@property (nonatomic, strong) IFAColorScheme *IFA_colorScheme;

@end

@implementation IFADefaultAppearanceTheme {
    
}

#pragma mark - Private

typedef NS_ENUM(NSUInteger, IFAThemeColour){
    IFAThemeColourInlineHelpText,
};

- (UIColor *)IFA_themeColour:(IFAThemeColour)a_themeColour {
    UIColor *colour = nil;
    switch (a_themeColour){
        case IFAThemeColourInlineHelpText:
            colour = [UIColor ifa_grayColorWithRGB:142];
            break;
        default:
            NSAssert(NO, @"Unexpected theme colour: %lu", (unsigned long)a_themeColour);
    }
    return colour;
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

- (void)IFA_updateSeparatorsVisibilityForFormTableViewCell:(IFAFormTableViewCell *)a_cell {
    if (a_cell.highlighted && a_cell.selectionStyle!=UITableViewCellSelectionStyleNone) {
        a_cell.topSeparatorImageView.hidden = YES;
        a_cell.bottomSeparatorImageView.hidden = YES;
    }else{
        NSIndexPath *l_indexPath = a_cell.indexPath;
        IFAFormViewController *a_formViewController = a_cell.formViewController;
        a_cell.topSeparatorImageView.hidden = l_indexPath.row != 0;
        a_cell.bottomSeparatorImageView.hidden = NO;
        NSInteger l_numberOfRowsInSection = [a_formViewController tableView:a_formViewController.tableView
                                                      numberOfRowsInSection:l_indexPath.section];
        BOOL l_isTheLastRowInSection = (l_indexPath.row + 1) == l_numberOfRowsInSection;
        a_cell.bottomSeparatorLeftConstraint.constant = l_isTheLastRowInSection ? 0 : 15;
    }
}

- (void)IFA_setAppearanceForFormInputAccessoryView:(IFAFormInputAccessoryView *)a_view
                                  inViewController:(UIViewController *)a_viewController {

    UIToolbar *l_toolbar = a_view.toolbar;

    l_toolbar.translucent = NO;
    l_toolbar.barTintColor = [UIColor ifa_colorWithSpaceOrTabDelimitedRGB:@"240\t241\t242\t"];
    l_toolbar.tintColor = self.IFA_defaultTintColor;

    // Correct trailing space for the "Done" button
    NSMutableArray *l_items = [l_toolbar.items mutableCopy];
    UIBarButtonItem *l_rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                  target:nil
                                                                                  action:nil];
    l_rightSpace.width = [self spaceBarButtonItemWidthForPosition:IFABarButtonItemSpacingPositionRight
                                                          barType:IFABarButtonItemSpacingBarTypeToolbar
                                                   viewController:a_viewController
                                                            items:@[l_items[l_items.count-1]]].floatValue;
    [l_items addObject:l_rightSpace];
    l_toolbar.items = l_items;

}

- (UIColor *)IFA_defaultTintColor {
    return [UIApplication sharedApplication].delegate.window.tintColor;
}

- (void)IFA_tintImageInButton:(UIButton *)a_button withColor:(UIColor *)a_color{
    if (a_button && a_color) {
        UIImage *currentImage = [a_button imageForState:UIControlStateNormal];
        UIImage *newImage = [currentImage ifa_imageWithOverlayColor:a_color];
        [a_button setImage:newImage forState:UIControlStateNormal];
    }
}

- (void)IFA_tintCustomViewButtonImageInBarButtonItem:(UIBarButtonItem *)a_barButtonItem withColor:(UIColor *)a_color {
    if ([a_barButtonItem.customView isKindOfClass:[UIButton class]] && a_color) {
        [self IFA_tintImageInButton:(UIButton *) a_barButtonItem.customView withColor:a_color];
    }
}

#pragma mark - IFAAppearanceTheme

-(void)setAppearance {
    
    // Navigation bar
    {
        NSString *l_imageName = [IFAUtils infoPList][@"IFAThemeNavigationBarBackgroundImageName"];
        if (l_imageName) {
            [self.navigationBarAppearance setBackgroundImage:[UIImage imageNamed:l_imageName]
                                               forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    // Toolbar
    {
        NSString *l_imageName = [IFAUtils infoPList][@"IFAThemeToolbarBackgroundImageName"];
        if (l_imageName) {
            [self.toolbarAppearance setBackgroundImage:[UIImage imageNamed:l_imageName]
                                    forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }
    
    // Tab bar
    {
        NSString *l_imageName = [IFAUtils infoPList][@"IFAThemeTabBarBackgroundImageName"];
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
        
        l_imageName = [IFAUtils infoPList][@"IFAThemeBackBarButtonItemBackgroundImageNormalDefaultImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
            [self.barButtonItemAppearance setBackButtonBackgroundImage:l_image forState:UIControlStateNormal
                                                            barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [IFAUtils infoPList][@"IFAThemeBackBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
            [self.barButtonItemAppearance setBackButtonBackgroundImage:l_image forState:UIControlStateNormal
                                                            barMetrics:UIBarMetricsCompact];
        }
    }
    
    // Bar segmented control
    {
        NSString *l_imageName = nil;
        
        l_imageName = [IFAUtils infoPList][@"IFAThemeBarButtonItemBackgroundImageNormalDefaultImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateNormal
                                                        barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [IFAUtils infoPList][@"IFAThemeBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateNormal
                                                        barMetrics:UIBarMetricsCompact];
        }
        
        l_imageName = [IFAUtils infoPList][@"IFAThemeBarButtonItemBackgroundImageSelectedDefaultImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateSelected
                                                        barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [IFAUtils infoPList][@"IFAThemeBarButtonItemBackgroundImageSelectedLandscapeIphoneImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
            [self.barSegmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateSelected
                                                        barMetrics:UIBarMetricsCompact];
        }
        
        l_imageName = [IFAUtils infoPList][@"IFAThemeBarSegmentedControlDividerImageName"];
        if (l_imageName) {
            [self.barSegmentedControlAppearance setDividerImage:[UIImage imageNamed:l_imageName]
                                            forLeftSegmentState:UIControlStateNormal
                                              rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [self.barSegmentedControlAppearance setDividerImage:[UIImage imageNamed:l_imageName]
                                            forLeftSegmentState:UIControlStateNormal
                                              rightSegmentState:UIControlStateNormal
                                                     barMetrics:UIBarMetricsCompact];
        }
        
    }
    
    // Form segmented control
    {
        NSString *l_imageName = nil;
        
        l_imageName = [IFAUtils infoPList][@"IFAThemeSegmentedControlBackgroundImageNormalImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            [self.segmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateNormal
                                                     barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [IFAUtils infoPList][@"IFAThemeSegmentedControlBackgroundImageSelectedImageName"];
        if (l_imageName) {
            UIImage *l_image = [[UIImage imageNamed:l_imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
            [self.segmentedControlAppearance setBackgroundImage:l_image forState:UIControlStateSelected
                                                     barMetrics:UIBarMetricsDefault];
        }
        
        l_imageName = [IFAUtils infoPList][@"IFAThemeSegmentedControlDividerImageName"];
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
                                                                                     barMetrics:UIBarMetricsCompact];

    [self setOrientationDependentBackgroundImagesForViewController:a_viewController];
    if ([a_viewController isKindOfClass:[UITableViewController class]]) {

        UITableViewController *l_tableViewController = (UITableViewController*)a_viewController;
        if (l_tableViewController.tableView.style==UITableViewStyleGrouped) {
            l_tableViewController.tableView.separatorColor = [self IFA_colorForInfoPlistKey:@"IFAThemeGroupedTableSeparatorColor"];
        }

        if ([a_viewController isKindOfClass:[IFAFormViewController class]]) {
            IFAFormViewController *l_viewController = (IFAFormViewController *) a_viewController;
            [self IFA_setAppearanceForFormInputAccessoryView:l_viewController.formInputAccessoryView
                                            inViewController:l_viewController];

        }else if ([a_viewController isKindOfClass:[IFAListViewController class]]) {
            IFAListViewController *listViewController = (IFAListViewController *) a_viewController;
            UIColor *noDataHelpColor = [self IFA_themeColour:IFAThemeColourInlineHelpText];
            listViewController.noDataPlaceholderAddHintPrefixLabel.textColor = noDataHelpColor;
            listViewController.noDataPlaceholderAddHintSuffixLabel.textColor = noDataHelpColor;
            listViewController.noDataPlaceholderDescriptionLabel.textColor = noDataHelpColor;
            UIImage *currentNoDataHelpAddHintImage = listViewController.noDataPlaceholderAddHintImageView.image;
            UIImage *newNoDataHelpAddHintImage = [currentNoDataHelpAddHintImage ifa_imageWithOverlayColor:self.IFA_defaultTintColor];
            listViewController.noDataPlaceholderAddHintImageView.image = newNoDataHelpAddHintImage;
        }

    }else if([a_viewController isKindOfClass:[IFAMasterDetailViewController class]]) {

        IFAMasterDetailViewController *l_viewController = (IFAMasterDetailViewController *) a_viewController;
        l_viewController.separatorView.backgroundColor = [self.class splitViewControllerDividerColour];

#ifdef IFA_AVAILABLE_Help
    }else if ([a_viewController isKindOfClass:[IFAHelpViewController class]]) {

        IFAHelpViewController *viewController = (IFAHelpViewController *) a_viewController;
        viewController.view.backgroundColor = [UIColor clearColor];
        [viewController.navigationBar setBackgroundImage:[UIImage ifa_imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
        viewController.navigationBar.shadowImage = [[UIImage ifa_separatorImageForType:IFASeparatorImageTypeHorizontalTop] ifa_imageWithOverlayColor:[UIColor whiteColor]];

    }else if ([a_viewController isKindOfClass:[IFAHelpContentViewController class]]) {

        a_viewController.edgesForExtendedLayout = UIRectEdgeNone;
        a_viewController.automaticallyAdjustsScrollViewInsets = NO;
        a_viewController.view.backgroundColor = [UIColor clearColor];
#endif

    }else if([a_viewController isKindOfClass:[IFALazyTableDataLoadingViewController class]]) {

        IFALazyTableDataLoadingViewController *l_viewController = (IFALazyTableDataLoadingViewController *) a_viewController;
        l_viewController.activityIndicatorView.color = [UIColor blackColor];

    }

    [self setTextAppearanceForSelectedContentSizeCategoryInObject:a_viewController];

}

-(void)setAppearanceOnViewWillAppearForViewController:(UIViewController*)a_viewController{
    
    // Navigation item title view titles and subtitle, if applicable
    a_viewController.ifa_titleViewDefault.titleLabel.text = a_viewController.navigationItem.title ?: a_viewController.title;
    a_viewController.ifa_titleViewDefault.subTitleLabel.text = a_viewController.ifa_subTitle;
    a_viewController.ifa_titleViewLandscapePhone.titleLabel.text = a_viewController.navigationItem.title ?: a_viewController.title;
    a_viewController.ifa_titleViewLandscapePhone.subTitleLabel.text = a_viewController.ifa_subTitle;

    [self setNavigationItemTitleViewForViewController:a_viewController
                                 interfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    if ([a_viewController isKindOfClass:[IFAAbstractFieldEditorViewController class]]) {
        NSString *l_imageName = [IFAUtils infoPList][@"IFAThemeFieldEditorToolbarBackgroundImageName"];
        if (l_imageName) {
            [a_viewController.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:l_imageName] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }

#ifdef IFA_AVAILABLE_Help
    UIColor *navigationBarTintColor = a_viewController.navigationController.navigationBar.tintColor;
    [self IFA_tintCustomViewButtonImageInBarButtonItem:a_viewController.ifa_helpBarButtonItem
                                             withColor:navigationBarTintColor];
    if ([a_viewController isKindOfClass:[IFAHelpContentViewController class]]) {
        IFAHelpContentViewController *helpViewController = (IFAHelpContentViewController *) a_viewController;
        [self IFA_tintCustomViewButtonImageInBarButtonItem:helpViewController.closeBarButtonItem
                                                 withColor:navigationBarTintColor];
    }
#endif

}

-(void)setAppearanceOnViewDidAppearForViewController:(UIViewController*)a_viewController{
    if (a_viewController.ifa_manageToolbar) {
        // The speed that the navigation view controller resizes its view is different than the speed of the toolbar visibility animation. This can cause an undesired visual effect if the background colours do not match.
        // The line of code below makes sure the navigation controller view colour always matches that of the view that has a toolbar hiding or showing.
        a_viewController.navigationController.view.backgroundColor = a_viewController.view.backgroundColor;
    }
}

- (void)setAppearanceOnWillRotateForViewController:(UIViewController *)a_viewController
                            toInterfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation {
    [self setNavigationItemTitleViewForViewController:a_viewController
                                 interfaceOrientation:a_toInterfaceOrientation];
}

-(void)setAppearanceOnWillAnimateRotationForViewController:(UIViewController *)a_viewController interfaceOrientation:(UIInterfaceOrientation)a_toInterfaceOrientation{
    [self setOrientationDependentBackgroundImagesForViewController:a_viewController];
}

-(void)setAppearanceOnInitForView:(UIView*)a_view{
    [self setTextAppearanceForSelectedContentSizeCategoryInObject:a_view];
}

- (void)setAppearanceForCell:(UITableViewCell *)a_cell onSetHighlighted:(BOOL)a_highlighted
                    animated:(BOOL)a_shouldAnimate {
    if ([a_cell isKindOfClass:[IFAFormTableViewCell class]]) {
        [self IFA_updateSeparatorsVisibilityForFormTableViewCell:(IFAFormTableViewCell *) a_cell];
    }
}

- (void)setAppearanceForCell:(UITableViewCell *)a_cell onSetSelected:(BOOL)a_selected animated:(BOOL)a_shouldAnimate {
}

- (void)setAppearanceForCell:(UITableViewCell *)a_cell atIndexPath:(NSIndexPath *)a_indexPath
              viewController:(IFATableViewController *)a_tableViewController {
    [self setTextAppearanceForSelectedContentSizeCategoryInObject:a_cell];
}

-(void)setAppearanceOnAwakeFromNibForView:(UIView*)a_view{
    [self setTextAppearanceForSelectedContentSizeCategoryInObject:a_view];
    if ([a_view isKindOfClass:[UITableViewCell class]]) {
        [self setTextAppearanceForChildrenOfView:((UITableViewCell *) a_view).contentView];
        if ([a_view isKindOfClass:[IFAMultipleSelectionListViewCell class]]) {
            IFAMultipleSelectionListViewCell *l_cell = (IFAMultipleSelectionListViewCell *) a_view;
            UIColor *l_defaultTintColor = self.IFA_defaultTintColor;
            l_cell.addToSelectionImageView.image = [l_cell.addToSelectionImageView.image ifa_imageWithOverlayColor:l_defaultTintColor];
            l_cell.removeFromSelectionImageView.image = [l_cell.removeFromSelectionImageView.image ifa_imageWithOverlayColor:l_defaultTintColor];
        }
    }else if ([a_view isKindOfClass:[IFAFormTableViewCellContentView class]]) {
        IFAFormTableViewCellContentView *l_view = (IFAFormTableViewCellContentView *) a_view;
        l_view.formTableViewCell.topSeparatorImageView.image = [UIImage ifa_separatorImageForType:IFASeparatorImageTypeHorizontalBottom];
        l_view.formTableViewCell.bottomSeparatorImageView.image = [UIImage ifa_separatorImageForType:IFASeparatorImageTypeHorizontalBottom];
    }else if ([a_view isKindOfClass:[IFASingleSelectionListViewControllerHeaderView class]]) {
        IFASingleSelectionListViewControllerHeaderView *view = (IFASingleSelectionListViewControllerHeaderView *) a_view;
        view.textLabel.textColor = [self IFA_themeColour:IFAThemeColourInlineHelpText];
        view.textLabel.textAlignment = NSTextAlignmentLeft;
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
    [self setTextAppearanceForChildrenOfView:a_cell.contentView];
    UIColor *l_formFieldLabelThemeColor = [self IFA_colorForInfoPlistKey:@"IFAThemeFormFieldLabelColor"];
    if (l_formFieldLabelThemeColor 
            && [a_tableViewController isKindOfClass:[IFAFormViewController class]] 
            && a_cell.detailTextLabel) {   // Is it a cell style that has text and detail?
        // textLabel here in this context refers to the form field label
        //  So, it is setting the form field label colour
        a_cell.textLabel.textColor = l_formFieldLabelThemeColor;
    }

    if ([a_cell isKindOfClass:[IFAFormTableViewCell class]]) {
        IFAFormTableViewCell *l_formTableViewCell = (IFAFormTableViewCell *) a_cell;
        if ([l_formTableViewCell.formViewController fieldTypeForIndexPath:l_formTableViewCell.indexPath]==IFAEntityConfigFieldTypeButton) {
            BOOL l_isDestructiveButton = [l_formTableViewCell.formViewController isDestructiveButtonForCell:l_formTableViewCell];
            UIColor *l_textColor = l_isDestructiveButton ? [UIColor redColor] : self.IFA_defaultTintColor;
            l_formTableViewCell.centeredLabel.textColor = l_textColor;
        }
        if ([l_formTableViewCell isKindOfClass:[IFASegmentedControlTableViewCell class]]) {
            IFASegmentedControlTableViewCell *l_cell = (IFASegmentedControlTableViewCell *) l_formTableViewCell;
            [l_cell.segmentedControl setTitleTextAttributes:@{NSFontAttributeName : l_cell.leftLabel.font}
                                                   forState:UIControlStateNormal];
        }
    }

}

-(void)setAppearanceOnWillDisplayCell:(UITableViewCell *)a_cell forRowAtIndexPath:(NSIndexPath *)a_indexPath
                       viewController:(IFATableViewController *)a_tableViewController{
    
    // Table cell text color
    if ([a_tableViewController isKindOfClass:[IFAFormViewController class]]) {
        if ([a_cell isKindOfClass:[IFAFormTableViewCell class]]) {
            IFAFormTableViewCell *l_cell = (IFAFormTableViewCell *) a_cell;
            [self IFA_updateSeparatorsVisibilityForFormTableViewCell:l_cell];
        }
    }else{
        UIColor *l_color = a_tableViewController.tableCellTextColor;
        if (l_color) {
            a_cell.textLabel.textColor = l_color;
            a_cell.detailTextLabel.textColor = l_color;
        }
    }

    // Set table cell background image
    if ([a_tableViewController isKindOfClass:[IFAListViewController class]]) {
        NSString *l_imageName = [IFAUtils infoPList][@"IFAThemeListTableCellBackgroundImageName"];
        if (l_imageName) {
            a_cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:l_imageName]];
        }
    }
    
    // Custom disclosure indicator
    if ([a_tableViewController isKindOfClass:[IFAMenuViewController class]]){
        if ( [a_tableViewController tableView:a_tableViewController.tableView heightForRowAtIndexPath:a_indexPath]!=0 ) {   // This check is to avoid showing the custom disclose indicator for non-supported menu items
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

- (void)setAppearanceForView:(UIView *)a_view {
    if ([a_view isKindOfClass:[IFAFormSectionHeaderFooterView class]]) {
        IFAFormSectionHeaderFooterView *view = (IFAFormSectionHeaderFooterView *) a_view;
        view.label.textColor = [UIColor ifa_grayColorWithRGB:113];
    }
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
        l_imageNameDefault = [IFAUtils infoPList][@"IFAThemeImportantBarButtonItemBackgroundImageNormalDefaultImageName"];
        l_imageNameLandscapeIphone = [IFAUtils infoPList][@"IFAThemeImportantBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
    }else{
        l_imageNameDefault = [IFAUtils infoPList][@"IFAThemeBarButtonItemBackgroundImageNormalDefaultImageName"];
        l_imageNameLandscapeIphone = [IFAUtils infoPList][@"IFAThemeBarButtonItemBackgroundImageNormalLandscapeIphoneImageName"];
    }
    if (l_imageNameDefault) {
        UIImage *l_image = [[UIImage imageNamed:l_imageNameDefault] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [a_barButtonItem setBackgroundImage:l_image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
    if (l_imageNameLandscapeIphone) {
        UIImage *l_image = [[UIImage imageNamed:l_imageNameLandscapeIphone] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [a_barButtonItem setBackgroundImage:l_image forState:UIControlStateNormal barMetrics:UIBarMetricsCompact];
    }

}

-(void)setAppearanceForToolbarButtonItem:(UIBarButtonItem*)a_barButtonItem{
    NSNumber *l_backgroundVerticalPositionAdjustmentDefault = [IFAUtils infoPList][@"IFAThemeBarButtonItemBackgroundVerticalPositionAdjustmentDefault"];
    if (l_backgroundVerticalPositionAdjustmentDefault) {
        [a_barButtonItem setBackgroundVerticalPositionAdjustment:l_backgroundVerticalPositionAdjustmentDefault.floatValue forBarMetrics:UIBarMetricsDefault];
    }
    NSNumber *l_backgroundVerticalPositionAdjustmentLandscapeIphone = [IFAUtils infoPList][@"IFAThemeBarButtonItemBackgroundVerticalPositionAdjustmentLandscapeIphone"];
    if (l_backgroundVerticalPositionAdjustmentLandscapeIphone) {
        [a_barButtonItem setBackgroundVerticalPositionAdjustment:l_backgroundVerticalPositionAdjustmentLandscapeIphone.floatValue forBarMetrics:UIBarMetricsCompact];
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

- (void)setAppearanceOnPrepareForReuseForTableViewCell:(UITableViewCell *)a_cell {
    [self setTextAppearanceForSelectedContentSizeCategoryInObject:a_cell];
}

- (void)setAppearanceOnPrepareForReuseForTableViewHeaderFooterView:(IFATableViewHeaderFooterView *)a_view {
    [self setTextAppearanceForSelectedContentSizeCategoryInObject:a_view];
}

-(void)setNavigationItemTitleViewForViewController:(UIViewController *)a_viewController interfaceOrientation:(UIInterfaceOrientation)a_interfaceOrientation{

    if (a_viewController.ifa_titleViewDefault && a_viewController.ifa_titleViewLandscapePhone) {

        CGFloat l_navigationBarHeight = a_viewController.navigationController.navigationBar.bounds.size.height;

        // Determine which title view to use
        BOOL l_isIPhoneLandscape = ![IFAUIUtils isIPad] && UIInterfaceOrientationIsLandscape(a_interfaceOrientation);
//        NSLog(@"l_isIPhoneLandscape: %u", l_isIPhoneLandscape);
        IFANavigationItemTitleView *l_titleView = l_isIPhoneLandscape ? a_viewController.ifa_titleViewLandscapePhone : a_viewController.ifa_titleViewDefault;

        // Resize the title view according to the greatest label width
        CGFloat l_greatestMaxWidth = 0;
        for (UIView *l_view in l_titleView.subviews) {
            if ([l_view isKindOfClass:[UILabel class]]) {
                UILabel *l_label = (UILabel*)l_view;
                CGFloat l_widthConstraint = l_titleView.preferredWidth ?: CGFLOAT_MAX;
                CGFloat l_maxWidth = [l_label sizeThatFits:CGSizeMake(l_widthConstraint, l_navigationBarHeight)].width;
                if (l_maxWidth>l_greatestMaxWidth) {
                    l_greatestMaxWidth = l_maxWidth;
                }
//                NSLog(@"l_maxWidth: %f", l_maxWidth);
            }
        }
//        NSLog(@"l_greatestMaxWidth: %f", l_greatestMaxWidth);
        CGFloat l_x = l_titleView.frame.origin.x;
        CGFloat l_y = l_titleView.frame.origin.y;
        CGFloat l_width = l_greatestMaxWidth;
        CGFloat l_height = l_navigationBarHeight;
        l_titleView.frame = CGRectMake(l_x, l_y, l_width, l_height);

        // Set it in the navigation item
        [self titleViewNavigationItemForViewViewController:a_viewController].titleView = l_titleView;

    }
}

- (void)setTextAppearanceForSelectedContentSizeCategoryInObject:(id)a_object {

    if ([a_object isKindOfClass:[UIView class]]) {

        if ([a_object isKindOfClass:[IFAFormSectionHeaderFooterView class]]) {

            IFAFormSectionHeaderFooterView *obj = a_object;
            obj.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

        }else if ([a_object isKindOfClass:[IFASingleSelectionListViewControllerHeaderView class]]) {

            IFASingleSelectionListViewControllerHeaderView *obj = (IFASingleSelectionListViewControllerHeaderView *) a_object;
            obj.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

        } else if ([a_object isKindOfClass:[UITableViewCell class]]) {

            UIFont *headlineSizeFont = [UIFont systemFontOfSize:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize];  // Font based on the headline text style font size

            if ([a_object isKindOfClass:[IFAFormTableViewCell class]]) {
                IFAFormTableViewCell *obj = a_object;
                obj.leftLabel.font = headlineSizeFont;
                obj.centeredLabel.font = headlineSizeFont;
                obj.rightLabel.font = headlineSizeFont;
                if ([a_object isKindOfClass:[IFAFormTextFieldTableViewCell class]]) {
                    IFAFormTextFieldTableViewCell *cell = a_object;
                    cell.textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];   // Form some obscure reason, this font does not cause truncation of the text at the largest size.
                } else if ([a_object isKindOfClass:[IFASegmentedControlTableViewCell class]]) {
                    IFASegmentedControlTableViewCell *cell = a_object;
                    [cell.segmentedControl setTitleTextAttributes:@{NSFontAttributeName : headlineSizeFont}
                                                         forState:UIControlStateNormal];
                }
            } else if ([a_object isKindOfClass:[IFAMultipleSelectionListViewCell class]]) {
                IFAMultipleSelectionListViewCell *obj = (IFAMultipleSelectionListViewCell *) a_object;
                obj.label.font = headlineSizeFont;
            }

        }

    } else if ([a_object isKindOfClass:[UIViewController class]]) {

        if ([a_object isKindOfClass:[IFAAboutFormViewController class]]) {
            IFAAboutFormViewController *obj = (IFAAboutFormViewController *) a_object;
            obj.appNameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            obj.copyrightNoticeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        } else if ([a_object isKindOfClass:[IFAListViewController class]]) {
            IFAListViewController *obj = (IFAListViewController *) a_object;
            obj.noDataPlaceholderAddHintPrefixLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            obj.noDataPlaceholderAddHintSuffixLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            obj.noDataPlaceholderDescriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        }

    }

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

//-(UIButton*)newDetailDisclosureButton {
//    UIButton *l_button = nil;
//    NSString *l_imageNameNormal = [IFAUtils infoPList][@"IFAThemeDetailDisclosureButtonImageNormal"];
//    if (l_imageNameNormal) {
//        UIImage *l_imageNormal = [UIImage imageNamed:l_imageNameNormal];
//        UIImage *l_imageHighlighted = [UIImage imageNamed:[IFAUtils infoPList][@"IFAThemeDetailDisclosureButtonImageHighlighted"]];
//        l_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, l_imageNormal.size.width, l_imageNormal.size.height)];
//        [l_button setImage:l_imageNormal forState:UIControlStateNormal];
//        [l_button setImage:l_imageHighlighted forState:UIControlStateHighlighted];
//    }
//    return l_button;
//}

-(UIView*)newDisclosureIndicatorView {
    UIImageView *l_view = nil;
    NSString *l_imageNameNormal = [IFAUtils infoPList][@"IFAThemeDisclosureIndicatorImageNormal"];
    if (l_imageNameNormal) {
        NSString *l_imageNameSelected = [IFAUtils infoPList][@"IFAThemeDisclosureIndicatorImageSelected"];
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
    NSString *l_imageName = [IFAUtils infoPList][l_infoPlistKey];
    
    return [UIImage imageNamed:l_imageName];

}

-(void)setTextAppearanceForChildrenOfView:(UIView*)a_view{
    UIFont *l_tableCellTextColor = [self tableCellTextFont];
    if (l_tableCellTextColor) {
        for (UIView *l_subView in a_view.subviews) {
            //            NSLog(@"  l_subView: %@", [l_subView description]);
            if ([l_subView isKindOfClass:[UILabel class]]) {
                UILabel *l_label = (UILabel*)l_subView;
                l_label.textColor = [self tableCellTextColor];
                UIFont *l_font = l_tableCellTextColor;
                l_label.font = l_font;
            }else if ([l_subView isKindOfClass:[UITextField class]]){
                UITextField *l_textField = (UITextField*)l_subView;
                l_textField.textColor = [self tableCellTextColor];
                UIFont *l_font = l_tableCellTextColor;
                l_textField.font = l_font;
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

- (NSNumber *)spaceBarButtonItemWidthForPosition:(IFABarButtonItemSpacingPosition)a_position
                                         barType:(IFABarButtonItemSpacingBarType)a_barType
                                  viewController:(UIViewController *)a_viewController items:(NSArray *)a_items {
    return nil;
}

- (UIBarButtonItem *)doneBarButtonItemWithTarget:(id)a_target action:(SEL)a_action
                                  viewController:(UIViewController *)a_viewController {
    return [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeDone target:a_target action:a_action];
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

- (void)setCustomAccessoryViewAppearanceForFormTableViewCell:(IFAFormTableViewCell *)a_cell {

    NSString *l_imageName = nil;
    BOOL l_shouldUseButton = NO;
//    BOOL l_shouldTintImage = NO;
    switch (a_cell.customAccessoryType){
        case IFAFormTableViewCellAccessoryTypeDisclosureIndicatorInfo:
            l_shouldUseButton = YES;
        case IFAFormTableViewCellAccessoryTypeNone:
            l_imageName = nil;
            break;
        case IFAFormTableViewCellAccessoryTypeDisclosureIndicatorRight:
            l_imageName = @"IFA_Icon_DisclosureIndicatorRight";
            break;
        case IFAFormTableViewCellAccessoryTypeDisclosureIndicatorDown:
            l_imageName = @"IFA_Icon_DisclosureIndicatorDown";
            break;
    }
    a_cell.customAccessoryButton.hidden = !l_shouldUseButton;
    UIImage *l_image = l_imageName ? [UIImage imageNamed:l_imageName] : nil;
//    if (l_image && l_shouldTintImage) {
//        UIColor *l_overlayColor = self.IFA_defaultTintColor;
//        l_image = [l_image ifa_imageWithOverlayColor:l_overlayColor];
//    }
    a_cell.customAccessoryImageView.image = l_image;
    a_cell.customAccessoryImageView.hidden = l_imageName == nil;
    [a_cell.customAccessoryImageView sizeToFit];    // Make sure the size is available below

    // Update right label right constraint accordingly
    CGFloat l_horizontalSpace = a_cell.leftLabelLeftConstraint.constant;
    BOOL l_areCustomAccessoryViewsHidden = a_cell.customAccessoryImageView.hidden && a_cell.customAccessoryButton.hidden;
    if (l_areCustomAccessoryViewsHidden) {
        a_cell.rightLabelRightConstraint.constant = l_horizontalSpace;
    }
    else {
        UIView *l_visibleCustomAccessoryView = a_cell.customAccessoryImageView.hidden ? a_cell.customAccessoryButton : a_cell.customAccessoryImageView;
        CGFloat l_customAccessoryViewWidth = l_visibleCustomAccessoryView.bounds.size.width;
        a_cell.rightLabelRightConstraint.constant = l_horizontalSpace * 2 + l_customAccessoryViewWidth;
    }

    [a_cell.customAccessoryImageView layoutIfNeeded]; // Make sure differences in the image sizes trigger layout constraint recalculation

}


- (UIColor *)groupStyleTableViewBackgroundColour {
    return [UIColor ifa_colorWithRed:239
                               green:239
                                blue:244];
}

+ (NSDictionary *)defaultAppearancePropertiesForHudView:(IFAHudView *)a_hudView {

    // chromeViewMaximumLayoutWidth
    CGFloat smallestScreenDimension = fminf([IFAUIUtils screenBoundsSize].width, [IFAUIUtils screenBoundsSize].height);
    CGFloat smallestScreenDimensionFactor = [IFAUIUtils isIPad] ? 0.5f : 1.0f;
    CGFloat chromeViewMaximumLayoutWidth = smallestScreenDimension * smallestScreenDimensionFactor;

    // nonModalChromeBackgroundColour
    UIColor *nonModalChromeBackgroundColour;
    if ([UIVisualEffectView class]) {   // iOS 8 backwards compatibility
        nonModalChromeBackgroundColour = [UIColor clearColor];
    } else {
        nonModalChromeBackgroundColour = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    }

    return @{
            @"nonModalStyle" : @(IFAHudViewStyleBlur),
            @"modalStyle" : @(IFAHudViewStylePlain),
            @"nonModalBlurEffectStyle" : @(UIBlurEffectStyleDark),
            @"modalBlurEffectStyle" : @(UIBlurEffectStyleDark),
            @"chromeViewLayoutFittingSize" : [NSValue valueWithCGSize:UILayoutFittingCompressedSize],
            @"shouldAnimateLayoutChanges" : @(NO),
            @"chromeHorizontalPadding" : @(10),
            @"chromeVerticalPadding" : @(10),
            @"chromeVerticalInteritemSpacing" : @(8),
            @"nonModalOverlayColour" : [UIColor clearColor],
            @"nonModalChromeForegroundColour" : [UIColor whiteColor],
            @"nonModalChromeBackgroundColour" : nonModalChromeBackgroundColour,
            @"nonModalProgressViewTrackTintColour" : [UIColor lightGrayColor],
            @"modalOverlayColour" : [[UIColor blackColor] colorWithAlphaComponent:0.5],
            @"modalChromeForegroundColour" : [UIColor blackColor],
            @"modalChromeBackgroundColour" : [[UIColor whiteColor] colorWithAlphaComponent:0.9],
            @"modalProgressViewTrackTintColour" : [UIColor lightGrayColor],
            @"textLabelFontTextStyle" : UIFontTextStyleHeadline,
            @"detailTextLabelFontTextStyle" : UIFontTextStyleSubheadline,
            @"chromeViewMaximumLayoutWidth" : @(chromeViewMaximumLayoutWidth),
            @"chromeHorizontalMargin" : @(20),
    };

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
