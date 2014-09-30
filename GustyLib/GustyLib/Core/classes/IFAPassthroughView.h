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

#import "IFAView.h"

// This view can be used to detect hits and, for instance, hide the keyboard when a UIView that conforms to UITextInput is hit (e.g. the clear button in a text field)
@interface IFAPassthroughView : IFAView

/**
* As hitTest:withEvent: may be called multiple times, do not implement logic in this block that cannot be called multiple times.
* In fact, hitTest:withEvent: should not have side effects at all.
* A potential solution for this would be to move the side effect behaviour to the recently added touchesEndedBlock property. But the final implementation might be a collaboration between hitTestBlock and touchesEndedBlock.
*/
@property (nonatomic, strong) UIView *(^hitTestBlock)(CGPoint a_point, UIEvent *a_event, UIView *a_predictedView);

/**
* This block set here will be called at when touchesEnded:withEvent: is called on an instance of this class.
*/
@property (nonatomic, strong) void(^touchesEndedBlock)(NSSet *a_touches, UIEvent *a_event);

/**
* IMPORTANT: enabling this may cause some issues. The problem is that hitTest:withEvent: should not have any side effects as it may be called multiple times.
* The behaviour enabled by this property relies on hitTest:withEvent:, which is incorrect. This should be rectified soon.
*/
@property (nonatomic) BOOL shouldDismissKeyboardOnNonTextInputInteractions;

@end