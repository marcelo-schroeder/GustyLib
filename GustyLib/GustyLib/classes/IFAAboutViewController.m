//
//  AboutViewController.m
//  IFAAboutViewController
//
//  Created by Marcelo Schroeder on 10/12/11.
//  Copyright (c) 2011 InfoAccent Pty Limited. All rights reserved.
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

@implementation IFAAboutViewController {
    
    @private
    IFAEmailManager *v_emailManager;
    
}
@synthesize copyrightNoticeLabel;
@synthesize createdByLabel;
@synthesize visualDesignByLabel;
@synthesize editionLabel;


#pragma mark - Private

-(NSString*)ifa_supportEmailAddress {
    return [[IFAUtils infoPList] objectForKey:@"IASupportEmailAddress"];
}

-(NSString*)ifa_bugReportEmailAddress {
    NSString *l_emailAddress = [[IFAUtils infoPList] objectForKey:@"IABugReportEmailAddress"];
    if (!l_emailAddress) {
        l_emailAddress = [self ifa_supportEmailAddress];
    }
    return l_emailAddress;
}

-(NSString*)ifa_feedbackEmailAddress {
    NSString *l_emailAddress = [[IFAUtils infoPList] objectForKey:@"IAFeedbackEmailAddress"];
    if (!l_emailAddress) {
        l_emailAddress = [self ifa_supportEmailAddress];
    }
    return l_emailAddress;
}

#pragma mark - Public

- (IBAction)bugReportButtonTap:(id)sender{
    NSString *l_body = [NSString stringWithFormat:@"Hi there,\n\nPlease fix the following bug I have found in %@:", [IFAUtils appFullName]];
    [v_emailManager composeEmailWithSubject:[NSString stringWithFormat:@"%@ In-App Bug Report",
                                                                       [IFAUtils appNameAndEdition]]
                                  recipient:[self ifa_bugReportEmailAddress] body:l_body];
}

- (IBAction)feedbackButtonTap:(id)sender{
    NSString *l_body = [NSString stringWithFormat:@"Hi there,\n\nI have the following feedback to provide for %@:", [IFAUtils appFullName]];
    [v_emailManager composeEmailWithSubject:[NSString stringWithFormat:@"%@ In-App Feedback",
                                                                       [IFAUtils appNameAndEdition]]
                                  recipient:[self ifa_feedbackEmailAddress] body:l_body];
}

- (IBAction)forceCrashButtonTap:(id)sender {
    [IFAUtils forceCrash];
}

- (IBAction)thirdPartyCreditsButtonTap:(id)sender {
    UIViewController *l_viewController = [[IFAThirdPartyCodeCreditsViewController alloc] init];
    l_viewController.title = @"Third Party Credits";
    [self IFA_presentModalViewController:l_viewController
                       presentationStyle:UIModalPresentationCurrentContext
                         transitionStyle:UIModalTransitionStyleCoverVertical
                     shouldAddDoneButton:YES];
}

#pragma mark - Overrides

-(BOOL)IFA_manageToolbar {
    return NO;
}

-(void)viewDidLoad{

    [super viewDidLoad];

    // Set product name and version in the view
    self.appNameLabel.text = [IFAUtils appName];
    self.editionLabel.text = [IFAUtils appEdition];
    self.versionLabel.text = [IFAUtils appVersionAndBuildNumber];
    self.copyrightNoticeLabel.text = [[IFAUtils infoPList] objectForKey:@"IACopyrightNotice"];
    self.createdByLabel.text = [[IFAUtils infoPList] objectForKey:@"IACreatedBy"];
    self.visualDesignByLabel.text = [[IFAUtils infoPList] objectForKey:@"IAVisualDesignBy"];
    
    // Set email manager
    v_emailManager = [[IFAEmailManager alloc] initWithParentViewController:self];

    self.forceCrashButton.hidden = ![[[IFAUtils infoPList] objectForKey:@"IAShowForceCrashButton"] boolValue];

}

@end
