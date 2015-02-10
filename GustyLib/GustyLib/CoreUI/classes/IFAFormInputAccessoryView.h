//
// Created by Marcelo Schroeder on 27/08/2014.
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

#import <Foundation/Foundation.h>
#import "IFAView.h"

@protocol IFAFormInputAccessoryViewDataSource;

typedef NS_ENUM(NSUInteger, IFAFormInputAccessoryViewDirection){
    IFAFormInputAccessoryViewDirectionPrevious,
    IFAFormInputAccessoryViewDirectionNext,
};

/**
* Input accessory view that manages a toolbar containing buttons (i.e. previous and next) for navigating through input fields that accept keyboard input in a form view.
* It also presents a Done button to dismiss the keyboard.
*/
@interface IFAFormInputAccessoryView : IFAView

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *previousBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;

@property (weak, nonatomic) id<IFAFormInputAccessoryViewDataSource> dataSource;

/**
* Designated initializer.
* @param a_tableView Table view instance used to implement the form view.
*/
- (instancetype)initWithTableView:(UITableView *)a_tableView;

/**
* Call this method to notify that a given index path contains an input field that has now become the keyboard focus (i.e. user has manually tapped on an input field).
* This method will allow the receiver to update its internal state with the most up to date information.
* This method is normally called from UITextFieldDelegate's implementation of the textFieldDidBeginEditing: method.
* @param a_indexPath Index path that contains the input field which has become the keyboard focus.
*/
- (void)notifyOfCurrentInputFieldIndexPath:(NSIndexPath *)a_indexPath;

/**
* Call this method to notify that table view scrolling has ended.
* This method will allow the receiver to complete any pending UI state changes such as adding keyboard focus to a field has just been scrolled to.
* This method is normally called from UIScrollViewDelegate's implementation of the scrollViewDidEndScrollingAnimation: method.
*/
- (void)notifyTableViewDidEndScrollingAnimation;

- (IBAction)onDoneButtonTap;
- (IBAction)onPreviousButtonTap;
- (IBAction)onNextButtonTap;

/**
* Call this method to move the keyboard input focus to the cell at the index path specified.
* Before moving the focus, this method will check if it is possible for the current focus to resign being the first responder by calling the canResignFirstResponder method on the current first responder.
* The current first responder is obtained by calling the formInputAccessoryView:responderForKeyboardInputFocusAtIndexPath: delegate method.
* If it is not possible to resign the first responder, then the input focus will not change.
* The above means that this method works well in conjunction with any validations already implemented by the responders.
* @param a_indexPath Index path of the cell to point the input focus at.
*/
- (void)moveInputFocusToIndexPath:(NSIndexPath *)a_indexPath;

@end

@protocol IFAFormInputAccessoryViewDataSource <NSObject>

/**
* This method allows the caller to update the UI state of the navigation buttons.
* @return YES if the given index path has an input field that can receive keyboard focus.
*/
- (BOOL)    formInputAccessoryView:(IFAFormInputAccessoryView *)a_formInputAccessoryView
canReceiveKeyboardInputAtIndexPath:(NSIndexPath *)a_indexPath;

/**
* This allows the caller to move the keyboard focus to the specified responder.
* @return An instance that will become the first responder to gain keyboard input focus.
*/
- (UIResponder *)  formInputAccessoryView:(IFAFormInputAccessoryView *)a_formInputAccessoryView
responderForKeyboardInputFocusAtIndexPath:(NSIndexPath *)a_indexPath;

@end