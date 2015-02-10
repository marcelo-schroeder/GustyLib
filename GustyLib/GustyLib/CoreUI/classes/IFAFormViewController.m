//
//  IFAFormViewController.m
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

#import "GustyLibCoreUI.h"

#ifdef IFA_AVAILABLE_Help
#import "GustyLibHelp.h"
#endif

static NSString *const k_sectionHeaderFooterReuseId = @"sectionHeaderFooter";

@interface IFAFormViewController ()

@property (nonatomic, strong) NSIndexPath *IFA_indexPathForPopoverController;
@property (nonatomic, strong) UIBarButtonItem *IFA_dismissModalFormBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *IFA_cancelBarButtonItem;
@property (nonatomic) BOOL IFA_textFieldEditing;
@property (nonatomic) BOOL IFA_textFieldTextChanged;
@property (nonatomic, strong) NSMutableDictionary *IFA_indexPathToTextFieldCellDictionary;
@property (nonatomic, strong) NSMutableArray *IFA_editableTextFieldCells;
@property(nonatomic, strong) NSMutableDictionary *IFA_propertyNameToCell;
@property(nonatomic, strong) NSMutableArray *IFA_uiControlsWithTargets;
@property(nonatomic) BOOL IFA_changesMadeByThisViewController;
@property(nonatomic) BOOL IFA_saveButtonTapped;
@property(nonatomic) BOOL IFA_preparingForDismissalAfterRollback;
@property(nonatomic) BOOL IFA_isManagedObject;
@property(nonatomic) BOOL IFA_createModeAutoFieldEditDone;
@property(nonatomic, strong) IFAFormInputAccessoryView *formInputAccessoryView;

/* Public as readonly */
@property(nonatomic, strong) NSMutableDictionary *switchControlTagToPropertyName;
@property(nonatomic, strong) NSMutableDictionary *propertyNameToIndexPath;
@property (nonatomic, weak) IFAFormViewController *parentFormViewController;

@property(nonatomic) BOOL IFA_readOnlyModeSuspendedForEditing;
@property(nonatomic) BOOL IFA_rollbackPerformed;
@property(nonatomic) NSUInteger IFA_initialChildManagedObjectContextCountForAssertion;
@property(nonatomic) BOOL IFA_fixForContentBottomInsetAppleBugEnabled;
@property(nonatomic) UIEdgeInsets contentInsetBeforePresentingSemiModalViewController;
//@property(nonatomic) NSTimeInterval totalDuration;
@property(nonatomic, strong) NSMutableDictionary *IFA_cachedSectionHeaderHeightsBySection;
@property(nonatomic, strong) NSMutableDictionary *IFA_cachedSectionFooterHeightsBySection;
@end

@implementation IFAFormViewController

#pragma mark - Private

// Private initialiser
- (id)initWithObject:(NSObject *)a_object readOnlyMode:(BOOL)a_readOnlyMode createMode:(BOOL)a_createMode
              inForm:(NSString *)a_formName parentFormViewController:(IFAFormViewController *)a_parentFormViewController
      showEditButton:(BOOL)a_showEditButton {

    //    NSLog(@"hello from init - form");

    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {

		self.readOnlyMode = a_readOnlyMode;
		self.createMode = a_createMode;
		self.object = a_object;
		self.formName = a_formName;
		self.parentFormViewController = a_parentFormViewController;
        self.showEditButton = a_showEditButton;

    }

	return self;

}

- (IFAFormTableViewCell *)IFA_cellForTableView:(UITableView *)a_tableView
                                     indexPath:(NSIndexPath *)a_indexPath
                                     className:(NSString *)a_className {

    NSString *l_propertyName = [self nameForIndexPath:a_indexPath];

//    NSLog(@"IFA_cellForTableView [a_indexPath description] = %@", [a_indexPath description]);
//    NSLog(@"  l_propertyName = %@", l_propertyName);

    // Create reusable cell
    IFAFormTableViewCell *l_cell = [a_tableView dequeueReusableCellWithIdentifier:l_propertyName];
    if (l_cell == nil) {
//        NSLog(@"    initialising cell...");
        l_cell = [[NSClassFromString(a_className) alloc] initWithReuseIdentifier:l_propertyName
                                                                    propertyName:l_propertyName indexPath:a_indexPath
                                                              formViewController:self];
        // Set appearance
        [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                        cell:l_cell];
    }

    return l_cell;

}

- (IFAFormTextFieldTableViewCell *)IFA_textFieldCellForTableView:(UITableView *)a_tableView
                                                     atIndexPath:(NSIndexPath *)a_indexPath {
    IFAFormTextFieldTableViewCell *cell = self.IFA_indexPathToTextFieldCellDictionary[a_indexPath];
    if (cell) {
        // Make sure things such as setting dynamic fonts are done
        [self.ifa_appearanceTheme setAppearanceForCell:cell atIndexPath:a_indexPath viewController:self];
    } else {
        NSUInteger editorType = [self editorTypeForIndexPath:a_indexPath];
        NSString *className = [(editorType == IFAEditorTypeText ? [IFAFormTextFieldTableViewCell class] : [IFAFormNumberFieldTableViewCell class]) description];
        cell = (IFAFormTextFieldTableViewCell *) [self IFA_cellForTableView:a_tableView
                                                                  indexPath:a_indexPath
                                                                  className:className];
        self.IFA_indexPathToTextFieldCellDictionary[a_indexPath] = cell;
        if ([self IFA_isReadOnlyForIndexPath:a_indexPath]) {
            [cell.textField removeFromSuperview];
        } else {
            [self.IFA_editableTextFieldCells addObject:cell];
        }
    }
    return cell;
}

- (NSMutableDictionary *)IFA_indexPathToTextFieldCellDictionary {
    if (!_IFA_indexPathToTextFieldCellDictionary) {
        _IFA_indexPathToTextFieldCellDictionary = [NSMutableDictionary new];
    }
    return _IFA_indexPathToTextFieldCellDictionary;
}

- (NSMutableArray *)IFA_editableTextFieldCells {
    if (!_IFA_editableTextFieldCells) {
        _IFA_editableTextFieldCells = [NSMutableArray new];
    }
    return _IFA_editableTextFieldCells;
}

- (void)IFA_rollbackAndRestoreNonEditingState {
    [[IFAPersistenceManager sharedInstance] rollback];
    NSAssert(!self.IFA_rollbackPerformed, @"Incorrect value for self.IFA_rollbackPerformed: %u", self.IFA_rollbackPerformed);
    NSAssert(!self.IFA_preparingForDismissalAfterRollback, @"Incorrect value for self.IFA_preparingForDismissalAfterRollback: %u", self.IFA_preparingForDismissalAfterRollback);
    self.IFA_rollbackPerformed = YES;
    if (self.IFA_readOnlyModeSuspendedForEditing && !self.contextSwitchRequestPending) {
        [self setEditing:NO animated:YES];
    }else{
        self.IFA_preparingForDismissalAfterRollback = YES;
        [self setEditing:NO animated:YES];
        self.IFA_preparingForDismissalAfterRollback = NO;
        [self ifa_notifySessionCompletion];
    }
    self.IFA_rollbackPerformed = NO;
}

- (void)IFA_onCancelButtonTap:(id)sender {
    [self quitEditing];
}

- (void)IFA_onDismissButtonTap:(id)sender {
    [self ifa_notifySessionCompletion];
}

-(NSInteger)IFA_tagForIndexPath:(NSIndexPath*)a_indexPath{
    return (a_indexPath.section*100)+a_indexPath.row;
}

