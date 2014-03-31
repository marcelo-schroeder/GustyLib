//
//  IAUIMenuMasterViewController.m
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

#import "IACommon.h"

@interface IAUIMenuViewController ()

@property (nonatomic, strong) UIViewController *p_previousViewController;

@end

@implementation IAUIMenuViewController{
    @private
    
}

#pragma mark - Private

- (void)oncontextSwitchRequestGrantedNotification:(NSNotification*)aNotification{
//    NSLog(@"IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST_GRANTED received by %@", [self description]);
    [self m_commitSelectionForIndexPath:aNotification.object];
}

- (void)oncontextSwitchRequestDeniedNotification:(NSNotification*)aNotification{
//    NSLog(@"IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST_DENIED received by %@", [self description]);
    [self m_restoreCurrentSelection];
}

-(void)onSlidingViewTopDidResetNotification:(NSNotification*)a_notification{
    [[self m_firstResponder] resignFirstResponder];
}

#pragma mark - Public

-(void)m_restoreCurrentSelection{
    
    [self m_highlightCurrentSelection];
    
    // Dismiss the popover controller if a split view controller is used
    [self m_dismissMenuPopoverController];
    
}

-(void)m_highlightCurrentSelection{
//    NSLog(@"t: %@, p: %@, = %u", [self.tableView.indexPathForSelectedRow description], [self.p_selectedIndexPath description], [self.tableView.indexPathForSelectedRow isEqual:self.p_selectedIndexPath]);
    [self.tableView selectRowAtIndexPath:self.p_selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

-(UIViewController*)m_newViewControllerForIndexPath:(NSIndexPath*)a_indexPath{
    UITableViewCell *l_cell = [self tableView:self.tableView cellForRowAtIndexPath:a_indexPath];
    BOOL l_useDeviceAgnosticMainStoryboard = [IAUIApplicationDelegate m_instance].p_useDeviceAgnosticMainStoryboard;
    UIStoryboard *l_storyboard = l_useDeviceAgnosticMainStoryboard ? self.storyboard : [self m_commonStoryboard];
    UIViewController *l_viewController = [l_storyboard instantiateViewControllerWithIdentifier:l_cell.reuseIdentifier];
    if ((self.splitViewController || self.slidingViewController) && ![l_viewController isKindOfClass:[UINavigationController class]]) {
        // Automatically add a navigation controller as the parent
        l_viewController = [[[[self m_appearanceTheme] m_navigationControllerClass] alloc] initWithRootViewController:l_viewController];
    }
    return l_viewController;
}

-(UIResponder *)m_firstResponder{
    return nil;
}

-(UIViewController*)m_viewControllerForIndexPath:(NSIndexPath*)a_indexPath{
    UIViewController *l_viewController = [self.p_indexPathToViewControllerDictionary objectForKey:a_indexPath];
    if (l_viewController) { // A view controller is cached
        //        NSLog(@"   view controller is cached: %@", [l_viewController description]);
        // Reset view controller's state
        [l_viewController m_reset];
    }else{
        // Configure a new view controller
        l_viewController = [self m_newViewControllerForIndexPath:a_indexPath];
        l_viewController.p_presenter = self;
        [self.p_indexPathToViewControllerDictionary setObject:l_viewController forKey:a_indexPath];
        //        NSLog(@"   p_indexPathToViewControllerDictionary: %@", [self.p_indexPathToViewControllerDictionary description]);
    }
    return l_viewController;
}

-(void)m_commitSelectionForIndexPath:(NSIndexPath*)a_indexPath{
    
    //    NSLog(@"m_commitSelectionForIndexPath: %@", [a_indexPath description]);
    
    UIViewController *l_viewController = [self m_viewControllerForIndexPath:a_indexPath];
    if (self.splitViewController) {
        self.splitViewController.viewControllers = @[[self.splitViewController.viewControllers objectAtIndex:0], l_viewController];
    }else if(self.slidingViewController){
        if (self.slidingViewController.topViewController) {
            [IAUtils m_dispatchAsyncMainThreadBlock:^{
                if (self.slidingViewController.topViewController!=l_viewController) {
                    self.slidingViewController.topViewController = l_viewController;
                }
                [self.slidingViewController resetTopView];
            } afterDelay:0.05];
        }else { // First time only
            self.slidingViewController.topViewController = l_viewController;
        }
    }else{
        [self.navigationController pushViewController:l_viewController animated:YES];
    }
    
    self.p_selectedIndexPath = a_indexPath;
    //    NSLog(@"self.p_selectedIndexPath: %@", [self.p_selectedIndexPath description]);
    
    if (self.splitViewController || self.slidingViewController) {
        if (self.p_previousViewController && [self.p_previousViewController isKindOfClass:[UINavigationController class]]) {
            // If the previously selected view controller is a navigation controller then make sure to pop to its root view controller
            //  in order to minimise memory requirements and avoid complications with entities being changed somewhere else (for now)
            UINavigationController *l_navigationController = (UINavigationController*)self.p_previousViewController;
            //            NSLog(@"before...");
            //            NSLog(@"  [l_navigationController.viewControllers count]: %u", [l_navigationController.viewControllers count]);
            //            NSLog(@"  [l_navigationController.topViewController description]: %@", [l_navigationController.topViewController description]);
            [l_navigationController popToRootViewControllerAnimated:NO];
            //            NSLog(@"...after");
            //            NSLog(@"[l_navigationController.viewControllers count]: %u", [l_navigationController.viewControllers count]);
            //            NSLog(@"[l_navigationController.topViewController description]: %@", [l_navigationController.topViewController description]);
        }
        self.p_previousViewController = l_viewController;
        [IAUIUtils m_postNavigationEventNotification];
    }
    
    // Dismiss the popover controller if a split view controller is used
    [self m_dismissMenuPopoverController];
    
}

-(void)m_selectMenuItemAtIndex:(NSUInteger)a_index{
    if ([self tableView:self.tableView numberOfRowsInSection:0]) {
        NSIndexPath *l_selectedIndexPath = [NSIndexPath indexPathForRow:a_index inSection:0];
        [self.tableView selectRowAtIndexPath:l_selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:l_selectedIndexPath];
    }
}

+(IAUIMenuViewController*)m_mainMenuViewController{
    IAUIMenuViewController *l_menuViewController = nil;
    UIViewController *l_rootViewController = [[UIApplication sharedApplication].delegate.window rootViewController];
    if ([l_rootViewController isKindOfClass:[UISplitViewController class]] || [l_rootViewController isKindOfClass:[IAUISlidingViewController class]]) {
        if ([l_rootViewController isKindOfClass:[UISplitViewController class]]) {
            UISplitViewController *l_splitViewController = (UISplitViewController*)l_rootViewController;
            UINavigationController *l_navigationController = (UINavigationController*)[l_splitViewController.viewControllers objectAtIndex:0];
            l_menuViewController = (IAUIMenuViewController*)l_navigationController.topViewController;
        }else{
            IAUISlidingViewController *l_slidingViewController = (IAUISlidingViewController*)l_rootViewController;
            UINavigationController *l_navigationController = (UINavigationController*)l_slidingViewController.underLeftViewController;
            l_menuViewController = (IAUIMenuViewController*)l_navigationController.topViewController;
        }
    }
    return l_menuViewController;
}

-(NSMutableDictionary *)p_indexPathToViewControllerDictionary{
    id l_obj = [[IADynamicCache instance] objectForKey:IA_CACHE_KEY_MENU_VIEW_CONTROLLERS_DICTIONARY];
    if (!l_obj) {
//        NSLog(@"Menu view controllers dictionary not in the cache. Creating a new one...");
        l_obj = [NSMutableDictionary new];
        [[IADynamicCache instance] setObject:l_obj forKey:IA_CACHE_KEY_MENU_VIEW_CONTROLLERS_DICTIONARY];
    }
    return l_obj;
}

#pragma mark - Overrides

-(void)viewDidLoad{

    [super viewDidLoad];
    
    // Clear view controller dictionary in case the UI has been re-loaded   
    [self.p_indexPathToViewControllerDictionary removeAllObjects];

    // Add observers if required
    if (self.splitViewController || self.slidingViewController) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(oncontextSwitchRequestGrantedNotification:)
                                                     name:IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST_GRANTED
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(oncontextSwitchRequestDeniedNotification:)
                                                     name:IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST_DENIED
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSlidingViewTopDidResetNotification:)
                                                     name:ECSlidingViewTopDidReset
                                                   object:nil];
    }

}

