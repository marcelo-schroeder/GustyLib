//
//  IFAFormViewController.h
//  Gusty
//
//  Created by Marcelo Schroeder on 25/08/09.
//  Copyright 2009 InfoAccent Pty Limited. All rights reserved.
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

#import "IFATableViewController.h"
#import "IFAFormTableViewCell.h"
#import "IFAFormTextFieldTableViewCell.h"
#import "IFAConstants.h"

@interface IFAFormViewController : IFATableViewController <UIActionSheetDelegate>

@property (nonatomic, strong) NSObject *object;
@property (nonatomic, strong) NSString *formName;
@property (nonatomic) BOOL textFieldCommitSuspended;
@property (nonatomic) BOOL createMode;
@property (nonatomic) BOOL readOnlyMode;
@property (nonatomic) BOOL isSubForm;

@property(nonatomic, strong, readonly) NSMutableDictionary *tagToPropertyName;
@property(nonatomic, strong, readonly) NSMutableDictionary *propertyNameToIndexPath;

/* Submission forms */
- (id)initWithObject:(NSObject *)anObject;
- (id)initWithObject:(NSObject *)anObject inForm:(NSString *)aFormName isSubForm:(BOOL)aSubFormFlag;

/* CRUD forms */
- (id)initWithObject:(NSObject *)anObject createMode:(BOOL)aCreateMode;
- (id)initWithObject:(NSObject *)anObject createMode:(BOOL)aCreateMode inForm:(NSString*)aFormName isSubForm:(BOOL)aSubFormFlag;
- (id)initWithReadOnlyObject:(NSObject *)anObject;
- (id)initWithReadOnlyObject:(NSObject *)anObject inForm:(NSString*)aFormName isSubForm:(BOOL)aSubFormFlag;

- (void)onSegmentedControlAction:(id)aSender;

- (IFAFormTableViewCellAccessoryType)accessoryTypeForIndexPath:(NSIndexPath *)a_indexPath;

- (IFAEditorType)editorTypeForIndexPath:(NSIndexPath *)anIndexPath;

-(IFAFormTableViewCell *)populateCell:(IFAFormTableViewCell *)a_cell;

- (void)onSwitchAction:(UISwitch*)a_switch;

- (void)handleReturnKeyForTextFieldCell:(IFAFormTextFieldTableViewCell *)a_cell;

/* to be overridden by subclasses */
- (void)onSubmitButtonTap;

- (NSString *)labelForIndexPath:(NSIndexPath *)anIndexPath;

- (NSString *)nameForIndexPath:(NSIndexPath *)anIndexPath;

- (NSString *)entityNameForProperty:(NSString *)aPropertyName;

-(void)updateBackingPreferences;

@end
