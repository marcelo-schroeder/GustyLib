//
// Created by Marcelo Schroeder on 29/01/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

#import "IAUIView.h"

// This view can be used to detect hits and, for instance, hide the keyboard when a UIView that conforms to UITextInput is hit.
@interface IAUIPassthroughView : IAUIView

@property (nonatomic, strong) void(^p_hitTestBlock)(CGPoint a_point, UIEvent *a_event, UIView *a_view);
@property (nonatomic) BOOL p_shouldDismissKeyboardOnNonTextInputInteractions;

- (void)m_commonInit;
@end