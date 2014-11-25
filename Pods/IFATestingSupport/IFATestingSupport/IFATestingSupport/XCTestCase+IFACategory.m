//
// Created by Marcelo Schroeder on 16/04/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import <UIKit/UIKit.h>
#import "IFACommonTests.h"

@implementation XCTestCase (IFACategory)

#pragma mark - Private

- (void)IFA_assertThatControl:(UIControl *)a_control hasEvent:(enum UIControlEvents)l_controlEvent
         configuredWithTarget:(id)a_target action:(SEL)a_action {
    NSArray *l_actions = [a_control actionsForTarget:a_target forControlEvent:l_controlEvent];
    assertThat(l_actions, hasItem(NSStringFromSelector(a_action)));
}

#pragma mark - Public

- (void)ifa_assertThatControl:(UIControl *)a_control hasTapEventConfiguredWithTarget:(id)a_target action:(SEL)a_action{
    [self IFA_assertThatControl:a_control hasEvent:UIControlEventTouchUpInside configuredWithTarget:a_target
                         action:a_action];
}

- (void)ifa_assertThatControl:(UIControl *)a_control hasValueChangedEventConfiguredWithTarget:(id)a_target action:(SEL)a_action{
    [self IFA_assertThatControl:a_control hasEvent:UIControlEventValueChanged configuredWithTarget:a_target
                         action:a_action];
}

- (void)ifa_assertThatBarButtonItem:(UIBarButtonItem *)a_barButtonItem hasTapEventConfiguredWithTarget:(id)a_target
                             action:(SEL)a_action{
    assertThat(a_barButtonItem.target, is(equalTo(a_target)));
    assertThat(NSStringFromSelector(a_barButtonItem.action), is(equalTo(NSStringFromSelector(a_action))));
}

- (void)ifa_assertThatControl:(UIControl *)a_control hasEditingChangedEventConfiguredWithTarget:(id)a_target action:(SEL)a_action{
    [self IFA_assertThatControl:a_control hasEvent:UIControlEventEditingChanged configuredWithTarget:a_target
                         action:a_action];
}

- (void)ifa_waitForSemaphore:(dispatch_semaphore_t)semaphore {
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)ifa_signalSemaphore:(dispatch_semaphore_t)semaphore {
    dispatch_semaphore_signal(semaphore);
}

- (dispatch_semaphore_t)ifa_createSemaphore {
    return dispatch_semaphore_create(0);
}

@end