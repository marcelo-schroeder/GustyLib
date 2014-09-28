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
#import "IFAFormInputAccessoryView.h"
#import "IFAEntityConfig.h"

#ifdef IFA_AVAILABLE_Help
#import "IFAHelpTarget.h"
#endif

@protocol IFAFormViewControllerDelegate;

@interface IFAFormViewController : IFATableViewController <UIActionSheetDelegate, IFAFormInputAccessoryViewDataSource
#ifdef IFA_AVAILABLE_Help
        , IFAHelpTarget
#endif
        >

@property (nonatomic, strong) NSObject *object;
@property (nonatomic, strong) NSString *formName;
@property (nonatomic, weak, readonly) IFAFormViewController *parentFormViewController;
@property (nonatomic) BOOL textFieldCommitSuspended;
@property (nonatomic) BOOL createMode;
@property (nonatomic) BOOL readOnlyMode;
@property (nonatomic) BOOL showEditButton;

@property(nonatomic, strong, readonly) NSMutableDictionary *tagToPropertyName;
@property(nonatomic, strong, readonly) NSMutableDictionary *propertyNameToIndexPath;
@property(nonatomic, strong, readonly) IFAFormInputAccessoryView *formInputAccessoryView;

@property (nonatomic, weak) id<IFAFormViewControllerDelegate> formViewControllerDelegate;

- (IFAEntityConfigFieldType)fieldTypeForIndexPath:(NSIndexPath *)a_indexPath;

- (BOOL)shouldShowDeleteButton;

- (BOOL)isDestructiveButtonForCell:(IFAFormTableViewCell *)a_cell;

/* Submission forms */
- (id)initWithObject:(NSObject *)a_object;
- (id)    initWithObject:(NSObject *)a_object inForm:(NSString *)a_formName
parentFormViewController:(IFAFormViewController *)a_parentFormViewController;

/* CRUD forms */
- (id)initWithObject:(NSObject *)a_object createMode:(BOOL)a_createMode;
- (id)    initWithObject:(NSObject *)a_object createMode:(BOOL)a_createMode inForm:(NSString *)a_formName
parentFormViewController:(IFAFormViewController *)a_parentFormViewController;
- (id)initWithReadOnlyObject:(NSObject *)anObject;
- (id)initWithReadOnlyObject:(NSObject *)a_object inForm:(NSString *)a_formName
    parentFormViewController:(IFAFormViewController *)a_parentFormViewController
              showEditButton:(BOOL)a_showEditButton;

- (void)onSegmentedControlAction:(id)aSender;

- (IFAFormTableViewCellAccessoryType)accessoryTypeForIndexPath:(NSIndexPath *)a_indexPath;

- (IFAEditorType)editorTypeForIndexPath:(NSIndexPath *)anIndexPath;

- (NSIndexPath *)indexPathForPropertyNamed:(NSString *)a_propertyName;

-(IFAFormTableViewCell *)populateCell:(IFAFormTableViewCell *)a_cell;

- (void)onSwitchAction:(UISwitch*)a_switch;

- (void)handleReturnKeyForTextFieldCell:(IFAFormTextFieldTableViewCell *)a_cell;

- (BOOL)isSubForm;

/* to be overridden by subclasses */
- (void)onNavigationBarSubmitButtonTap;

- (NSString *)labelForIndexPath:(NSIndexPath *)anIndexPath;

- (NSString *)nameForIndexPath:(NSIndexPath *)anIndexPath;

- (NSString *)entityNameForProperty:(NSString *)aPropertyName;

-(void)updateBackingPreferences;

- (void)updateAndSaveBackingPreferences;

@end

@protocol IFAFormViewControllerDelegate <NSObject>

@optional

/**
* This method is called when the user taps on a row configured with the "button" type in EntityConfig.plist.
* @param a_formViewController The caller.
* @param a_buttonName Name of the button as specified in EntityConfig.plist.
*/
- (void)formViewController:(IFAFormViewController *)a_formViewController didTapButtonNamed:(NSString *)a_buttonName;

@end
