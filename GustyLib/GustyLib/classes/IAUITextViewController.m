//
//  IAUITextViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 9/04/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//

#import "IACommon.h"
#import "UIScrollView+IACategory.h"

@interface IAUITextViewController ()

@property (nonatomic, strong) NSString *p_originalTextViewValue;

@end

@implementation IAUITextViewController{
    
}

#pragma mark - Private

- (void)m_onKeyboardDidShowNotification:(NSNotification *)aNotification{

    [self m_updateScrollViewContentSize];

    NSDictionary*l_userInfo = [aNotification userInfo];
    CGRect l_keyboardFrame = [[l_userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    // Convert frame to view coordinates to take device orientation into consideration
    l_keyboardFrame = [self.view convertRect:l_keyboardFrame fromView:nil];
    CGSize l_keyboardSize = l_keyboardFrame.size;

    UIEdgeInsets l_newContentInset = self.p_scrollView.contentInset;
    l_newContentInset.bottom = l_keyboardSize.height;
    self.p_scrollView.contentInset = l_newContentInset;
    self.p_scrollView.scrollIndicatorInsets = l_newContentInset;

    [self m_updateGrowingTextViewMinimumHeight];

    [self m_scrollToCaret];

}

- (void)m_updateGrowingTextViewMinimumHeight {
//    self.p_growingTextView.minHeight = (int) (self.p_scrollView.frame.size.height - self.p_scrollView.contentInset.top - self.p_scrollView.contentInset.bottom - self.p_growingTextView.frame.origin.y);
//    [self.p_growingTextView refreshHeight];
}

- (void)m_onKeyboardWillHideNotification:(NSNotification *)aNotification{

    UIEdgeInsets l_newContentInset = self.p_scrollView.contentInset;
    l_newContentInset.bottom = 0;
    self.p_scrollView.contentInset = l_newContentInset;
    self.p_scrollView.scrollIndicatorInsets = l_newContentInset;

}

-(void)m_updateScrollViewContentSize {
    CGRect l_newContentViewFrame = self.p_contentView.frame;
    l_newContentViewFrame.size.height = self.p_growingTextView.frame.origin.y + self.p_growingTextView.frame.size.height;
    self.p_contentView.frame = l_newContentViewFrame;
    self.p_scrollView.contentSize = self.p_contentView.frame.size;
}

- (void)m_quitEditing{
    [self m_notifySessionCompletion];
}

- (void)m_configureContentView {
    [[NSBundle mainBundle] loadNibNamed:@"CommentSubmissionFormView" owner:self
                                options:nil];
/*
    {
        // DEV ONLY - START
        self.p_contentView.backgroundColor = [UIColor orangeColor];
        // DEV ONLY - END
    }
*/
    self.p_contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
    self.p_contentView.autoresizingMask = [IAUIUtils m_fullAutoresizingMask];
    [self.view addSubview:self.p_contentView];
}

- (void)m_scrollToCaret {
    if (self.p_growingTextView.internalTextView.isFirstResponder) {
        [self.p_scrollView m_scrollToCaretInTextView:self.p_growingTextView.internalTextView];
    }
}

- (void)m_configureTextView {
    self.p_growingTextView.minNumberOfLines = 1;
    self.p_growingTextView.maxHeight = NSIntegerMax;
    self.p_growingTextView.delegate = self;
    CGFloat l_horizontalInset = [IAUtils m_isIOS7OrGreater] ? 3 : 0;
    self.p_growingTextView.contentInset = UIEdgeInsetsMake(0, l_horizontalInset, 0, l_horizontalInset);
/*
    {
        // DEV ONLY - START
        self.p_growingTextView.backgroundColor = [UIColor redColor];
        self.p_growingTextView.internalTextView.backgroundColor = [UIColor yellowColor];
        // DEV ONLY - END
    }
*/
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self m_updateScrollViewContentSize];
    [self m_updateGrowingTextViewMinimumHeight];
}

- (void)m_configureScrollView {
    self.p_scrollView.delegate = self;
/*
    {
        // DEV ONLY - START
        self.p_scrollView.backgroundColor = [UIColor greenColor];
        // DEV ONLY - END
    }
*/
}

#pragma mark - Public

-(BOOL)m_hasValueChanged{
    return ![self.p_originalTextViewValue isEqualToString:self.p_growingTextView.internalTextView.text];
}

- (IBAction)m_onCancelButtonAction:(id)sender {
    if ([self m_hasValueChanged]) {
        [IAUIUtils showActionSheetWithMessage:@"Are you sure you want to discard your changes?"
                 destructiveButtonLabelSuffix:@"discard"
                               viewController:self
                                barButtonItem:nil
                                     delegate:self
                                          tag:IA_UIVIEW_TAG_ACTION_SHEET_CANCEL];
    }else {
        [self m_quitEditing];
    }
}

-(UIResponder*)m_initialFirstResponder{
    return self.p_growingTextView.internalTextView;
}

#pragma mark - Overrides

-(void)viewDidLoad{

    [self m_configureContentView];

    [super viewDidLoad];

    [self m_configureScrollView];
    [self m_configureTextView];

    // Save text view's original value
    self.p_originalTextViewValue = self.p_growingTextView.internalTextView.text;

}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onKeyboardDidShowNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onKeyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    // Show keyboard
    [[self m_initialFirstResponder] becomeFirstResponder];

}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    // Hide keyboard
    [self.view endEditing:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - HPGrowingTextViewDelegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height {
    [self m_updateScrollViewContentSize];
    [self m_scrollToCaret];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        [self m_quitEditing];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
