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

#import "GustyLibHelp.h"

//wip: more styling to appearance theme

//wip: clean up
@interface IFAHelpViewController ()
@property (nonatomic, strong) IFAHelpPopTipView *IFA_activePopTipView;
//@property (nonatomic, strong) IFAViewControllerTransitioningDelegate *IFA_viewControllerTransitioningDelegate;
@property(nonatomic, weak) UIViewController *IFA_targetViewController;
@end

@implementation IFAHelpViewController {

}

#pragma Overrides

- (instancetype)initWithTargetViewController:(UIViewController *)a_targetViewController { //wip: review parameter names and type (i.e. should it be a rect instead of a view?)
    self = [super init];
    if (self) {
        self.IFA_targetViewController = a_targetViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //wip: clean up
//    self.modalPresentationStyle = UIModalPresentationCustom;
//    self.transitioningDelegate = self.IFA_viewControllerTransitioningDelegate;
    self.view.backgroundColor = [UIColor clearColor];

//    UILabel *label = [UILabel new];
//    label.numberOfLines = 0;
//    label.text = @"dsfjsd sdljf sdfl kldf\n\naslkdfj sdlkfj lsdkf\n\nsdlfjsdfljdsf";
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:label];
//    [label ifa_addLayoutConstraintsToFillSuperview];

//    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IFA_Icon_Help"]
//                                                                           style:UIBarButtonItemStylePlain
//                                                                          target:self
//                                                                          action:@selector(IFA_onCloseButtonTap:)];
    [self ifa_addRightBarButtonItem:[[IFAHelpManager sharedInstance] newHelpBarButtonItemForViewController:self.IFA_targetViewController]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    void (^completion)() = ^{
//
//    };

//    completion();

//        IFAAbstractFieldEditorViewController *l_fieldEditorViewController = (IFAAbstractFieldEditorViewController *)self.observedHelpTargetContainer;
//        NSLog(@"l_fieldEditorViewController.helpTargetId: %@", l_fieldEditorViewController.helpTargetId);
//        NSLog(@"  l_fieldEditorViewController.view.frame: %@", NSStringFromCGRect(l_fieldEditorViewController.view.frame));
//        NSLog(@"  l_fieldEditorViewController.navigationController.view.frame: %@", NSStringFromCGRect(l_fieldEditorViewController.navigationController.view.frame));
//        NSLog(@"  a_button.frame: %@", NSStringFromCGRect(a_button.frame));

    NSAssert(self.IFA_activePopTipView ==nil, @"self.IFA_activePopTipView no nil: %@", [self.IFA_activePopTipView description]);

//        // Configure tap gesture recogniser
//        self.IFA_simpleHelpBackgroundGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                                 action:@selector(IFA_onSimpleHelpGestureRecogniserAction:)];
//
//        // Configure background view
//        CGRect l_frame = l_fieldEditorViewController.navigationController.view.frame;
//        UIView *l_backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, l_frame.size.width, l_frame.size.height)];
//        l_backgroundView.tag = IFAViewTagHelpBackground;
//        l_backgroundView.backgroundColor = [UIColor clearColor];
//        [l_backgroundView addGestureRecognizer:self.IFA_simpleHelpBackgroundGestureRecogniser];
//        [l_fieldEditorViewController.navigationController.view addSubview:l_backgroundView];

    // Present pop tip view
//    NSString *keyPath = l_fieldEditorViewController.helpTargetId; //wip: review
//        NSString *keyPath = @"controllers.NowViewController.screen";
//        NSString *l_description = [self IFA_helpDescriptionForKeyPath:keyPath];

        NSString *description = @"Test description.";
        self.IFA_activePopTipView = [IFAHelpPopTipView new];
        [self.IFA_activePopTipView presentWithTitle:@"Test Title" description:description
                                     pointingAtView:self.IFA_targetViewController.IFA_helpBarButtonItem.customView inView:self.navigationController.view
                                    completionBlock:nil];

//    WYPopoverBackgroundView *popoverAppearance = [WYPopoverBackgroundView appearance];
//    [popoverAppearance setArrowHeight:10];
//    [popoverAppearance setArrowBase:20];
//
//    UIViewController *vc = [UIViewController new];
//    vc.preferredContentSize = CGSizeMake(200, 300);
//    vc.view.backgroundColor = [UIColor clearColor];
//    self.pc = [[WYPopoverController alloc] initWithContentViewController:vc];
//    [self.pc presentPopoverFromRect:CGRectMake(272, 40, 44, 24)
//                             inView:self.IFA_view
//           permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];

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

//- (void)IFA_onCloseButtonTap:(UIBarButtonItem *)a_button {
//    [self.parentViewController ifa_notifySessionCompletion];
//}

@end