-(IFASwitchTableViewCell *)IFA_switchCellForTable:(UITableView *)a_tableView indexPath:(NSIndexPath*)a_indexPath{
    
    IFASwitchTableViewCell *l_cell = (IFASwitchTableViewCell *) [self IFA_cellForTableView:a_tableView
                                                                                 indexPath:a_indexPath
                                                                                 className:@"IFASwitchTableViewCell"];
    NSString *propertyName = [self nameForIndexPath:a_indexPath];
    
    // Set up event handling
    l_cell.switchControl.tag = [self IFA_tagForIndexPath:a_indexPath];
    [l_cell.switchControl addTarget:self action:@selector(onSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [self.IFA_uiControlsWithTargets addObject:l_cell.switchControl];
    //                [l_cell addValueChangedEventHandlerWithTarget:self action:@selector(onSwitchAction:)];
    //                NSLog(@"indexpath: %@, property: %@", indexPath, propertyName);
    (self.switchControlTagToPropertyName)[@(l_cell.switchControl.tag)] = propertyName;
    
    return l_cell;
    
}

-(BOOL)IFA_isDependencyEnabledForIndexPath:(NSIndexPath*)l_indexPath{
//    NSLog(@"IFA_isDependencyEnabledForIndexPath: %@", [l_indexPath description]);
    NSString *propertyName = [self nameForIndexPath:l_indexPath];
    NSString *l_dependencyParentPropertyName = [[IFAPersistenceManager sharedInstance].entityConfig parentPropertyForDependent:propertyName
                                                                                                                     inObject:self.object];
    BOOL l_dependencyEnabled = YES;
    if (l_dependencyParentPropertyName) {
        IFASwitchTableViewCell *l_parentCell = (self.IFA_propertyNameToCell)[l_dependencyParentPropertyName];
//        NSLog(@"  parent: %@, value: %u", [l_parentCell description], l_parentCell.switchControl.on);
        l_dependencyEnabled = l_parentCell.switchControl.on;
    }
    return l_dependencyEnabled;
}

-(CGRect)IFA_fromPopoverRectForIndexPath:(NSIndexPath*)a_indexPath{
    UITableViewCell *l_cell = [self visibleCellForIndexPath:a_indexPath];
    CGRect l_cellContentRect = l_cell.contentView.bounds;
//    NSLog(@"l_cellContentRect: %@", NSStringFromCGRect(l_cellContentRect));
    CGRect l_cellBackgroundRect = l_cell.backgroundView.bounds;
//    NSLog(@"l_cellBackgroundRect: %@", NSStringFromCGRect(l_cellBackgroundRect));
    CGRect l_cellRect = [self.tableView rectForRowAtIndexPath:a_indexPath];
//    NSLog(@"l_cellRect: %@", NSStringFromCGRect(l_cellRect));
    CGRect l_rect = CGRectMake((((l_cellRect.size.width-l_cellBackgroundRect.size.width)/2) + l_cellContentRect.size.width - l_cell.indentationWidth/2), l_cellRect.origin.y, l_cellBackgroundRect.size.width-l_cellContentRect.size.width, l_cellRect.size.height);
//    NSLog(@"l_rect: %@", NSStringFromCGRect(l_rect));
//    static NSUInteger const k_horizontalOffset = 100;
//    return CGRectMake(l_cellRect.origin.x+l_cellRect.size.width - k_horizontalOffset, l_cellRect.origin.y, k_horizontalOffset, l_cellRect.size.height);
    return l_rect;
}

-(void)IFA_updateLeftBarButtonItemsStates {
    if (self.isSubForm) {
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }else{
        [self ifa_removeLeftBarButtonItem:self.IFA_dismissModalFormBarButtonItem];
        [self ifa_removeLeftBarButtonItem:self.IFA_cancelBarButtonItem];
        if (self.editing) {
            if (self.IFA_isManagedObject || ((!self.IFA_isManagedObject) && self.ifa_presentedAsModal)) {
                if (self.navigationItem.leftItemsSupplementBackButton) {
                    [self.navigationItem setHidesBackButton:YES animated:YES];
                }
                [self ifa_addLeftBarButtonItem:self.IFA_cancelBarButtonItem];
            }
        }else {
            [self.navigationItem setHidesBackButton:NO animated:YES];
            if(self.ifa_presentedAsModal) {
                [self ifa_addLeftBarButtonItem:self.IFA_dismissModalFormBarButtonItem];
            }
        }
    }
}

-(BOOL)IFA_endTextFieldEditingWithCommit:(BOOL)a_commit{

    if (self.IFA_textFieldEditing) {

        if (!a_commit) {
            self.textFieldCommitSuspended = YES;
        }
        BOOL l_validationOk = [self.view endEditing:NO];
        if (self.textFieldCommitSuspended) {
            self.textFieldCommitSuspended = NO;
        }
        return l_validationOk;

    }else {
        
        return YES;
        
    }

}

-(void)IFA_onTextFieldNotification:(NSNotification*)a_notification{
//    NSLog(@"IFA_onTextFieldNotification: %@", a_notification.name);
    if ([a_notification.name isEqualToString:UITextFieldTextDidBeginEditingNotification] || [a_notification.name isEqualToString:UITextFieldTextDidEndEditingNotification]) {
        self.IFA_textFieldEditing = [a_notification.name isEqualToString:UITextFieldTextDidBeginEditingNotification];
        self.IFA_textFieldTextChanged = NO;
    }else if ([a_notification.name isEqualToString:UITextFieldTextDidChangeNotification]){
        self.IFA_textFieldTextChanged = YES;
    }else{
        NSAssert(NO, @"Unexpected notification name: %@", a_notification.name);
    }
}

-(UITableViewCell*)IFA_updateEditingStateForCell:(UITableViewCell *)a_cell indexPath:(NSIndexPath *)a_indexPath{
    if ([a_cell isKindOfClass:[IFAFormTextFieldTableViewCell class]]) {
        IFAFormTextFieldTableViewCell *l_textFieldCell = (IFAFormTextFieldTableViewCell *)a_cell;
//        NSLog(@"a_cell: %@, a_indexPath: %@", [a_cell description], [a_indexPath description]);
        BOOL l_editing = self.editing && ![self IFA_isReadOnlyForIndexPath:a_indexPath];
//        NSLog(@"  l_editing: %u, self.editing: %u, [self IFA_isReadOnlyForIndexPath:[self.tableView indexPathForCell:l_textFieldCell]]: %u", l_editing, self.editing, [self isReadOnlyForIndexPath:[self.tableView indexPathForCell:l_textFieldCell]]);
        l_textFieldCell.rightLabel.hidden = l_editing;
        l_textFieldCell.textField.hidden = !l_editing;
        if (l_textFieldCell.rightLabel.hidden) {
            l_textFieldCell.rightLabel.text = nil;  // Prevents a hidden label to have an influence on on auto layout
        }
        if (l_textFieldCell.textField.hidden) {
            l_textFieldCell.textField.text = nil;  // Prevents a hidden text field to have an influence on auto layout
        }
    }
    return a_cell;
}

-(NSString*)IFA_urlPropertyNameForIndexPath:(NSIndexPath*)a_indexPath{
    NSString *l_urlPropertyName = [[IFAPersistenceManager sharedInstance].entityConfig urlPropertyNameForIndexPath:a_indexPath
                                                                                                         inObject:self.object
                                                                                                           inForm:self.formName
                                                                                                       createMode:self.createMode];
//    NSLog(@"IFA_urlPropertyNameForIndexPath: %@, l_urlPropertyName: %@", [a_indexPath description], l_urlPropertyName);
    return l_urlPropertyName;
}

-(BOOL)IFA_shouldLinkToUrlForIndexPath:(NSIndexPath*)a_indexPath {
    if ([self IFA_isDeleteButtonAtIndexPath:a_indexPath]) {
        return NO;
    }else{
        return [self IFA_urlPropertyNameForIndexPath:a_indexPath] != nil;
    }
}

- (BOOL)IFA_canUserChangeFieldAtIndexPath:(NSIndexPath *)a_indexPath {
    return ![self IFA_isReadOnlyForIndexPath:a_indexPath] && [self IFA_isDependencyEnabledForIndexPath:a_indexPath];
}

- (IFAFormTableViewCellAccessoryType)IFA_accessoryTypeForEditorType:(IFAEditorType)a_editorType {
    IFAFormTableViewCellAccessoryType l_accessoryType = IFAFormTableViewCellAccessoryTypeNone;
    if (![self IFA_isEmbeddedEditorForType:a_editorType]) {
        switch (a_editorType) {
            case IFAEditorTypeDatePicker:
            case IFAEditorTypePicker:
            case IFAEditorTypeTimeInterval:
            case IFAEditorTypeFullDateAndTime:
                l_accessoryType = IFAFormTableViewCellAccessoryTypeDisclosureIndicatorDown;
                break;
            case IFAEditorTypeSelectionList:
            case IFAEditorTypeForm:
                l_accessoryType = IFAFormTableViewCellAccessoryTypeDisclosureIndicatorRight;
                break;
            case IFAEditorTypeNotApplicable:
                // None;
                break;
            default:
                NSAssert(NO, @"Unexpected editor type: %lu", (unsigned long)a_editorType);
        }
    }
    return l_accessoryType;
}

- (BOOL)IFA_hasEmbeddedEditorForFieldAtIndexPath:(NSIndexPath *)a_indexPath {
    IFAEditorType l_editorType = [self editorTypeForIndexPath:a_indexPath];
    return [self IFA_isEmbeddedEditorForType:l_editorType];
}

- (BOOL)IFA_isEmbeddedEditorForType:(IFAEditorType)a_editorType {
    switch (a_editorType) {
        case IFAEditorTypeText:
        case IFAEditorTypeSegmented:
        case IFAEditorTypeSwitch:
        case IFAEditorTypeNumber:
            return YES;
        default:
            return NO;
    }
}

-(BOOL)IFA_isFormEditorTypeForIndexPath:(NSIndexPath*)a_indexPath{
    return [self editorTypeForIndexPath:a_indexPath]== IFAEditorTypeForm;
}

/*
* Checks the read only attribute at the entity config level.
*/
-(BOOL)IFA_isReadOnlyForIndexPath:(NSIndexPath*)anIndexPath{
    BOOL l_readOnly = [[IFAPersistenceManager sharedInstance].entityConfig isReadOnlyForIndexPath:anIndexPath
                                                                                         inObject:self.object
                                                                                           inForm:self.formName
                                                                                       createMode:self.createMode];
    return l_readOnly;
}

- (BOOL)IFA_shouldEnableUserInteractionForIndexPath:(NSIndexPath *)anIndexPath {
    if (self.editing) {
        IFAFormTableViewCellAccessoryType l_accessoryType = [self accessoryTypeForIndexPath:anIndexPath];
        if (l_accessoryType == IFAFormTableViewCellAccessoryTypeNone) {
            if ([self IFA_hasEmbeddedEditorForFieldAtIndexPath:anIndexPath]) {
                return YES;
            } else {
                return [self IFA_isFormEditorTypeForIndexPath:anIndexPath] || [self IFA_shouldLinkToUrlForIndexPath:anIndexPath];
            }
        } else {
            return YES;
        }
    }else{
        return YES;
    }
}

- (UIViewController*)IFA_editorViewControllerForIndexPath:(NSIndexPath*)anIndexPath{

    NSString *propertyName = [self nameForIndexPath:anIndexPath];
    UIViewController *controller;

    NSUInteger editorType = [self editorTypeForIndexPath:anIndexPath];
    switch (editorType) {
        case IFAEditorTypeForm:
        {
            NSString *customFormViewControllerClassName = [[IFAPersistenceManager sharedInstance].entityConfig viewControllerForForm:propertyName
                                                                                                                            inObject:self.object];
            Class formViewControllerClass;
            if (customFormViewControllerClassName) {
                formViewControllerClass = NSClassFromString(customFormViewControllerClassName);
            }else {
                formViewControllerClass = [IFAFormViewController class];
            }
            __weak NSObject *l_weakObject = self.object;
            if (self.readOnlyMode) {
                controller = [[formViewControllerClass alloc] initWithReadOnlyObject:l_weakObject inForm:propertyName
                                                            parentFormViewController:self showEditButton:NO];
            }else{
                controller = [[formViewControllerClass alloc] initWithObject:l_weakObject createMode:self.editing
                                                                      inForm:propertyName parentFormViewController:self];
            }
        }
            break;
        case IFAEditorTypeSelectionList:
        {
            NSAssert([self.object isKindOfClass:NSManagedObject.class], @"Selection list editor type not yet implemented for non-NSManagedObject instances");
            NSManagedObject *l_managedObject = (NSManagedObject*)self.object;
            if ([[IFAPersistenceManager sharedInstance].entityConfig isToManyRelationshipForProperty:propertyName inManagedObject:l_managedObject]) {
                controller = [[IFAMultipleSelectionListViewController alloc] initWithManagedObject:l_managedObject
                                                                                      propertyName:propertyName
                                                                                formViewController:self];
            }else {
                controller = [[IFASingleSelectionListViewController alloc] initWithManagedObject:l_managedObject
                                                                                    propertyName:propertyName
                                                                              formViewController:self];
            }
        }
            break;
        case IFAEditorTypeFullDateAndTime:
        case IFAEditorTypeDatePicker:
        case IFAEditorTypeTimeInterval:
        case IFAEditorTypePicker:
            if (editorType== IFAEditorTypePicker) {
                controller = [[IFAPickerViewController alloc] initWithObject:self.object propertyName:propertyName];
            }else {
                UIDatePickerMode l_datePickerMode = (UIDatePickerMode) NSNotFound;
                BOOL l_showTimePicker = NO;
                switch (editorType) {
                    case IFAEditorTypeFullDateAndTime:
                        l_showTimePicker = YES;
                        l_datePickerMode = UIDatePickerModeDate;
                        break;
                    case IFAEditorTypeDatePicker:
                    {
                        NSDictionary *l_propertyOptions = [[[IFAPersistenceManager sharedInstance] entityConfig] optionsForProperty:propertyName
                                                                                                                           inObject:self.object];
                        if ([l_propertyOptions[@"datePickerMode"] isEqualToString:@"date"]) {
                            l_datePickerMode = UIDatePickerModeDate;
                        }else{
                            l_datePickerMode = UIDatePickerModeDateAndTime;
                        }
                        break;
                    }
                    case IFAEditorTypeTimeInterval:
                        l_datePickerMode = UIDatePickerModeCountDownTimer;
                        break;
                    default:
                        NSAssert(NO, @"Unexpected editor type - case 1: %lu", (unsigned long)editorType);
                        break;
                }
                controller = [[IFADatePickerViewController alloc] initWithObject:self.object propertyName:propertyName
                                                                  datePickerMode:l_datePickerMode
                                                                  showTimePicker:l_showTimePicker];
            }
            break;
        default:
            NSAssert(NO, @"Unexpected editor type - case 2: %lu", (unsigned long)editorType);
            break;
    }

    return controller;

}

- (BOOL)IFA_isReadOnlyWithEditButtonCase {
    return self.readOnlyMode && self.showEditButton;
}

/*
* @returns YES if the field has received focus and no more handling is required (e.g. keyboard focus).
*/
- (BOOL)IFA_transitionToEditModeWithSelectedRowAtIndexPath:(NSIndexPath *)a_indexPath {

    // Transition to edit mode
    [self setEditing:YES animated:YES];

    // If it is a field that can receive keyboard input than let it receive focus automatically
    BOOL l_canReceiveKeyboardInput = [self formInputAccessoryView:self.formInputAccessoryView
                               canReceiveKeyboardInputAtIndexPath:a_indexPath];
    if (l_canReceiveKeyboardInput) {
        UIResponder *l_firstResponder = [self formInputAccessoryView:self.formInputAccessoryView
                           responderForKeyboardInputFocusAtIndexPath:a_indexPath];
        [IFAUtils dispatchAsyncMainThreadBlock:^{
            [l_firstResponder becomeFirstResponder];
        }];
    }

    return l_canReceiveKeyboardInput;

}

- (BOOL)IFA_isStaticFieldTypeForIndexPath:(NSIndexPath *)a_indexPath{
    IFAEntityConfigFieldType l_fieldType = [self fieldTypeForIndexPath:a_indexPath];
    switch (l_fieldType) {
        case IFAEntityConfigFieldTypeViewController:
        case IFAEntityConfigFieldTypeButton:
        case IFAEntityConfigFieldTypeCustom:
            return YES;
        default:
            return NO;
    }
}

- (UITableViewCell *)IFA_staticFieldTypeCellForRowAtIndexPath:(NSIndexPath *)indexPath {

    IFAFormTableViewCell *l_cell = nil;

    BOOL l_isDeleteButton = [self IFA_isDeleteButtonAtIndexPath:indexPath];
    NSString *l_propertyName = l_isDeleteButton ? IFAEntityConfigPropertyNameDeleteButton : [self nameForIndexPath:indexPath];

    IFAEntityConfig *l_entityConfig = [IFAPersistenceManager sharedInstance].entityConfig;

    IFAEntityConfigFieldType l_fieldType = [self fieldTypeForIndexPath:indexPath];
    switch (l_fieldType) {

        case IFAEntityConfigFieldTypeViewController: {
            l_cell= [self.tableView dequeueReusableCellWithIdentifier:l_propertyName];
            if (!l_cell) {
                l_cell = [[IFAFormTableViewCell alloc] initWithReuseIdentifier:l_propertyName
                                                                  propertyName:l_propertyName indexPath:indexPath
                                                            formViewController:self];
                BOOL l_isModalViewController = [l_entityConfig isModalForViewControllerFieldTypeAtIndexPath:indexPath inObject:self.object
                                                                                                     inForm:self.formName createMode:self.createMode];
                l_cell.customAccessoryType = l_isModalViewController ? IFAFormTableViewCellAccessoryTypeDisclosureIndicatorInfo : IFAFormTableViewCellAccessoryTypeDisclosureIndicatorRight;
                // Set appearance
                [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                                cell:l_cell];
            }
            NSString *l_labelText = [l_entityConfig labelForViewControllerFieldTypeAtIndexPath:indexPath
                                                                                              inObject:self.object
                                                                                                inForm:self.formName
                                                                                            createMode:self.createMode];
            [l_cell setLeftLabelText:l_labelText rightLabelText:nil];
            return l_cell;
        }

        case IFAEntityConfigFieldTypeButton: {
            l_cell= [self.tableView dequeueReusableCellWithIdentifier:l_propertyName];
            if (!l_cell) {
                l_cell = [[IFAFormTableViewCell alloc] initWithReuseIdentifier:l_propertyName
                                                                  propertyName:l_propertyName indexPath:indexPath
                                                            formViewController:self];
                l_cell.customAccessoryType = IFAFormTableViewCellAccessoryTypeNone;
                l_cell.leftLabel.text = nil;
                l_cell.rightLabel.text = nil;
                l_cell.centeredLabel.hidden = NO;
                // Set appearance
                [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                                cell:l_cell];
            }
            if (l_isDeleteButton) {
                NSString *l_text = @"Delete";
                NSString *l_entityLabel = [self.object.ifa_entityLabel lowercaseString];
                if (l_entityLabel) {
                    l_text= [NSString stringWithFormat:@"Delete %@", l_entityLabel];
                }
                l_cell.centeredLabel.text = l_text;
            }else{
                l_cell.centeredLabel.text = [l_entityConfig labelForViewControllerFieldTypeAtIndexPath:indexPath
                                                                                              inObject:self.object
                                                                                                inForm:self.formName
                                                                                            createMode:self.createMode];
            }
            return l_cell;

        }

        case IFAEntityConfigFieldTypeCustom: {
            l_cell= [self.tableView dequeueReusableCellWithIdentifier:l_propertyName];
            if (!l_cell) {
                l_cell = [[IFAFormTableViewCell alloc] initWithReuseIdentifier:l_propertyName
                                                                  propertyName:l_propertyName indexPath:indexPath
                                                            formViewController:self];
                [l_cell.leftLabel removeFromSuperview];
                [l_cell.centeredLabel removeFromSuperview];
                [l_cell.rightLabel removeFromSuperview];
                l_cell.customAccessoryType = IFAFormTableViewCellAccessoryTypeNone;
                l_cell.userInteractionEnabled = NO;
                // Set appearance
                [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                                cell:l_cell];
            }
            return l_cell;
        }

        default:
            NSAssert(NO, @"Unexpected field type: %lu", (unsigned long)l_fieldType);
            break;
    }

    return l_cell;

}

- (void)IFA_popChildManagedObjectContext {
    IFAPersistenceManager *l_persistenceManager = [IFAPersistenceManager sharedInstance];
    [l_persistenceManager popChildManagedObjectContext];
    self.object = [l_persistenceManager findById:((NSManagedObject *) self.object).objectID];
    NSAssert(l_persistenceManager.childManagedObjectContexts.count== self.IFA_initialChildManagedObjectContextCountForAssertion, @"Incorrect l_persistenceManager.childManagedObjectContexts.count: %lu", (unsigned long)l_persistenceManager.childManagedObjectContexts.count);
}

- (void)IFA_pushChildManagedObjectContext {
    IFAPersistenceManager *l_persistenceManager = [IFAPersistenceManager sharedInstance];
    NSAssert(l_persistenceManager.childManagedObjectContexts.count== self.IFA_initialChildManagedObjectContextCountForAssertion, @"Incorrect l_persistenceManager.childManagedObjectContexts.count: %lu", (unsigned long)l_persistenceManager.childManagedObjectContexts.count);
    [l_persistenceManager pushChildManagedObjectContext];
    self.object = [l_persistenceManager findById:((NSManagedObject *) self.object).objectID];
}

- (BOOL)IFA_isDeleteButtonAtIndexPath:(NSIndexPath *)a_indexPath{
    return a_indexPath.section == self.IFA_deleteButtonSection;
}

- (NSInteger)IFA_deleteButtonSection {
    return self.shouldShowDeleteButton ? [self.tableView.dataSource numberOfSectionsInTableView:self.tableView] - 1 : NSNotFound;
}

/*
* This bug causes incorrect table view bottom content inset when keyboard is showing.
* The fix here is an improvement on this idea: http://stackoverflow.com/questions/22051373/scroll-area-incorrect-when-editing-uitextfield-on-uitableviewcontroller
*/
- (void)IFA_handleContentBottomInsetAppleBugIfRequiredForKeyboardShowing:(BOOL)a_isKeyboardShowing {
//    NSLog(@"IFA_handleContentBottomInsetAppleBugIfRequiredForKeyboardShowing: %u", a_isKeyboardShowing);
//    NSLog(@"  [IFAUIUtils isKeyboardVisible] = %d", [IFAUIUtils isKeyboardVisible]);
//    NSLog(@"  NSStringFromCGRect([IFAUIUtils keyboardFrame]) = %@", NSStringFromCGRect([IFAUIUtils keyboardFrame]));
    static const CGFloat k_appleBugIncorrectBottomContentInsetOffset = 49; // At this stage, I don't know where this comes from, but the app was using a tab bar controller.
    UIEdgeInsets l_tableViewContentInset = self.tableView.contentInset;
    CGFloat l_incorrectBottomContentInset = [IFAUIUtils keyboardFrame].size.height + k_appleBugIncorrectBottomContentInsetOffset;
    if ((a_isKeyboardShowing && l_tableViewContentInset.bottom == l_incorrectBottomContentInset) || (!a_isKeyboardShowing && self.IFA_fixForContentBottomInsetAppleBugEnabled)) {
        NSAssert((a_isKeyboardShowing && !self.IFA_fixForContentBottomInsetAppleBugEnabled) || (!a_isKeyboardShowing && self.IFA_fixForContentBottomInsetAppleBugEnabled), @"Incorrect state. a_isKeyboardShowing: %u | self.IFA_fixForContentBottomInsetAppleBugEnabled: %u", a_isKeyboardShowing, self.IFA_fixForContentBottomInsetAppleBugEnabled);
        l_tableViewContentInset.bottom += k_appleBugIncorrectBottomContentInsetOffset * (a_isKeyboardShowing ? (-1) : 1);
        self.tableView.contentInset = l_tableViewContentInset;
        self.tableView.scrollIndicatorInsets = l_tableViewContentInset;
        self.IFA_fixForContentBottomInsetAppleBugEnabled = a_isKeyboardShowing;
    }
}

- (BOOL)IFA_shouldAdjustContentInsetForPresentedViewController:(UIViewController *)a_viewController {
    return a_viewController.ifa_hasFixedSize;
}

- (UIView *)IFA_sectionHeaderFooterWithLabelText:(NSString *)a_labelText
                                        isHeader:(BOOL)a_isHeader
                                         section:(NSUInteger)a_section {
    IFAFormSectionHeaderFooterView *sectionFooterView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:k_sectionHeaderFooterReuseId];
    [self IFA_populateSectionFooterView:sectionFooterView withLabelText:a_labelText isHeader:a_isHeader
                                section:a_section];
//    sectionFooterView.customContentView.backgroundColor = a_isHeader ? [UIColor purpleColor] : [UIColor blueColor];
//    sectionFooterView.label.backgroundColor = [UIColor orangeColor];
    return sectionFooterView;
}

- (NSMutableDictionary *)IFA_cachedSectionHeaderHeightsBySection {
    if (!_IFA_cachedSectionHeaderHeightsBySection) {
        _IFA_cachedSectionHeaderHeightsBySection = [@{} mutableCopy];
    }
    return _IFA_cachedSectionHeaderHeightsBySection;
}

- (NSMutableDictionary *)IFA_cachedSectionFooterHeightsBySection {
    if (!_IFA_cachedSectionFooterHeightsBySection) {
        _IFA_cachedSectionFooterHeightsBySection = [@{} mutableCopy];
    }
    return _IFA_cachedSectionFooterHeightsBySection;
}

- (CGFloat)IFA_sectionHeaderFooterHeightForLabelTextIsHeader:(BOOL)a_isHeader section:(NSUInteger)a_section {

//    NSTimeInterval timeInterval1 = [NSDate date].timeIntervalSinceReferenceDate;

    NSMutableDictionary *cachedSectionHeightsBySection = a_isHeader ? self.IFA_cachedSectionHeaderHeightsBySection : self.IFA_cachedSectionFooterHeightsBySection;
    NSNumber *cachedHeightNumber = cachedSectionHeightsBySection[@(a_section)];

    CGFloat height;

    if (cachedHeightNumber) {   // cache hit

        height = cachedHeightNumber.floatValue;

    } else {    // cache miss

        IFAFormSectionHeaderFooterView *view;
        if (a_isHeader) {
            view = (IFAFormSectionHeaderFooterView *) [self tableView:self.tableView viewForHeaderInSection:a_section];
        }else{
            view = (IFAFormSectionHeaderFooterView *) [self tableView:self.tableView viewForFooterInSection:a_section];
        }

        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view.contentView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:0
                                                                          multiplier:1
                                                                            constant:self.view.bounds.size.width];
        [view.contentView addConstraint:widthConstraint];
        CGSize size = [view.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        [view.contentView removeConstraint:widthConstraint];

        height = size.height;

        cachedSectionHeightsBySection[@(a_section)] = @(height);

    }

//    NSTimeInterval timeInterval2 = [NSDate date].timeIntervalSinceReferenceDate;
//    NSTimeInterval duration = timeInterval2 - timeInterval1;
//    self.totalDuration += duration;
//    NSLog(@" ");
//    NSLog(@"*** duration = %f", duration);
//    NSLog(@"***   self.totalDuration = %f", self.totalDuration);

    return height;

}

- (void)IFA_populateSectionFooterView:(IFAFormSectionHeaderFooterView *)a_sectionFooterView
                        withLabelText:(NSString *)a_labelText isHeader:(BOOL)a_isHeader section:(NSUInteger)a_section {
    static const CGFloat k_emptySectionHeaderFooterHeight = 10;
    static const CGFloat k_spaceBetweenCellAndSectionHeaderOrFooter = 7;
    static const CGFloat k_sectionHeaderFooterExternalVerticalSpace = 26;
    static const CGFloat k_sectionHeaderFooterInternalVerticalSpace = 15;
    BOOL isFirstHeader = a_isHeader && a_section == 0;
    BOOL isLastFooter = !a_isHeader && a_section == self.tableView.numberOfSections - 1;
    if (a_labelText) {
        if (a_isHeader) {
            a_sectionFooterView.topLayoutConstraint.constant = isFirstHeader ? k_sectionHeaderFooterExternalVerticalSpace : k_sectionHeaderFooterInternalVerticalSpace;
            a_sectionFooterView.bottomLayoutConstraint.constant = k_spaceBetweenCellAndSectionHeaderOrFooter;
        }else{
            a_sectionFooterView.topLayoutConstraint.constant = k_spaceBetweenCellAndSectionHeaderOrFooter;
            a_sectionFooterView.bottomLayoutConstraint.constant = isLastFooter ? k_sectionHeaderFooterExternalVerticalSpace : k_sectionHeaderFooterInternalVerticalSpace;
        }
    }else{
        a_sectionFooterView.topLayoutConstraint.constant = isFirstHeader || isLastFooter ? k_sectionHeaderFooterExternalVerticalSpace : k_emptySectionHeaderFooterHeight;
        a_sectionFooterView.bottomLayoutConstraint.constant = 0;
    }
    a_sectionFooterView.label.text = a_labelText;
}

#pragma mark - Public

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.readOnlyMode = NO;
        self.createMode = YES;
        self.formName = IFAEntityConfigFormNameDefault;
    }
    return self;
}

