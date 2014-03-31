//
//  AboutViewController.m
//  IAUIAboutViewController
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

#import "IACommon.h"

@implementation IAUIAboutViewController{
    
    @private
    IAEmailManager *v_emailManager;
    
}
@synthesize p_copyrightNoticeLabel;
@synthesize p_createdByLabel;
@synthesize p_visualDesignByLabel;
@synthesize p_editionLabel;


#pragma mark - Private

-(NSString*)m_supportEmailAddress{
    return [[IAUtils infoPList] objectForKey:@"IASupportEmailAddress"];
}

-(NSString*)m_bugReportEmailAddress{
    NSString *l_emailAddress = [[IAUtils infoPList] objectForKey:@"IABugReportEmailAddress"];
    if (!l_emailAddress) {
        l_emailAddress = [self m_supportEmailAddress];
    }
    return l_emailAddress;
}

-(NSString*)m_feedbackEmailAddress{
    NSString *l_emailAddress = [[IAUtils infoPList] objectForKey:@"IAFeedbackEmailAddress"];
    if (!l_emailAddress) {
        l_emailAddress = [self m_supportEmailAddress];
    }
    return l_emailAddress;
}

#pragma mark - Public

- (IBAction)m_bugReportButtonTap:(id)sender{
    NSString *l_body = [NSString stringWithFormat:@"Hi there,\n\nPlease fix the following bug I have found in %@:", [IAUtils appFullName]];
    [v_emailManager m_composeEmailWithSubject:[NSString stringWithFormat:@"%@ In-App Bug Report", [IAUtils appNameAndEdition]] recipient:[self m_bugReportEmailAddress] body:l_body];
}

- (IBAction)m_feedbackButtonTap:(id)sender{
    NSString *l_body = [NSString stringWithFormat:@"Hi there,\n\nI have the following feedback to provide for %@:", [IAUtils appFullName]];
    [v_emailManager m_composeEmailWithSubject:[NSString stringWithFormat:@"%@ In-App Feedback", [IAUtils appNameAndEdition]] recipient:[self m_feedbackEmailAddress] body:l_body];
}

- (IBAction)m_forceCrashButtonTap:(id)sender {
    [IAUtils m_forceCrash];
}

- (IBAction)m_thirdPartyCreditsButtonTap:(id)sender {
    UIViewController *l_viewController = [[IAUIThirdPartyCodeCreditsViewController alloc] init];
    l_viewController.title = @"Third Party Credits";
    [self m_presentModalViewController:l_viewController
                     presentationStyle:UIModalPresentationCurrentContext
                       transitionStyle:UIModalTransitionStyleCoverVertical
                   shouldAddDoneButton:YES];
}

#pragma mark - Overrides

-(BOOL)p_manageToolbar{
    return NO;
}

-(void)viewDidLoad{

    [super viewDidLoad];

    // Set product name and version in the view
    self.p_appNameLabel.text = [IAUtils appName];
    self.p_editionLabel.text = [IAUtils appEdition];
    self.p_versionLabel.text = [IAUtils appVersionAndBuildNumber];
    self.p_copyrightNoticeLabel.text = [[IAUtils infoPList] objectForKey:@"IACopyrightNotice"];
    self.p_createdByLabel.text = [[IAUtils infoPList] objectForKey:@"IACreatedBy"];
    self.p_visualDesignByLabel.text = [[IAUtils infoPList] objectForKey:@"IAVisualDesignBy"];
    
    // Set email manager
    v_emailManager = [[IAEmailManager alloc ] initWithParentViewController:self];

    self.p_forceCrashButton.hidden = ![[[IAUtils infoPList] objectForKey:@"IAShowForceCrashButton"] boolValue];

}

@end
