//
//  IFAInternalWebBrowserActivity.m
//  Gusty
//
//  Created by Marcelo Schroeder on 15/11/12.
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

@interface IFAInternalWebBrowserActivity ()

@property (nonatomic, strong) UIViewController *IFA_internalWebBrowserViewController;

@end

@implementation IFAInternalWebBrowserActivity {
    
}

#pragma mark - Private

- (UIViewController *)IFA_internalWebBrowserViewController {
    if (!_IFA_internalWebBrowserViewController) {
        id <IFAAppearanceTheme> l_appearanceTheme = [[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme];
        __weak __typeof(self) l_weakSelf = self;
        UIViewController *l_viewController = [l_appearanceTheme newInternalWebBrowserViewControllerWithUrl:self.url
                                                                                           completionBlock:^{
                                                                                               [l_weakSelf activityDidFinish:YES];
                                                                                           }];
        IFANavigationController *l_navigationController = [[[l_appearanceTheme navigationControllerClass] alloc] initWithRootViewController:l_viewController];
        l_navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        l_navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        _IFA_internalWebBrowserViewController = l_navigationController;
    }
    return _IFA_internalWebBrowserViewController;
}

#pragma mark - Overrides

-(NSString *)activityType{
    return @"IFAInternalWebBrowser";
}

- (UIViewController *)activityViewController {
    return self.IFA_internalWebBrowserViewController;
}

@end
