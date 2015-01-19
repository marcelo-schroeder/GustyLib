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

#import "GustyLibCoreUI.h"

@interface IFATabBarController ()
@property (nonatomic, strong) IFAContextSwitchingManager *IFA_contextSwitchingManager;
@end

@implementation IFATabBarController

#pragma mark - Private

- (IFAContextSwitchingManager *)IFA_contextSwitchingManager {
    if (!_IFA_contextSwitchingManager) {
        _IFA_contextSwitchingManager = [IFAContextSwitchingManager new];
        _IFA_contextSwitchingManager.delegate = self;
    }
    return _IFA_contextSwitchingManager;
}

-(void)IFA_selectViewController:(UIViewController*)a_viewController{
//    NSLog(@"going to select tab view controller...");
    self.selectedViewController = a_viewController;
    [self tabBarController:self didSelectViewController:self.selectedViewController];
//    NSLog(@"tab view controller selected");
}

#pragma mark - UITabBarControllerDelegate

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    return [self.IFA_contextSwitchingManager requestContextSwitchForObject:viewController];
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    [self.IFA_contextSwitchingManager didCommitContextSwitchForViewController:viewController];
}

#pragma mark - Overrides

-(id)initWithCoder:(NSCoder *)aDecoder{

    self = [super initWithCoder:aDecoder];

    self.customizableViewControllers = nil;
    self.delegate = self;

    // Update initial context
    [self.IFA_contextSwitchingManager didCommitContextSwitchForViewController:(self.viewControllers)[0]];

    return self;
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

#pragma mark - IFAContextSwitchingManagerDelegate

- (void)             contextSwitchingManager:(IFAContextSwitchingManager *)a_contextSwitchingManager
didReceiveContextSwitchRequestReplyForObject:(id)a_object granted:(BOOL)a_granted {
    if (a_granted) {
        [self IFA_selectViewController:a_object];
    }
}

@end
