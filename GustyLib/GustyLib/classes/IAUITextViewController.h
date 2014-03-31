//
//  IAUITextViewController.h
//  Gusty
//
//  Created by Marcelo Schroeder on 9/04/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//

#import "IAUIViewController.h"

@interface IAUITextViewController : IAUIViewController <IA_HPGrowingTextViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *p_contentView;
@property (strong, nonatomic) IBOutlet UIScrollView *p_scrollView;
@property (strong, nonatomic) IBOutlet IA_HPGrowingTextView *p_growingTextView;

- (IBAction)m_onCancelButtonAction:(id)sender;

// To be overriden by subclasses
-(BOOL)m_hasValueChanged;

-(UIResponder*)m_initialFirstResponder;

@end