/* Submission forms */

- (id)initWithObject:(NSObject *)a_object {
    return [self initWithObject:a_object readOnlyMode:NO createMode:YES inForm:IFAEntityConfigFormNameDefault
       parentFormViewController:nil showEditButton:NO];
}

- (id)initWithObject:(NSObject *)a_object inForm:(NSString *)a_formName
        parentFormViewController:(IFAFormViewController *)a_parentFormViewController {
    return [self initWithObject:a_object readOnlyMode:NO createMode:YES inForm:a_formName
       parentFormViewController:a_parentFormViewController showEditButton:NO];
}

/* CRUD forms */

- (id)    initWithObject:(NSObject *)a_object createMode:(BOOL)a_createMode inForm:(NSString *)a_formName
parentFormViewController:(IFAFormViewController *)a_parentFormViewController {
	return [self initWithObject:a_object readOnlyMode:!a_createMode createMode:a_createMode inForm:a_formName
       parentFormViewController:a_parentFormViewController
                 showEditButton:!a_createMode];
}

- (id)initWithObject:(NSObject *)a_object createMode:(BOOL)a_createMode {
	return [self initWithObject:a_object createMode:a_createMode inForm:IFAEntityConfigFormNameDefault
       parentFormViewController:nil];
}

- (id)initWithReadOnlyObject:(NSObject *)a_object inForm:(NSString *)a_formName
    parentFormViewController:(IFAFormViewController *)a_parentFormViewController
              showEditButton:(BOOL)a_showEditButton {
	return [self initWithObject:a_object readOnlyMode:YES createMode:NO inForm:a_formName
       parentFormViewController:a_parentFormViewController
                 showEditButton:a_showEditButton];
}

