//
//  IFANavigationController.m
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

#import "IFACommon.h"

@interface IFANavigationController (){
}

@end

@implementation IFANavigationController {
    
}

#pragma mark - Overrides

- (void)viewDidLoad {

    [super viewDidLoad];

    // Set appearance
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnViewDidLoadForViewController:self];

}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    // Force iOS to re-calculate positioning of the title label.
    // This seems to be a bug in iOS when using non system fonts in title text attributes.
    if (self.navigationBar.titleTextAttributes || [UINavigationBar appearance].titleTextAttributes) {
        [self.navigationBar setNeedsLayout];
    }

}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return [self ifa_shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return [self ifa_supportedInterfaceOrientations];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [IFAUIUtils postNavigationEventNotification];
    [super pushViewController:viewController animated:animated];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    [IFAUIUtils postNavigationEventNotification];
    return [super popViewControllerAnimated:animated];
}

-(NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
    [IFAUIUtils postNavigationEventNotification];
    return [super popToRootViewControllerAnimated:animated];
}

-(NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [IFAUIUtils postNavigationEventNotification];
    return [super popToViewController:viewController animated:animated];
}

-(BOOL)disablesAutomaticKeyboardDismissal{
    return self.visibleViewController.disablesAutomaticKeyboardDismissal;
}

@end
