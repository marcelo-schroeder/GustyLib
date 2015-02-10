//
//  IFAUIUtils.m
//  Gusty
//
//  Created by Marcelo Schroeder on 17/06/10.
//  Copyright 2010 InfoAccent Pty Limited. All rights reserved.
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

static UIImage *c_menuBarButtonItemImage = nil;

@implementation IFAUIUtils

#pragma mark - Private

+ (void)IFA_presentHudViewControllerWithText:(NSString *)a_text {
    IFAHudViewController *hudViewController = [IFAHudViewController new];
    hudViewController.text = a_text;
    hudViewController.autoDismissalDelay = 1;
    hudViewController.modal = NO;
    [hudViewController presentHudViewControllerWithParentViewController:nil
                                                             parentView:nil
                                                               animated:YES
                                                             completion:nil];
}

+(void)IFA_traverseHierarchyForView:(UIView *)a_view withBlock:(void (^) (UIView *))a_block level:(NSUInteger)a_level{

//    NSMutableString *l_indentation = [NSMutableString string];
//    for (int i=0; i<a_level; i++) {
//        [l_indentation appendString:@" "];
//    }
//    NSLog(@"%@ %u a_superview: %@", l_indentation, a_level, [a_view description]);
    
    a_block(a_view);

    NSUInteger l_subviewLevel = a_level + 1;

    if ([a_view isKindOfClass:[UITableView class]]) {

        UITableView *l_tableView = (UITableView*)a_view;
        NSMutableSet *l_fullyVisibleIndexPaths = [NSMutableSet new];
        for (UITableViewCell *l_tableViewCell in l_tableView.visibleCells) {
            NSIndexPath *l_indexPath = [l_tableView indexPathForCell:l_tableViewCell];
//            if ([l_tableView m_isCellFullyVisibleForRowAtIndexPath:l_indexPath]) {
            [self IFA_traverseHierarchyForView:l_tableViewCell withBlock:a_block level:l_subviewLevel];
                [l_fullyVisibleIndexPaths addObject:l_indexPath];
//            }
        }
        NSMutableSet *l_visibleSections = [NSMutableSet new];
        for (NSIndexPath *l_indexPath in l_fullyVisibleIndexPaths) {
            @autoreleasepool {
                NSNumber *l_section = [NSNumber numberWithUnsignedInteger:(NSUInteger) l_indexPath.section];
                [l_visibleSections addObject:l_section];
            }
        }
        for (NSNumber *l_section in l_visibleSections) {
            @autoreleasepool {
                if ([l_tableView.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
                    UIView *l_sectionHeaderView = [l_tableView.delegate tableView:l_tableView
                                                           viewForHeaderInSection:[l_section unsignedIntegerValue]];
                    [self IFA_traverseHierarchyForView:l_sectionHeaderView withBlock:a_block level:l_subviewLevel];
                }
                if ([l_tableView.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
                    UIView *l_sectionFooterView = [l_tableView.delegate tableView:l_tableView
                                                           viewForFooterInSection:[l_section unsignedIntegerValue]];
                    [self IFA_traverseHierarchyForView:l_sectionFooterView withBlock:a_block level:l_subviewLevel];
                }
            }
        }
        [self IFA_traverseHierarchyForView:l_tableView.tableHeaderView withBlock:a_block level:l_subviewLevel];
        [self IFA_traverseHierarchyForView:l_tableView.tableFooterView withBlock:a_block level:l_subviewLevel];

    }else {
        
        // The check below is to avoid going deeper into Apple's private implementations and other class kinds that could cause issues
        if ([a_view isKindOfClass:[UIDatePicker class]] || [a_view isKindOfClass:[UIPickerView class]] || [a_view isKindOfClass:[IFAHudView class]]) {
            return;
        }
        
        // Go deeper...
        for (UIView *l_subview in a_view.subviews) {
            [self IFA_traverseHierarchyForView:l_subview withBlock:a_block level:l_subviewLevel];
        }

    }

}

#pragma mark - Public

+ (void) showAlertWithMessage:(NSString*)aMessage title:(NSString*)aTitle{
	[self showAlertWithMessage:aMessage 
						 title:aTitle 
					  delegate:nil
				   buttonLabel:nil];
}

+ (void) showAlertWithMessage:(NSString*)aMessage title:(NSString*)aTitle buttonLabel:(NSString*)aButtonLabel{
	[self showAlertWithMessage:aMessage 
						 title:aTitle 
					  delegate:nil
				   buttonLabel:aButtonLabel];
}

+ (void) showAlertWithMessage:(NSString*)aMessage title:(NSString*)aTitle delegate:(id)aDelegate{
	[self showAlertWithMessage:aMessage 
						 title:aTitle 
					  delegate:aDelegate
				   buttonLabel:nil];
}

+ (void) showAlertWithMessage:(NSString*)aMessage 
						title:(NSString*)aTitle 
					 delegate:(id)aDelegate 
				  buttonLabel:(NSString*)aButtonLabel{
    [self showAlertWithMessage:aMessage title:aTitle delegate:aDelegate buttonLabel:aButtonLabel tag:NSNotFound];
}

+ (void) showAlertWithMessage:(NSString*)aMessage title:(NSString*)aTitle delegate:(id)aDelegate buttonLabel:(NSString*)aButtonLabel tag:(NSInteger)aTag{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:aTitle message:aMessage
												   delegate:aDelegate
										  cancelButtonTitle:(aButtonLabel==nil?@"Continue":aButtonLabel)
										  otherButtonTitles:nil];
//	alert.accessibilityLabel = aTitle;
    if (aTag!=NSNotFound) {
        alert.tag = aTag;
    }
	[alert show];
}

+(UIView*)actionSheetShowInViewForViewController:(UIViewController*)a_viewController{
    UIView *l_view = nil;
    if (!(l_view = a_viewController.tabBarController.view)) {
        if (!(l_view = a_viewController.splitViewController.view)) {
            l_view = a_viewController.navigationController.toolbar;
            if (l_view.hidden || !l_view) { // Added check for hidden is it was crashing the app in some cases when the toolbar was not visible and it had been used by a view controller that had been pushed
                l_view = a_viewController.view;
            }
        }
    }
    return l_view;
}

+ (void) showActionSheetWithMessage:(NSString*)aMessage
	   destructiveButtonLabelSuffix:(NSString*)aDestructiveButtonLabelSuffix
                     viewController:(UIViewController*)aViewController
                      barButtonItem:(UIBarButtonItem*)aBarButtonItem
						   delegate:(id<UIActionSheetDelegate>)aDelegate{
	[self showActionSheetWithMessage:aMessage 
		destructiveButtonLabelSuffix:aDestructiveButtonLabelSuffix 
                      viewController:aViewController
                       barButtonItem:aBarButtonItem
							delegate:aDelegate
								 tag:0];
}

+ (void) showActionSheetWithMessage:(NSString*)aMessage 
	   destructiveButtonLabelSuffix:(NSString*)aDestructiveButtonLabelSuffix
                     viewController:(UIViewController*)aViewController
                      barButtonItem:(UIBarButtonItem*)aBarButtonItem
						   delegate:(id<UIActionSheetDelegate>)aDelegate
								tag:(NSInteger)aTag{
	[self showActionSheetWithMessage:aMessage 
			 cancelButtonLabelSuffix:nil 
		destructiveButtonLabelSuffix:aDestructiveButtonLabelSuffix 
								view:[self actionSheetShowInViewForViewController:aViewController]
                       barButtonItem:aBarButtonItem
							delegate:aDelegate
								 tag:aTag];
}

+ (void) showActionSheetWithMessage:(NSString*)aMessage 
			cancelButtonLabelSuffix:(NSString*)aCancelButtonLabelSuffix 
	   destructiveButtonLabelSuffix:(NSString*)aDestructiveButtonLabelSuffix
							   view:(UIView*)aView
                      barButtonItem:(UIBarButtonItem*)aBarButtonItem
						   delegate:(id<UIActionSheetDelegate>)aDelegate
								tag:(NSInteger)aTag{
	UIActionSheet *actionSheet = 
		[[UIActionSheet alloc] initWithTitle:aMessage
									delegate:aDelegate 
						   cancelButtonTitle:[@"No" stringByAppendingString:(aCancelButtonLabelSuffix?[NSString stringWithFormat:@", %@", aCancelButtonLabelSuffix]:@"")]
					  destructiveButtonTitle:[@"Yes, " stringByAppendingString:aDestructiveButtonLabelSuffix]
						   otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
//    NSLog(@"aView: %@", [aView description]);
    if ([IFAUIUtils isIPad] && aBarButtonItem) {
        [actionSheet showFromBarButtonItem:aBarButtonItem animated:YES];
    }else {
        [actionSheet showInView:aView];
    }
	if(aTag!=0){
		actionSheet.tag = aTag;
	}
}

+ (UIBarButtonItem*)barButtonItemForType:(IFABarButtonItemType)a_type target:(id)a_target action:(SEL)a_action {
	UIBarButtonItem *barButtonItem;
	switch (a_type) {
		case IFABarButtonItemTypeCancel:
			barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                          target:a_target action:a_action];
//			barButtonItem.accessibilityLabel = @"Cancel Button";
			break;
		case IFABarButtonItemTypeDone:
			barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:a_target action:a_action];
            [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceForBarButtonItem:barButtonItem
                                                                                              viewController:nil
                                                                                                   important:YES ];
//			barButtonItem.accessibilityLabel = @"Done Button";
			break;
		case IFABarButtonItemTypeDelete:
			barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IFA_Icon_Delete.png"]
                                                             style:UIBarButtonItemStylePlain target:a_target
                                                            action:a_action];
//			barButtonItem.accessibilityLabel = @"Delete Button";
			break;
		case IFABarButtonItemTypeFlexibleSpace:
			barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                          target:a_target action:a_action];
			break;
		case IFABarButtonItemTypeFixedSpace:
			barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                          target:a_target action:a_action];
			barButtonItem.width = 5;
			break;
		case IFABarButtonItemTypeAdd:
			barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                          target:a_target action:a_action];
            barButtonItem.tag = 10000;
