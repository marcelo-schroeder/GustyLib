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

#import "GustyLibCoreUI.h"

@interface IFATextViewController ()

@property (nonatomic, strong) NSString *IFA_originalTextViewValue;

@end

@implementation IFATextViewController {
    
}

#pragma mark - Private

- (void)IFA_onKeyboardDidShowNotification:(NSNotification *)aNotification{

    [self IFA_updateScrollViewContentSize];

    NSDictionary*l_userInfo = [aNotification userInfo];
    CGRect l_keyboardFrame = [[l_userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    // Convert frame to view coordinates to take device orientation into consideration
    l_keyboardFrame = [self.view convertRect:l_keyboardFrame fromView:nil];
    CGSize l_keyboardSize = l_keyboardFrame.size;

    UIEdgeInsets l_newContentInset = self.scrollView.contentInset;
    l_newContentInset.bottom = l_keyboardSize.height;
    self.scrollView.contentInset = l_newContentInset;
    self.scrollView.scrollIndicatorInsets = l_newContentInset;

    [self IFA_updateGrowingTextViewMinimumHeight];

    [self IFA_scrollToCaret];

}

- (void)IFA_onKeyboardWillHideNotification:(NSNotification *)aNotification{

    UIEdgeInsets l_newContentInset = self.scrollView.contentInset;
    l_newContentInset.bottom = 0;
    self.scrollView.contentInset = l_newContentInset;
    self.scrollView.scrollIndicatorInsets = l_newContentInset;

}

- (void)IFA_updateGrowingTextViewMinimumHeight {
//    self.growingTextView.minHeight = (int) (self.scrollView.frame.size.height - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom - self.growingTextView.frame.origin.y);
//    [self.growingTextView refreshHeight];
}

-(void)IFA_updateScrollViewContentSize {
    CGRect l_newContentViewFrame = self.contentView.frame;
    l_newContentViewFrame.size.height = self.growingTextView.frame.origin.y + self.growingTextView.frame.size.height;
    self.contentView.frame = l_newContentViewFrame;
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)IFA_quitEditing {
    [self ifa_notifySessionCompletion];
}

- (void)IFA_configureContentView {
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

- (void)IFA_scrollToCaret {
    if (self.growingTextView.internalTextView.isFirstResponder) {
        [self.scrollView ifa_scrollToCaretInTextView:self.growingTextView.internalTextView];
    }
}

- (void)IFA_configureTextView {
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
    [self IFA_updateScrollViewContentSize];
    [self IFA_updateGrowingTextViewMinimumHeight];
}

- (void)IFA_configureScrollView {
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
    return ![self.IFA_originalTextViewValue isEqualToString:self.growingTextView.internalTextView.text];
}

- (IBAction)onCancelButtonAction:(id)sender {
    if ([self hasValueChanged]) {
        __weak __typeof(self) l_weakSelf = self;
        void (^destructiveActionBlock)() = ^{
            [l_weakSelf IFA_quitEditing];
        };
        [self ifa_presentAlertControllerWithTitle:nil
                                          message:@"Are you sure you want to discard your changes?"
                     destructiveActionButtonTitle:@"Discard changes"
                           destructiveActionBlock:destructiveActionBlock
                                      cancelBlock:nil];



    }else {
        [self IFA_quitEditing];
    }
}

-(UIResponder*)initialFirstResponder {
    return self.growingTextView.internalTextView;
}

#pragma mark - Overrides

-(void)viewDidLoad{

    [self IFA_configureContentView];

    [super viewDidLoad];

    [self IFA_configureScrollView];
    [self IFA_configureTextView];

    // Save text view's original value
    self.IFA_originalTextViewValue = self.growingTextView.internalTextView.text;

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

-(void)ifa_onKeyboardNotification:(NSNotification*)a_notification {
    if ([a_notification.name isEqualToString:UIKeyboardDidShowNotification]) {
        [self IFA_onKeyboardDidShowNotification:a_notification];
    } else if ([a_notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        [self IFA_onKeyboardWillHideNotification:a_notification];
    }
}

#pragma mark - HPGrowingTextViewDelegate

- (void)growingTextView:(IFA_HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    [self IFA_updateScrollViewContentSize];
    [self IFA_scrollToCaret];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
