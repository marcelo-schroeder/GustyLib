//
// Created by Marcelo Schroeder on 20/09/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import "GustyLibHelp.h"

//wip: move styling to appearance theme
//wip: after recent changes (tooltip), do I still need this class?
@interface IFAHelpNavigationController ()
@property (nonatomic, strong) IFAViewControllerTransitioningDelegate *IFA_viewControllerTransitioningDelegate;
@end

@implementation IFAHelpNavigationController {

}

#pragma mark - Overrides

//wip: still need title?
- (instancetype)initWithTitle:(NSString *)a_title view:(UIView *)a_view {
    IFAHelpViewController *helpViewController = [[IFAHelpViewController alloc] initWithView:a_view];
//    helpViewController.title = a_title;
    self = [super initWithRootViewController:helpViewController];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self.IFA_viewControllerTransitioningDelegate;
    self.view.backgroundColor = [UIColor clearColor];
    [self.navigationBar setBackgroundImage:[UIImage ifa_imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
//    self.navigationBar.shadowImage = [[UIImage ifa_separatorImageForType:IFASeparatorImageTypeHorizontalTop] ifa_imageWithOverlayColor:[UIColor whiteColor]];
}

#pragma mark - Private

- (IFAViewControllerTransitioningDelegate *)IFA_viewControllerTransitioningDelegate {
    if (!_IFA_viewControllerTransitioningDelegate) {
        IFAViewControllerAnimatedTransitioning *viewControllerAnimatedTransitioning = [IFAViewControllerAnimatedTransitioning new];
        _IFA_viewControllerTransitioningDelegate = [[IFAViewControllerTransitioningDelegate alloc] initWithViewControllerAnimatedTransitioning:viewControllerAnimatedTransitioning];
    }
    return _IFA_viewControllerTransitioningDelegate;
}

@end