//
//  IAUIApplicationDelegate.h
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

@protocol IAUIAppearanceTheme;
@class IAUIColorScheme;
@class GADAdMobExtras;
@class GADBannerView;

@interface IAUIApplicationDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic) UIViewController *p_semiModalViewController;
@property (nonatomic) UIInterfaceOrientation p_semiModalInterfaceOrientation;
@property (nonatomic) UIViewController *p_popoverControllerPresenter;
@property (nonatomic, getter = p_isKeyboardVisible) BOOL p_keyboardVisible;
@property (nonatomic) BOOL p_skipWindowSetup;
@property (nonatomic) BOOL p_skipWindowRootViewControllerSetup;
@property (nonatomic, readonly) BOOL p_useDeviceAgnosticMainStoryboard;
@property (nonatomic) BOOL p_adsSuspended;
@property (nonatomic, weak) UIViewController *p_adsOwnerViewController;

@property(nonatomic) CGRect p_keyboardFrame;

// to be overriden by subclasses
-(Class)m_appearanceThemeClass;
-(IAUIColorScheme*)m_colorScheme;
-(NSString*)m_gadUnitId;
-(GADAdMobExtras*)m_gadExtras;

-(GADBannerView*)m_gadBannerView;

-(id<IAUIAppearanceTheme>)m_appearanceTheme;

-(NSString*)m_storyboardName;

- (NSString *)m_storyboardFileName;

-(NSString*)m_storyboardInitialViewControllerId;
-(UIStoryboard*)m_storyboard;
-(UIViewController*)m_initialViewController;
-(void)m_configureWindowRootViewController;

-(NSString*)m_formatCrashReportValue:(id)a_value;
-(void)m_configureCrashReportingWithUserInfo:(NSDictionary*)a_userInfo;
-(void)m_configureAnalytics;

+(IAUIApplicationDelegate*)m_instance;

@end
