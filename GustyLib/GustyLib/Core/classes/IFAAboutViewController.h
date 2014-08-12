//
//  IFAAboutViewController.h
//  GustyLib
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

#import "IFAViewController.h"

@interface IFAAboutViewController : IFAViewController

@property (strong, nonatomic) IBOutlet UILabel *appNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *editionLabel;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *copyrightNoticeLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdByLabel;
@property (strong, nonatomic) IBOutlet UILabel *visualDesignByLabel;
@property (strong, nonatomic) IBOutlet UIButton *bugReportButton;
@property (strong, nonatomic) IBOutlet UIButton *feedbackButton;
@property (strong, nonatomic) IBOutlet UIButton *forceCrashButton;
@property (strong, nonatomic) IBOutlet UIButton *thirdPartyCreditsButton;

- (IBAction)bugReportButtonTap:(id)sender;
- (IBAction)feedbackButtonTap:(id)sender;
- (IBAction)forceCrashButtonTap:(id)sender;
- (IBAction)thirdPartyCreditsButtonTap:(id)sender;

@end
