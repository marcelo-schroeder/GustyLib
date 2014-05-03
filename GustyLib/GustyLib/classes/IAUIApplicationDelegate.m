//
//  IAUIApplicationDelegate.m
//  Gusty
//
//  Created by Marcelo Schroeder on 21/05/12.
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

@interface IAUIApplicationDelegate ()

@property (nonatomic, strong) id<IAUIAppearanceTheme> p_appearanceTheme;
@property (nonatomic) BOOL p_useDeviceAgnosticMainStoryboard;
@property (nonatomic, strong) GADBannerView *p_gadBannerView;

@end

@implementation IAUIApplicationDelegate


#pragma mark - Private

-(void)m_onKeyboardNotification:(NSNotification*)a_notification{
    
    //    NSLog(@"m_onKeyboardNotification");
    
    if([a_notification.name isEqualToString:UIKeyboardDidShowNotification] || [a_notification.name isEqualToString:UIKeyboardDidHideNotification]) {
        
        self.p_keyboardVisible = [a_notification.name isEqualToString:UIKeyboardDidShowNotification];
        
    }else{
        NSAssert(NO, @"Unexpected notification name: %@", a_notification.name);
    }

    if (self.p_keyboardVisible) {

        NSDictionary *l_userInfo = [a_notification userInfo];
        self.p_keyboardFrame = [[l_userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
    }else{

        self.p_keyboardFrame = CGRectZero;
        
    }
    
}

- (void)m_onAdsSuspendRequest:(NSNotification*)aNotification{
    self.p_adsSuspended = YES;
}

- (void)m_onAdsResumeRequest:(NSNotification*)aNotification{
    self.p_adsSuspended = NO;
}

#pragma mark - Public

// to be overriden by subclasses
-(Class)appearanceThemeClass {
    return nil;
}

// to be overriden by subclasses
-(IAUIColorScheme*)colorScheme {
    return nil;
}

// to be overriden by subclasses
- (NSString*)gadUnitId {
    return nil;
}

// to be overriden by subclasses
-(GADAdMobExtras*)gadExtras {
    return nil;
}

-(GADBannerView*)gadBannerView {
    if (!self.p_gadBannerView) {
        self.p_gadBannerView = [GADBannerView new];
        self.p_gadBannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [[self appearanceTheme] setAppearanceForAdBannerView:self.p_gadBannerView];
    }
    self.p_gadBannerView.adUnitID = [self gadUnitId];
    return self.p_gadBannerView;
}

-(id<IAUIAppearanceTheme>)appearanceTheme {
    Class l_appearanceThemeClass = [self appearanceThemeClass];
    if (!self.p_appearanceTheme || ![self.p_appearanceTheme isMemberOfClass:l_appearanceThemeClass]) {
        self.p_appearanceTheme = [l_appearanceThemeClass new];
    }
    return self.p_appearanceTheme;
}

+(IAUIApplicationDelegate*)sharedInstance {
    return (IAUIApplicationDelegate*)[UIApplication sharedApplication].delegate;
}

// Note on device specific storyboards:
// The "~" (tilde) as a device modifier works for the initial load, but it has issues when view controllers attempt to access
//  the storyboard via self.storyboard. For some reason the device modifier is not taken into consideration in those cases
// By loading the storyboard using the device modifier explicitly in the name avoids any problems.
-(NSString*)storyboardName {
    return [NSString stringWithFormat:@"%@%@", [self storyboardFileName],
                                      self.p_useDeviceAgnosticMainStoryboard ? @"" : [IAUIUtils m_resourceNameDeviceModifier]];
}

- (NSString *)storyboardFileName {
    return @"MainStoryboard";
}

-(NSString*)storyboardInitialViewControllerId {
    return [NSString stringWithFormat:@"%@InitialController", [IAUIUtils m_isIPad]?@"ipad":@"iphone"];
}

-(UIStoryboard*)storyboard {
    return [UIStoryboard storyboardWithName:[self storyboardName] bundle:nil];
}

-(UIViewController*)initialViewController {
    UIStoryboard *l_storyboard = [self storyboard];
    NSString *l_storyboardInitialViewControllerId = [self storyboardInitialViewControllerId];
    UIViewController *l_initialViewController = nil;
    if (l_storyboardInitialViewControllerId) {
        l_initialViewController = [l_storyboard instantiateViewControllerWithIdentifier:l_storyboardInitialViewControllerId];
    }
    if (!l_initialViewController) {
        l_initialViewController = [l_storyboard instantiateInitialViewController];
    }
    return l_initialViewController;
}

-(void)configureWindowRootViewController {
    self.window.rootViewController = [self initialViewController];
}

-(NSString*)formatCrashReportValue:(id)a_value{
    
//    NSLog(@"formatCrashReportValue: %@", [a_value description]);
    
    if (a_value) {
        
        if ([a_value isKindOfClass:[NSDate class]]) {
            
            return [a_value descriptionWithCurrentLocale];
            
        }else{
            
            id l_displayValue = a_value;
            if ([a_value isKindOfClass:[NSManagedObject class]]) {
                if ([a_value isKindOfClass:[S_SystemEntity class]]) {
                    l_displayValue = ((S_SystemEntity*)a_value).systemEntityId;
                }else{
                    l_displayValue = ((NSManagedObject*)a_value).p_stringId;
                }
            }else if ([a_value isKindOfClass:[NSLocale class]]){
                l_displayValue = ((NSLocale*)a_value).localeIdentifier;
            }
            
            // Unformatted string
            NSString *l_unformattedString = [l_displayValue description];
//            NSLog(@"  l_unformattedString: %@", l_unformattedString);
            // Remove new line characters
            NSString *l_formattedString = [l_unformattedString m_stringByRemovingNewLineCharacters];
            // Remove double quotes to avoid issues with displaying the values on the Crashlytics web site
            l_formattedString = [l_formattedString stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
//            NSLog(@"  l_formattedString: %@", l_formattedString);
            return l_formattedString;

        }
        
    }else{
//        NSLog(@"  NIL");
        return @"NIL";
    }
    
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnresolvedMessage"
-(BOOL)configureCrashReportingWithUserInfo:(NSDictionary*)a_userInfo{

//    NSLog(@"configureCrashReportingWithUserInfo: %@", [a_userInfo description]);

    Class l_crashlyticsClass = NSClassFromString(@"Crashlytics");
    if (!l_crashlyticsClass) {
        NSLog(@"Crashlytics not available at runtime. Crash reporting configured skipped.");
        return NO;
    }

    NSLog(@"Configuring crash reporting...");
    
    NSString *l_apiKey = [[IAUtils infoPList] valueForKey:@"IACrashlyticsApiKey"];
    NSAssert(l_apiKey, @"IACrashlyticsApiKey not found");
    
    NSString *l_vendorDeviceId = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    // Configure crash reporting API
//    [Crashlytics startWithAPIKey:l_apiKey];
    [l_crashlyticsClass performSelector:@selector(startWithAPIKey:) withObject:l_apiKey];
//    [Crashlytics setUserIdentifier:l_vendorDeviceId];
    [l_crashlyticsClass performSelector:@selector(setUserIdentifier:) withObject:l_vendorDeviceId];

    // Bundle version
    // Crashlytics should derive this automatically from the app bundle, but it is not at the moment. I'm adding this info here so it does not get lost.
    NSString *l_bundleVersion = [IAUtils infoPList][@"CFBundleVersion"];
//    [Crashlytics setObjectValue:l_bundleVersion forKey:@"IA_bundle_version"];
    [l_crashlyticsClass performSelector:@selector(setObjectValue:forKey:) withObject:l_bundleVersion withObject:@"IA_bundle_version"];

    // Locale info
//    [Crashlytics setObjectValue:[self m_formatCrashReportValue:l_vendorDeviceId] forKey:@"IA_vendor_Device_Id"];
    [l_crashlyticsClass performSelector:@selector(setObjectValue:forKey:) withObject:[self formatCrashReportValue:l_vendorDeviceId] withObject:@"IA_vendor_Device_Id"];
//    [Crashlytics setObjectValue:[self formatCrashReportValue:[NSLocale systemLocale]] forKey:@"IA_system_Locale"];
    [l_crashlyticsClass performSelector:@selector(setObjectValue:forKey:) withObject:[self formatCrashReportValue:[NSLocale systemLocale]] withObject:@"IA_system_Locale"];
//    [Crashlytics setObjectValue:[self formatCrashReportValue:[NSLocale currentLocale]] forKey:@"IA_current_Locale"];
    [l_crashlyticsClass performSelector:@selector(setObjectValue:forKey:) withObject:[self formatCrashReportValue:[NSLocale currentLocale]] withObject:@"IA_current_Locale"];
//    [Crashlytics setObjectValue:[self formatCrashReportValue:[NSLocale preferredLanguages]] forKey:@"IA_preferred_Languages"];
    [l_crashlyticsClass performSelector:@selector(setObjectValue:forKey:) withObject:[self formatCrashReportValue:[NSLocale preferredLanguages]] withObject:@"IA_preferred_Languages"];

    // User info
    for (NSString *l_key in a_userInfo.allKeys) {
//        [Crashlytics setObjectValue:a_userInfo[l_key] forKey:l_key];
        [l_crashlyticsClass performSelector:@selector(setObjectValue:forKey:) withObject:a_userInfo[l_key] withObject:l_key];
    }
    
    NSLog(@"Crash reporting configured");

    return YES;
    
}
#pragma clang diagnostic pop

-(void)configureAnalytics {

    NSLog(@"Configuring analytics...");
    
    NSString *l_apiKey = [[IAUtils infoPList] valueForKey:@"IAAnalyticsApiKey"];
    NSAssert(l_apiKey, @"IAAnalyticsApiKey not found");

    [Flurry startSession:l_apiKey];

    NSLog(@"Analytics configured...");
    
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    // Save some info plist settings
    self.p_useDeviceAgnosticMainStoryboard = [[[IAUtils infoPList] objectForKey:@"IAUseDeviceAgnosticMainStoryboard"] boolValue];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(m_onKeyboardNotification:) 
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(m_onKeyboardNotification:) 
                                                 name:UIKeyboardDidHideNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onAdsSuspendRequest:)
                                                 name:IA_NOTIFICATION_ADS_SUSPEND_REQUEST
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onAdsResumeRequest:)
                                                 name:IA_NOTIFICATION_ADS_RESUME_REQUEST
                                               object:nil];

    // Configure the app's window
    if (!self.p_skipWindowSetup) {
        self.window = [[UIWindow alloc] initWithFrame:[IAUIUtils screenBounds]];
        [self.window makeKeyAndVisible];
    }

    // Make sure to initialise the appearance theme
    [self appearanceTheme];

    // Apply appearance using the appearance manager
    [[IAUIAppearanceThemeManager sharedInstance] applyAppearanceTheme];

    // Configure the window's root view controller
    if (!self.p_skipWindowSetup && !self.p_skipWindowRootViewControllerSetup) {

        // Configure the window's root view controller
        [self configureWindowRootViewController];

    }
    
    // Configure help
    [IAHelpManager sharedInstance].p_helpEnabled = [[[IAUtils infoPList] objectForKey:@"IAHelpEnabled"] boolValue];
    
    return YES;
	
}

/*
 -(void)applicationWillResignActive:(UIApplication *)application{
 NSLog(@" ");
 //    [IAUtils appLogWithTitle:@"Life Cycle Event" message:@"applicationWillResignActive"];
 NSLog(@"applicationWillResignActive");
 NSLog(@"applicationState: %u", application.applicationState);
 NSLog(@" ");
 }
 */

/*
 -(void)applicationDidBecomeActive:(UIApplication *)application{
 NSLog(@" ");
 //    [IAUtils appLogWithTitle:@"Life Cycle Event" message:@"applicationDidBecomeActive"];
 NSLog(@"applicationDidBecomeActive");
 NSLog(@"applicationState: %u", application.applicationState);
 NSLog(@" ");
 }
 */

/*
-(void)applicationDidEnterBackground:(UIApplication *)application{
    NSLog(@" ");
    [IAUtils appLogWithTitle:@"Life Cycle Event 1/3" message:@"applicationDidEnterBackground"];
    [IAUtils appLogWithTitle:@"Life Cycle Event 2/3" message:[NSString stringWithFormat:@"applicationState: %u", application.applicationState]];
    [IAUtils appLogWithTitle:@"Life Cycle Event 3/3" message:[NSString stringWithFormat:@"background time remaining: %f", [UIApplication sharedApplication].backgroundTimeRemaining]];
    NSLog(@" ");
}
 */

/*
-(void)applicationWillEnterForeground:(UIApplication *)application{
    NSLog(@" ");
    [IAUtils appLogWithTitle:@"Life Cycle Event 1/3" message:@"applicationWillEnterForeground"];
    [IAUtils appLogWithTitle:@"Life Cycle Event 2/3" message:[NSString stringWithFormat:@"applicationState: %u", application.applicationState]];
    [IAUtils appLogWithTitle:@"Life Cycle Event 3/3" message:[NSString stringWithFormat:@"background time remaining: %f", [UIApplication sharedApplication].backgroundTimeRemaining]];
    NSLog(@" ");
}
 */

-(void)applicationWillTerminate:(UIApplication *)application{

//    NSLog(@" ");
//    [IAUtils appLogWithTitle:@"Life Cycle Event 1/3" message:@"applicationWillTerminate"];
//    [IAUtils appLogWithTitle:@"Life Cycle Event 2/3" message:[NSString stringWithFormat:@"applicationState: %u", application.applicationState]];
//    [IAUtils appLogWithTitle:@"Life Cycle Event 3/3" message:[NSString stringWithFormat:@"background time remaining: %f", [UIApplication sharedApplication].backgroundTimeRemaining]];
//    NSLog(@" ");
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IA_NOTIFICATION_ADS_SUSPEND_REQUEST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IA_NOTIFICATION_ADS_RESUME_REQUEST object:nil];

}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
	//TODO: review this behaviour - are we making the most of NSCache here? (i.e. by removing everything from the cache)
	//	I did a lot of testing with IAPurgeableObject and always all entries would get evicted, even with setEvictsObjectsWithDiscardedContent true
	//  And removing the removeAllObjects lines below does not do anything if a memory warning is received (probably because it's hard to test
	//	under normal memory circumstances)
    //	NSLog(@"*** applicationDidReceiveMemoryWarning ***");
	[[IADynamicCache sharedInstance] removeAllObjects];
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
//    NSLog(@"didChangeAuthorizationStatus: %u", status);
    NSNotification *notification = [NSNotification notificationWithName:IA_NOTIFICATION_LOCATION_AUTHORIZATION_STATUS_CHANGE object:nil userInfo:@{@"status":@(status)}];
    [[NSNotificationQueue defaultQueue] enqueueNotification:notification
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];
}

@end
