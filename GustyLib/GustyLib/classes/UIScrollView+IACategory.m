//
// Created by Marcelo Schroeder on 24/09/13.
// Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIScrollView+IACategory.h"


static const CGFloat k_caretScrollBottomInset = 7;

@implementation UIScrollView (IACategory)

#pragma mark - Public

- (void)m_scrollToCaretInTextView:(UITextView *)a_textView {
    NSRange l_selectedRange = a_textView.selectedRange;
    UITextPosition *l_positionUpToCaret = [a_textView positionFromPosition:a_textView.beginningOfDocument
                                                                    offset:l_selectedRange.location];
//    NSLog(@"l_positionUpToCaret: %@", [l_positionUpToCaret description]);
    UITextPosition *l_caretPosition = [a_textView positionFromPosition:l_positionUpToCaret
                                                                offset:l_selectedRange.length];
//    NSLog(@"l_caretPosition: %@", [l_caretPosition description]);
    CGRect l_caretFrameInTextView = [a_textView caretRectForPosition:l_caretPosition];
//    NSLog(@"l_caretFrameInTextView: %@", NSStringFromCGRect(l_caretFrameInTextView));
    CGRect l_caretFrameInWindow = [a_textView convertRect:l_caretFrameInTextView toView:nil];
    CGRect l_caretFrameInScrollView = [self convertRect:l_caretFrameInWindow
                                               fromView:nil];
    CGRect l_scrollToRect = l_caretFrameInScrollView;
//    NSLog(@"  l_scrollToRect: %@", NSStringFromCGRect(l_scrollToRect));
    l_scrollToRect.size.height += k_caretScrollBottomInset;
    [self scrollRectToVisible:l_scrollToRect animated:YES];
}

@end