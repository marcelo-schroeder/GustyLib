//
// Created by Marcelo Schroeder on 19/09/2014.
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

#import "GustyLibCore.h"

//wip: more styling to appearance theme

//wip: clean up
//@interface IFAHelpViewController ()
//@property (nonatomic, strong) IFAViewControllerTransitioningDelegate *IFA_viewControllerTransitioningDelegate;
//@end

@implementation IFAHelpViewController {

}

#pragma Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    //wip: clean up
//    self.modalPresentationStyle = UIModalPresentationCustom;
//    self.transitioningDelegate = self.IFA_viewControllerTransitioningDelegate;
    self.view.backgroundColor = [UIColor clearColor];

    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.text = @"dsfjsd sdljf sdfl kldf\n\naslkdfj sdlkfj lsdkf\n\nsdlfjsdfljdsf";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    [label ifa_addLayoutConstraintsToFillSuperview];

    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IFA_Icon_Close"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(IFA_onCloseButtonTap:)];
    [self ifa_addRightBarButtonItem:closeBarButtonItem];
}

#pragma mark - Private

//wip: clean up
//- (IFAViewControllerTransitioningDelegate *)IFA_viewControllerTransitioningDelegate {
//    if (!_IFA_viewControllerTransitioningDelegate) {
//        IFAViewControllerAnimatedTransitioning *viewControllerAnimatedTransitioning = [IFAViewControllerAnimatedTransitioning new];
//        _IFA_viewControllerTransitioningDelegate = [[IFAViewControllerTransitioningDelegate alloc] initWithViewControllerAnimatedTransitioning:viewControllerAnimatedTransitioning];
//    }
//    return _IFA_viewControllerTransitioningDelegate;
//}

- (void)IFA_onCloseButtonTap:(UIBarButtonItem *)a_button {
    [self.parentViewController ifa_notifySessionCompletion];
}

@end