-(void)dealloc{
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    if (self.splitViewController || self.slidingViewController) {
        [self m_highlightCurrentSelection];
    }

}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[self m_firstResponder] resignFirstResponder];
}

#pragma mark - UITableViewDelegate Protocol

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSLog(@"didSelectRowAtIndexPath: %@", [indexPath description]);
    
    [[self m_firstResponder] resignFirstResponder];
    
    UIViewController *l_selectedViewController = nil;
    if (self.splitViewController || self.slidingViewController) {
        l_selectedViewController = self.splitViewController ? [self.splitViewController.viewControllers objectAtIndex:1] : self.slidingViewController.topViewController;
        if ([l_selectedViewController isKindOfClass:[IAUINavigationController class]]) {
            //    NSLog(@"l_navigationController.p_contextSwitchRequestRequired: %u", l_selectedNavigationController.p_contextSwitchRequestRequired);
            if (((IAUINavigationController*)l_selectedViewController).p_contextSwitchRequestRequired) {
                NSNotification *l_notification = [NSNotification notificationWithName:IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST object:indexPath userInfo:nil];
                [[NSNotificationQueue defaultQueue] enqueueNotification:l_notification 
                                                           postingStyle:NSPostASAP
                                                           coalesceMask:NSNotificationNoCoalescing 
                                                               forModes:nil];
                //        NSLog(@" ");
                //        NSLog(@"IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST sent by %@", [self description]);
                return;
            }
        }
    }

    [self m_commitSelectionForIndexPath:indexPath];

}

@end
