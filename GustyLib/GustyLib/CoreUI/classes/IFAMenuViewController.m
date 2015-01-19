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

#import "GustyLibCoreUI.h"
#import "IFAMenuViewController.h"

@interface IFAMenuViewController ()
@property (nonatomic, strong) IFAContextSwitchingManager *IFA_contextSwitchingManager;
@end

@implementation IFAMenuViewController

#pragma mark - Private

- (IFAContextSwitchingManager *)IFA_contextSwitchingManager {
    if (!_IFA_contextSwitchingManager) {
        _IFA_contextSwitchingManager = [IFAContextSwitchingManager new];
        _IFA_contextSwitchingManager.delegate = self;
    }
    return _IFA_contextSwitchingManager;
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
    NSString *storyboardViewControllerId = l_cell.reuseIdentifier;  // Use the cell reuse ID by default
    if ([self.menuViewControllerDataSource respondsToSelector:@selector(storyboardViewControllerIdForIndexPath:menuViewController:)]) {
        storyboardViewControllerId = [self.menuViewControllerDataSource storyboardViewControllerIdForIndexPath:a_indexPath
                                                                                            menuViewController:self];
    }
    UIViewController *l_viewController = [l_storyboard instantiateViewControllerWithIdentifier:storyboardViewControllerId];
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
        [self.navigationController pushViewController:l_viewController animated:YES];
    }

    self.selectedIndexPath = a_indexPath;
    //    NSLog(@"self.selectedIndexPath: %@", [self.selectedIndexPath description]);
    
    if (self.splitViewController || self.slidingViewController) {
        [self.IFA_contextSwitchingManager didCommitContextSwitchForViewController:l_viewController];
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
                                                 selector:@selector(onSlidingViewTopDidResetNotification:)
                                                     name:ECSlidingViewTopDidReset
                                                   object:nil];
    }

}

-(void)dealloc{
    
    // Remove observers if required
    if (self.splitViewController || self.slidingViewController) {
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
    
    if (self.splitViewController || self.slidingViewController) {
        if (![self.IFA_contextSwitchingManager requestContextSwitchForObject:indexPath]) {
            return;
        }
    }

    [self commitSelectionForIndexPath:indexPath];

}

#pragma mark - IFAContextSwitchingManagerDelegate

- (void)             contextSwitchingManager:(IFAContextSwitchingManager *)a_contextSwitchingManager
didReceiveContextSwitchRequestReplyForObject:(id)a_object granted:(BOOL)a_granted {
    if (a_granted) {
        [self commitSelectionForIndexPath:a_object];
    }else{
        [self restoreCurrentSelection];
    }
}

@end