//			barButtonItem.accessibilityLabel = @"Add Button";
			break;
		case IFABarButtonItemTypeSelectNone:
		{
			NSString *l_title = [IFAUtils infoPList][@"IFASelectNoneButtonLabel"];
            if (!l_title) {
                l_title = @"Select None";
            }
			barButtonItem = [[UIBarButtonItem alloc] initWithTitle:l_title style:UIBarButtonItemStylePlain
                                                            target:a_target action:a_action];
//			barButtonItem.accessibilityLabel = @"Select None Button";
			break;
		}
		case IFABarButtonItemTypeSelectAll:
		{
			NSString *l_title = @"Select All";
			barButtonItem = [[UIBarButtonItem alloc] initWithTitle:l_title style:UIBarButtonItemStylePlain
                                                            target:a_target action:a_action];
//			barButtonItem.accessibilityLabel = @"Select All Button";
			break;
		}
		case IFABarButtonItemTypePreviousPage:
			barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IFA_Icon_Previous"]
                                                             style:UIBarButtonItemStylePlain target:a_target
                                                            action:a_action];
//			barButtonItem.accessibilityLabel = @"Previous Page Button";
			break;
		case IFABarButtonItemTypeNextPage:
			barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IFA_Icon_Next"]
                                                             style:UIBarButtonItemStylePlain target:a_target
                                                            action:a_action];
