//
//  IFAStaticPagingContainerViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 31/05/12.
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

@interface IFAStaticPagingContainerViewController ()

@property (nonatomic) NSUInteger newChildViewControllerCount;

@end

@implementation IFAStaticPagingContainerViewController


#pragma mark - Overrides

-(void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"viewWillAppear for %@", [self description]);
    
    [super viewWillAppear:animated];
    
    self.childViewDidAppearCount = 0;
    self.newChildViewControllerCount = 0;

    if (![self ifa_isReturningVisibleViewController]) {
        
        for (UIViewController *l_viewController in self.childViewControllers) {
            if([l_viewController isKindOfClass:[IFAListViewController class]]){
                IFAListViewController *l_listViewController = (IFAListViewController *)l_viewController;
                if (l_listViewController.staleData) {
                    self.newChildViewControllerCount++;
                }
            }
        }
        
    }
    
}

@end
