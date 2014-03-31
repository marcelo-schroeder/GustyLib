//
//  IAUIInternalBrowserActivity.m
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

@interface IAUIInternalWebBrowserActivity ()

@property (nonatomic, strong) UIViewController *p_internalWebBrowserViewController;

@end

@implementation IAUIInternalWebBrowserActivity {
    
}

#pragma mark - Private

- (UIViewController *)p_internalWebBrowserViewController {
    if (!_p_internalWebBrowserViewController) {
        id <IAUIAppearanceTheme> l_appearanceTheme = [[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme];
        UIViewController *l_viewController = [l_appearanceTheme m_newInternalWebBrowserViewControllerWithUrl:self.p_url
                                                                                             completionBlock:^{
                                                                                                 [self activityDidFinish:YES];
                                                                                             }];
        IAUINavigationController *l_navigationController = [[[l_appearanceTheme m_navigationControllerClass] alloc] initWithRootViewController:l_viewController];
        l_navigationController.modalPresentationStyle = UIModalPresentationPageSheet;
        l_navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        _p_internalWebBrowserViewController = l_navigationController;
    }
    return _p_internalWebBrowserViewController;
}

#pragma mark - Overrides

-(NSString *)activityType{
    return @"IAInternalWebBrowser";
}

- (UIViewController *)activityViewController {
    return self.p_internalWebBrowserViewController;
}

@end