//			barButtonItem.accessibilityLabel = @"Next Page Button";
			break;
		case IFABarButtonItemTypeSelectNow:
			barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Now" style:UIBarButtonItemStylePlain
                                                            target:a_target action:a_action];
//			barButtonItem.accessibilityLabel = @"Now Button";
			break;
		case IFABarButtonItemTypeSelectToday:
			barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStylePlain
                                                            target:a_target action:a_action];
//			barButtonItem.accessibilityLabel = @"Today Button";
			break;
		case IFABarButtonItemTypeAction:
			barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                          target:a_target action:a_action];
//			barButtonItem.accessibilityLabel = @"Action Button";
			break;
		case IFABarButtonItemTypeRefresh:
			barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                          target:a_target action:a_action];
//			barButtonItem.accessibilityLabel = @"Refresh Button";
			break;
		case IFABarButtonItemTypeDismiss:
			barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain
                                                            target:a_target action:a_action];
//			barButtonItem.accessibilityLabel = @"Dismiss Button";
			break;
		case IFABarButtonItemTypeBack:
			barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain
                                                            target:a_target action:a_action];
//			barButtonItem.accessibilityLabel = @"Back Button";
			break;
        case IFABarButtonItemTypeInfo:
            barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IFA_Icon_Info"]
                                                             style:UIBarButtonItemStylePlain target:a_target
                                                            action:a_action];
            break;
        case IFABarButtonItemTypeUserLocation:
            barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IFA_Icon_UserLocation"]
                                                             style:UIBarButtonItemStylePlain target:a_target
                                                            action:a_action];
            break;
        case IFABarButtonItemTypeList:
            barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IFA_Icon_List"]
                                                             style:UIBarButtonItemStylePlain target:a_target
                                                            action:a_action];
            break;
		default:
			NSAssert(NO, @"Unexpected button item code: %lu", (unsigned long)a_type);
			break;
	}
    barButtonItem.ifa_type = a_type;
	return barButtonItem;
}

