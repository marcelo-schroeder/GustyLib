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

#import "IFACommon.h"

@interface IFAInternalWebBrowserActivity ()

@property (nonatomic, strong) UIViewController *ifa_internalWebBrowserViewController;

@end

@implementation IFAInternalWebBrowserActivity {
    
}

#pragma mark - Private

- (UIViewController *)ifa_internalWebBrowserViewController {
    if (!_ifa_internalWebBrowserViewController) {
        id <IFAAppearanceTheme> l_appearanceTheme = [[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme];
        UIViewController *l_viewController = [l_appearanceTheme newInternalWebBrowserViewControllerWithUrl:self.url
                                                                                           completionBlock:^{
                                                                                               [self activityDidFinish:YES];
                                                                                           }];
        IFANavigationController *l_navigationController = [[[l_appearanceTheme navigationControllerClass] alloc] initWithRootViewController:l_viewController];
        l_navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        l_navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        _ifa_internalWebBrowserViewController = l_navigationController;
    }
    return _ifa_internalWebBrowserViewController;
}

#pragma mark - Overrides

-(NSString *)activityType{
    return @"IFAInternalWebBrowser";
}

- (UIViewController *)activityViewController {
    return self.ifa_internalWebBrowserViewController;
}

@end
