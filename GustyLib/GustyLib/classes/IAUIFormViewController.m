//
//  IAFormViewController.m
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

#import "IACommon.h"

@interface IAUIFormViewController()

@property (nonatomic, strong) NSIndexPath *p_indexPathForPopoverController;
@property (nonatomic, strong) UIBarButtonItem *p_dismissModalFormBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *p_cancelBarButtonItem;
@property (nonatomic) BOOL p_textFieldEditing;
@property (nonatomic) BOOL p_textFieldTextChanged;
@property (nonatomic, strong) NSMutableDictionary *p_indexPathToTextFieldCellDictionary;
@property (nonatomic, strong) NSMutableArray *p_editableTextFieldCells;

@end

@implementation IAUIFormViewController{
    
    @private
    BOOL v_createModeAutoFieldEditDone;
    BOOL v_isManagedObject;

}


NSString* const IA_TT_CELL_IDENTIFIER_GENERIC = @"genericCell";
NSString* const IA_TT_CELL_IDENTIFIER_SEGMENTED_CONTROL = @"segmentedControlCell";
NSString* const IA_TT_CELL_IDENTIFIER_SWITCH = @"switchCell";
NSString* const IA_TT_CELL_IDENTIFIER_VIEW_CONTROLLER = @"viewControllerCell";
NSString* const IA_TT_CELL_IDENTIFIER_CUSTOM = @"customCell";

#pragma mark - Private

- (id)initWithObject:(NSObject *)anObject readOnlyMode:(BOOL)aReadOnlyMode createMode:(BOOL)aCreateMode inForm:(NSString*)aFormName isSubForm:(BOOL)aSubFormFlag{

    //    NSLog(@"hello from init - form");

    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {

		self.readOnlyMode = aReadOnlyMode;
		self.createMode = aCreateMode;
		self.p_object = anObject;
		self.formName = aFormName;
		self.isSubForm = aSubFormFlag;

        self.p_helpTargetId = [IAUIUtils m_helpTargetIdForName:[@"form" stringByAppendingString:self.createMode?@".new":@".existing"]];

    }
	
	return self;
	
}