- (id)initWithReadOnlyObject:(NSObject *)anObject{
	return [self initWithReadOnlyObject:anObject inForm:IFAEntityConfigFormNameDefault parentFormViewController:nil
                         showEditButton:NO];
}

-(IFAFormTableViewCell *)populateCell:(IFAFormTableViewCell *)a_cell {

//    NSLog(@"populateCell: %@", [a_cell description]);
//    NSLog(@"  a_cell.indexPath: %@", [a_cell.indexPath description]);

    if ([self IFA_isStaticFieldTypeForIndexPath:a_cell.indexPath]) {
        // Cell is non-property based, so simply return it with no modification
        return a_cell;
    }

    id l_value = [self.object valueForKey:a_cell.propertyName];

    a_cell.customAccessoryType = [self accessoryTypeForIndexPath:a_cell.indexPath];

    if ([a_cell isMemberOfClass:[IFAFormTableViewCell class]] || [a_cell isMemberOfClass:[IFASwitchTableViewCell class]] || [a_cell isKindOfClass:[IFAFormTextFieldTableViewCell class]]) {

        NSString *leftLabelText = [self labelForIndexPath:a_cell.indexPath];

        if ([a_cell isMemberOfClass:[IFASwitchTableViewCell class]]) {

            IFASwitchTableViewCell *l_cell = (IFASwitchTableViewCell *) a_cell;
            l_cell.switchControl.on = [(NSNumber *) l_value boolValue];
            [a_cell setLeftLabelText:leftLabelText rightLabelText:nil];

        } else{

            NSString *l_valueFormat = [[IFAPersistenceManager sharedInstance].entityConfig valueFormatForProperty:a_cell.propertyName
                                                                                                         inObject:self.object];
            NSString *l_valueString = [self.object ifa_propertyStringValueForIndexPath:a_cell.indexPath
                                                                                inForm:self.formName
                                                                            createMode:self.createMode
                                                                              calendar:[self calendar]];
            NSString *rightLabelText = l_valueFormat ? [NSString stringWithFormat:l_valueFormat, l_valueString] : l_valueString;
            [a_cell setLeftLabelText:leftLabelText rightLabelText:rightLabelText];

            if ([a_cell isKindOfClass:[IFAFormTextFieldTableViewCell class]]) {

                IFAFormTextFieldTableViewCell *l_cell = (IFAFormTextFieldTableViewCell *) a_cell;
                if (self.IFA_isManagedObject) {
                    NSPropertyDescription *propertyDescription = [self.object ifa_descriptionForProperty:a_cell.propertyName];
                    l_cell.textField.placeholder = propertyDescription.isOptional ? @"Optional" : @"Required";
                }
                [l_cell reloadData];

            }

        }

    } else if ([a_cell isMemberOfClass:[IFASegmentedControlTableViewCell class]]) {

        IFASegmentedControlTableViewCell *l_cell = (IFASegmentedControlTableViewCell *) a_cell;
        l_cell.segmentedControl.selectedSegmentIndex = [((NSNumber *) [l_value valueForKey:@"index"]) intValue];
        l_cell.segmentedControl.enabled = self.editing;

    } else {
        NSAssert(false, @"Unexpected cell type: %@", [[a_cell class] description]);
    }

    // Selection style
    a_cell.selectionStyle = a_cell.customAccessoryType == IFAFormTableViewCellAccessoryTypeNone ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;

    // Should enable user interaction?
    a_cell.userInteractionEnabled = [self IFA_shouldEnableUserInteractionForIndexPath:a_cell.indexPath];

    return a_cell;

}

- (BOOL)isSubForm {
    return self.parentFormViewController!=nil;
}

- (void)onNavigationBarSubmitButtonTap {
    // to be overridden by subclasses
}

