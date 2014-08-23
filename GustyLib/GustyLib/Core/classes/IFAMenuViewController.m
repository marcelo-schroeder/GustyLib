//
//  IFAMenuViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 11/05/12.
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

@interface IFAMenuViewController ()

@property (nonatomic, strong) UIViewController *IFA_previousViewController;

@end

@implementation IFAMenuViewController {
    @private
    
}

#pragma mark - Private

- (void)oncontextSwitchRequestGrantedNotification:(NSNotification*)aNotification{
//    NSLog(@"IFANotificationContextSwitchRequestGranted received by %@", [self description]);
    [self commitSelectionForIndexPath:aNotification.object];
}

- (void)oncontextSwitchRequestDeniedNotification:(NSNotification*)aNotification{
//    NSLog(@"IFANotificationContextSwitchRequestDenied received by %@", [self description]);
    [self restoreCurrentSelection];
}

-(void)onSlidingViewTopDidResetNotification:(NSNotification*)a_notification{
    [[self firstResponder] resignFirstResponder];
}

#pragma mark - Public

-(void)restoreCurrentSelection {

    [self highlightCurrentSelection];
    
    // Dismiss the popover controller if a split view controller is used
    [self ifa_dismissMenuPopoverController];
    
}

-(void)highlightCurrentSelection {
//    NSLog(@"t: %@, p: %@, = %u", [self.tableView.indexPathForSelectedRow description], [self.selectedIndexPath description], [self.tableView.indexPathForSelectedRow isEqual:self.selectedIndexPath]);
    [self.tableView selectRowAtIndexPath:self.selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

-(UIViewController*)newViewControllerForIndexPath:(NSIndexPath*)a_indexPath{
    UITableViewCell *l_cell = [self tableView:self.tableView cellForRowAtIndexPath:a_indexPath];
    BOOL l_useDeviceAgnosticMainStoryboard = [IFAApplicationDelegate sharedInstance].useDeviceAgnosticMainStoryboard;
    UIStoryboard *l_storyboard = l_useDeviceAgnosticMainStoryboard ? self.storyboard : [self ifa_commonStoryboard];
    UIViewController *l_viewController = [l_storyboard instantiateViewControllerWithIdentifier:l_cell.reuseIdentifier];
    if ((self.splitViewController || self.slidingViewController) && ![l_viewController isKindOfClass:[UINavigationController class]]) {
        // Automatically add a navigation controller as the parent
        l_viewController = [[[[self ifa_appearanceTheme] navigationControllerClass] alloc] initWithRootViewController:l_viewController];
    }
    return l_viewController;
}

-(UIResponder *)firstResponder {
    return nil;
}

-(UIViewController*)viewControllerForIndexPath:(NSIndexPath*)a_indexPath{
    UIViewController *l_viewController = (self.indexPathToViewControllerDictionary)[a_indexPath];
    if (l_viewController) { // A view controller is cached
        //        NSLog(@"   view controller is cached: %@", [l_viewController description]);
        // Reset view controller's state
        [l_viewController ifa_reset];
    }else{
        // Configure a new view controller
        l_viewController = [self newViewControllerForIndexPath:a_indexPath];
        l_viewController.ifa_presenter = self;
        (self.indexPathToViewControllerDictionary)[a_indexPath] = l_viewController;
        //        NSLog(@"   indexPathToViewControllerDictionary: %@", [self.indexPathToViewControllerDictionary description]);
    }
    return l_viewController;
}

-(void)commitSelectionForIndexPath:(NSIndexPath*)a_indexPath{
    
    //    NSLog(@"commitSelectionForIndexPath: %@", [a_indexPath description]);
    
    UIViewController *l_viewController = [self viewControllerForIndexPath:a_indexPath];
    if (self.splitViewController) {
        self.splitViewController.viewControllers = @[(self.splitViewController.viewControllers)[0], l_viewController];
    }else if(self.slidingViewController){
        if (self.slidingViewController.topViewController) {
            __weak __typeof(self) l_weakSelf = self;
            [IFAUtils dispatchAsyncMainThreadBlock:^{
                if (l_weakSelf.slidingViewController.topViewController != l_viewController) {
                    l_weakSelf.slidingViewController.topViewController = l_viewController;
                }
                [l_weakSelf.slidingViewController resetTopView];
            }                           afterDelay:0.05];
        }else { // First time only
            self.slidingViewController.topViewController = l_viewController;
        }
    }else {
        if ([l_viewController isKindOfClass:[IFAPreferencesFormViewController class]]) {
            [self ifa_presentModalFormViewController:l_viewController];
        }else{
            [self.navigationController pushViewController:l_viewController animated:YES];
        }
    }
    
    self.selectedIndexPath = a_indexPath;
    //    NSLog(@"self.selectedIndexPath: %@", [self.selectedIndexPath description]);
    
    if (self.splitViewController || self.slidingViewController) {
        if (self.IFA_previousViewController && [self.IFA_previousViewController isKindOfClass:[UINavigationController class]]) {
            // If the previously selected view controller is a navigation controller then make sure to pop to its root view controller
            //  in order to minimise memory requirements and avoid complications with entities being changed somewhere else (for now)
            UINavigationController *l_navigationController = (UINavigationController*)self.IFA_previousViewController;
            //            NSLog(@"before...");
            //            NSLog(@"  [l_navigationController.viewControllers count]: %u", [l_navigationController.viewControllers count]);
            //            NSLog(@"  [l_navigationController.topViewController description]: %@", [l_navigationController.topViewController description]);
            [l_navigationController popToRootViewControllerAnimated:NO];
            //            NSLog(@"...after");
            //            NSLog(@"[l_navigationController.viewControllers count]: %u", [l_navigationController.viewControllers count]);
            //            NSLog(@"[l_navigationController.topViewController description]: %@", [l_navigationController.topViewController description]);
        }
        self.IFA_previousViewController = l_viewController;
        [IFAUIUtils postNavigationEventNotification];
    }
    
    // Dismiss the popover controller if a split view controller is used
    [self ifa_dismissMenuPopoverController];
    
}

-(void)selectMenuItemAtIndex:(NSUInteger)a_index{
    if ([self tableView:self.tableView numberOfRowsInSection:0]) {
        NSIndexPath *l_selectedIndexPath = [NSIndexPath indexPathForRow:a_index inSection:0];
        [self.tableView selectRowAtIndexPath:l_selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:l_selectedIndexPath];
    }
}

+(IFAMenuViewController *)mainMenuViewController {
    IFAMenuViewController *l_menuViewController = nil;
    UIViewController *l_rootViewController = [[UIApplication sharedApplication].delegate.window rootViewController];
    if ([l_rootViewController isKindOfClass:[UISplitViewController class]] || [l_rootViewController isKindOfClass:[IFASlidingViewController class]]) {
        if ([l_rootViewController isKindOfClass:[UISplitViewController class]]) {
            UISplitViewController *l_splitViewController = (UISplitViewController*)l_rootViewController;
            UINavigationController *l_navigationController = (UINavigationController*) (l_splitViewController.viewControllers)[0];
            l_menuViewController = (IFAMenuViewController *)l_navigationController.topViewController;
        }else{
            IFASlidingViewController *l_slidingViewController = (IFASlidingViewController *)l_rootViewController;
            UINavigationController *l_navigationController = (UINavigationController*)l_slidingViewController.underLeftViewController;
            l_menuViewController = (IFAMenuViewController *)l_navigationController.topViewController;
        }
    }
    return l_menuViewController;
}

-(NSMutableDictionary *)indexPathToViewControllerDictionary {
    if (self.shouldCacheViewControllers) {
        id l_obj = [[IFADynamicCache sharedInstance] objectForKey:IFACacheKeyMenuViewControllersDictionary];
        if (!l_obj) {
//        NSLog(@"Menu view controllers dictionary not in the cache. Creating a new one...");
            l_obj = [NSMutableDictionary new];
            [[IFADynamicCache sharedInstance] setObject:l_obj forKey:IFACacheKeyMenuViewControllersDictionary];
        }
        return l_obj;
    }else{
        return nil;
    }
}

#pragma mark - Overrides

-(void)viewDidLoad{

    [super viewDidLoad];
    
    // Clear view controller dictionary in case the UI has been re-loaded   
    [self.indexPathToViewControllerDictionary removeAllObjects];

    // Add observers if required
    if (self.splitViewController || self.slidingViewController) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(oncontextSwitchRequestGrantedNotification:)
                                                     name:IFANotificationContextSwitchRequestGranted
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(oncontextSwitchRequestDeniedNotification:)
                                                     name:IFANotificationContextSwitchRequestDenied
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSlidingViewTopDidResetNotification:)
                                                     name:ECSlidingViewTopDidReset
                                                   object:nil];
    }

}