-(IAUIFormTableViewCell*)cellForTable:(UITableView *)a_tableView indexPath:(NSIndexPath*)a_indexPath className:(NSString*)a_className{
    
    NSString *l_propertyName = [self nameForIndexPath:a_indexPath];

    // Create reusable cell
    IAUIFormTableViewCell *l_cell = [a_tableView dequeueReusableCellWithIdentifier:l_propertyName];
    if (l_cell == nil) {
        l_cell = [[NSClassFromString(a_className) alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:l_propertyName object:self.p_object propertyName:l_propertyName indexPath:a_indexPath];
        // Set appearance
        [[[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme] m_setAppearanceOnInitReusableCellForViewController:self cell:l_cell];
    }
    l_cell.p_helpTargetId = [IAHelpManager m_helpTargetIdForPropertyName:l_propertyName inObject:self.p_object];
    
    return l_cell;
    
}

- (NSString*) labelForIndexPath:(NSIndexPath*)anIndexPath{
	return [[IAPersistenceManager instance].entityConfig labelForIndexPath:anIndexPath inObject:self.p_object inForm:self.formName createMode:self.createMode];
}

- (NSString*) nameForIndexPath:(NSIndexPath*)anIndexPath{
	return [[IAPersistenceManager instance].entityConfig nameForIndexPath:anIndexPath inObject:self.p_object inForm:self.formName createMode:self.createMode];
}

- (NSString*) entityNameForProperty:(NSString*)aPropertyName{
	return [[IAPersistenceManager instance].entityConfig entityNameForProperty:aPropertyName 
																		inEntity:[[self.p_object class] description]];
}

- (void)onDeleteButtonTap:(id)sender{
	NSString *entityName = [[self.p_object entityLabel] lowercaseString];
	NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the %@?", entityName];
	[IAUIUtils showActionSheetWithMessage:message 
			 destructiveButtonLabelSuffix:@"delete" 
                           viewController:self
                            barButtonItem:nil
								 delegate:self
									  tag:IA_UIVIEW_TAG_ACTION_SHEET_DELETE];
}

- (void)restoreNonEditingState{
    [[IAPersistenceManager instance] rollback];
    v_restoringNonEditingState = YES;
    [self setEditing:NO animated:YES];
    v_restoringNonEditingState = NO;
    [self m_notifySessionCompletion];
}

- (void)onCancelButtonTap:(id)sender {
    [self quitEditing];
}

- (void)onDismissButtonTap:(id)sender {
    [self m_notifySessionCompletion];
}

- (UIViewController*) editorViewControllerForIndexPath:(NSIndexPath*)anIndexPath{
	
	NSString *propertyName = [self nameForIndexPath:anIndexPath];
	UIViewController *controller;
    
	NSUInteger editorType = [self editorTypeForIndexPath:anIndexPath];
    BOOL l_shouldSetHelpTargetId = YES;
	switch (editorType) {
		case IA_EDITOR_TYPE_FORM:
        {
            NSString *customFormViewControllerClassName = [[IAPersistenceManager instance].entityConfig viewControllerForForm:propertyName inObject:self.p_object];
            Class formViewControllerClass;
            if (customFormViewControllerClassName) {
                formViewControllerClass = NSClassFromString(customFormViewControllerClassName);
            }else {
                formViewControllerClass = [IAUIFormViewController class];
            }
            if (self.readOnlyMode) {
                controller = [[formViewControllerClass alloc] initWithReadOnlyObject:self.p_object inForm:propertyName isSubForm:YES];
            }else{
                controller = [[formViewControllerClass alloc] initWithObject:self.p_object createMode:self.editing inForm:propertyName isSubForm:YES];
            }
        }
			break;
		case IA_EDITOR_TYPE_SELECTION_LIST:
        {
            NSAssert([self.p_object isKindOfClass:NSManagedObject.class], @"Selection list editor type not yet implemented for non-NSManagedObject instances");
            NSManagedObject *l_managedObject = (NSManagedObject*)self.p_object;
			if ([[IAPersistenceManager instance].entityConfig isToManyRelationshipForProperty:propertyName inManagedObject:l_managedObject]) {
				controller = [[IAUIMultiSelectionListViewController alloc] initWithManagedObject:l_managedObject propertyName:propertyName];
			}else {
				controller = [[IAUISingleSelectionListViewController alloc] initWithManagedObject:l_managedObject propertyName:propertyName];
			}
            l_shouldSetHelpTargetId = NO;
        }
            break;
		case IA_EDITOR_TYPE_FULL_DATE_AND_TIME:
		case IA_EDITOR_TYPE_DATE_PICKER:
		case IA_EDITOR_TYPE_TIME_INTERVAL:
		case IA_EDITOR_TYPE_PICKER:
            if (editorType==IA_EDITOR_TYPE_PICKER) {
                controller = [[IAUIPickerViewController alloc] initWithObject:self.p_object propertyName:propertyName];
            }else {
                UIDatePickerMode l_datePickerMode = NSNotFound;
                BOOL l_showTimePicker = NO;
                switch (editorType) {
                    case IA_EDITOR_TYPE_FULL_DATE_AND_TIME:
                        l_showTimePicker = YES;
                        l_datePickerMode = UIDatePickerModeDate;
                        break;
                    case IA_EDITOR_TYPE_DATE_PICKER:
                    {
                        NSDictionary *l_propertyOptions = [[[IAPersistenceManager instance] entityConfig] optionsForProperty:propertyName inObject:self.p_object];
                        if ([[l_propertyOptions objectForKey:@"datePickerMode"] isEqualToString:@"date"]) {
                            l_datePickerMode = UIDatePickerModeDate;
                        }else{
                            l_datePickerMode = UIDatePickerModeDateAndTime;
                        }
                        break;
                    }
                    case IA_EDITOR_TYPE_TIME_INTERVAL:
                        l_datePickerMode = UIDatePickerModeCountDownTimer;
                        break;
                    default:
                        NSAssert(NO, @"Unexpected editor type - case 1: %u", editorType);
                        break;
                }
                controller = [[IAUIDatePickerViewController alloc] initWithObject:self.p_object propertyName:propertyName datePickerMode:l_datePickerMode showTimePicker:l_showTimePicker];
            }
			break;
		default:
			NSAssert(NO, @"Unexpected editor type - case 2: %u", editorType);
			break;
	}

    // Set the help target ID for the view controller, if required
    if (l_shouldSetHelpTargetId) {
        UITableViewCell *l_cell = [self m_visibleCellForIndexPath:anIndexPath];
        controller.p_helpTargetId = l_cell.p_helpTargetId;
    }
    
	return controller;
    
}

- (BOOL) hasOwnEditorViewForIndexPath:(NSIndexPath*)anIndexPath{
    
	NSUInteger editorType = [self editorTypeForIndexPath:anIndexPath];
	switch (editorType) {
		case IA_EDITOR_TYPE_FORM:
		case IA_EDITOR_TYPE_DATE_PICKER:
		case IA_EDITOR_TYPE_SELECTION_LIST:
		case IA_EDITOR_TYPE_PICKER:
		case IA_EDITOR_TYPE_TIME_INTERVAL:
		case IA_EDITOR_TYPE_FULL_DATE_AND_TIME:
			return YES;
		case IA_EDITOR_TYPE_TEXT:
		case IA_EDITOR_TYPE_NUMBER:
		case IA_EDITOR_TYPE_SEGMENTED:
		case IA_EDITOR_TYPE_SWITCH:
		case IA_EDITOR_TYPE_NOT_APPLICABLE:
			return NO;
		default:
			NSAssert(NO, @"Unexpected editor type: %u", editorType);
			return NO;
	}
    
}

- (IAEditorType) editorTypeForIndexPath:(NSIndexPath*)anIndexPath{
    
    IAEntityConfig *l_entityConfig = [IAPersistenceManager instance].entityConfig;
    if ([l_entityConfig isViewControllerFieldTypeForIndexPath:anIndexPath inObject:self.p_object inForm:self.formName createMode:self.createMode] || [l_entityConfig isCustomFieldTypeForIndexPath:anIndexPath inObject:self.p_object inForm:self.formName createMode:self.createMode]) {
        return IA_EDITOR_TYPE_NOT_APPLICABLE;
    }
    
	NSString *propertyName = [self nameForIndexPath:anIndexPath];
    
    // Introspection to get property type information
    objc_property_t l_property = class_getProperty(self.p_object.class, [propertyName UTF8String]);
    NSString *l_propertyDescription = @(property_getAttributes(l_property));
    //            NSLog(@"property attributes: %@: ", l_propertyDescription);
    
    //    NSLog(@"editorTypeForIndexPath: %@, propertyName: %@", [anIndexPath description], propertyName);
	
	if ([[IAPersistenceManager instance].entityConfig isFormFieldTypeForIndexPath:anIndexPath inObject:self.p_object inForm:self.formName createMode:self.createMode]) {
        
		return IA_EDITOR_TYPE_FORM;
        
    }else if ([[IAPersistenceManager instance].entityConfig isEnumerationForProperty:propertyName inObject:self.p_object]) {
        
        return IA_EDITOR_TYPE_PICKER;
        
    }else if([l_propertyDescription hasPrefix:@"T@\"NSDate\","]){
        
        NSDictionary *l_propertyOptions = [[[IAPersistenceManager instance] entityConfig] optionsForProperty:propertyName inObject:self.p_object];
        if ([[l_propertyOptions objectForKey:@"datePickerMode"] isEqualToString:@"fullDateAndTime"]) {
            return IA_EDITOR_TYPE_FULL_DATE_AND_TIME;
        }else{
            return IA_EDITOR_TYPE_DATE_PICKER;
        }
        
	}else if ([self.p_object isKindOfClass:NSManagedObject.class]) {
        
        NSPropertyDescription *propertyDescription = [self.p_object descriptionForProperty:propertyName];
        //            NSLog(@"propertyDescription: %@", [propertyDescription validationPredicates]);
        
        if ([propertyDescription isKindOfClass:[NSAttributeDescription class]] && [(NSAttributeDescription*)propertyDescription attributeType]==NSBooleanAttributeType && ![self isReadOnlyForIndexPath:anIndexPath]) {
            
            return IA_EDITOR_TYPE_SWITCH;
            
        }else if ([propertyDescription isKindOfClass:[NSAttributeDescription class]] && [(NSAttributeDescription*)propertyDescription attributeType]==NSDoubleAttributeType && ![self isReadOnlyForIndexPath:anIndexPath]) {
            
            NSUInteger dataType = [[IAPersistenceManager instance].entityConfig dataTypeForProperty:propertyName inObject:self.p_object];
            if (dataType==IA_DATA_TYPE_TIME_INTERVAL) {
                return IA_EDITOR_TYPE_TIME_INTERVAL;
            }else {
                return IA_EDITOR_TYPE_NUMBER;
            }
            
        }else if ([[IAPersistenceManager instance].entityConfig isRelationshipForProperty:propertyName inManagedObject:(NSManagedObject*)self.p_object]) {
            
            NSString *entityName = [[IAPersistenceManager instance].entityConfig entityNameForProperty:propertyName inObject:self.p_object];
            NSUInteger editorType = [[IAPersistenceManager instance].entityConfig fieldEditorForEntity:entityName];
            if (editorType==NSNotFound) {
                // Attempt to infer editor type from target entity
                return [[IAPersistenceManager instance] isSystemEntityForEntity:entityName] ? IA_EDITOR_TYPE_PICKER : IA_EDITOR_TYPE_SELECTION_LIST;
            }else {
                return editorType;
            }
            
        }else {
            
            return IA_EDITOR_TYPE_TEXT;
            
        }
        
    }else{
        
        return IA_EDITOR_TYPE_TEXT;
        
    }
    
}

- (void)onSegmentedControlAction:(id)aSender{
	IAUISegmentedControl *segmentedControl = aSender;
	NSString *entityName = [self entityNameForProperty:segmentedControl.propertyName];
	NSManagedObject *selectedManagedObject = [[[IAPersistenceManager instance] findAllForEntity:entityName] 
											  objectAtIndex:[segmentedControl selectedSegmentIndex]];
	[self.p_object setValue:selectedManagedObject forProperty:segmentedControl.propertyName];
}

-(NSInteger)tagForIndexPath:(NSIndexPath*)a_indexPath{
    return (a_indexPath.section*100)+a_indexPath.row;
}

-(IAUISwitchTableViewCell*)switchCellForTable:(UITableView *)a_tableView indexPath:(NSIndexPath*)a_indexPath{
    
    IAUISwitchTableViewCell *l_cell = (IAUISwitchTableViewCell*)[self cellForTable:a_tableView indexPath:a_indexPath className:@"IAUISwitchTableViewCell"];
    NSString *propertyName = [self nameForIndexPath:a_indexPath];
    
    // Set up event handling
    l_cell.p_switch.tag = [self tagForIndexPath:a_indexPath];
    [l_cell.p_switch addTarget:self action:@selector(onSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [v_uiControlsWithTargets addObject:l_cell.p_switch];
    //                [l_cell addValueChangedEventHandlerWithTarget:self action:@selector(onSwitchAction:)];
    //                NSLog(@"indexpath: %@, property: %@", indexPath, propertyName);
    [v_tagToPropertyName setObject:propertyName forKey:@(l_cell.p_switch.tag)];
    
    return l_cell;
    
}

-(BOOL)isDependencyEnabledForIndexPath:(NSIndexPath*)l_indexPath{
//    NSLog(@"isDependencyEnabledForIndexPath: %@", [l_indexPath description]);
    NSString *propertyName = [self nameForIndexPath:l_indexPath];
    NSString *l_dependencyParentPropertyName = [[IAPersistenceManager instance].entityConfig parentPropertyForDependent:propertyName inObject:self.p_object];
    BOOL l_dependencyEnabled = YES;
    if (l_dependencyParentPropertyName) {
        IAUISwitchTableViewCell *l_parentCell = [v_propertyNameToCell objectForKey:l_dependencyParentPropertyName];
//        NSLog(@"  parent: %@, value: %u", [l_parentCell description], l_parentCell.p_switch.on);
        l_dependencyEnabled = l_parentCell.p_switch.on;
    }
    return l_dependencyEnabled;
}

-(void)updateAndSaveBackingPreferences{
    [self updateBackingPreferences];
    [[IAPersistenceManager instance] save];
//    NSLog(@"backing preferences saved");
}

-(CGRect)m_fromPopoverRectForIndexPath:(NSIndexPath*)a_indexPath{
    UITableViewCell *l_cell = [self m_visibleCellForIndexPath:a_indexPath];
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

-(void)m_updateLeftBarButtonItemsStates{
    if (self.isSubForm) {
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }else{
        [self m_removeLeftBarButtonItem:self.p_dismissModalFormBarButtonItem];
        [self m_removeLeftBarButtonItem:self.p_cancelBarButtonItem];
        if (self.editing) {
            if (v_isManagedObject || ((!v_isManagedObject) && self.p_presentedAsModal)) {
                if (self.navigationItem.leftItemsSupplementBackButton) {
                    [self.navigationItem setHidesBackButton:YES animated:YES];
                }
                [self m_addLeftBarButtonItem:self.p_cancelBarButtonItem];
            }
        }else {
            [self.navigationItem setHidesBackButton:NO animated:YES];
            if(self.p_presentedAsModal) {
                [self m_addLeftBarButtonItem:self.p_dismissModalFormBarButtonItem];
            }
        }
    }
}

-(BOOL)m_endTextFieldEditingWithCommit:(BOOL)a_commit{

    if (self.p_textFieldEditing) {

        if (!a_commit) {
            self.p_textFieldCommitSuspended = YES;
        }
        BOOL l_validationOk = [self.view endEditing:NO];
        if (self.p_textFieldCommitSuspended) {
            self.p_textFieldCommitSuspended = NO;
        }
        return l_validationOk;

    }else {
        
        return YES;
        
    }

}

-(void)m_onTextFieldNotification:(NSNotification*)a_notification{
//    NSLog(@"m_onTextFieldNotification: %@", a_notification.name);
    if ([a_notification.name isEqualToString:UITextFieldTextDidBeginEditingNotification] || [a_notification.name isEqualToString:UITextFieldTextDidEndEditingNotification]) {
        self.p_textFieldEditing = [a_notification.name isEqualToString:UITextFieldTextDidBeginEditingNotification];
        self.p_textFieldTextChanged = NO;
    }else if ([a_notification.name isEqualToString:UITextFieldTextDidChangeNotification]){
        self.p_textFieldTextChanged = YES;
    }else{
        NSAssert(NO, @"Unexpected notification name: %@", a_notification.name);
    }
}

-(UITableViewCell*)m_updateEditingStateForCell:(UITableViewCell*)a_cell indexPath:(NSIndexPath *)a_indexPath{
    if ([a_cell isKindOfClass:[IAUIFormTextFieldTableViewCell class]]) {
        IAUIFormTextFieldTableViewCell *l_textFieldCell = (IAUIFormTextFieldTableViewCell*)a_cell;
//        NSLog(@"a_cell: %@, a_indexPath: %@", [a_cell description], [a_indexPath description]);
        BOOL l_editing = self.editing && ![self isReadOnlyForIndexPath:a_indexPath];
//        NSLog(@"  l_editing: %u, self.editing: %u, [self isReadOnlyForIndexPath:[self.tableView indexPathForCell:l_textFieldCell]]: %u", l_editing, self.editing, [self isReadOnlyForIndexPath:[self.tableView indexPathForCell:l_textFieldCell]]);
        l_textFieldCell.detailTextLabel.hidden = l_editing;
        l_textFieldCell.p_textField.hidden = !l_editing;
        if ([l_textFieldCell isKindOfClass:[IAUIFormNumberFieldTableViewCell class]]) {
            IAUIFormNumberFieldTableViewCell *l_numberFieldCell = (IAUIFormNumberFieldTableViewCell*)l_textFieldCell;
            l_numberFieldCell.p_stepper.hidden = !l_editing;
            l_numberFieldCell.p_slider.hidden = !l_editing;
//            l_numberFieldCell.p_minLabel.hidden = !l_editing;
//            l_numberFieldCell.p_maxLabel.hidden = !l_editing;
        }
    }
    return a_cell;
}

-(NSString*)m_urlPropertyNameForIndexPath:(NSIndexPath*)a_indexPath{
    NSString *l_urlPropertyName = [[IAPersistenceManager instance].entityConfig urlPropertyNameForIndexPath:a_indexPath inObject:self.p_object inForm:self.formName createMode:self.createMode];
//    NSLog(@"m_urlPropertyNameForIndexPath: %@, l_urlPropertyName: %@", [a_indexPath description], l_urlPropertyName);
    return l_urlPropertyName;
}

-(BOOL)m_shouldLinkToUrlForIndexPath:(NSIndexPath*)a_indexPath{
    BOOL l_b = [self m_urlPropertyNameForIndexPath:a_indexPath]!=nil;
//    NSLog(@"m_shouldLinkToUrlForIndexPath: %@, bool: %u", [a_indexPath description], l_b);
    return l_b;
}

#pragma mark - Public

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.readOnlyMode = NO;
        self.createMode = YES;
        self.formName = IA_ENTITY_CONFIG_FORM_NAME_DEFAULT;
        self.isSubForm = NO;
    }
    return self;
}

/* Submission forms */

- (id)initWithObject:(NSObject *)anObject {
    return [self initWithObject:anObject readOnlyMode:NO createMode:YES inForm:IA_ENTITY_CONFIG_FORM_NAME_DEFAULT isSubForm:NO];
}

- (id)initWithObject:(NSObject *)anObject inForm:(NSString *)aFormName isSubForm:(BOOL)aSubFormFlag {
    return [self initWithObject:anObject readOnlyMode:NO createMode:YES inForm:aFormName isSubForm:aSubFormFlag];
}

/* CRUD forms */

- (id)initWithObject:(NSObject *)anObject createMode:(BOOL)aCreateMode inForm:(NSString*)aFormName isSubForm:(BOOL)aSubFormFlag{
	return [self initWithObject:anObject readOnlyMode:NO createMode:aCreateMode inForm:aFormName isSubForm:aSubFormFlag];
}

- (id)initWithObject:(NSObject *)anObject createMode:(BOOL)aCreateMode{
	return [self initWithObject:anObject createMode:aCreateMode inForm:IA_ENTITY_CONFIG_FORM_NAME_DEFAULT isSubForm:NO];
}

- (id)initWithReadOnlyObject:(NSObject *)anObject inForm:(NSString*)aFormName isSubForm:(BOOL)aSubFormFlag{
	return [self initWithObject:anObject readOnlyMode:YES createMode:NO inForm:aFormName isSubForm:aSubFormFlag];
}

- (id)initWithReadOnlyObject:(NSObject *)anObject{
	return [self initWithReadOnlyObject:anObject inForm:IA_ENTITY_CONFIG_FORM_NAME_DEFAULT isSubForm:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[IAPersistenceManager instance].entityConfig formSectionsCountForObject:self.p_object inForm:self.formName createMode:self.createMode];
}

-(NSString *)m_editBarButtonItemHelpTargetId{
    if([[IAPersistenceManager instance].entityConfig hasSubmitButtonForForm:self.formName inEntity:[self.p_object entityName]]) {
        return [self m_helpTargetIdForName:@"submitButton"];
    }else{
        return [super m_editBarButtonItemHelpTargetId];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
//    NSLog(@"setEditing: %u", editing);
    
    v_saveButtonTapped = NO;
    v_objectSaved = NO;
    self.p_doneButtonSaves = NO;

    BOOL l_contextSwitchRequestPending = self.p_contextSwitchRequestPending;    // save this value before the super class resets it
//    BOOL l_reloadData = !l_contextSwitchRequestPending;

	if(editing){

		[super setEditing:editing animated:animated];

		if (!self.isSubForm) {
            if([[IAPersistenceManager instance].entityConfig hasSubmitButtonForForm:self.formName inEntity:[self.p_object entityName]]) {
                self.editButtonItem.title = [[IAPersistenceManager instance].entityConfig submitButtonLabelForForm:self.formName inEntity:[self.p_object entityName]];
//                self.editButtonItem.accessibilityLabel = self.editButtonItem.title;
            }else{
                self.editButtonItem.title = IA_BUTTON_LABEL_SAVE;
//                self.editButtonItem.accessibilityLabel = @"Save Button";
                self.p_doneButtonSaves = YES;
            }
            [self m_updateLeftBarButtonItemsStates];
		}

	}else {
        
        if (![self m_endTextFieldEditingWithCommit:!v_restoringNonEditingState]) {
            return;
        };
        
		if (!self.isSubForm) {   // does not execute this block if it's a context switching scenario for a sub-form
            
            v_saveButtonTapped = !v_restoringNonEditingState;
            
            if (v_isManagedObject) {
                
                NSManagedObject *l_managedObject = (NSManagedObject *) self.p_object;
                
                if ([l_managedObject isInserted] || [l_managedObject isUpdated]) {
                    
                    bool l_isInserted = [l_managedObject isInserted];
                    
                    [self updateBackingPreferences];
                    
                    // Persist changes
                    if (![[IAPersistenceManager instance] save:l_managedObject]) {
                        // If validation error occurs then simply redisplay screen (at this point, the error has already been handled from a UI POV)
                        return;
                    }
                    
                    v_objectSaved = YES;
                    
                    [IAUIUtils showAndHideUserActionConfirmationHudWithText:[NSString stringWithFormat:@"%@ %@", self.title, l_isInserted ? @"created" : @"updated"]];
                    
                }
                
            }else{
                
                [self updateAndSaveBackingPreferences];
                
                if (!v_restoringNonEditingState) {
                    [self onSubmitButtonTap];
                    return;
                }
                
            }
            
        }

         self.p_skipEditingUiStateChange = YES;
        [super setEditing:editing animated:animated];

		if (!self.isSubForm) {   // does not execute this block if it's a context switching scenario for a sub-form
            
            if (!self.p_skipEditingUiStateChange) {
//                self.editButtonItem.accessibilityLabel = self.editButtonItem.title;
                [self m_updateLeftBarButtonItemsStates];
            }
            BOOL l_canDismissView = self.p_presentedAsModal || [self.navigationController.viewControllers objectAtIndex:0]!=self;
            if ((v_saveButtonTapped || self.createMode) && l_canDismissView && !v_restoringNonEditingState) {
                if (!l_contextSwitchRequestPending) {    // Make sure this controller has not already been popped by a context switch request somewhere else
                    [self m_notifySessionCompletionWithChangesMade:v_objectSaved data:nil ];
                }
            }
            
        }

    }
    
    
    // Perform cell transition
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self reloadData];
    } completion:NULL];
    
}

-(BOOL)m_isFormEditorTypeForIndexPath:(NSIndexPath*)a_indexPath{
    return [self editorTypeForIndexPath:a_indexPath]==IA_EDITOR_TYPE_FORM;
}

-(IAUIFormTableViewCell*)populateCell:(IAUIFormTableViewCell*)a_cell{
    
    id l_value = [self.p_object valueForKey:a_cell.p_propertyName];
    
    if ([a_cell isMemberOfClass:[IAUIFormTableViewCell class]] || [a_cell isMemberOfClass:[IAUISwitchTableViewCell class]] || [a_cell isKindOfClass:[IAUIFormTextFieldTableViewCell class]]) {
        
        NSString *l_label = [self labelForIndexPath:a_cell.p_indexPath];
        a_cell.textLabel.text = l_label;
        NSString *l_valueFormat = [[IAPersistenceManager instance].entityConfig valueFormatForProperty:a_cell.p_propertyName inObject:self.p_object];
        NSString *l_valueString = [self.p_object propertyStringValueForIndexPath:a_cell.p_indexPath inForm:self.formName createMode:self.createMode calendar:[self m_calendar]];
        a_cell.detailTextLabel.text = l_valueFormat ? [NSString stringWithFormat:l_valueFormat, l_valueString] : l_valueString;
        
        if ([a_cell isMemberOfClass:[IAUIFormTableViewCell class]]) {

            if ([self m_isFormEditorTypeForIndexPath:a_cell.p_indexPath]) {
                a_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                a_cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                a_cell.accessoryType = UITableViewCellAccessoryNone;
                a_cell.editingAccessoryType = [self showDetailDisclosureInEditModeForIndexPath:a_cell.p_indexPath inForm:self.formName] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
//                NSLog(@"  a_cell.editingAccessoryType: %u", a_cell.editingAccessoryType);
            }

        }else if([a_cell isMemberOfClass:[IAUISwitchTableViewCell class]]){
            
            IAUISwitchTableViewCell *l_cell = (IAUISwitchTableViewCell*)a_cell;
            l_cell.p_switch.on = [(NSNumber*)l_value boolValue];
            if (!self.editing) {
                l_cell.p_switch.enabled = NO;
            }
            l_cell.p_enabledInEditing = [self isDependencyEnabledForIndexPath:a_cell.p_indexPath];
            
        }else {

            if ([self m_shouldLinkToUrlForIndexPath:a_cell.p_indexPath]) {
                a_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                a_cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                a_cell.accessoryType = UITableViewCellAccessoryNone;
                a_cell.editingAccessoryType = UITableViewCellAccessoryNone;
            }
            IAUIFormTextFieldTableViewCell *l_cell = (IAUIFormTextFieldTableViewCell*)a_cell;
            [l_cell m_reloadData];

        }
        
    }else if([a_cell isMemberOfClass:[IAUISegmentedControlTableViewCell class]]){
        
        IAUISegmentedControlTableViewCell *l_cell = (IAUISegmentedControlTableViewCell*)a_cell;
        l_cell.segmentedControl.selectedSegmentIndex = [((NSNumber*)[l_value valueForKey:@"index"]) intValue];
        l_cell.segmentedControl.enabled = self.editing;
        
    }else{
        NSAssert(false, @"Unexpected cell type: %@", [[a_cell class ] description]);
    }

    // Selection style
    if (self.editing) {
        a_cell.selectionStyle = a_cell.editingAccessoryType==UITableViewCellAccessoryDisclosureIndicator ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    }else{
        a_cell.selectionStyle = a_cell.accessoryType==UITableViewCellAccessoryDisclosureIndicator ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
    }
    
    // Is cell selectable?
    BOOL l_isSelectable = NO;
	if (self.editing) {
        //        NSLog(@"editing");
		l_isSelectable = [self allowUserInteractionInEditModeForIndexPath:a_cell.p_indexPath inForm:self.formName];
	}else {
        //        NSLog(@"NOT editing");
		l_isSelectable = [self m_isFormEditorTypeForIndexPath:a_cell.p_indexPath] || [self m_shouldLinkToUrlForIndexPath:a_cell.p_indexPath];
	}
    //    NSLog(@"l_isSelectable: %u", l_isSelectable);
    a_cell.userInteractionEnabled = l_isSelectable;
    
    return a_cell;
    
}

-(BOOL)isReadOnlyForIndexPath:(NSIndexPath*)anIndexPath{
    BOOL l_readOnly = [[IAPersistenceManager instance].entityConfig isReadOnlyForIndexPath:anIndexPath inObject:self.p_object inForm:self.formName createMode:self.createMode];
    return l_readOnly;
}

/* This can be overriden by subclasses */
- (BOOL)showDetailDisclosureInEditModeForIndexPath:(NSIndexPath*)anIndexPath inForm:(NSString*)aFormName{
//    NSLog(@"showDetailDisclosureInEditModeForIndexPath: %@, formName: %@", [anIndexPath description], aFormName);
//    NSLog(@"  [self hasOwnEditorViewForIndexPath:anIndexPath]: %u", [self hasOwnEditorViewForIndexPath:anIndexPath]);
//    NSLog(@"  [self isReadOnlyForIndexPath:anIndexPath]: %u", [self isReadOnlyForIndexPath:anIndexPath]);
//    NSLog(@"  [self isDependencyEnabledForIndexPath:anIndexPath]: %u", [self isDependencyEnabledForIndexPath:anIndexPath]);
    return [self hasOwnEditorViewForIndexPath:anIndexPath] && ![self isReadOnlyForIndexPath:anIndexPath] && [self isDependencyEnabledForIndexPath:anIndexPath];
}

/* This can be overriden by subclasses */
- (BOOL)allowUserInteractionInEditModeForIndexPath:(NSIndexPath*)anIndexPath inForm:(NSString*)aFormName{
    BOOL l_allow = [self showDetailDisclosureInEditModeForIndexPath:anIndexPath inForm:aFormName];
    if (l_allow) {
        return YES;
    }else{
        return ![self hasOwnEditorViewForIndexPath:anIndexPath];
    }
}

- (void)onSubmitButtonTap {
    // to be overridden by subclasses
}

- (void)onSwitchAction:(UISwitch*)a_switch{
//    NSLog(@"onSwitchAction with tag: %u", a_switch.tag);
    NSString *l_propertyName = [v_tagToPropertyName objectForKey:@(a_switch.tag)];
//    NSLog(@"  property name: %@", l_propertyName);
	[self.p_object setValue:@((a_switch.on)) forProperty:l_propertyName];
    NSArray *l_dependentPropertyNames = [[IAPersistenceManager instance].entityConfig dependentsForProperty:l_propertyName inObject:self.p_object];
//    NSLog(@"  dependents: %@", l_dependentPropertyNames);
    NSMutableArray *l_indexPathsToReload = [[NSMutableArray alloc] init];
    for (NSString *l_propertyName in l_dependentPropertyNames) {
//        NSLog(@"    l_propertyName: %@", l_propertyName);
        NSIndexPath *l_indexPath = [v_propertyNameToIndexPath objectForKey:l_propertyName];
//        NSLog(@"    l_indexPath: %@", [l_indexPath description]);
        if (l_indexPath) {
            [l_indexPathsToReload addObject:l_indexPath];
        }
    }
//    NSLog(@"  About to reload: %@", [l_indexPathsToReload description]);
    [self.tableView reloadRowsAtIndexPaths:l_indexPathsToReload withRowAnimation:UITableViewRowAnimationNone];
}

-(void)handleReturnKeyForTextFieldCell:(IAUIFormTextFieldTableViewCell*)a_cell{
    
    // My index
    NSUInteger l_myIndex = [self.p_editableTextFieldCells indexOfObject:a_cell];
    
    // The next index
    NSUInteger l_nextIndex = l_myIndex+1==[self.p_editableTextFieldCells count] ? 0 : l_myIndex+1;
    
    // The next cell containing a text field
    IAUIFormTextFieldTableViewCell *l_nextTextFieldCell = [self.p_editableTextFieldCells objectAtIndex:l_nextIndex];
    
    // The next index path
    NSIndexPath *l_nextIndexPath = [[self.p_indexPathToTextFieldCellDictionary allKeysForObject:l_nextTextFieldCell] objectAtIndex:0];
    
    // Scroll to the next index path to make sure the next field will be visible
    [self.tableView scrollToRowAtIndexPath:l_nextIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    // The next text field
    UITextField *l_nextTextField = l_nextTextFieldCell.p_textField;
    
    // Move keyboard focus to the next text field
    [l_nextTextField becomeFirstResponder];

}

-(void)updateBackingPreferences{
    
    for (NSString *l_propertyWithBackingPreferencesProperty in [[IAPersistenceManager instance].entityConfig propertiesWithBackingPreferencesForObject:self.p_object]) {
        //                    NSLog(@"l_propertyWithBackingPreferencesProperty: %@", l_propertyWithBackingPreferencesProperty);
        @autoreleasepool {
            NSString *l_backingPreferencesProperty = [[IAPersistenceManager instance].entityConfig backingPreferencesPropertyForProperty:l_propertyWithBackingPreferencesProperty inObject:self.p_object];
            id l_preferencesValue = [self.p_object valueForKey:l_propertyWithBackingPreferencesProperty];
            id l_preferences = [[IAPreferencesManager m_instance] m_preferences];
            [l_preferences setValue:l_preferencesValue forKey:l_backingPreferencesProperty];
        }
    }
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch (actionSheet.tag) {
		case IA_UIVIEW_TAG_ACTION_SHEET_CANCEL:
			if(buttonIndex==0){
				[self restoreNonEditingState];
			}else{
                // Notify that any pending context switch has been denied
                [self m_replyToContextSwitchRequestWithGranted:NO];
            }
			break;
		case IA_UIVIEW_TAG_ACTION_SHEET_DELETE:
			if(buttonIndex==0){
                NSAssert([self.p_object isKindOfClass:NSManagedObject.class], @"Selection list editor type not yet implemented for non-NSManagedObject instances");
                NSManagedObject *l_managedObject = (NSManagedObject*)self.p_object;
				if (![[IAPersistenceManager instance] m_deleteAndSave:l_managedObject]) {
					return;
				}
                [self m_notifySessionCompletionWithChangesMade:YES data:nil ];
                [IAUIUtils showAndHideUserActionConfirmationHudWithText:[NSString stringWithFormat:@"%@ deleted", self.title]];
			}
			break;
		default:
			NSAssert(NO, @"Unexpected tag: %u", actionSheet.tag);
			break;
	}
}

#pragma mark -
#pragma mark UITableViewDataSource

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[IAPersistenceManager instance].entityConfig fieldCountCountForSectionIndex:section inObject:self.p_object inForm:self.formName createMode:self.createMode];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [[IAPersistenceManager instance].entityConfig headerForSectionIndex:section inObject:self.p_object inForm:self.formName createMode:self.createMode];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	return [[IAPersistenceManager instance].entityConfig footerForSectionIndex:section inObject:self.p_object inForm:self.formName createMode:self.createMode];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"cellForRowAtIndexPath: %@", [indexPath description]);

    IAEntityConfig *l_entityConfig = [IAPersistenceManager instance].entityConfig;
	if ([l_entityConfig isViewControllerFieldTypeForIndexPath:indexPath inObject:self.p_object inForm:self.formName createMode:self.createMode]) {
        UITableViewCell *l_cell = [self.tableView dequeueReusableCellWithIdentifier:IA_TT_CELL_IDENTIFIER_VIEW_CONTROLLER];
        if (!l_cell) {
            l_cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IA_TT_CELL_IDENTIFIER_VIEW_CONTROLLER];
            l_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            l_cell.textLabel.textColor = [[self m_appearanceTheme] m_tableCellTextColor];
            // Set appearance
            [[[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme] m_setAppearanceOnInitReusableCellForViewController:self cell:l_cell];
        }
        l_cell.textLabel.text = [l_entityConfig labelForViewControllerFieldTypeAtIndexPath:indexPath inObject:self.p_object inForm:self.formName createMode:self.createMode];
        return l_cell;
    }else if ([l_entityConfig isCustomFieldTypeForIndexPath:indexPath inObject:self.p_object inForm:self.formName createMode:self.createMode]){
        UITableViewCell *l_cell = [self.tableView dequeueReusableCellWithIdentifier:IA_TT_CELL_IDENTIFIER_CUSTOM];
        if (!l_cell) {
            l_cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IA_TT_CELL_IDENTIFIER_CUSTOM];
            l_cell.userInteractionEnabled = NO;
            // Set appearance
            [[[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme] m_setAppearanceOnInitReusableCellForViewController:self cell:l_cell];
        }
        return l_cell;
    }
    
    // Property name
    NSString *propertyName = [self nameForIndexPath:indexPath];
    
