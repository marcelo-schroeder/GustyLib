//
//  AboutViewController.h
//  TimeNBill
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

#import "IAUIViewController.h"

@interface IAUIAboutViewController : IAUIViewController

@property (strong, nonatomic) IBOutlet UILabel *p_appNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *p_editionLabel;
@property (strong, nonatomic) IBOutlet UILabel *p_versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *p_copyrightNoticeLabel;
@property (strong, nonatomic) IBOutlet UILabel *p_createdByLabel;
@property (strong, nonatomic) IBOutlet UILabel *p_visualDesignByLabel;
@property (strong, nonatomic) IBOutlet UIButton *p_bugReportButton;
@property (strong, nonatomic) IBOutlet UIButton *p_feedbackButton;
@property (strong, nonatomic) IBOutlet UIButton *p_forceCrashButton;
@property (strong, nonatomic) IBOutlet UIButton *p_thirdPartyCreditsButton;

- (IBAction)m_bugReportButtonTap:(id)sender;
- (IBAction)m_feedbackButtonTap:(id)sender;
- (IBAction)m_forceCrashButtonTap:(id)sender;
- (IBAction)m_thirdPartyCreditsButtonTap:(id)sender;

@end
