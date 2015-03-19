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
#import "IFACoreUiConstants.h"
#import "IFAFormInputAccessoryView.h"
#import "IFAEntityConfig.h"
#import "UIViewController+IFACoreUI.h"

#ifdef IFA_AVAILABLE_Help
#import "IFAHelpTarget.h"
#endif

@protocol IFAFormViewControllerDelegate;
@class IFAFormSectionHeaderFooterView;
@class IFAPersistenceChangeDetector;

/**
* This view controller delivers a fully fledged form that allows viewing and editing of the object instance pointed by <object>.
* It implements two-way binding between view and model (<object>) by using GustyLib's persistent entity configuration system.
* This class optionally collaborates with a <IFAFormViewControllerDelegate> instance set in the <formViewControllerDelegate> property.
*/
@interface IFAFormViewController : IFATableViewController <UIActionSheetDelegate, IFAFormInputAccessoryViewDataSource, IFAViewControllerDelegate
#ifdef IFA_AVAILABLE_Help
        , IFAHelpTarget
#endif
        >
/**
* Object instance for which the form is displaying details.
*/
@property (nonatomic, strong) NSObject *object;

@property (nonatomic, strong) NSString *formName;
@property (nonatomic, weak, readonly) IFAFormViewController *parentFormViewController;
@property (nonatomic) BOOL textFieldCommitSuspended;
@property (nonatomic) BOOL createMode;
@property (nonatomic) BOOL readOnlyMode;
@property (nonatomic) BOOL showEditButton;

@property(nonatomic, strong, readonly) NSMutableDictionary *switchControlTagToPropertyName;
@property(nonatomic, strong, readonly) NSMutableDictionary *propertyNameToIndexPath;
@property(nonatomic, strong, readonly) IFAFormInputAccessoryView *formInputAccessoryView;

/**
* Optional delegate for this class.
*/
@property (nonatomic, weak) id<IFAFormViewControllerDelegate> formViewControllerDelegate;

/**
* Indicates whether the form view controller should automatically track and handle external changes to the instance pointed by the <managedObject> property.
* An external change is detected when an external update or a delete is performed on the <managedObject> instance.
* Default value: NO.
*
* External changes are constantly tracked and then checked at the time the user taps the "Save" button or deletes the object.
* If external changes exist, the form will inform the user that editing will be cancelled and any changes done locally will be discarded.
*/
@property (nonatomic) BOOL shouldHandleExternalChangesAutomatically;

/**
* Managed object instance for which the form is displaying details.
* This matches the instance returned by <object>, but it is nil when <object> is not a subclass of NSManagedObject.
*/
@property (nonatomic) NSManagedObject *managedObject;

- (IFAEntityConfigFieldType)fieldTypeForIndexPath:(NSIndexPath *)a_indexPath;

- (BOOL)shouldShowDeleteButton;

- (BOOL)isDestructiveButtonForCell:(IFAFormTableViewCell *)a_cell;

/**
* Clear section footer help text.
* This method can be called before table cell animations to avoid some undesired visual effects as a result of those animations.
* @param a_propertyName Property name whose section footer help text will be cleared.
*/
- (void)clearSectionFooterHelpTextForPropertyNamed:(NSString *)a_propertyName;

/* Non-coder based common initialiser */
- (id)initWithObject:(NSObject *)a_object
            readOnlyMode:(BOOL)a_readOnlyMode
              createMode:(BOOL)a_createMode
                  inForm:(NSString *)a_formName
parentFormViewController:(IFAFormViewController *)a_parentFormViewController
          showEditButton:(BOOL)a_showEditButton;

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

/**
* This method is called by tableView:viewForHeaderInSection: and tableView:heightForHeaderInSection: to determine the string to be used as the section header.
* It can be overridden to, for instance, provide a custom section header such as when the string has to change dynamically (as opposed to using a static string from EntityConfig.plist).
* @param a_section Section the header title relates to.
* @returns Header title for a given section.
*/
- (NSString *)titleForHeaderInSection:(NSInteger)a_section;

/**
* This method is called by tableView:viewForFooterInSection: and tableView:heightForFooterInSection: to determine the string to be used as the section footer.
* It can be overridden to, for instance, provide custom help content such as when the help string changes dynamically.
* @param a_section Section the footer title relates to.
* @returns Footer title for a given section.
*/
- (NSString *)titleForFooterInSection:(NSInteger)a_section;

@end

@protocol IFAFormViewControllerDelegate <NSObject>

@optional

/**
* This method is called when the user taps on a row configured with the "button" type in EntityConfig.plist.
* @param a_formViewController The caller.
* @param a_buttonName Name of the button as specified in EntityConfig.plist.
*/
- (void)formViewController:(IFAFormViewController *)a_formViewController didTapButtonNamed:(NSString *)a_buttonName;

/**
* This method is called when the has tapped on a field that requires presenting a view controller for viewing or editing.
* It gives an opportunity to modify the of the view controller about to be presented or even provide a different view controller instance.
* @param a_formViewController Form view controller presenting the field editor view controller.
* @param a_fieldEditorViewController Field editor view controller to be presented.
* @param a_indexPath Index path corresponding to the selected field.
* @param a_propertyName Name of the property corresponding to the field selected.
*/
- (UIViewController *)formViewController:(IFAFormViewController *)a_formViewController
    willPresentFieldEditorViewController:(UIViewController *)a_fieldEditorViewController
                            forIndexPath:(NSIndexPath *)a_indexPath
                            propertyName:(NSString *)a_propertyName;

/**
* This method allows for "pessimistic locking" of the form and can be used to, for instance, prevent changes to an object that could lead to data inconsistency due to external changes.
* It is called once before the form gets displayed for the first time and every time the user leaves editing mode either by cancelling it, saving changes or deleting the object.
*
* The form is locked by setting it to read-only mode and removing the "Edit" button from the navigation bar.
* A navigation bar prompt message can optionally be displayed.
* @param a_formViewController The sender.
* @param a_promptMessagePointer Optional pointer to set to a prompt message to be displayed on the navigation bar to help the user understand why the form is locked.
* @returns YES if the form should be locked, otherwise NO.
*/
- (BOOL)     formViewController:(IFAFormViewController *)a_formViewController
shouldLockFormWithPromptMessage:(NSString **)a_promptMessagePointer;

@end
