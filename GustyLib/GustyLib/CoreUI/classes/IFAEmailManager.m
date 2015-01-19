//
//  IFAEmailManager.m
//  Gusty
//
//  Created by Marcelo Schroeder on 16/02/12.
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

#import "GustyLibCoreUI.h"

@interface IFAEmailManager ()
@property (nonatomic, weak) UIViewController *IFA_parentViewController;
@property (nonatomic, strong) void (^completionBlock)(void);
@end

@implementation IFAEmailManager

#pragma mark - Public

-(id)initWithParentViewController:(UIViewController *)a_parentViewController{
    return [self initWithParentViewController:a_parentViewController completionBlock:^{}];
}

-(id)initWithParentViewController:(UIViewController*)a_parentViewController completionBlock:(void (^)(void))a_completionBlock{
    if (self=[super init]) {
        self.IFA_parentViewController = a_parentViewController;
        self.completionBlock = a_completionBlock;
    }
    return self;
}

-(void)composeEmailWithSubject:(NSString *)a_subject recipient:(NSString *)a_recipient body:(NSString *)a_body{
    [self composeEmailWithSubject:a_subject recipient:a_recipient body:a_body attachmentUrl:nil attachmentMimeType:nil];
}

-(void)composeEmailWithSubject:(NSString *)a_subject recipient:(NSString *)a_recipient body:(NSString *)a_body
                 attachmentUrl:(NSURL *)a_attachmentUrl attachmentMimeType:(NSString*)a_attachmentMimeType{
    
    if ([MFMailComposeViewController canSendMail]){

        MFMailComposeViewController *l_mailer = [[MFMailComposeViewController alloc] init];
        l_mailer.mailComposeDelegate = self;
        [l_mailer setSubject:a_subject];
        if (a_recipient) {
            [l_mailer setToRecipients:@[a_recipient]];
        }
        [l_mailer setMessageBody:a_body isHTML:NO];
        if (a_attachmentUrl && a_attachmentMimeType) {
            NSData *l_attachmentData = [[NSData alloc] initWithContentsOfURL:a_attachmentUrl];
//            NSLog(@"a_attachmentUrl.lastPathComponent: %@", a_attachmentUrl.lastPathComponent);
            [l_mailer addAttachmentData:l_attachmentData mimeType:a_attachmentMimeType fileName:a_attachmentUrl.lastPathComponent];
        }
        [self.IFA_parentViewController presentViewController:l_mailer animated:YES completion:nil];
        
    }else{
        
        [IFAUIUtils showAlertWithMessage:@"This device is not able to send email!" title:@"Warning"];

    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    
    self.completionBlock();
    
    // Remove the mail view
    [self.IFA_parentViewController dismissViewControllerAnimated:YES completion:NULL];
    
    if (result==MFMailComposeResultFailed) {
        [IFAUtils dispatchAsyncMainThreadBlock:^{
            [IFAUIUtils showAlertWithMessage:@"The email has not been sent due to an error." title:@"Email Error"];
        }                           afterDelay:0.1];
    }
    
}

@end