- (void)onSwitchAction:(UISwitch*)a_switch {

//    NSLog(@"onSwitchAction with tag: %u", a_switch.tag);
    NSString *l_propertyName = (self.switchControlTagToPropertyName)[@(a_switch.tag)];
//    NSLog(@"  property name: %@", l_propertyName);
    [self.object ifa_setValue:@((a_switch.on)) forProperty:l_propertyName];
    NSArray *l_dependentPropertyNames = [[IFAPersistenceManager sharedInstance].entityConfig dependentsForProperty:l_propertyName
                                                                                                          inObject:self.object];
//    NSLog(@"  dependents: %@", l_dependentPropertyNames);
    NSMutableArray *l_indexPathsToReload = [[NSMutableArray alloc] init];
    for (NSString *l_dependentPropertyName in l_dependentPropertyNames) {
//        NSLog(@"    l_dependentPropertyName: %@", l_dependentPropertyName);
        NSIndexPath *l_indexPath = (self.propertyNameToIndexPath)[l_dependentPropertyName];
//        NSLog(@"    l_indexPath: %@", [l_indexPath description]);
        if (l_indexPath) {
            [l_indexPathsToReload addObject:l_indexPath];
        }
    }

    __weak __typeof(self) l_weakSelf = self;
    [IFAUtils dispatchAsyncMainThreadBlock:^{

        if (!l_weakSelf.isSubForm && !l_weakSelf.editing) {
            [l_weakSelf setEditing:YES animated:YES];
        }

//        NSLog(@"  About to reload: %@", [l_indexPathsToReload description]);
        if (l_indexPathsToReload.count) {
            [l_weakSelf.tableView reloadRowsAtIndexPaths:l_indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
        }

        // Reload section in case help for the property needs to be updated
        [self clearSectionFooterHelpTextForPropertyNamed:l_propertyName];
        [l_weakSelf.tableView reloadData];

    } afterDelay:IFAAnimationDuration]; // Add delay to allow for the switch animation to complete

}

-(void)handleReturnKeyForTextFieldCell:(IFAFormTextFieldTableViewCell *)a_cell{
    
    // My index
    NSUInteger l_myIndex = [self.IFA_editableTextFieldCells indexOfObject:a_cell];
    
    // The next index
    NSUInteger l_nextIndex = l_myIndex+1==[self.IFA_editableTextFieldCells count] ? 0 : l_myIndex+1;
    
    // The next cell containing a text field
    IFAFormTextFieldTableViewCell *l_nextTextFieldCell = (self.IFA_editableTextFieldCells)[l_nextIndex];
    
    // The next index path
    NSIndexPath *l_nextIndexPath = [self.IFA_indexPathToTextFieldCellDictionary allKeysForObject:l_nextTextFieldCell][0];

    // Move input focus to that index path
    [self.formInputAccessoryView moveInputFocusToIndexPath:l_nextIndexPath];

}

- (NSString*)labelForIndexPath:(NSIndexPath*)anIndexPath{
    return [[IFAPersistenceManager sharedInstance].entityConfig labelForIndexPath:anIndexPath inObject:self.object
                                                                           inForm:self.formName
                                                                       createMode:self.createMode];
}

- (NSString*) nameForIndexPath:(NSIndexPath*)anIndexPath{
    return [[IFAPersistenceManager sharedInstance].entityConfig nameForIndexPath:anIndexPath inObject:self.object
                                                                          inForm:self.formName createMode:self.createMode];
}

- (NSString*) entityNameForProperty:(NSString*)aPropertyName{
    return [[IFAPersistenceManager sharedInstance].entityConfig entityNameForProperty:aPropertyName
                                                                             inEntity:[[self.object class] description]];
}

-(void)updateBackingPreferences{
    
    for (NSString *l_propertyWithBackingPreferencesProperty in [[IFAPersistenceManager sharedInstance].entityConfig propertiesWithBackingPreferencesForObject:self.object]) {
        //                    NSLog(@"l_propertyWithBackingPreferencesProperty: %@", l_propertyWithBackingPreferencesProperty);
        @autoreleasepool {
            NSString *l_backingPreferencesProperty = [[IFAPersistenceManager sharedInstance].entityConfig backingPreferencesPropertyForProperty:l_propertyWithBackingPreferencesProperty
                                                                                                                                      inObject:self.object];
            id l_preferencesValue = [self.object valueForKey:l_propertyWithBackingPreferencesProperty];
            id l_preferences = [[IFAPreferencesManager sharedInstance] preferences];
            [l_preferences setValue:l_preferencesValue forKey:l_backingPreferencesProperty];
        }
    }
    
}

-(void)updateAndSaveBackingPreferences {
    [self updateBackingPreferences];
    [[IFAPersistenceManager sharedInstance] save];
//    NSLog(@"backing preferences saved");
}

- (void)onSegmentedControlAction:(id)aSender{

    if (!self.isSubForm && !self.editing) {
        [self setEditing:YES animated:YES];
    }

    IFASegmentedControl *segmentedControl = aSender;
    NSString *entityName = [self entityNameForProperty:segmentedControl.propertyName];
    NSManagedObject *selectedManagedObject = [[IFAPersistenceManager sharedInstance] findAllForEntity:entityName][(NSUInteger) [segmentedControl selectedSegmentIndex]];
    [self.object ifa_setValue:selectedManagedObject forProperty:segmentedControl.propertyName];

    [self clearSectionFooterHelpTextForPropertyNamed:segmentedControl.propertyName];

}

- (IFAFormTableViewCellAccessoryType)accessoryTypeForIndexPath:(NSIndexPath *)a_indexPath {
    IFAEditorType l_editorType = [self editorTypeForIndexPath:a_indexPath];
    IFAFormTableViewCellAccessoryType l_accessoryType = [self IFA_accessoryTypeForEditorType:l_editorType];
    if (l_editorType==IFAEditorTypeNotApplicable) {
        if ([self IFA_shouldLinkToUrlForIndexPath:a_indexPath]){
            l_accessoryType = IFAFormTableViewCellAccessoryTypeDisclosureIndicatorInfo;
        }
    }else{
        BOOL l_cannotBeChanged = ![self IFA_canUserChangeFieldAtIndexPath:a_indexPath];
        BOOL l_isInReadOnlyMode = self.readOnlyMode && !self.showEditButton;
        if (l_cannotBeChanged || l_isInReadOnlyMode) {
            l_accessoryType = IFAFormTableViewCellAccessoryTypeNone;
        }
    }
    return l_accessoryType;
}

- (IFAEditorType)editorTypeForIndexPath:(NSIndexPath*)anIndexPath {

    IFAEntityConfigFieldType l_fieldType = [self fieldTypeForIndexPath:anIndexPath];
    BOOL l_shouldLinkToUrl = [self IFA_shouldLinkToUrlForIndexPath:anIndexPath];
    if (l_fieldType == IFAEntityConfigFieldTypeViewController || l_fieldType == IFAEntityConfigFieldTypeButton || l_fieldType == IFAEntityConfigFieldTypeCustom || l_shouldLinkToUrl) {
        return IFAEditorTypeNotApplicable;
    }

    NSString *propertyName = [self nameForIndexPath:anIndexPath];

//    NSLog(@"editorTypeForIndexPath: %@, propertyName: %@", [anIndexPath description], propertyName);

    // Introspection to get property type information
    objc_property_t l_property = class_getProperty(self.object.class, [propertyName UTF8String]);
    NSString *l_propertyDescription = l_property ? @(property_getAttributes(l_property)) : nil;
//    NSLog(@"  property attributes: %@: ", l_propertyDescription);

    if (l_fieldType == IFAEntityConfigFieldTypeForm) {

        return IFAEditorTypeForm;

    } else if ([[IFAPersistenceManager sharedInstance].entityConfig isEnumerationForProperty:propertyName
                                                                                    inObject:self.object]) {

        return IFAEditorTypePicker;

    } else if ([l_propertyDescription hasPrefix:@"T@\"NSDate\","]) {

        NSDictionary *l_propertyOptions = [[[IFAPersistenceManager sharedInstance] entityConfig] optionsForProperty:propertyName
                                                                                                           inObject:self.object];
        if ([l_propertyOptions[@"datePickerMode"] isEqualToString:@"fullDateAndTime"]) {
            return IFAEditorTypeFullDateAndTime;
        } else {
            return IFAEditorTypeDatePicker;
        }

    } else if ([self.object isKindOfClass:NSManagedObject.class]) {

        NSPropertyDescription *propertyDescription = [self.object ifa_descriptionForProperty:propertyName];
        //            NSLog(@"propertyDescription: %@", [propertyDescription validationPredicates]);

        if ([propertyDescription isKindOfClass:[NSAttributeDescription class]] && [(NSAttributeDescription *) propertyDescription attributeType] == NSBooleanAttributeType && ![self IFA_isReadOnlyForIndexPath:anIndexPath]) {

            return IFAEditorTypeSwitch;

        } else if ([propertyDescription isKindOfClass:[NSAttributeDescription class]] && [(NSAttributeDescription *) propertyDescription attributeType] == NSDoubleAttributeType && ![self IFA_isReadOnlyForIndexPath:anIndexPath]) {

            NSUInteger dataType = [[IFAPersistenceManager sharedInstance].entityConfig dataTypeForProperty:propertyName
                                                                                                  inObject:self.object];
            if (dataType == IFADataTypeTimeInterval) {
                return IFAEditorTypeTimeInterval;
            } else {
                return IFAEditorTypeNumber;
            }

        } else if ([[IFAPersistenceManager sharedInstance].entityConfig isRelationshipForProperty:propertyName
                                                                                  inManagedObject:(NSManagedObject *) self.object]) {

            NSString *entityName = [[IFAPersistenceManager sharedInstance].entityConfig entityNameForProperty:propertyName
                                                                                                     inObject:self.object];
            IFAEditorType editorType = [[IFAPersistenceManager sharedInstance].entityConfig fieldEditorForEntity:entityName];
            if (editorType == (IFAEditorType) NSNotFound) {
                // Attempt to infer editor type from target entity
                return [[IFAPersistenceManager sharedInstance] isSystemEntityForEntity:entityName] ? IFAEditorTypePicker : IFAEditorTypeSelectionList;
            } else {
                return editorType;
            }

        } else {

            return IFAEditorTypeText;

        }

    } else {

        return IFAEditorTypeText;

    }

}

- (IFAFormInputAccessoryView *)formInputAccessoryView {
    if (!_formInputAccessoryView) {
        _formInputAccessoryView = [[IFAFormInputAccessoryView alloc] initWithTableView:self.tableView];
        _formInputAccessoryView.dataSource = self;
        _formInputAccessoryView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, _formInputAccessoryView.bounds.size.height);
        _formInputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    }
    return _formInputAccessoryView;
}

- (NSIndexPath *)indexPathForPropertyNamed:(NSString *)a_propertyName {
    return [[IFAPersistenceManager sharedInstance].entityConfig indexPathForProperty:a_propertyName
                                                                            inObject:self.object
                                                                              inForm:self.formName
                                                                          createMode:self.createMode];
}

- (IFAEntityConfigFieldType)fieldTypeForIndexPath:(NSIndexPath *)a_indexPath {
    if ([self IFA_isDeleteButtonAtIndexPath:a_indexPath]) {
        return IFAEntityConfigFieldTypeButton;
    }else{
        IFAEntityConfig *l_entityConfig = [IFAPersistenceManager sharedInstance].entityConfig;
        return [l_entityConfig fieldTypeForIndexPath:a_indexPath inObject:self.object inForm:self.formName
                                          createMode:self.createMode];
    }
}

- (BOOL)shouldShowDeleteButton {
    return (self.editing && !self.createMode);
}

- (BOOL)isDestructiveButtonForCell:(IFAFormTableViewCell *)a_cell{
    IFAEntityConfig *l_entityConfig = [IFAPersistenceManager sharedInstance].entityConfig;
    BOOL isDeleteButton = [a_cell.propertyName isEqualToString:IFAEntityConfigPropertyNameDeleteButton];
    BOOL isGenericDestructiveButton = !isDeleteButton && [l_entityConfig isDestructiveButtonAtIndexPath:a_cell.indexPath
                                                                                               inObject:self.object
                                                                                                 inForm:self.formName
                                                                                             createMode:self.createMode];
    return isDeleteButton || isGenericDestructiveButton;
}

