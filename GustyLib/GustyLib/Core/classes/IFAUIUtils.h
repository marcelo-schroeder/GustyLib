//
//  IFAUIUtils.h
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

// Size limit for UIWebView to be able to display images in iOS 7 and above.
// 5Mb seems to be limit for UIWebView to be able to display images in iOS 7 (i.e. no devices have less than 256Mb of RAM)
// Based on the "Know iOS Resource Limits" section at https://developer.apple.com/library/safari/documentation/AppleApplications/Reference/SafariWebContent/CreatingContentforSafarioniPhone/CreatingContentforSafarioniPhone.html
// JPEG's have a higher limit, but I have not taken that into consideration yet.
static const CGFloat IFAMaximumImageSizeInPixels =  5 * 1024 * 1024;

@class IFAMenuViewController;
@class IFA_MBProgressHUD;

@interface IFAUIUtils : NSObject {

}

+ (void) showAlertWithMessage:(NSString*)aMessage title:(NSString*)aTitle;
+ (void) showAlertWithMessage:(NSString*)aMessage title:(NSString*)aTitle buttonLabel:(NSString*)aButtonLabel;
+ (void) showAlertWithMessage:(NSString*)aMessage title:(NSString*)aTitle delegate:(id)aDelegate;
+ (void) showAlertWithMessage:(NSString*)aMessage title:(NSString*)aTitle delegate:(id)aDelegate buttonLabel:(NSString*)aButtonLabel;
+ (void) showAlertWithMessage:(NSString*)aMessage title:(NSString*)aTitle delegate:(id)aDelegate buttonLabel:(NSString*)aButtonLabel tag:(NSInteger)aTag;

+(UIView*)actionSheetShowInViewForViewController:(UIViewController*)a_viewController;
+ (void) showActionSheetWithMessage:(NSString*)aMessage
	   destructiveButtonLabelSuffix:(NSString*)aDestructiveButtonLabelSuffix
                     viewController:(UIViewController*)aViewController
                      barButtonItem:(UIBarButtonItem*)aBarButtonItem
						   delegate:(id<UIActionSheetDelegate>)aDelegate;

+ (void) showActionSheetWithMessage:(NSString*)aMessage 
	   destructiveButtonLabelSuffix:(NSString*)aDestructiveButtonLabelSuffix
                     viewController:(UIViewController*)aViewController
                      barButtonItem:(UIBarButtonItem*)aBarButtonItem
						   delegate:(id<UIActionSheetDelegate>)aDelegate
								tag:(NSInteger)aTag;

+ (void) showActionSheetWithMessage:(NSString*)aMessage 
			cancelButtonLabelSuffix:(NSString*)aCancelButtonLabelSuffix 
	   destructiveButtonLabelSuffix:(NSString*)aDestructiveButtonLabelSuffix
							   view:(UIView*)aView
                      barButtonItem:(UIBarButtonItem*)aBarButtonItem
						   delegate:(id<UIActionSheetDelegate>)aDelegate
								tag:(NSInteger)aTag;

+(NSString*)helpTargetIdForName:(NSString*)a_name;
+ (UIBarButtonItem*) barButtonItemForType:(NSUInteger)aType target:(id)aTarget action:(SEL)anAction;

+(BOOL)isDeviceInLandscapeOrientation;

+ (CGPoint)appFrameOrigin;
+ (CGSize)appFrameSize;
+ (CGRect)appFrame;

+ (CGRect)convertToCurrentOrientationForFrame:(CGRect)a_frame;

+ (CGPoint)screenBoundsOrigin;
+ (CGSize)screenBoundsSize;
+ (CGSize)screenBoundsSizeForCurrentOrientation;
+ (CGRect)screenBounds;

+ (CGSize)statusBarSize;
+ (CGSize)statusBarSizeForCurrentOrientation;
+ (CGRect)statusBarFrame;

+ (NSString*)stringValueForObject:(id)anObject;
+ (NSString*)stringValueForBoolean:(BOOL)aBoolean;
+ (NSString*)onOffStringValueForBoolean:(BOOL)aBoolean;

+(IFA_MBProgressHUD *)showHudWithText:(NSString*)a_text;
+(IFA_MBProgressHUD *)showHudWithText:(NSString*)a_text inView:(UIView*)a_view animated:(BOOL)a_animated;
+(void)hideHud:(IFA_MBProgressHUD *)a_hud;
+(void)hideHud:(IFA_MBProgressHUD *)a_hud animated:(BOOL)a_animated;
+ (void)showAndHideUserActionConfirmationHudWithText:(NSString*)a_text;
+ (void)showAndHideModeToggleConfirmationHudWithText:(NSString*)a_text on:(BOOL)a_on;
+(UIView*)nonModalHudContainerView;

+(void)traverseHierarchyForView:(UIView *)a_view withBlock:(void (^) (UIView*))a_block;

+(CGFloat)widthForPortraitNumerator:(float)a_portraitNumerator
                portraitDenominator:(float)a_portraitDenominator
                 landscapeNumerator:(float)a_landscapeNumerator
               landscapeDenominator:(float)a_landscapeDenominator;

+(BOOL)isIPad;
+(BOOL)isIPhoneLandscape;
+(NSString*)resourceNameDeviceModifier;
+(UIViewAutoresizing)fullAutoresizingMask;
+(NSString*)menuBarButtonItemImageName;
+(UIImage*)menuBarButtonItemImage;

+(void)dismissSplitViewControllerPopover;
+(void)setKeyWindowRootViewController:(UIViewController*)a_viewController;
+(void)setKeyWindowRootViewControllerToMainStoryboardInitialViewController;

+(void)adjustImageInsetsForBarButtonItem:(UIBarButtonItem*)a_barButtonItem insetValue:(CGFloat)a_insetValue;

+(UIColor*)colorForInfoPlistKey:(NSString*)a_infoPlistKey;

+ (BOOL)isImageWithinSafeMemoryThresholdForSizeInPixels:(CGSize)a_imageSizeInPixels;

// mimic iOS default separator inset
+ (UIEdgeInsets)tableViewCellDefaultSeparatorInset;

+ (void)showServerErrorAlertViewForNetworkReachable:(BOOL)a_networkReachable
                                  alertViewDelegate:(id <UIAlertViewDelegate>)a_alertViewDelegate;

/**
* Calculates height given width and aspect ratio.
* @param a_width Width to calculate height for.
* @param a_aspectRatio Aspect ratio (width divided by height)
*/
+ (CGFloat)heightForWidth:(CGFloat)a_width aspectRatio:(CGFloat)a_aspectRatio;

/**
* Calculates width given height and aspect ratio.
* @param a_height Height to calculate width for.
* @param a_aspectRatio Aspect ratio (width divided by height)
*/
+ (CGFloat)widthForHeight:(CGFloat)a_height aspectRatio:(CGFloat)a_aspectRatio;

+ (BOOL)isKeyboardVisible;
+ (CGRect)keyboardFrame;

@end
