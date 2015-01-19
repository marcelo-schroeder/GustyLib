//
// Created by Marcelo Schroeder on 24/09/13.
// Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
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

#import "UIScrollView+IFACoreUI.h"


static const CGFloat k_caretScrollBottomInset = 7;

@implementation UIScrollView (IFACoreUI)

#pragma mark - Public

- (void)ifa_scrollToCaretInTextView:(UITextView *)a_textView {
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