- (void)clearSectionFooterHelpTextForPropertyNamed:(NSString *)a_propertyName {

    NSIndexPath *propertyIndexPath = self.propertyNameToIndexPath[a_propertyName];
    NSInteger section = propertyIndexPath.section;

    // Remove section footer height cache entry
    [self.IFA_cachedSectionFooterHeightsBySection removeObjectForKey:@(section)];

    UIView *sectionFooterView = [self.tableView footerViewForSection:section];
    if ([sectionFooterView isKindOfClass:[IFAFormSectionHeaderFooterView class]]) {
        IFAFormSectionHeaderFooterView *formSectionHeaderFooterView = (IFAFormSectionHeaderFooterView *) sectionFooterView;
        formSectionHeaderFooterView.label.text = nil;
    }

}

- (NSString *)titleForHeaderInSection:(NSInteger)a_section {
    NSString *title = nil;
    if (a_section ==self.IFA_deleteButtonSection) {
        title = nil;
    } else {
        title = [[IFAPersistenceManager sharedInstance].entityConfig headerForSectionIndex:a_section
                                                                                  inObject:self.object
                                                                                    inForm:self.formName
                                                                                createMode:self.createMode];
    }
    return title.uppercaseString;
}

- (NSString *)titleForFooterInSection:(NSInteger)a_section {
    NSString *title = nil;
    if (a_section == self.IFA_deleteButtonSection) {
        title = nil;
    } else {
        title = [[IFAPersistenceManager sharedInstance].entityConfig footerForSectionIndex:a_section
                                                                                  inObject:self.object
                                                                                    inForm:self.formName
                                                                                createMode:self.createMode];
    }
    return title;
}

