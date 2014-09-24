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

@interface IFAHelpViewController ()
//@property (nonatomic, strong) IFAHelpPopTipView *popTipView;  //wip: clean up
@property (nonatomic, weak) UIViewController *IFA_targetViewController;
@property (nonatomic, strong) WYPopoverController *IFA_popoverController;
@property(nonatomic, strong) IFAHelpContentViewController *IFA_helpContentViewController;
@end

@implementation IFAHelpViewController {

}

#pragma Overrides

- (instancetype)initWithTargetViewController:(UIViewController *)a_targetViewController {
    self = [super init];
    if (self) {
        self.IFA_targetViewController = a_targetViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor clearColor];
    [self ifa_addRightBarButtonItem:[[IFAHelpManager sharedInstance] newHelpBarButtonItemForViewController:self.IFA_targetViewController]];
//wip: clean up
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                           action:@selector(IFA_onBackgroundDismissalViewTap)];
//    [self.navigationController.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //wip: clean up
//    [self.popTipView presentWithTitle:self.IFA_targetViewController.title
//                          description:[[IFAHelpManager sharedInstance] helpForViewController:self.IFA_targetViewController]
//                       pointingAtView:self.IFA_targetViewController.IFA_helpBarButtonItem.customView
//                               inView:self.navigationController.view
//                      completionBlock:nil];

    __weak __typeof(self) l_weakSelf = self;
    void (^completion)() = ^{
        UIView *helpButton = l_weakSelf.IFA_targetViewController.IFA_helpBarButtonItem.customView;
        CGRect fromRect = [l_weakSelf.view convertRect:helpButton.frame fromView:helpButton.superview];
        [l_weakSelf.IFA_popoverController presentPopoverFromRect:fromRect inView:l_weakSelf.view
                                        permittedArrowDirections:WYPopoverArrowDirectionUp
                                                        animated:YES
                                                      completion:^{
                                                          [l_weakSelf.IFA_helpContentViewController.webView.scrollView flashScrollIndicators];
                                                      }];
    };
    NSString *htmlBody = [[IFAHelpManager sharedInstance] helpForViewController:self.IFA_targetViewController];
    [self.IFA_helpContentViewController loadWebViewWithHtmlBody:htmlBody
                                                     completion:completion];
}

//wip: clean up
//#pragma mark - CMPopTipViewDelegate
//
//- (void)popTipViewWasDismissedByUser:(IFA_CMPopTipView *)popTipView {
//    [self IFA_dismissHelpViewController];
//}

#pragma mark - WYPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController {
    [self IFA_dismissHelpViewController];
}

#pragma mark - Private

//wip: clean up
//- (IFAHelpPopTipView *)popTipView {
//    if (!_popTipView) {
//        _popTipView = [IFAHelpPopTipView new];
//        _popTipView.delegate = self;
//    }
//    return _popTipView;
//}

//wip: clean up
//- (void)IFA_onBackgroundDismissalViewTap {
//    NSLog(@"IFA_onBackgroundDismissalViewTap"); //wip: clean up
//    [[IFAHelpManager sharedInstance] toggleHelpModeForViewController:self.IFA_targetViewController];
//}

- (void)IFA_dismissHelpViewController {
    NSLog(@"IFA_dismissHelpViewController"); //wip: clean up
    [self.navigationController ifa_notifySessionCompletion];
}

- (WYPopoverController *)IFA_popoverController {
    if (!_IFA_popoverController) {
        _IFA_popoverController = [[WYPopoverController alloc] initWithContentViewController:self.IFA_helpContentViewController];
        _IFA_popoverController.delegate = self;
        _IFA_popoverController.theme.overlayColor = [UIColor clearColor]; //wip: move styling
        _IFA_popoverController.theme.fillTopColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        _IFA_popoverController.theme.fillBottomColor = _IFA_popoverController.theme.fillTopColor;
        //wip: review
//        _IFA_popoverController.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
//        settingsPopoverController.passthroughViews = @[btn];
//        settingsPopoverController.wantsDefaultContentAppearance = NO;
    }
    return _IFA_popoverController;
}

- (IFAHelpContentViewController *)IFA_helpContentViewController {
    if (!_IFA_helpContentViewController) {
        _IFA_helpContentViewController = [IFAHelpContentViewController new];
    }
    return _IFA_helpContentViewController;
}

@end