-(void)dealloc{
    
    // Remove observers if required
    if (self.splitViewController || self.slidingViewController) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationContextSwitchRequestGranted
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationContextSwitchRequestDenied
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECSlidingViewTopDidReset
                                                      object:nil];
    }

}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    if (self.splitViewController || self.slidingViewController) {
        [self highlightCurrentSelection];
    }

}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[self firstResponder] resignFirstResponder];
}

#pragma mark - UITableViewDelegate Protocol

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSLog(@"didSelectRowAtIndexPath: %@", [indexPath description]);
    
    [[self firstResponder] resignFirstResponder];
    
    UIViewController *l_selectedViewController = nil;
    if (self.splitViewController || self.slidingViewController) {
        l_selectedViewController = self.splitViewController ? (self.splitViewController.viewControllers)[1] : self.slidingViewController.topViewController;
        if ([l_selectedViewController isKindOfClass:[IFANavigationController class]]) {
            //    NSLog(@"l_navigationController.contextSwitchRequestRequired: %u", l_selectedNavigationController.contextSwitchRequestRequired);
            if (((IFANavigationController *)l_selectedViewController).contextSwitchRequestRequired) {
                NSNotification *l_notification = [NSNotification notificationWithName:IFANotificationContextSwitchRequest
                                                                               object:indexPath userInfo:nil];
                [[NSNotificationQueue defaultQueue] enqueueNotification:l_notification 
                                                           postingStyle:NSPostASAP
                                                           coalesceMask:NSNotificationNoCoalescing 
                                                               forModes:nil];
                //        NSLog(@" ");
                //        NSLog(@"IFANotificationContextSwitchRequest sent by %@", [self description]);
                return;
            }
        }
    }

    [self commitSelectionForIndexPath:indexPath];

}

@end
