//
//  IFATabBarController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 18/05/11.
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

#import "GustyLibCore.h"

#ifdef IFA_AVAILABLE_Help
#import "GustyLibHelp.h"
#endif

@interface IFATabBarController ()
@property(nonatomic, strong) UIViewController *IFA_previousViewController;
@end

@implementation IFATabBarController

#pragma mark - Private

-(void)IFA_selectViewController:(UIViewController*)a_viewController{
//    NSLog(@"going to select tab view controller...");
    //continuehere
    self.selectedViewController = a_viewController;
    [self tabBarController:self didSelectViewController:self.selectedViewController];
//    NSLog(@"tab view controller selected");
}

- (void)onContextSwitchRequestGrantedNotification:(NSNotification*)aNotification{
//    NSLog(@"IFANotificationContextSwitchRequestGranted received by %@", [self description]);
    [self IFA_selectViewController:aNotification.object];
}

/*
-(void)IFA_releaseMemory {
//    NSLog(@"IFA_releaseMemory in %@", [self description]);
    for (UIViewController *l_viewController in self.viewControllers) {
//        NSLog(@"   inspecting view controller: %@", [l_viewController description]);
        if (l_viewController!=self.selectedViewController) {
//            NSLog(@"      not selected - releasing view...");
            [l_viewController ifa_releaseView];
        }
    }
}
*/

/*
-(void)ifa_onApplicationDidEnterBackgroundNotification:(NSNotification *)aNotification{
    [super ifa_onApplicationDidEnterBackgroundNotification:aNotification];
//    [self IFA_releaseMemory];
}
*/

#pragma mark - UITabBarControllerDelegate

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{

    //    NSLog(@"shouldSelectViewController: %@", [viewController description]);

#ifdef IFA_AVAILABLE_Help
    // Check if we are in help mode first
    if ([IFAHelpManager sharedInstance].helpMode) {
        NSUInteger l_selectedViewControllerIndex = [self.viewControllers indexOfObject:viewController];
        UITabBarItem *l_tabBarItem = ((UITabBarItem*) (tabBarController.tabBar.items)[l_selectedViewControllerIndex]);
        NSString *l_title = l_tabBarItem.title;
        if (!l_title && [viewController isKindOfClass:[UINavigationController class]]) {
            // If a title is not available (e.g. the tab bar item is a system item), then it will attempt to derive the title from the navigation controller's root view controller
            UINavigationController *l_navigationController = (UINavigationController*)viewController;
            UIViewController *l_rootViewController = (l_navigationController.viewControllers)[0];
            l_title = l_rootViewController.title;
        }
        l_title = [NSString stringWithFormat:@"%@ Tab", l_title];
        [[IFAHelpManager sharedInstance] helpRequestedForTabBarItemIndex:l_selectedViewControllerIndex
                                                           helpTargetId:l_tabBarItem.helpTargetId title:l_title];
        return NO;
    }
#endif

    BOOL l_shouldSelectViewController = YES;
    if ([self.selectedViewController conformsToProtocol:@protocol(IFAContextSwitchTarget)] && ((id <IFAContextSwitchTarget>) self.selectedViewController).contextSwitchRequestRequired) {
        NSNotification *l_notification = [NSNotification notificationWithName:IFANotificationContextSwitchRequest
                                                                       object:viewController userInfo:nil];
        [[NSNotificationQueue defaultQueue] enqueueNotification:l_notification
                                                   postingStyle:NSPostASAP
                                                   coalesceMask:NSNotificationNoCoalescing
                                                       forModes:nil];
//        NSLog(@" ");
//        NSLog(@"IFANotificationContextSwitchRequest sent by %@", [self description]);
        l_shouldSelectViewController = NO;
    }
    return l_shouldSelectViewController;

}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
//    NSLog(@"didSelectViewController: %@", [viewController description]);
//    if (v_previousViewController && [v_previousViewController isKindOfClass:[UINavigationController class]]) {
//        UINavigationController *l_navigationController = (UINavigationController*)viewController;
//        NSLog(@"[l_navigationController.viewControllers count]: %u", [l_navigationController.viewControllers count]);
//        NSLog(@"[l_navigationController.topViewController description]: %@", [l_navigationController.topViewController description]);
//    }
    if (self.IFA_previousViewController && [self.IFA_previousViewController isKindOfClass:[UINavigationController class]]) {
        // If the previously selected view controller is a navigation controller then make sure to pop to its root view controller
        //  in order to minimise memory requirements and avoid complications with entities being changed somewhere else (for now)
        UINavigationController *l_navigationController = (UINavigationController*) self.IFA_previousViewController;
//        NSLog(@"before...");
//        NSLog(@"  [l_navigationController.viewControllers count]: %u", [l_navigationController.viewControllers count]);
//        NSLog(@"  [l_navigationController.topViewController description]: %@", [l_navigationController.topViewController description]);
        [l_navigationController popToRootViewControllerAnimated:NO];
//        NSLog(@"...after");
//        NSLog(@"[l_navigationController.viewControllers count]: %u", [l_navigationController.viewControllers count]);
//        NSLog(@"[l_navigationController.topViewController description]: %@", [l_navigationController.topViewController description]);
    }
    self.IFA_previousViewController = viewController;
    [IFAUIUtils postNavigationEventNotification];
}

#pragma mark - Overrides

-(id)initWithCoder:(NSCoder *)aDecoder{

    self = [super initWithCoder:aDecoder];

    self.customizableViewControllers = nil;
    self.delegate = self;
    self.IFA_previousViewController = (self.viewControllers)[0];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onContextSwitchRequestGrantedNotification:)
                                                 name:IFANotificationContextSwitchRequestGranted
                                               object:nil];

    return self;
}

-(void)dealloc{
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationContextSwitchRequestGranted
                                                  object:nil];

}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self ifa_viewDidLoad];
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return [self ifa_shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return [self ifa_supportedInterfaceOrientations];
}

/*
-(void)didReceiveMemoryWarning{
//    NSLog(@"didReceiveMemoryWarning in %@", [self description]);
    [super didReceiveMemoryWarning];
    [self IFA_releaseMemory];
}
*/

@end
