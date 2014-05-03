//
//  IAUISplitViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 2/05/12.
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

@interface IAUISplitViewController ()

@property(nonatomic) BOOL p_firstLoadDone;
@end

@implementation IAUISplitViewController{
    
}


#pragma mark - Private

-(UIViewController*)m_visibleDetailTopViewController{
    UIViewController *l_visibleDetailViewController = nil;
    UIViewController *l_detailViewController = [self.viewControllers objectAtIndex:1];
    if ([l_detailViewController isKindOfClass:[UINavigationController class]]) {
        l_visibleDetailViewController = ((UINavigationController*)l_detailViewController).topViewController;
    }else{
        l_visibleDetailViewController = l_detailViewController;
    }
    return l_visibleDetailViewController;
}

#pragma mark - Overrides

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.delegate = self;
    }
    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return [self m_shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return [self m_supportedInterfaceOrientations];
}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];

    if (!self.p_firstLoadDone) {
        UIViewController *l_masterViewController = self.viewControllers[0];
        if ([l_masterViewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *l_masterRootViewController = ((UINavigationController*)l_masterViewController).viewControllers[0];
            if ([l_masterRootViewController isKindOfClass:[IAUIMenuViewController class]]) {
                [((IAUIMenuViewController *) l_masterRootViewController) selectMenuItemAtIndex:0];
                self.p_firstLoadDone = YES;
            }
        }
    }

}

#pragma mark - UISplitViewControllerDelegate protocol

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{

//    NSLog(@"willHideViewController");
    
    // Configure bar button item to get back to the master view controller
    UIBarButtonItem *l_barButtonItem = [[self m_appearanceTheme] splitViewControllerBarButtonItem];
    if (l_barButtonItem) {
        l_barButtonItem.target = barButtonItem.target;
        l_barButtonItem.action = barButtonItem.action;
    }else{
        l_barButtonItem = barButtonItem;
    }
    l_barButtonItem.tag = IA_UIBAR_ITEM_TAG_LEFT_SLIDING_PANE_BUTTON;

    // Manage bar button item visibility
    UIViewController *l_visibleDetailTopViewController = [self m_visibleDetailTopViewController];
    if ([l_visibleDetailTopViewController m_shouldShowLeftSlidingPaneButton]) {
        [[self m_visibleDetailTopViewController] m_addLeftBarButtonItem:l_barButtonItem];
    }

    // Save details for later
    self.p_popoverController = popoverController;
    self.p_popoverControllerBarButtonItem = l_barButtonItem;
    
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
//    NSLog(@"willShowViewController");
    
    // Notify view controllers of invalidated menu button
    [[NSNotificationCenter defaultCenter] postNotificationName:IA_NOTIFICATION_MENU_BAR_BUTTON_ITEM_INVALIDATED object:self.p_popoverControllerBarButtonItem];
    
    // Reset saved details
    self.p_popoverController = nil;
    self.p_popoverControllerBarButtonItem = nil;
    
}

@end
