//
//  IFATextViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 9/04/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
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
#import "UIScrollView+IFACategory.h"

@interface IFATextViewController ()

@property (nonatomic, strong) NSString *ifa_originalTextViewValue;

@end

@implementation IFATextViewController {
    
}

#pragma mark - Private

- (void)ifa_onKeyboardDidShowNotification:(NSNotification *)aNotification{

    [self ifa_updateScrollViewContentSize];

    NSDictionary*l_userInfo = [aNotification userInfo];
    CGRect l_keyboardFrame = [[l_userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    // Convert frame to view coordinates to take device orientation into consideration
    l_keyboardFrame = [self.view convertRect:l_keyboardFrame fromView:nil];
    CGSize l_keyboardSize = l_keyboardFrame.size;

    UIEdgeInsets l_newContentInset = self.scrollView.contentInset;
    l_newContentInset.bottom = l_keyboardSize.height;
    self.scrollView.contentInset = l_newContentInset;
    self.scrollView.scrollIndicatorInsets = l_newContentInset;

    [self ifa_updateGrowingTextViewMinimumHeight];

    [self ifa_scrollToCaret];

}

- (void)ifa_onKeyboardWillHideNotification:(NSNotification *)aNotification{

    UIEdgeInsets l_newContentInset = self.scrollView.contentInset;
    l_newContentInset.bottom = 0;
    self.scrollView.contentInset = l_newContentInset;
    self.scrollView.scrollIndicatorInsets = l_newContentInset;

}

- (void)ifa_updateGrowingTextViewMinimumHeight {
//    self.growingTextView.minHeight = (int) (self.scrollView.frame.size.height - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom - self.growingTextView.frame.origin.y);
//    [self.growingTextView refreshHeight];
}

-(void)ifa_updateScrollViewContentSize {
    CGRect l_newContentViewFrame = self.contentView.frame;
    l_newContentViewFrame.size.height = self.growingTextView.frame.origin.y + self.growingTextView.frame.size.height;
    self.contentView.frame = l_newContentViewFrame;
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)ifa_quitEditing {
    [self IFA_notifySessionCompletion];
}

- (void)ifa_configureContentView {
    [[NSBundle mainBundle] loadNibNamed:@"CommentSubmissionFormView" owner:self
                                options:nil];
/*
    {
        // DEV ONLY - START
        self.contentView.backgroundColor = [UIColor orangeColor];
        // DEV ONLY - END
    }
*/
    self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
    self.contentView.autoresizingMask = [IFAUIUtils fullAutoresizingMask];
    [self.view addSubview:self.contentView];
}

- (void)ifa_scrollToCaret {
    if (self.growingTextView.internalTextView.isFirstResponder) {
        [self.scrollView IFA_scrollToCaretInTextView:self.growingTextView.internalTextView];
    }
}

- (void)ifa_configureTextView {
    self.growingTextView.minNumberOfLines = 1;
    self.growingTextView.maxHeight = NSIntegerMax;
    self.growingTextView.delegate = self;
    CGFloat l_horizontalInset = [IFAUtils isIOS7OrGreater] ? 3 : 0;
    self.growingTextView.contentInset = UIEdgeInsetsMake(0, l_horizontalInset, 0, l_horizontalInset);
/*
    {
        // DEV ONLY - START
        self.growingTextView.backgroundColor = [UIColor redColor];
        self.growingTextView.internalTextView.backgroundColor = [UIColor yellowColor];
        // DEV ONLY - END
    }
*/
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self ifa_updateScrollViewContentSize];
    [self ifa_updateGrowingTextViewMinimumHeight];
}

- (void)ifa_configureScrollView {
    self.scrollView.delegate = self;
/*
    {
        // DEV ONLY - START
        self.scrollView.backgroundColor = [UIColor greenColor];
        // DEV ONLY - END
    }
*/
}

#pragma mark - Public

-(BOOL)hasValueChanged {
    return ![self.ifa_originalTextViewValue isEqualToString:self.growingTextView.internalTextView.text];
}

- (IBAction)onCancelButtonAction:(id)sender {
    if ([self hasValueChanged]) {
        [IFAUIUtils showActionSheetWithMessage:@"Are you sure you want to discard your changes?"
                  destructiveButtonLabelSuffix:@"discard"
                                viewController:self
                                 barButtonItem:nil
                                      delegate:self
                                           tag:IFAViewTagActionSheetCancel];
    }else {
        [self ifa_quitEditing];
    }
}

-(UIResponder*)initialFirstResponder {
    return self.growingTextView.internalTextView;
}

#pragma mark - Overrides

-(void)viewDidLoad{

    [self ifa_configureContentView];

    [super viewDidLoad];

    [self ifa_configureScrollView];
    [self ifa_configureTextView];

    // Save text view's original value
    self.ifa_originalTextViewValue = self.growingTextView.internalTextView.text;

}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    // Show keyboard
    [[self initialFirstResponder] becomeFirstResponder];

}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    // Hide keyboard
    [self.view endEditing:YES];
    
}

-(void)IFA_onKeyboardNotification:(NSNotification*)a_notification {
    if ([a_notification.name isEqualToString:UIKeyboardDidShowNotification]) {
        [self ifa_onKeyboardDidShowNotification:a_notification];
    } else if ([a_notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        [self ifa_onKeyboardWillHideNotification:a_notification];
    }
}

#pragma mark - HPGrowingTextViewDelegate

- (void)growingTextView:(IFA_HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    [self ifa_updateScrollViewContentSize];
    [self ifa_scrollToCaret];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        [self ifa_quitEditing];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
