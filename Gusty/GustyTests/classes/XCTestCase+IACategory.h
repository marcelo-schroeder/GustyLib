//
// Created by Marcelo Schroeder on 16/08/13.
// Copyright (c) 2013 IAG. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


@interface XCTestCase (IACategory)
- (void)m_assertThatControl:(UIControl *)a_control hasTapEventConfiguredWithTarget:(id)a_target action:(SEL)a_action;

- (void)m_assertThatControl:(UIControl *)a_control hasValueChangedEventConfiguredWithTarget:(id)a_target
                                                                                     action:(SEL)a_action;

- (void)m_assertThatBarButtonItem:(UIBarButtonItem *)a_barButtonItem hasTapEventConfiguredWithTarget:(id)a_target
                                                                                              action:(SEL)a_action;

/*************************************************************/
/* Methods to turn asynchronous calls into synchronous calls */
/*************************************************************/
// First step: create the semaphore
- (dispatch_semaphore_t)m_createSemaphore;
// Intermediate step(s): signal the semaphore the asynchronous call has returned
- (void)m_signalSemaphore:(dispatch_semaphore_t)semaphore;

- (void)m_assertThatControl:(UIControl *)a_control hasEditingChangedEventConfiguredWithTarget:(id)a_target
                                                                                       action:(SEL)a_action;

// Last step: wait until the semaphore is signalled
- (void)m_waitForSemaphore:(dispatch_semaphore_t)semaphore;

@end