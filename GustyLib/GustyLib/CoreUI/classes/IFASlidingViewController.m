//
//  IFASlidingViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 10/07/12.
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

@interface IFASlidingViewController ()

@property (nonatomic) BOOL IFA_hasInitialLoadBeenDone;

@end

@implementation IFASlidingViewController {
    
}

#pragma mark - Overrides

-(void)awakeFromNib{

    [super awakeFromNib];

    UIViewController *l_storyboardMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
    [self setAnchorRightRevealAmount:280.0f];
    self.underLeftWidthLayout = ECFixedRevealWidth;
    self.underLeftViewController = l_storyboardMenuViewController;

    // Configure placeholder view controller
    if (self.placeholderViewControllerStoryboardId) {
        self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.placeholderViewControllerStoryboardId];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];

    if (!self.IFA_hasInitialLoadBeenDone) {
        UIViewController *l_masterViewController = self.underLeftViewController;
        if ([l_masterViewController isKindOfClass:[UINavigationController class]]) {
            UIViewController *l_masterRootViewController = ((UINavigationController*)l_masterViewController).viewControllers[0];
            if ([l_masterRootViewController isKindOfClass:[IFAMenuViewController class]]) {
                [((IFAMenuViewController *) l_masterRootViewController) selectMenuItemAtIndex:0];
            }
        }
        self.IFA_hasInitialLoadBeenDone = YES;
    }

}

@end