+ (CGPoint)appFrameOrigin{
	return [self appFrame].origin;
}

+ (CGSize)appFrameSize{
	return [self appFrame].size;
}

+ (CGRect)appFrame{
	return [[UIScreen mainScreen] applicationFrame];
}

+ (CGRect)convertToCurrentOrientationForFrame:(CGRect)a_frame{
    return [self isDeviceInLandscapeOrientation] ? CGRectMake(a_frame.origin.y, a_frame.origin.x, a_frame.size.height, a_frame.size.width) : a_frame;
}

+ (CGPoint)screenBoundsOrigin{
	return [self screenBounds].origin;
}

+ (CGSize)screenBoundsSize{
	return [self screenBounds].size;
}

+ (CGSize)screenBoundsSizeForCurrentOrientation{
    CGSize l_screenBoundsSize = [self screenBoundsSize];
    return [self isDeviceInLandscapeOrientation] ? CGSizeMake(l_screenBoundsSize.height, l_screenBoundsSize.width) : l_screenBoundsSize;
}

+ (CGRect)screenBounds{
	return [UIScreen mainScreen].bounds;
}

+ (CGSize)statusBarSize{
	return [self statusBarFrame].size;
}

+ (CGSize)statusBarSizeForCurrentOrientation{
    CGSize l_statusBarSize = [self statusBarSize];
    return [self isDeviceInLandscapeOrientation] ? CGSizeMake(l_statusBarSize.height, l_statusBarSize.width) : l_statusBarSize;
}

+ (CGRect)statusBarFrame{
    return [[UIApplication sharedApplication] statusBarFrame];
}