//    NSLog(@"cellForRowAtIndexPath: %@, propertyName: %@", [indexPath description], propertyName);
    
    // The field editor type for this property
    NSUInteger editorType = [self editorTypeForIndexPath:indexPath];
    
    IAUIFormTableViewCell *l_cellToReturn = nil;
	
    if ([self hasOwnEditorViewForIndexPath:indexPath]) {
        
		l_cellToReturn = [self cellForTable:tableView indexPath:indexPath className:@"IAUIFormTableViewCell"];
		
	}else {
		
        switch (editorType) {
                
            case IA_EDITOR_TYPE_TEXT:
            {
                l_cellToReturn = (IAUIFormTextFieldTableViewCell*)[self.p_indexPathToTextFieldCellDictionary objectForKey:indexPath];
                break;
            }
                
            case IA_EDITOR_TYPE_NUMBER:
            {
                l_cellToReturn = (IAUIFormNumberFieldTableViewCell*)[self.p_indexPathToTextFieldCellDictionary objectForKey:indexPath];
                break;
            }
                
            case IA_EDITOR_TYPE_SWITCH:
            {
                l_cellToReturn = [self switchCellForTable:tableView indexPath:indexPath];
                break;
            }
                
            case IA_EDITOR_TYPE_SEGMENTED:
                
            {
                
                // Create reusable cell
                NSString *cellIdentifier = [NSString stringWithFormat:@"%@+%@", IA_TT_CELL_IDENTIFIER_SEGMENTED_CONTROL, propertyName];
                IAUIFormTableViewCell *cell = (IAUIFormTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {

                    // Load segmented UI control items
                    NSMutableArray *segmentControlItems = [NSMutableArray array];
                    for (NSManagedObject *mo in [[IAPersistenceManager instance] findAllForEntity:[self entityNameForProperty:propertyName]]) {
                        [segmentControlItems addObject:[mo displayValue]];
                    }
                    
                    // Instantiate segmented UI control
                    IAUISegmentedControl *segmentedControl = [[IAUISegmentedControl alloc] initWithItems:segmentControlItems];
                    segmentedControl.propertyName = propertyName;
                    [segmentedControl addTarget:self action:@selector(onSegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
                    [v_uiControlsWithTargets addObject:segmentedControl];
                    
                    cell = [[IAUISegmentedControlTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier object:self.p_object propertyName:propertyName indexPath:indexPath segmentedControl:segmentedControl];
                    cell.p_helpTargetId = [IAHelpManager m_helpTargetIdForPropertyName:propertyName inObject:self.p_object];
                    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

                    // Set appearance
                    [[[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme] m_setAppearanceOnInitReusableCellForViewController:self cell:cell];
                    
                    // Position segmented UI control appropriately
                    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
                    segmentedControl.frame = cell.frame;
                    [cell.contentView addSubview:segmentedControl];
                    
                }
                
                l_cellToReturn = cell;
                
                break;
                
            }
                
            default:
                NSAssert(NO, @"Unexpected editor type: %u", editorType);
                return nil;
        }
        
	}
    
    [v_propertyNameToCell setObject:l_cellToReturn forKey:propertyName];
    [v_propertyNameToIndexPath setObject:indexPath forKey:propertyName];
    
    l_cellToReturn.p_formViewController = self;
    return [self m_updateEditingStateForCell:[self populateCell:l_cellToReturn] indexPath:indexPath];
    
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    IAEntityConfig *l_entityConfig = [IAPersistenceManager instance].entityConfig;

	if ([self m_shouldLinkToUrlForIndexPath:indexPath]) {
        NSString *l_urlPropertyName = [self m_urlPropertyNameForIndexPath:indexPath];
        NSString *l_urlString = [self.p_object valueForKeyPath:l_urlPropertyName];
        NSURL *l_url = [NSURL URLWithString:l_urlString];
        [self m_openUrl:l_url];
        return;
    }
    
    if ([l_entityConfig isViewControllerFieldTypeForIndexPath:indexPath inObject:self.p_object inForm:self.formName createMode:self.createMode]) {
        NSString *l_viewControllerClassName = [[IAPersistenceManager instance].entityConfig classNameForViewControllerFieldTypeAtIndexPath:indexPath inObject:self.p_object inForm:self.formName createMode:self.createMode];
        Class l_viewControllerClass = NSClassFromString(l_viewControllerClassName);
        UIViewController *l_viewController = [l_viewControllerClass new];
        if (!l_viewController.title) {
            l_viewController.title = [l_entityConfig labelForViewControllerFieldTypeAtIndexPath:indexPath inObject:self.p_object inForm:self.formName createMode:self.createMode];
        }
        NSDictionary *p_properties = [l_entityConfig propertiesForViewControllerFieldTypeAtIndexPath:indexPath inObject:self.p_object inForm:self.formName createMode:self.createMode];
        if (p_properties) {
            for (NSString *l_key in p_properties.allKeys) {
                [l_viewController setValue:p_properties[l_key] forKeyPath:l_key];
            }
        }
        if ([l_entityConfig isModalForViewControllerFieldTypeAtIndexPath:indexPath inObject:self.p_object inForm:self.formName createMode:self.createMode]) {
            [self m_presentModalViewController:l_viewController presentationStyle:UIModalPresentationFullScreen transitionStyle:UIModalTransitionStyleCoverVertical];
        }else{
            [self.navigationController pushViewController:l_viewController animated:YES];
        }
        return;
    }

	if ([self showDetailDisclosureInEditModeForIndexPath:indexPath inForm:self.formName]) {

        if ([self m_isFormEditorTypeForIndexPath:indexPath]) {
            
            // Push appropriate editor view controller
            UIViewController *l_viewController = [self editorViewControllerForIndexPath:indexPath];
            [self.navigationController pushViewController:l_viewController animated:YES];
            
        }else{
            
            if ([self m_endTextFieldEditingWithCommit:YES]) {

                __weak IAUIFormViewController *l_weakSelf = self;
                
                UIViewController *l_viewController = [self editorViewControllerForIndexPath:indexPath];
                l_viewController.p_presenter = l_weakSelf;
                
                self.p_indexPathForPopoverController = indexPath;
                CGRect l_fromPopoverRect = [self m_fromPopoverRectForIndexPath:self.p_indexPathForPopoverController];
                
                if ([l_viewController m_hasFixedSize]) {
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
                
                [self m_presentModalSelectionViewController:l_viewController fromRect:l_fromPopoverRect inView:l_weakSelf.tableView];
                
            }else{

                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

            }
            
        }
        
    }else{
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
	
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath { 
	return UITableViewCellEditingStyleNone; 
} 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.editing && [self editorTypeForIndexPath:indexPath]==IA_EDITOR_TYPE_NUMBER ? 68 : 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    IAUITableSectionHeaderView *l_view = nil;
    NSString *l_title = [self tableView:tableView titleForHeaderInSection:section];
    if (l_title) {
        NSString *l_xibName = [[IAUtils infoPList] objectForKey:@"IAUIThemeFormSectionHeaderViewXib"];
        if (l_xibName) {
            l_view = [[NSBundle mainBundle] loadNibNamed:l_xibName owner:self options:nil][0];
            l_view.p_titleLabel.text = l_title;
        }
    }
    return l_view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSString *l_title = [self tableView:tableView titleForHeaderInSection:section];
    return l_title ? IA_FORM_SECTION_HEADER_DEFAULT_HEIGHT : 0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    // Set custom disclosure indicator for cell
    [[self m_appearanceTheme] m_setCustomDisclosureIndicatorForCell:cell tableViewController:self];
    
    // Clear custom view if required
    if (cell.accessoryType==UITableViewCellAccessoryNone) {
        cell.accessoryView = nil;
    }
    if (cell.editingAccessoryType==UITableViewCellAccessoryNone) {
        cell.editingAccessoryView = nil;
    }
    
}

#pragma mark - IAUIPresenter

-(void)m_changesMadeByViewController:(UIViewController *)a_viewController{
//    NSLog(@"m_changesMadeByViewController: %@", [a_viewController description]);
    [super m_changesMadeByViewController:a_viewController];
    [self reloadData];
}

- (void)m_sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                         data:(id)a_data {
//    NSLog(@"m_sessionDidCompleteForViewController in: %@, for: %@, changesMade: %u", [self description], [a_viewController description], a_changesMade);
    [super m_sessionDidCompleteForViewController:a_viewController changesMade:a_changesMade data:a_data];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark -
#pragma mark Overrides

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    v_isManagedObject = [self.p_object isKindOfClass:NSManagedObject.class];
    
    // Set managed object default values based on backing preferences
    if (self.createMode && !self.isSubForm) {
        [[IAPersistenceManager instance].entityConfig setDefaultValuesFromBackingPreferencesForObject:self.p_object];
    }
    
    v_tagToPropertyName = [[NSMutableDictionary alloc] init];
    v_propertyNameToCell = [[NSMutableDictionary alloc] init];
    v_propertyNameToIndexPath = [[NSMutableDictionary alloc] init];
    
    if (!(self.title = [[IAPersistenceManager instance].entityConfig labelForForm:self.formName inObject:self.p_object])) {
        self.title = [[IAPersistenceManager instance].entityConfig labelForObject:self.p_object];
    }
    
    //		self.hidesBottomBarWhenPushed = YES;
    
    if (!self.isSubForm) {
        [[IAPersistenceManager instance] resetEditSession];
    }
    
    v_uiControlsWithTargets = [NSMutableArray new];

	if (!self.readOnlyMode && !self.isSubForm) {
        self.editButtonItem.tag = IA_UIBAR_ITEM_TAG_EDIT_BUTTON;
        [self m_addRightBarButtonItem:self.editButtonItem];
	}
    
    //	self.tableView.allowsSelection = NO;
	self.tableView.allowsSelectionDuringEditing = YES;

	if(self.createMode){
		self.editing = YES;
	}
    
    // Form header
    NSString *l_formHeader = nil;
    if ((l_formHeader = [[IAPersistenceManager instance].entityConfig headerForForm:self.formName inObject:self.p_object])) {
        UILabel *l_label = [UILabel new];
        l_label.textAlignment = NSTextAlignmentCenter;
        l_label.backgroundColor = [UIColor clearColor];
        l_label.text = l_formHeader;
        l_label.textColor = [IAUIUtils m_colorForInfoPlistKey:@"IAUIThemeFormHeaderTextColor"];
        [l_label sizeToFit];
        self.tableView.tableHeaderView = l_label;
    }
    
    // Form footer
    NSString *l_formFooter = nil;
    if ((l_formFooter = [[IAPersistenceManager instance].entityConfig footerForForm:self.formName inObject:self.p_object])) {
        UILabel *l_label = [UILabel new];
        l_label.textAlignment = NSTextAlignmentCenter;
        l_label.backgroundColor = [UIColor clearColor];
        l_label.text = l_formFooter;
        l_label.textColor = [IAUIUtils m_colorForInfoPlistKey:@"IAUIThemeFormFooterTextColor"];
        [l_label sizeToFit];
        self.tableView.tableFooterView = l_label;
    }
    
    self.p_dismissModalFormBarButtonItem = [IAUIUtils m_isIPad] ? [IAUIUtils barButtonItemForType:IA_UIBAR_BUTTON_ITEM_DISMISS target:self action:@selector(onDismissButtonTap:)] : [IAUIUtils barButtonItemForType:IA_UIBAR_BUTTON_ITEM_BACK target:self action:@selector(onDismissButtonTap:)];
    self.p_cancelBarButtonItem = [IAUIUtils barButtonItemForType:IA_UIBAR_BUTTON_ITEM_CANCEL target:self action:@selector(onCancelButtonTap:)];
    
    // Instantiate text field cells that will be reused.
    //  Text fields, which are properties in the text field cells, must be know in advance to provide the functionality to cycle through text fields with the Return key.
    self.p_indexPathToTextFieldCellDictionary = [NSMutableDictionary new];
    self.p_editableTextFieldCells = [NSMutableArray new];
    for (int l_section=0; l_section<[self numberOfSectionsInTableView:self.tableView]; l_section++) {
        for (int l_row=0; l_row<[self tableView:self.tableView numberOfRowsInSection:l_section]; l_row++) {
            @autoreleasepool {
                NSIndexPath *l_indexPath = [NSIndexPath indexPathForRow:l_row inSection:l_section];
//                NSLog(@"l_indexPath: %@", [l_indexPath description]);
                NSUInteger l_editorType = [self editorTypeForIndexPath:l_indexPath];
                if (l_editorType==IA_EDITOR_TYPE_TEXT || l_editorType==IA_EDITOR_TYPE_NUMBER) {
                    NSString *l_className = [(l_editorType==IA_EDITOR_TYPE_TEXT?[IAUIFormTextFieldTableViewCell class]:[IAUIFormNumberFieldTableViewCell class]) description];
                    IAUIFormTextFieldTableViewCell *l_cell = (IAUIFormTextFieldTableViewCell*)[self cellForTable:self.tableView indexPath:l_indexPath className:l_className];
                    [self.p_indexPathToTextFieldCellDictionary setObject:l_cell forKey:l_indexPath];
                    if ([self isReadOnlyForIndexPath:l_indexPath]) {
                        [l_cell.p_textField removeFromSuperview];
                    }else {
                        [self.p_editableTextFieldCells addObject:l_cell];
                    }
                }
            }
        }
    }
//    NSLog(@"p_editableTextFieldCells: %@", [self.p_editableTextFieldCells description]);

}

- (void)viewWillAppear:(BOOL)animated {

//    [TestFlight passCheckpoint:[NSString stringWithFormat:@"IAUIFormViewController.viewWillAppear.%@", [managedObject entityName]]];
//    NSLog(@"self: %@", [self description]);
//    NSLog(@"self.presentedViewController: %@", [self.presentedViewController description]);
//    NSLog(@"self.presentingViewController: %@", [self.presentingViewController description]);
//    NSLog(@"self.navigationController.presentedViewController: %@", [self.navigationController.presentedViewController description]);
//    NSLog(@"self.navigationController.presentingViewController: %@", [self.navigationController.presentingViewController description]);

    [super viewWillAppear:animated];
    
    if (!self.readOnlyMode && !self.editing) {
        self.editing = YES;
    }else if(self.editing && ![self m_isReturningVisibleViewController] && [self contextSwitchRequestRequiredInEditMode]) {
        // If it's already in editing mode, need to make sure context switch request is required (e.g. the view controller could be cached by the menu)
        self.p_contextSwitchRequestRequired = YES;
    }

    [self m_updateLeftBarButtonItemsStates];
    [self reloadData];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onTextFieldNotification:) 
                                                 name:UITextFieldTextDidBeginEditingNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(m_onTextFieldNotification:) 
                                                 name:UITextFieldTextDidChangeNotification 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(m_onTextFieldNotification:) 
                                                 name:UITextFieldTextDidEndEditingNotification 
                                               object:nil];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.createMode && !v_createModeAutoFieldEditDone) {
        NSIndexPath *l_indexPath = [[IAPersistenceManager instance].entityConfig indexPathForProperty:@"name" inObject:self.p_object inForm:self.formName createMode:self.createMode];
        if (l_indexPath) {
            IAUIFormTextFieldTableViewCell *l_cell = (IAUIFormTextFieldTableViewCell*)[self m_visibleCellForIndexPath:l_indexPath];
            [l_cell.p_textField becomeFirstResponder];
        }
        v_createModeAutoFieldEditDone = YES;
    }
}

-(void)viewWillDisappear:(BOOL)animated{

//    NSLog(@"viewWillDisappear for %@", [self description]);

    [super viewWillDisappear:animated];

    if (!v_isManagedObject && !self.p_presentedAsModal) {
        [self updateAndSaveBackingPreferences];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated{

//    NSLog(@"viewDidDisappear for %@", [self description]);

    [super viewDidDisappear:animated];

    for (UIControl *l_uiControl in v_uiControlsWithTargets) {
//        NSLog(@"l_uiControl: %@", [l_uiControl description]);
        [l_uiControl removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    }
    [v_uiControlsWithTargets removeAllObjects];
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];

}

- (NSArray*)m_editModeToolbarItems{
	if(!self.createMode){
		UIBarButtonItem *deleteButtonItem = [IAUIUtils barButtonItemForType:IA_UIBAR_BUTTON_ITEM_DELETE target:self action:@selector(onDeleteButtonTap:)];
		return @[deleteButtonItem];
	}else {
		return nil;
	}

}

- (void)quitEditing{
	if (v_isManagedObject && ([IAPersistenceManager instance].isCurrentManagedObjectDirty || self.p_textFieldTextChanged)) {
		[IAUIUtils showActionSheetWithMessage:@"Are you sure you want to discard your changes?" 
				 destructiveButtonLabelSuffix:@"discard" 
                               viewController:self
                                barButtonItem:nil
									 delegate:self
										  tag:IA_UIVIEW_TAG_ACTION_SHEET_CANCEL];
	}else{
		[self restoreNonEditingState];
	}
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

    if (self.p_activePopoverController && !self.p_activePopoverControllerBarButtonItem) {
        
        // Present popover controller in the new interface orientation
        [self.tableView scrollToRowAtIndexPath:self.p_indexPathForPopoverController atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        CGRect l_fromPopoverRect = [self m_fromPopoverRectForIndexPath:self.p_indexPathForPopoverController];
        [self m_presentPopoverController:self.p_activePopoverController fromRect:l_fromPopoverRect inView:self.tableView];
        
    }

}

-(BOOL)p_contextSwitchRequestRequired{
    if (v_isManagedObject) {
        return [super p_contextSwitchRequestRequired];
    }else{
        return NO;
    }
}

-(void)setP_contextSwitchRequestRequired:(BOOL)a_contextSwitchRequestRequired{
    [super setP_contextSwitchRequestRequired:v_isManagedObject ? a_contextSwitchRequestRequired : NO];
}

-(void)m_onKeyboardNotification:(NSNotification*)a_notification{

    [super m_onKeyboardNotification:a_notification];

//    NSLog(@"m_onKeyboardNotification");

    if ([a_notification.name isEqualToString:UIKeyboardDidShowNotification]) {

        [IAUtils m_dispatchAsyncMainThreadBlock:^{
            [self.tableView flashScrollIndicators];

        }];

    }else if ([a_notification.name isEqualToString:UIKeyboardDidHideNotification]) {

        if (self.p_activePopoverController && !self.p_activePopoverControllerBarButtonItem) {

            CGRect l_fromPopoverRect = [self m_fromPopoverRectForIndexPath:self.p_indexPathForPopoverController];
            [self m_presentPopoverController:self.p_activePopoverController fromRect:l_fromPopoverRect inView:self.tableView];

        }

    }else{
        NSAssert(NO, @"Unexpected notification name: %@", a_notification.name);
    }

}

@end