#pragma mark -
#pragma mark UITableViewDataSource

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==self.IFA_deleteButtonSection) {
        return 1;
    } else {
        return [[IFAPersistenceManager sharedInstance].entityConfig fieldCountCountForSectionIndex:section
                                                                                          inObject:self.object
                                                                                            inForm:self.formName
                                                                                        createMode:self.createMode];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

//    NSLog(@"cellForRowAtIndexPath: %@", [indexPath description]);

    if ([self IFA_isStaticFieldTypeForIndexPath:indexPath]) {
        return [self IFA_staticFieldTypeCellForRowAtIndexPath:indexPath];
    }

    NSString *l_propertyName = [self nameForIndexPath:indexPath];

//    NSLog(@"cellForRowAtIndexPath: %@, l_propertyName: %@", [indexPath description], l_propertyName);

    // The field editor type for this property
    NSUInteger editorType = [self editorTypeForIndexPath:indexPath];

    IFAFormTableViewCell *l_cellToReturn = nil;

    if ([self IFA_hasEmbeddedEditorForFieldAtIndexPath:indexPath]) {

        switch (editorType) {

            case IFAEditorTypeText:
            case IFAEditorTypeNumber:
            {
                l_cellToReturn = [self IFA_textFieldCellForTableView:tableView atIndexPath:indexPath];
                break;
            }

            case IFAEditorTypeSwitch: {
                l_cellToReturn = [self IFA_switchCellForTable:tableView indexPath:indexPath];
                break;
            }

            case IFAEditorTypeSegmented: {

                // Create reusable cell
                IFAFormTableViewCell *cell = (IFAFormTableViewCell *) [tableView dequeueReusableCellWithIdentifier:l_propertyName];
                if (cell == nil) {

                    // Load segmented UI control items
                    NSMutableArray *segmentControlItems = [NSMutableArray array];
                    for (NSManagedObject *mo in [[IFAPersistenceManager sharedInstance] findAllForEntity:[self entityNameForProperty:l_propertyName]]) {
                        [segmentControlItems addObject:[mo ifa_displayValue]];
                    }

                    // Instantiate segmented UI control
                    IFASegmentedControl *segmentedControl = [[IFASegmentedControl alloc] initWithItems:segmentControlItems];
                    segmentedControl.propertyName = l_propertyName;
                    [segmentedControl addTarget:self action:@selector(onSegmentedControlAction:)
                               forControlEvents:UIControlEventValueChanged];
                    [self.IFA_uiControlsWithTargets addObject:segmentedControl];

                    cell = [[IFASegmentedControlTableViewCell alloc] initWithReuseIdentifier:l_propertyName
                                                                                      object:self.object
                                                                                propertyName:l_propertyName
                                                                                   indexPath:indexPath
                                                                          formViewController:self
                                                                            segmentedControl:segmentedControl];
                    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

                    // Set appearance
                    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                                    cell:cell];

                    // Add and position segmented UI control appropriately
                    [cell.contentView addSubview:segmentedControl];
                    [segmentedControl ifa_addLayoutConstraintsToCenterInSuperview];

                }

                l_cellToReturn = cell;

                break;

            }

            default:
                NSAssert(NO, @"Unexpected editor type: %lu", (unsigned long)editorType);
                return nil;
        }

    } else {

        l_cellToReturn = [self IFA_cellForTableView:tableView indexPath:indexPath className:@"IFAFormTableViewCell"];

    }

    (self.IFA_propertyNameToCell)[l_propertyName] = l_cellToReturn;
    (self.propertyNameToIndexPath)[l_propertyName] = indexPath;

    return [self IFA_updateEditingStateForCell:[self populateCell:l_cellToReturn] indexPath:indexPath];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger l_numberOfSections = [[IFAPersistenceManager sharedInstance].entityConfig formSectionsCountForObject:self.object
                                                                                                             inForm:self.formName
                                                                                                         createMode:self.createMode];
    if (self.shouldShowDeleteButton) {
        l_numberOfSections++;
    }
    return l_numberOfSections;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Implements the non-editing mode behaviour for when the user taps on a row
    if (self.showEditButton && !self.editing) {
        BOOL l_transitionComplete = [self IFA_transitionToEditModeWithSelectedRowAtIndexPath:indexPath];
        if (l_transitionComplete) {
            return;
        }
    }

    if (![self IFA_endTextFieldEditingWithCommit:self.editing]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }

    if ([self IFA_shouldLinkToUrlForIndexPath:indexPath]) {
        NSString *l_urlPropertyName = [self IFA_urlPropertyNameForIndexPath:indexPath];
        NSString *l_urlString = [self.object valueForKeyPath:l_urlPropertyName];
        NSURL *l_url = [NSURL URLWithString:l_urlString];
        [l_url ifa_openWithAlertPresenterViewController:self];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    IFAEntityConfig *l_entityConfig = [IFAPersistenceManager sharedInstance].entityConfig;

    IFAEntityConfigFieldType l_fieldType = [self fieldTypeForIndexPath:indexPath];
    switch (l_fieldType) {
        case IFAEntityConfigFieldTypeViewController:{
            NSString *l_viewControllerClassName = [[IFAPersistenceManager sharedInstance].entityConfig classNameForViewControllerFieldTypeAtIndexPath:indexPath
                                                                                                                                             inObject:self.object
                                                                                                                                               inForm:self.formName
                                                                                                                                           createMode:self.createMode];
            Class l_viewControllerClass = NSClassFromString(l_viewControllerClassName);
            UIViewController *l_viewController = [l_viewControllerClass new];
            if (!l_viewController.title) {
                l_viewController.title = [l_entityConfig labelForViewControllerFieldTypeAtIndexPath:indexPath
                                                                                           inObject:self.object
                                                                                             inForm:self.formName
                                                                                         createMode:self.createMode];
            }
            NSDictionary *l_properties = [l_entityConfig propertiesForViewControllerFieldTypeAtIndexPath:indexPath
                                                                                                inObject:self.object
                                                                                                  inForm:self.formName
                                                                                              createMode:self.createMode];
            if (l_properties) {
                for (NSString *l_key in l_properties.allKeys) {
                    [l_viewController setValue:l_properties[l_key] forKeyPath:l_key];
                }
            }
            if ([l_entityConfig isModalForViewControllerFieldTypeAtIndexPath:indexPath inObject:self.object
                                                                      inForm:self.formName createMode:self.createMode]) {
                [self ifa_presentModalViewController:l_viewController presentationStyle:UIModalPresentationFullScreen
                                     transitionStyle:UIModalTransitionStyleCoverVertical];
            } else {
                [self.navigationController pushViewController:l_viewController animated:YES];
            }
            return;
        }
        case IFAEntityConfigFieldTypeButton: {
            IFAFormTableViewCell *l_cell = (IFAFormTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
            if ([l_cell.propertyName isEqualToString:IFAEntityConfigPropertyNameDeleteButton]) {
                NSString *l_entityName = [[self.object ifa_entityLabel] lowercaseString];
                NSString *l_message = [NSString stringWithFormat:@"Are you sure you want to delete the %@?", l_entityName];
                NSString *l_destructiveActionButtonTitle = [NSString stringWithFormat:@"Delete %@", l_entityName];
                __weak __typeof(self) l_weakSelf = self;
                void (^destructiveActionBlock)() = ^{
                    NSAssert([l_weakSelf.object isKindOfClass:NSManagedObject.class], @"Selection list editor type not yet implemented for non-NSManagedObject instances");
                    if (l_weakSelf.IFA_readOnlyModeSuspendedForEditing) {
                        [l_weakSelf IFA_popChildManagedObjectContext];
                    }
                    NSManagedObject *l_managedObject = (NSManagedObject *) self.object;
                    if (![[IFAPersistenceManager sharedInstance] deleteAndSaveObject:l_managedObject validationAlertPresenter:self]) {
                        return;
                    }
                    l_weakSelf.IFA_changesMadeByThisViewController = YES;
                    [l_weakSelf ifa_notifySessionCompletion];
                    [IFAUIUtils showAndHideUserActionConfirmationHudWithText:[NSString stringWithFormat:@"%@ deleted",
                                                                                                        l_weakSelf.title]];
                };
                [self ifa_presentAlertControllerWithTitle:nil
                                                  message:l_message
                             destructiveActionButtonTitle:l_destructiveActionButtonTitle
                                   destructiveActionBlock:destructiveActionBlock
                                              cancelBlock:nil];
            }else{
                if ([self.formViewControllerDelegate respondsToSelector:@selector(formViewController:didTapButtonNamed:)]) {
                    [self.formViewControllerDelegate formViewController:self
                                                      didTapButtonNamed:[l_entityConfig nameForIndexPath:indexPath
                                                                                                inObject:self.object
                                                                                                  inForm:self.formName
                                                                                              createMode:self.createMode]];
                }
            }
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        default:
            // Continue on
            break;
    }

    if ([self accessoryTypeForIndexPath:indexPath] != IFAFormTableViewCellAccessoryTypeNone) {

        if ([self IFA_isFormEditorTypeForIndexPath:indexPath]) {

            // Push appropriate editor view controller
            UIViewController *l_viewController = [self IFA_editorViewControllerForIndexPath:indexPath];
            [self.navigationController pushViewController:l_viewController animated:YES];

        } else {

            UIViewController *l_viewController = [self IFA_editorViewControllerForIndexPath:indexPath];
            l_viewController.ifa_presenter = self;

            self.IFA_indexPathForPopoverController = indexPath;
            CGRect l_fromPopoverRect = [self IFA_fromPopoverRectForIndexPath:self.IFA_indexPathForPopoverController];

            if ([self IFA_shouldAdjustContentInsetForPresentedViewController:l_viewController]) {
                self.contentInsetBeforePresentingSemiModalViewController = tableView.contentInset;
                CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;   // Not the actual navigation bar that will be used. Just a reference for height.
                CGFloat toolbarHeight = l_viewController.ifa_editModeToolbarItems.count ? navigationBarHeight : 0;   // Assuming the toolbar height is the same as the navigation bar.
                CGFloat contentBottomInset = l_viewController.view.bounds.size.height + navigationBarHeight + toolbarHeight;
                [UIView animateWithDuration:IFAAnimationDuration animations:^{
                    tableView.contentInset = UIEdgeInsetsMake(0, 0, contentBottomInset, 0);
                }];
                [tableView scrollToRowAtIndexPath:indexPath
                                 atScrollPosition:UITableViewScrollPositionBottom
                                         animated:YES];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }

            [self ifa_presentModalSelectionViewController:l_viewController fromRect:l_fromPopoverRect
                                                   inView:self.tableView];

        }

    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];

    // Set custom disclosure indicator for cell
    [[self ifa_appearanceTheme] setCustomDisclosureIndicatorForCell:cell tableViewController:self];

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *labelText = [self titleForHeaderInSection:section];
    return [self IFA_sectionHeaderFooterWithLabelText:labelText isHeader:YES section:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self IFA_sectionHeaderFooterHeightForLabelTextIsHeader:YES section:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *labelText = [self titleForFooterInSection:section];
    return [self IFA_sectionHeaderFooterWithLabelText:labelText isHeader:NO section:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self IFA_sectionHeaderFooterHeightForLabelTextIsHeader:NO section:section];
}

#pragma mark - IFAPresenter

-(void)changesMadeByViewController:(UIViewController *)a_viewController {
//    NSLog(@"changesMadeByViewController: %@", [a_viewController description]);
    [super changesMadeByViewController:a_viewController];

    if ([a_viewController isKindOfClass:[IFAAbstractFieldEditorViewController class]]) {

        // Determine the index path for the property
        IFAAbstractFieldEditorViewController *fieldEditorViewController = (IFAAbstractFieldEditorViewController *) a_viewController;
        NSIndexPath *propertyIndexPath = self.propertyNameToIndexPath[fieldEditorViewController.propertyName];

        [self clearSectionFooterHelpTextForPropertyNamed:fieldEditorViewController.propertyName];

        // Reload section to reflect new values and new help text
        NSIndexSet *sectionsToReload = [NSIndexSet indexSetWithIndex:propertyIndexPath.section];
        [self.tableView reloadSections:sectionsToReload withRowAnimation:UITableViewRowAnimationNone];

        // Reposition cell as help text height may have changed
        [self.tableView scrollToRowAtIndexPath:propertyIndexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:YES];

    }else{
        [self reloadData];
    }
}

- (void)sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                       data:(id)a_data shouldAnimateDismissal:(BOOL)a_shouldAnimateDismissal {
//    NSLog(@"sessionDidCompleteForViewController in: %@, for: %@, changesMade: %u", [self description], [a_viewController description], a_changesMade);
    [super sessionDidCompleteForViewController:a_viewController changesMade:a_changesMade data:a_data
                        shouldAnimateDismissal:a_shouldAnimateDismissal];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    if ([self IFA_shouldAdjustContentInsetForPresentedViewController:a_viewController]) {
        __weak __typeof(self) l_weakSelf = self;
        [UIView animateWithDuration:IFAAnimationDuration animations:^{
            l_weakSelf.tableView.contentInset = l_weakSelf.contentInsetBeforePresentingSemiModalViewController;
        } completion:^(BOOL finished) {
            l_weakSelf.contentInsetBeforePresentingSemiModalViewController = UIEdgeInsetsZero;
        }];
    }
}

#pragma mark -
#pragma mark Overrides

- (void)viewDidLoad {

//    NSTimeInterval interval1 = [NSDate date].timeIntervalSinceReferenceDate;
//    NSLog(@"viewDidLoad interval1 = %f", interval1);

    self.ifa_delegate = self;

    [self.tableView registerClass:[IFAFormSectionHeaderFooterView class] forHeaderFooterViewReuseIdentifier:k_sectionHeaderFooterReuseId];

    [super viewDidLoad];

    self.IFA_initialChildManagedObjectContextCountForAssertion = [IFAPersistenceManager sharedInstance].childManagedObjectContexts.count;
    
    self.IFA_isManagedObject = [self.object isKindOfClass:NSManagedObject.class];

    // Set managed object default values based on backing preferences
    IFAEntityConfig *l_entityConfig = [IFAPersistenceManager sharedInstance].entityConfig;
    if (self.createMode && !self.isSubForm) {
        [l_entityConfig setDefaultValuesFromBackingPreferencesForObject:self.object];
    }

    self.switchControlTagToPropertyName = [[NSMutableDictionary alloc] init];
    self.IFA_propertyNameToCell = [[NSMutableDictionary alloc] init];
    self.propertyNameToIndexPath = [[NSMutableDictionary alloc] init];

    if (!(self.title = [l_entityConfig labelForForm:self.formName
                                           inObject:self.object])) {
        self.title = [l_entityConfig labelForObject:self.object];
    }

    //		self.hidesBottomBarWhenPushed = YES;

    if (!self.isSubForm) {
        [[IFAPersistenceManager sharedInstance] resetEditSession];
    }

    self.IFA_uiControlsWithTargets = [NSMutableArray new];

    BOOL hasNavigationBarSubmitButton = [l_entityConfig hasNavigationBarSubmitButtonForForm:self.formName
                                                                                   inEntity:self.object.ifa_entityName];
    if ( ((!self.readOnlyMode && !self.isSubForm) || self.IFA_isReadOnlyWithEditButtonCase) && (self.IFA_isManagedObject || hasNavigationBarSubmitButton)) {
        self.editButtonItem.tag = IFABarItemTagEditButton;
        [self ifa_addRightBarButtonItem:self.editButtonItem];
    }

    //	self.tableView.allowsSelection = NO;
    self.tableView.allowsSelectionDuringEditing = YES;

    // Form header
    NSString *l_formHeader = nil;
    if ((l_formHeader = [l_entityConfig headerForForm:self.formName
                                             inObject:self.object])) {
        UILabel *l_label = [UILabel new];
        l_label.textAlignment = NSTextAlignmentCenter;
        l_label.backgroundColor = [UIColor clearColor];
        l_label.text = l_formHeader;
        l_label.textColor = [IFAUIUtils colorForInfoPlistKey:@"IFAThemeFormHeaderTextColor"];
        [l_label sizeToFit];
        self.tableView.tableHeaderView = l_label;
    }

    // Form footer
    NSString *l_formFooter = nil;
    if ((l_formFooter = [l_entityConfig footerForForm:self.formName
                                             inObject:self.object])) {
        UILabel *l_label = [UILabel new];
        l_label.textAlignment = NSTextAlignmentCenter;
        l_label.backgroundColor = [UIColor clearColor];
        l_label.text = l_formFooter;
        l_label.textColor = [IFAUIUtils colorForInfoPlistKey:@"IFAThemeFormFooterTextColor"];
        [l_label sizeToFit];
        self.tableView.tableFooterView = l_label;
    }

    self.IFA_dismissModalFormBarButtonItem = [IFAUIUtils isIPad] ? [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeDismiss
                                                                                             target:self
                                                                                             action:@selector(IFA_onDismissButtonTap:)] : [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeBack
                                                                                                                                                                    target:self
                                                                                                                                                                    action:@selector(IFA_onDismissButtonTap:)];
    self.IFA_cancelBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeCancel target:self
                                                             action:@selector(IFA_onCancelButtonTap:)];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    if(self.createMode){
        self.editing = YES;
    }

//    NSTimeInterval interval2 = [NSDate date].timeIntervalSinceReferenceDate;
//    NSLog(@"viewDidLoad interval2 = %f", interval2);
//    NSLog(@"viewDidLoad interval2 - interval1 = %f", interval2 - interval1);

}

- (void)viewWillAppear:(BOOL)animated {

//    [TestFlight passCheckpoint:[NSString stringWithFormat:@"IFAFormViewController.viewWillAppear.%@", [managedObject ifa_entityName]]];
//    NSLog(@"self: %@", [self description]);
//    NSLog(@"self.presentedViewController: %@", [self.presentedViewController description]);
//    NSLog(@"self.presentingViewController: %@", [self.presentingViewController description]);
//    NSLog(@"self.navigationController.presentedViewController: %@", [self.navigationController.presentedViewController description]);
//    NSLog(@"self.navigationController.presentingViewController: %@", [self.navigationController.presentingViewController description]);

    [super viewWillAppear:animated];

    if (!self.readOnlyMode && !self.editing) {
        self.editing = YES;
    }

    [self IFA_updateLeftBarButtonItemsStates];
    [self reloadData];

    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onTextFieldNotification:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onTextFieldNotification:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onTextFieldNotification:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];

}

-(void)viewDidAppear:(BOOL)animated{

    // Make sure all text field cells that will be reused are instantiated at this point.
    //  Text fields, which are properties in the text field cells, must be known in advance to provide the functionality to cycle through text fields with the Return key.
//    NSLog(@"IFA_editableTextFieldCells before full instantiation: %@", [self.IFA_editableTextFieldCells description]);
    for (int l_section = 0; l_section < [self numberOfSectionsInTableView:self.tableView]; l_section++) {
        for (int l_row = 0; l_row < [self tableView:self.tableView numberOfRowsInSection:l_section]; l_row++) {
            @autoreleasepool {
                NSIndexPath *l_indexPath = [NSIndexPath indexPathForRow:l_row inSection:l_section];
//                NSLog(@"  l_indexPath: %@", [l_indexPath description]);
                NSUInteger l_editorType = [self editorTypeForIndexPath:l_indexPath];
                if (l_editorType == IFAEditorTypeText || l_editorType == IFAEditorTypeNumber) {
//                    NSLog(@"    requesting text field cell...");
                    [self IFA_textFieldCellForTableView:self.tableView atIndexPath:l_indexPath];
                }
            }
        }
    }
//    NSLog(@"IFA_editableTextFieldCells after full instantiation: %@", [self.IFA_editableTextFieldCells description]);

    [super viewDidAppear:animated];

    if (self.createMode && !self.IFA_createModeAutoFieldEditDone) {
        NSIndexPath *l_indexPath = [self indexPathForPropertyNamed:@"name"];
        if (l_indexPath) {
            IFAFormTextFieldTableViewCell *l_cell = (IFAFormTextFieldTableViewCell *) [self visibleCellForIndexPath:l_indexPath];
            [l_cell.textField becomeFirstResponder];
        }
        self.IFA_createModeAutoFieldEditDone = YES;
    }

}

-(void)viewWillDisappear:(BOOL)animated{

//    NSLog(@"viewWillDisappear for %@", [self description]);

    [super viewWillDisappear:animated];

    if (!self.IFA_isManagedObject && !self.ifa_presentedAsModal) {
        [self updateAndSaveBackingPreferences];
    }

}

-(void)viewDidDisappear:(BOOL)animated{

//    NSLog(@"viewDidDisappear for %@", [self description]);

    [super viewDidDisappear:animated];

    for (UIControl *l_uiControl in self.IFA_uiControlsWithTargets) {
//        NSLog(@"l_uiControl: %@", [l_uiControl description]);
        [l_uiControl removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    }
    [self.IFA_uiControlsWithTargets removeAllObjects];

    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];

    BOOL l_hasBeenPoppedByNavigationController = self.isMovingFromParentViewController;
    if (l_hasBeenPoppedByNavigationController) {
        [self ifa_notifySessionCompletion];
    }

}

- (void)quitEditing {
    if (self.editing) {
        if (self.IFA_isManagedObject && ([IFAPersistenceManager sharedInstance].isCurrentManagedObjectDirty || self.IFA_textFieldTextChanged)) {
            __weak __typeof(self) l_weakSelf = self;
            void (^destructiveActionBlock)() = ^{
                [l_weakSelf IFA_rollbackAndRestoreNonEditingState];
            };
            void (^cancelBlock)() = ^{
                // Notify that any pending context switch has been denied
                [l_weakSelf replyToContextSwitchRequestWithGranted:NO];
            };
            [self ifa_presentAlertControllerWithTitle:nil
                                              message:@"Are you sure you want to discard your changes?"
                         destructiveActionButtonTitle:@"Discard changes"
                               destructiveActionBlock:destructiveActionBlock
                                          cancelBlock:cancelBlock];
        } else {
            [self IFA_rollbackAndRestoreNonEditingState];
        }
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    if (self.ifa_activePopoverController && !self.ifa_activePopoverControllerBarButtonItem) {

        // Present popover controller in the new interface orientation
        [self.tableView scrollToRowAtIndexPath:self.IFA_indexPathForPopoverController
                              atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        CGRect l_fromPopoverRect = [self IFA_fromPopoverRectForIndexPath:self.IFA_indexPathForPopoverController];
        [self ifa_presentPopoverController:self.ifa_activePopoverController fromRect:l_fromPopoverRect
                                    inView:self.tableView];

    }

}

-(void)ifa_onKeyboardNotification:(NSNotification*)a_notification{

    [super ifa_onKeyboardNotification:a_notification];

//    NSLog(@"m_onKeyboardNotification");

    if ([a_notification.name isEqualToString:UIKeyboardDidShowNotification]) {

        [self IFA_handleContentBottomInsetAppleBugIfRequiredForKeyboardShowing:YES];

        __weak __typeof(self) l_weakSelf = self;
        [IFAUtils dispatchAsyncMainThreadBlock:^{
            [l_weakSelf.tableView flashScrollIndicators];
        }];

    }else if ([a_notification.name isEqualToString:UIKeyboardDidHideNotification]) {

        if (self.ifa_activePopoverController && !self.ifa_activePopoverControllerBarButtonItem) {

            CGRect l_fromPopoverRect = [self IFA_fromPopoverRectForIndexPath:self.IFA_indexPathForPopoverController];
            [self ifa_presentPopoverController:self.ifa_activePopoverController fromRect:l_fromPopoverRect
                                        inView:self.tableView];

        }

        [self IFA_handleContentBottomInsetAppleBugIfRequiredForKeyboardShowing:NO];

    }

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{

//    NSLog(@"setEditing: %u", editing);

    self.IFA_saveButtonTapped = NO;
    self.doneButtonSaves = NO;

    BOOL l_contextSwitchRequestPending = self.contextSwitchRequestPending;    // save this value before the super class resets it
//    BOOL l_reloadData = !l_contextSwitchRequestPending;

    IFAPersistenceManager *l_persistenceManager = [IFAPersistenceManager sharedInstance];

    if(editing){

        [super setEditing:editing animated:animated];

        if (!self.isSubForm) {
            if (self.IFA_isReadOnlyWithEditButtonCase) {
                self.readOnlyMode = NO;
                self.IFA_readOnlyModeSuspendedForEditing = YES;
                [self IFA_pushChildManagedObjectContext];
            }
            if ([l_persistenceManager.entityConfig hasNavigationBarSubmitButtonForForm:self.formName
                                                                              inEntity:[self.object ifa_entityName]]) {
                self.editButtonItem.title = [l_persistenceManager.entityConfig navigationBarSubmitButtonLabelForForm:self.formName
                                                                                                            inEntity:[self.object ifa_entityName]];
//                self.editButtonItem.accessibilityLabel = self.editButtonItem.title;
            }else{
                self.editButtonItem.title = IFAButtonLabelSave;
//                self.editButtonItem.accessibilityLabel = @"Save Button";
                self.doneButtonSaves = YES;
            }
            [self IFA_updateLeftBarButtonItemsStates];
        }

    }else {

        if (![self IFA_endTextFieldEditingWithCommit:!self.IFA_rollbackPerformed]) {
            return;
        };

        if (!self.isSubForm) {   // does not execute this block if it's a context switching scenario for a sub-form

            self.IFA_saveButtonTapped = !self.IFA_rollbackPerformed;

            if (self.IFA_isManagedObject) {

                NSManagedObject *l_managedObject = (NSManagedObject *) self.object;

                BOOL l_changesMade = NO;
                if ([l_managedObject isInserted] || [l_managedObject isUpdated]) {

                    bool l_isInserted = [l_managedObject isInserted];

                    [self updateBackingPreferences];

                    // Persist changes
                    if (![l_persistenceManager saveObject:l_managedObject validationAlertPresenter:self]) {
                        // If validation error occurs then simply redisplay screen (at this point, the error has already been handled from a UI POV)
                        return;
                    }

                    l_changesMade = YES;
                    self.IFA_changesMadeByThisViewController = YES;

                    [IFAUIUtils showAndHideUserActionConfirmationHudWithText:[NSString stringWithFormat:@"%@ %@",
                                                                                                        self.title,
                                                                                                        l_isInserted ? @"created" : @"updated"]];

                }

                if (self.IFA_readOnlyModeSuspendedForEditing) {
                    if (l_changesMade) {
                        [l_persistenceManager saveMainManagedObjectContext];
                    }
                    [self IFA_popChildManagedObjectContext];
                }

            }else{

                [self updateAndSaveBackingPreferences];

                if (!self.IFA_rollbackPerformed) {
                    [self onNavigationBarSubmitButtonTap];
                    return;
                }

            }

        }

        self.skipEditingUiStateChange = ! (self.IFA_readOnlyModeSuspendedForEditing && !l_contextSwitchRequestPending);
        [super setEditing:editing animated:animated];

        if (!self.isSubForm) {   // does not execute this block if it's a context switching scenario for a sub-form

            if (!self.skipEditingUiStateChange) {
//                self.editButtonItem.accessibilityLabel = self.editButtonItem.title;
                [self IFA_updateLeftBarButtonItemsStates];
            }

            if (!l_contextSwitchRequestPending) {    // Make sure this controller has not already been popped by a context switch request somewhere else
                if (self.IFA_readOnlyModeSuspendedForEditing) {
                    self.readOnlyMode = YES;
                    self.IFA_readOnlyModeSuspendedForEditing = NO;
                } else {
                    BOOL l_canDismissView = self.ifa_presentedAsModal || (self.navigationController.viewControllers)[0] != self;
                    if ((self.IFA_saveButtonTapped || self.createMode) && l_canDismissView && !self.IFA_preparingForDismissalAfterRollback) {
                        [self ifa_notifySessionCompletion];
                    }

                }
            }

        }

    }

    [UIView transitionWithView:self.view duration:IFAAnimationDuration
                       options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.tableView reloadData];
    } completion:NULL];

}

- (UIView *)inputAccessoryView {
    return self.formInputAccessoryView;
}

- (void)ifa_notifySessionCompletion {
    [self ifa_notifySessionCompletionWithChangesMade:self.IFA_changesMadeByThisViewController data:self.object];
}

- (BOOL)automaticallyHandleContextSwitchingBasedOnEditingState {
    return NO;
}

- (BOOL)contextSwitchRequestRequired {
    return self.parentFormViewController ? self.parentFormViewController.contextSwitchRequestRequired : self.IFA_isManagedObject;
}

- (void)onContextSwitchRequestNotification:(NSNotification *)aNotification {
    if (self.parentFormViewController) {
        [self.parentFormViewController onContextSwitchRequestNotification:aNotification];
    }else{
        [super onContextSwitchRequestNotification:aNotification];
        if (!self.editing) {
            [self replyToContextSwitchRequestWithGranted:YES];
            [self ifa_notifySessionCompletion];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self.formInputAccessoryView notifyTableViewDidEndScrollingAnimation];
}

#pragma mark - IFAInputAccessoryViewDelegate

- (BOOL)    formInputAccessoryView:(IFAFormInputAccessoryView *)a_formInputAccessoryView
canReceiveKeyboardInputAtIndexPath:(NSIndexPath *)a_indexPath {
    return [self.IFA_editableTextFieldCells containsObject:self.IFA_indexPathToTextFieldCellDictionary[a_indexPath]];
}

- (UIResponder *)  formInputAccessoryView:(IFAFormInputAccessoryView *)a_formInputAccessoryView
responderForKeyboardInputFocusAtIndexPath:(NSIndexPath *)a_indexPath {
    IFAFormTextFieldTableViewCell *l_textFieldCell = self.IFA_indexPathToTextFieldCellDictionary[a_indexPath];
    return l_textFieldCell.textField;
}

#ifdef IFA_AVAILABLE_Help

#pragma mark - IFAHelpTarget

- (NSString *)helpTargetId {
    if (self.isSubForm) {
        return nil;
    }else{
        return [[IFAHelpManager sharedInstance] helpTargetIdForEntityNamed:self.object.ifa_entityName];
    }
}

#endif

#pragma mark - IFAViewControllerDelegate

- (void)viewController:(UIViewController *)a_viewController didChangeContentSizeCategory:(NSString *)a_contentSizeCategory{

    // Clear section header/footer height cache
    self.IFA_cachedSectionHeaderHeightsBySection = nil;
    self.IFA_cachedSectionFooterHeightsBySection = nil;

    // Force a table reload as section header/footer heights may need to change
    [self.tableView reloadData];

}

@end