+(BOOL)isDeviceInLandscapeOrientation{
//    NSLog(@"[UIApplication sharedApplication].statusBarOrientation: %u", [UIApplication sharedApplication].statusBarOrientation);
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

+ (NSString*)stringValueForObject:(id)anObject{
//    NSLog(@"stringValueForObject: %@", [anObject description]);
	if (anObject==nil) {
		return anObject;
	}else if ([anObject isKindOfClass:[NSString class]]) {
		return anObject;
	}else if ([anObject isKindOfClass:[NSDate class]]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
		return [dateFormatter stringFromDate:anObject];
	}else if ([anObject isKindOfClass:[NSManagedObject class]]) {
		return [(NSManagedObject *)anObject ifa_longDisplayValue];
	}else if ([anObject isKindOfClass:[NSSet class]]) {
		if ([anObject count]==0) {
			return @"";
		}else {
			NSString *l_entityName = [((NSManagedObject *) [anObject anyObject]) ifa_entityName];
			NSArray *sortDescriptors = [[IFAPersistenceManager sharedInstance] listSortDescriptorsForEntity:l_entityName];
			NSArray *sortedArray = [[anObject allObjects] sortedArrayUsingDescriptors:sortDescriptors];
			NSMutableString *l_string = [NSMutableString string];
			BOOL l_firstTime = YES;
			for (NSManagedObject *l_managedObject in sortedArray) {
				if (l_firstTime) {
					l_firstTime = NO;
				}else {
					[l_string appendString:@", "];
				}
				[l_string appendString:[l_managedObject ifa_displayValue]];
			}
			return l_string;
		}
	}else {
		NSAssert(NO, @"Unexpected class: %@", [[anObject class] description]);
		return @"***UNKNOWN***";
	}
}

+ (NSString*)stringValueForBoolean:(BOOL)aBoolean{
    return aBoolean ? @"yes" : @"no";
}

+ (NSString*)onOffStringValueForBoolean:(BOOL)aBoolean{
    return aBoolean ? @"on" : @"off";
}

+ (void)showAndHideUserActionConfirmationHudWithText:(NSString*)a_text{
    [self IFA_presentHudViewControllerWithText:a_text];
}

+ (void)showAndHideModeToggleConfirmationHudWithText:(NSString*)a_text on:(BOOL)a_on{
    NSString *l_text = [NSString stringWithFormat: @"%@ %@", a_text, [IFAUIUtils onOffStringValueForBoolean:a_on]];
    [self IFA_presentHudViewControllerWithText:l_text];
}

+(UIViewController *)nonModalHudContainerViewController {
    UIViewController *viewController = nil;
    UIWindow *l_window = [UIApplication sharedApplication].delegate.window;
    if ([l_window.rootViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *l_splitViewController = (UISplitViewController *) l_window.rootViewController;
        UIViewController *l_detailViewController = (l_splitViewController.viewControllers)[1];
        viewController = l_detailViewController;
    } else {
        viewController = l_window.rootViewController;
    };
    return viewController;
}

+(void)traverseHierarchyForView:(UIView *)a_view withBlock:(void (^) (UIView*))a_block{
    [self IFA_traverseHierarchyForView:a_view withBlock:a_block level:0];
}

+(CGFloat)widthForPortraitNumerator:(float)a_portraitNumerator
                portraitDenominator:(float)a_portraitDenominator
                 landscapeNumerator:(float)a_landscapeNumerator
               landscapeDenominator:(float)a_landscapeDenominator
{
    float l_numerator = [IFAUIUtils isDeviceInLandscapeOrientation] ? a_landscapeNumerator : a_portraitNumerator;
    float l_denominator = [IFAUIUtils isDeviceInLandscapeOrientation] ? a_landscapeDenominator : a_portraitDenominator;
    CGFloat l_width = [IFAUIUtils screenBoundsSizeForCurrentOrientation].width * (l_numerator / l_denominator);
    return l_width;
}

+(BOOL)isIPad {
    return UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad;
}

+(BOOL)isIPhoneLandscape {
    return ![self isIPad] && [self isDeviceInLandscapeOrientation];
}

+(NSString*)resourceNameDeviceModifier {
    return [self isIPad] ? @"~ipad" : @"~iphone";
}

+(UIViewAutoresizing)fullAutoresizingMask {
    return UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
}

+(NSString*)menuBarButtonItemImageName {
    NSString *l_imageName = [IFAUtils infoPList][@"IFAMenuButtonImage"];
    if (!l_imageName) {
        l_imageName = @"271-ThreeColumn.png";
    }
    return l_imageName;
}

+(UIImage*)menuBarButtonItemImage {
    if (!c_menuBarButtonItemImage) {
        return [UIImage imageNamed:[self menuBarButtonItemImageName]];
    }
    return c_menuBarButtonItemImage;
}

+(void)dismissSplitViewControllerPopover {
    UIWindow *l_window = [UIApplication sharedApplication].delegate.window;
    UIViewController *l_appRootViewController = l_window.rootViewController;
    if ([l_appRootViewController isKindOfClass:[IFASplitViewController class]]) {
        IFASplitViewController *l_splitViewController = (IFASplitViewController *)l_appRootViewController;
        [l_splitViewController.splitViewControllerPopoverController dismissPopoverAnimated:NO];
    }
}

+(void)setKeyWindowRootViewController:(UIViewController*)a_viewController{
    [self dismissSplitViewControllerPopover];
    [UIApplication sharedApplication].keyWindow.rootViewController = a_viewController;
}

+(void)setKeyWindowRootViewControllerToMainStoryboardInitialViewController {
    [self setKeyWindowRootViewController:[[[IFAApplicationDelegate sharedInstance] storyboard] instantiateInitialViewController]];
}

+(void)adjustImageInsetsForBarButtonItem:(UIBarButtonItem*)a_barButtonItem insetValue:(CGFloat)a_insetValue{
    UIEdgeInsets l_imageInsets = UIEdgeInsetsZero;
    l_imageInsets.top = a_insetValue;
    l_imageInsets.bottom = a_insetValue*-1;
    a_barButtonItem.imageInsets = l_imageInsets;
}

+(UIColor*)colorForInfoPlistKey:(NSString*)a_infoPlistKey{
    UIColor *l_color = nil;
    NSDictionary *l_colorDictionary = [IFAUtils infoPList][a_infoPlistKey];
    if (l_colorDictionary) {
        NSUInteger l_red = [l_colorDictionary[@"red"] unsignedIntValue];
        NSUInteger l_green = [l_colorDictionary[@"green"] unsignedIntValue];
        NSUInteger l_blue = [l_colorDictionary[@"blue"] unsignedIntValue];
        CGFloat l_alpha = [l_colorDictionary[@"alpha"] floatValue];
        l_color = [UIColor ifa_colorWithRed:l_red green:l_green blue:l_blue alpha:l_alpha];
    }
    return l_color;
}

+ (BOOL)isImageWithinSafeMemoryThresholdForSizeInPixels:(CGSize)a_imageSizeInPixels {
    CGFloat l_imageSizeInPixels = a_imageSizeInPixels.width * a_imageSizeInPixels.height;
    BOOL l_ok = l_imageSizeInPixels <= IFAMaximumImageSizeInPixels;
    return l_ok;
}

+ (UIEdgeInsets)tableViewCellDefaultSeparatorInset {
    return UIEdgeInsetsMake(0, 15, 0, 0);
}

+ (void)showServerErrorAlertViewForNetworkReachable:(BOOL)a_networkReachable
                                  alertViewDelegate:(id <UIAlertViewDelegate>)a_alertViewDelegate {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *l_title;
    NSString *l_messageArgument;
    if (a_networkReachable) {
        l_title= @"Server error";
        l_messageArgument = @" Please try again later.";
    }else{
        l_title= @"No Internet access";
        l_messageArgument = @" Please try again when you are back online.";
    }
    NSString *l_message = [NSString stringWithFormat:@"It was not possible to complete the operation.%@", l_messageArgument];
    [IFAUIUtils showAlertWithMessage:l_message title:l_title delegate:a_alertViewDelegate];
}

+ (CGFloat)heightForWidth:(CGFloat)a_width aspectRatio:(CGFloat)a_aspectRatio {
    return a_width / a_aspectRatio;
}

+ (CGFloat)widthForHeight:(CGFloat)a_height aspectRatio:(CGFloat)a_aspectRatio {
    return a_height * a_aspectRatio;
}

+ (BOOL)isKeyboardVisible {
    IFAApplicationDelegate *l_applicationDelegate = (IFAApplicationDelegate *)[UIApplication sharedApplication].delegate;
    return l_applicationDelegate.isKeyboardVisible;
}

+ (CGRect)keyboardFrame {
    IFAApplicationDelegate *l_applicationDelegate = (IFAApplicationDelegate *)[UIApplication sharedApplication].delegate;
    return l_applicationDelegate.keyboardFrame;
}

+(void)appLogWithTitle:(NSString*)a_title
               message:(NSString*)a_message
              location:(CLLocation*)a_location
                 error:(NSError*)a_error
             showAlert:(BOOL)a_showAlert{
//    NSLog(@"%@ - %@", a_title, a_message);
    IFAApplicationLog *dbLogEntry = (IFAApplicationLog *) [[IFAPersistenceManager sharedInstance] instantiate:@"IFAApplicationLog"];
    dbLogEntry.date = [NSDate date];
    dbLogEntry.title = a_title;
    dbLogEntry.message = a_message;
    if (a_location) {
        dbLogEntry.isLocationAware = @(YES);
        dbLogEntry.latitude = @(a_location.coordinate.latitude);
        dbLogEntry.longitude = @(a_location.coordinate.longitude);
        dbLogEntry.horizontalAccuracy = @(a_location.horizontalAccuracy);
    }else{
        dbLogEntry.isLocationAware = @(NO);
    }
    if (a_error) {
        dbLogEntry.isError = @(YES);
        dbLogEntry.errorCode = @([a_error code]);
        dbLogEntry.errorDescription = [a_error localizedDescription];
    }else{
        dbLogEntry.isError = @(NO);
    }
    [[IFAPersistenceManager sharedInstance] save];
    if (a_showAlert) {
        if ([UIApplication sharedApplication].applicationState==UIApplicationStateActive) {
            [IFAUIUtils showAlertWithMessage:a_message title:a_title];
        }else if ([UIApplication sharedApplication].applicationState==UIApplicationStateBackground) {
            UILocalNotification *l_localNotification = [[UILocalNotification alloc] init];
            if (l_localNotification) {
                l_localNotification.alertBody = [NSString stringWithFormat:@"%@: %@", a_title, a_message];
                [[UIApplication sharedApplication] presentLocalNotificationNow:l_localNotification];
            }
        }
    }
}

+(void)appLogWithTitle:(NSString*)a_title message:(NSString*)a_message;{
    [self appLogWithTitle:a_title message:a_message location:nil error:nil showAlert:NO];
}

+ (void) handleUnrecoverableError:(NSError *)anErrorContainer{
    //TODO: are we losing important info here?
    NSLog(@"Unrecoverable error - description: %@", [anErrorContainer localizedDescription]);
    NSLog(@"Unrecoverable error - failure reason: %@", [anErrorContainer localizedFailureReason]);
    NSArray* detailedErrors = [[anErrorContainer userInfo] objectForKey:NSDetailedErrorsKey];
    if(detailedErrors != nil && [detailedErrors count] > 0) {
        for(NSError* detailedError in detailedErrors) {
            NSLog(@"Unrecoverable error - user info from detailed errors: %@", [detailedError userInfo]);
        }
    }else{
        NSLog(@"Unrecoverable error - user info: %@", [anErrorContainer userInfo]);
    }
    NSAssert(NO, @"Unrecoverable Error: %@", [anErrorContainer localizedDescription]);
}

+ (NSError*) newErrorWithCode:(NSInteger)anErrorCode errorMessage:(NSString*)anErrorMessage{
    NSArray *keyArray = @[NSLocalizedDescriptionKey];
    NSArray *objArray = @[anErrorMessage];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    return [[NSError alloc] initWithDomain:IFAErrorDomainCommon code:anErrorCode userInfo:userInfo];
}

+ (NSError*) newErrorContainer{
    NSArray *errors = [NSMutableArray array];
    NSArray *keyArray = @[NSDetailedErrorsKey];
    NSArray *objArray = @[errors];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
    return [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSValidationMultipleErrorsError userInfo:userInfo];
}

+ (NSError*) newErrorContainerWithError:(NSError*)anError{
    NSError *errorContainer = [self newErrorContainer];
    [self addError:anError toContainer:errorContainer];
    return errorContainer;
}

+ (void) addError:(NSError*)anError toContainer:(NSError*)anErrorContainer{
    AssertNotNil(anError);
    AssertNotNil(anErrorContainer);
            AssertTrue([anErrorContainer code]==NSValidationMultipleErrorsError);
    id obj = [[anErrorContainer userInfo] valueForKey:NSDetailedErrorsKey];
    AssertNotNil(obj);
    AssertNotNilAndClass(obj, NSMutableArray);
    NSMutableArray *errors = obj;
    [errors addObject:anError];
}

@end
