//
//  IFAApplicationDelegate.m
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

#import "GustyLibCoreUI.h"

@interface IFAApplicationDelegate ()

@property (nonatomic, strong) id<IFAAppearanceTheme> IFA_appearanceTheme;
@property (nonatomic) BOOL useDeviceAgnosticMainStoryboard;

@end

@implementation IFAApplicationDelegate


#pragma mark - Private

-(void)IFA_onKeyboardNotification:(NSNotification*)a_notification{
    
    //    NSLog(@"m_onKeyboardNotification");
    
    if([a_notification.name isEqualToString:UIKeyboardDidShowNotification] || [a_notification.name isEqualToString:UIKeyboardDidHideNotification]) {
        
        self.keyboardVisible = [a_notification.name isEqualToString:UIKeyboardDidShowNotification];
        
    }else{
        NSAssert(NO, @"Unexpected notification name: %@", a_notification.name);
    }

    if (self.keyboardVisible) {

        NSDictionary *l_userInfo = [a_notification userInfo];
        self.keyboardFrame = [l_userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
    }else{

        self.keyboardFrame = CGRectZero;
        
    }
    
}

#pragma mark - Public

// to be overriden by subclasses
-(Class)appearanceThemeClass {
    return [IFADefaultAppearanceTheme class];
}

// to be overriden by subclasses
-(IFAColorScheme *)colorScheme {
    return nil;
}

-(id<IFAAppearanceTheme>)appearanceTheme {
    Class l_appearanceThemeClass = [self appearanceThemeClass];
    if (!self.IFA_appearanceTheme || ![self.IFA_appearanceTheme isMemberOfClass:l_appearanceThemeClass]) {
        self.IFA_appearanceTheme = (id <IFAAppearanceTheme>) [l_appearanceThemeClass new];
    }
    return self.IFA_appearanceTheme;
}

+(IFAApplicationDelegate *)sharedInstance {
    id applicationDelegate = [UIApplication sharedApplication].delegate;
    if ([applicationDelegate isKindOfClass:[IFAApplicationDelegate class]]) {
        return (IFAApplicationDelegate *) applicationDelegate;
    }else{
        return nil;
    }
}

// Note on device specific storyboards:
// The "~" (tilde) as a device modifier works for the initial load, but it has issues when view controllers attempt to access
//  the storyboard via self.storyboard. For some reason the device modifier is not taken into consideration in those cases
// By loading the storyboard using the device modifier explicitly in the name avoids any problems.
-(NSString*)storyboardName {
    return [NSString stringWithFormat:@"%@%@", [self storyboardFileName],
                                      self.useDeviceAgnosticMainStoryboard ? @"" : [IFAUIUtils resourceNameDeviceModifier]];
}

- (NSString *)storyboardFileName {
    return @"MainStoryboard";
}

-(NSString*)storyboardInitialViewControllerId {
    return [NSString stringWithFormat:@"%@InitialController", [IFAUIUtils isIPad]?@"ipad":@"iphone"];
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

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    // Save some info plist settings
    self.useDeviceAgnosticMainStoryboard = [[IFAUtils infoPList][@"IFAUseDeviceAgnosticMainStoryboard"] boolValue];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(IFA_onKeyboardNotification:)
                                                 name:UIKeyboardDidShowNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(IFA_onKeyboardNotification:)
                                                 name:UIKeyboardDidHideNotification 
                                               object:nil];

    // Configure the app's window
    if (!self.skipWindowSetup) {
        self.window = [[UIWindow alloc] initWithFrame:[IFAUIUtils screenBounds]];
        [self.window makeKeyAndVisible];
    }

    // Make sure to initialise the appearance theme
    [self appearanceTheme];

    // Apply appearance using the appearance manager
    [[IFAAppearanceThemeManager sharedInstance] applyAppearanceTheme];

    // Configure the window's root view controller
    if (!self.skipWindowSetup && !self.skipWindowRootViewControllerSetup) {

        // Configure the window's root view controller
        [self configureWindowRootViewController];

    }

    return YES;
	
}

/*
 -(void)applicationWillResignActive:(UIApplication *)application{
 NSLog(@" ");
 //    [IFAUtils appLogWithTitle:@"Life Cycle Event" message:@"applicationWillResignActive"];
 NSLog(@"applicationWillResignActive");
 NSLog(@"applicationState: %u", application.applicationState);
 NSLog(@" ");
 }
 */

/*
 -(void)applicationDidBecomeActive:(UIApplication *)application{
 NSLog(@" ");
 //    [IFAUtils appLogWithTitle:@"Life Cycle Event" message:@"applicationDidBecomeActive"];
 NSLog(@"applicationDidBecomeActive");
 NSLog(@"applicationState: %u", application.applicationState);
 NSLog(@" ");
 }
 */

/*
-(void)applicationDidEnterBackground:(UIApplication *)application{
    NSLog(@" ");
    [IFAUtils appLogWithTitle:@"Life Cycle Event 1/3" message:@"applicationDidEnterBackground"];
    [IFAUtils appLogWithTitle:@"Life Cycle Event 2/3" message:[NSString stringWithFormat:@"applicationState: %u", application.applicationState]];
    [IFAUtils appLogWithTitle:@"Life Cycle Event 3/3" message:[NSString stringWithFormat:@"background time remaining: %f", [UIApplication sharedApplication].backgroundTimeRemaining]];
    NSLog(@" ");
}
 */

/*
-(void)applicationWillEnterForeground:(UIApplication *)application{
    NSLog(@" ");
    [IFAUtils appLogWithTitle:@"Life Cycle Event 1/3" message:@"applicationWillEnterForeground"];
    [IFAUtils appLogWithTitle:@"Life Cycle Event 2/3" message:[NSString stringWithFormat:@"applicationState: %u", application.applicationState]];
    [IFAUtils appLogWithTitle:@"Life Cycle Event 3/3" message:[NSString stringWithFormat:@"background time remaining: %f", [UIApplication sharedApplication].backgroundTimeRemaining]];
    NSLog(@" ");
}
 */

-(void)applicationWillTerminate:(UIApplication *)application{

//    NSLog(@" ");
//    [IFAUtils appLogWithTitle:@"Life Cycle Event 1/3" message:@"applicationWillTerminate"];
//    [IFAUtils appLogWithTitle:@"Life Cycle Event 2/3" message:[NSString stringWithFormat:@"applicationState: %u", application.applicationState]];
//    [IFAUtils appLogWithTitle:@"Life Cycle Event 3/3" message:[NSString stringWithFormat:@"background time remaining: %f", [UIApplication sharedApplication].backgroundTimeRemaining]];
//    NSLog(@" ");
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
	//TODO: review this behaviour - are we making the most of NSCache here? (i.e. by removing everything from the cache)
	//	I did a lot of testing with IFAPurgeableObject and always all entries would get evicted, even with setEvictsObjectsWithDiscardedContent true
	//  And removing the removeAllObjects lines below does not do anything if a memory warning is received (probably because it's hard to test
	//	under normal memory circumstances)
    //	NSLog(@"*** applicationDidReceiveMemoryWarning ***");
	[[IFADynamicCache sharedInstance] removeAllObjects];
}

@end
