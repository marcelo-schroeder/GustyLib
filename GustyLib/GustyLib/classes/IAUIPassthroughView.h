//
// Created by Marcelo Schroeder on 29/01/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IAUIView.h"

// This view can be used to detect hits and, for instance, hide the keyboard when a UIView that conforms to UITextInput is hit.
@interface IAUIPassthroughView : IAUIView

@property (nonatomic, strong) void(^p_hitTestBlock)(CGPoint a_point, UIEvent *a_event, UIView *a_view);
@property (nonatomic) BOOL p_shouldDismissKeyboardOnNonTextInputInteractions;

- (void)m_commonInit;
@end