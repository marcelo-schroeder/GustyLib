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

@interface IFAHelpViewController ()
@property (nonatomic, strong) IFAViewControllerTransitioningDelegate *IFA_viewControllerTransitioningDelegate;
@end

@implementation IFAHelpViewController {

}

#pragma mark - Overrides

- (instancetype)initWithTargetViewController:(UIViewController *)a_targetViewController {
    IFAHelpContentViewController *helpContentViewController = [[IFAHelpContentViewController alloc] initWithTargetViewController:a_targetViewController];
    self = [super initWithRootViewController:helpContentViewController];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self.IFA_viewControllerTransitioningDelegate;
}

#pragma mark - Private

- (IFAViewControllerTransitioningDelegate *)IFA_viewControllerTransitioningDelegate {
    if (!_IFA_viewControllerTransitioningDelegate) {
        IFAViewControllerFadeTransitioning *viewControllerAnimatedTransitioning = [IFAViewControllerFadeTransitioning new];
        _IFA_viewControllerTransitioningDelegate = [[IFAViewControllerTransitioningDelegate alloc] initWithViewControllerAnimatedTransitioning:viewControllerAnimatedTransitioning];
    }
    return _IFA_viewControllerTransitioningDelegate;
}

@end