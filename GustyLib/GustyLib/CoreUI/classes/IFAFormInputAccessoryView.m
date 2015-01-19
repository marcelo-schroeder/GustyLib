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

#import "GustyLibCoreUI.h"

@interface IFAFormInputAccessoryView ()

@property (weak, nonatomic) UITableView *IFA_tableView;
@property (strong, nonatomic) NSIndexPath *IFA_currentInputFieldIndexPath;
@property (strong, nonatomic) NSIndexPath *IFA_previousInputFieldIndexPath;
@property (strong, nonatomic) NSIndexPath *IFA_nextInputFieldIndexPath;
@property(nonatomic) BOOL IFA_scrollRequested;
@property (strong, nonatomic) NSIndexPath *IFA_scrollPendingIndexPath;

@end

@implementation IFAFormInputAccessoryView {

}

#pragma mark - Private

- (void)IFA_updateUiState {
    self.previousBarButtonItem.enabled = self.IFA_previousInputFieldIndexPath != nil;
    self.nextBarButtonItem.enabled = self.IFA_nextInputFieldIndexPath != nil;
}

- (NSIndexPath *)IFA_indexPathForDirection:(IFAFormInputAccessoryViewDirection)a_direction {
//    NSLog(@" ");
//    NSLog(@"self.IFA_currentInputFieldIndexPath: %@", [self.IFA_currentInputFieldIndexPath description]);

    NSIndexPath *l_inputFieldIndexPath = nil;

    NSInteger l_loopIncrement = (a_direction == IFAFormInputAccessoryViewDirectionNext) ? 1 : -1;

    NSInteger l_numberOfSections = [self.IFA_tableView.dataSource numberOfSectionsInTableView:self.IFA_tableView];
//    NSLog(@"l_numberOfSections: %u", l_numberOfSections);
    for (NSInteger l_section = self.IFA_currentInputFieldIndexPath.section; l_section >= 0 && l_section < l_numberOfSections; ) {
        @autoreleasepool {
            NSInteger l_numberOfRows = [self.IFA_tableView.dataSource tableView:self.IFA_tableView
                                                          numberOfRowsInSection:l_section];
//            NSLog(@"l_numberOfRows: %u", l_numberOfRows);
            NSInteger l_startRow = 0;
            if (l_section==self.IFA_currentInputFieldIndexPath.section) {
                l_startRow = self.IFA_currentInputFieldIndexPath.row;
            }else if(a_direction == IFAFormInputAccessoryViewDirectionPrevious){
                l_startRow = l_numberOfRows - 1;
            }
            for (NSInteger l_row = l_startRow; l_row >= 0 && l_row < l_numberOfRows; ) {
                @autoreleasepool {
//                    NSLog(@"  %u-%u", l_section, l_row);
                    NSIndexPath *l_indexPath = [NSIndexPath indexPathForRow:l_row inSection:l_section];
                    if (![l_indexPath isEqual:self.IFA_currentInputFieldIndexPath]) {
//                        NSLog(@"    not current field");
                        if ([self.dataSource formInputAccessoryView:self canReceiveKeyboardInputAtIndexPath:l_indexPath]) {
//                            NSLog(@"      is input field");
                            l_inputFieldIndexPath = l_indexPath;
                            goto label_inputFieldCellFound;
                        }
                    }
                    l_row += l_loopIncrement;
                }
            }
            l_section += l_loopIncrement;
        }
    }
    label_inputFieldCellFound:

    return l_inputFieldIndexPath;
}

#pragma mark - Public

- (id)initWithTableView:(UITableView *)a_tableView {

    if(self = [super init]){
        self.IFA_tableView = a_tableView;
        NSBundle *l_bundle = [NSBundle bundleForClass:[self class]];
        [l_bundle loadNibNamed:@"IFAFormInputAccessoryContentView" owner:self options:nil];
        [self addSubview:self.contentView];
        self.bounds = self.contentView.bounds;
        [self.contentView ifa_addLayoutConstraintsToFillSuperview];
    }

    return self;
}

- (void)notifyOfCurrentInputFieldIndexPath:(NSIndexPath *)a_indexPath {
    self.IFA_currentInputFieldIndexPath = a_indexPath;
    self.IFA_previousInputFieldIndexPath = [self IFA_indexPathForDirection:IFAFormInputAccessoryViewDirectionPrevious];
    self.IFA_nextInputFieldIndexPath = [self IFA_indexPathForDirection:IFAFormInputAccessoryViewDirectionNext];
//    NSLog(@" ");
//    NSLog(@"self.IFA_currentInputFieldIndexPath: %@", [self.IFA_currentInputFieldIndexPath description]);
//    NSLog(@"self.IFA_previousInputFieldIndexPath: %@", [self.IFA_previousInputFieldIndexPath description]);
//    NSLog(@"self.IFA_nextInputFieldIndexPath: %@", [self.IFA_nextInputFieldIndexPath description]);
    [self IFA_updateUiState];
}

- (void)notifyTableViewDidEndScrollingAnimation {
    if (self.IFA_scrollRequested && [self.IFA_scrollPendingIndexPath isEqual:self.IFA_currentInputFieldIndexPath]) {
        self.IFA_scrollRequested = NO;
        UIResponder *l_responderToBe = [self.dataSource formInputAccessoryView:self
           responderForKeyboardInputFocusAtIndexPath:self.IFA_currentInputFieldIndexPath];
        [l_responderToBe becomeFirstResponder];
    }
}

- (IBAction)onDoneButtonTap {
    [self.IFA_tableView endEditing:YES];
}

- (IBAction)onPreviousButtonTap {
    [self moveInputFocusToIndexPath:self.IFA_previousInputFieldIndexPath];
}

- (IBAction)onNextButtonTap {
    [self moveInputFocusToIndexPath:self.IFA_nextInputFieldIndexPath];
}

- (void)moveInputFocusToIndexPath:(NSIndexPath *)a_indexPath {
    UIResponder *l_currentResponder = [self.dataSource formInputAccessoryView:self
                                    responderForKeyboardInputFocusAtIndexPath:self.IFA_currentInputFieldIndexPath];
    if ([l_currentResponder canResignFirstResponder]) {
        self.IFA_currentInputFieldIndexPath = a_indexPath;
        if (a_indexPath) {
            UITableView *l_tableView = self.IFA_tableView;
            if ([l_tableView ifa_isCellFullyVisibleForRowAtIndexPath:a_indexPath]) {
                UIResponder *l_responderToBe = [self.dataSource formInputAccessoryView:self
                                             responderForKeyboardInputFocusAtIndexPath:a_indexPath];
                [l_responderToBe becomeFirstResponder];
            } else {
                [l_tableView scrollToRowAtIndexPath:a_indexPath
                                   atScrollPosition:UITableViewScrollPositionTop
                                           animated:YES];
                self.IFA_scrollRequested = YES;
                self.IFA_scrollPendingIndexPath = a_indexPath;
            }
        }
    }
}

@end