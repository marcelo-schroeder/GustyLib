//
//  IFAApplicationDelegate.h
//  Gusty
//
//  Created by Marcelo Schroeder on 30/08/11.
//  Copyright 2011 InfoAccent Pty Limited. All rights reserved.
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

#import <CoreLocation/CoreLocation.h>

@protocol IFAAppearanceTheme;
@class IFAColorScheme;
@class GADAdMobExtras;
@class GADBannerView;

@interface IFAApplicationDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic) UIViewController *semiModalViewController;
@property (nonatomic) UIInterfaceOrientation semiModalInterfaceOrientation;
@property (nonatomic) UIViewController *popoverControllerPresenter;
@property (nonatomic, getter = isKeyboardVisible) BOOL keyboardVisible;
@property (nonatomic) BOOL skipWindowSetup;
@property (nonatomic) BOOL skipWindowRootViewControllerSetup;
@property (nonatomic, readonly) BOOL useDeviceAgnosticMainStoryboard;
@property (nonatomic) BOOL adsSuspended;
@property (nonatomic, weak) UIViewController *adsOwnerViewController;

@property(nonatomic) CGRect keyboardFrame;

// to be overriden by subclasses
-(Class)appearanceThemeClass;
-(IFAColorScheme *)colorScheme;
-(NSString*)gadUnitId;
-(GADAdMobExtras*)gadExtras;

-(GADBannerView*)gadBannerView;

-(id<IFAAppearanceTheme>)appearanceTheme;

-(NSString*)storyboardName;

- (NSString *)storyboardFileName;

-(NSString*)storyboardInitialViewControllerId;
-(UIStoryboard*)storyboard;
-(UIViewController*)initialViewController;
-(void)configureWindowRootViewController;

-(NSString*)formatCrashReportValue:(id)a_value;

/**
* Configure crash reporting using the Crashlytics framework, if available at runtime.
*
* @param a_userInfo User info dictionary containing key/value pairs that are displayed in the 'Keys' section of a crash report on www.crashlytics.com.
*
* @returns YES if it succeeded configuring crash reporting. NO if it has failed (e.g. Crashlytics framework not available at runtime).
*/
-(BOOL)configureCrashReportingWithUserInfo:(NSDictionary*)a_userInfo;

-(void)configureAnalytics;

+(IFAApplicationDelegate *)sharedInstance;

@end
