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

#import "IFACommon.h"

#ifdef IFA_AVAILABLE_Help
#import "IFAHelpManager.h"
#import "UIViewController+IFAHelp.h"
#import "UIView+IFAHelp.h"
#endif

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
@property(nonatomic) BOOL IFA_objectSaved;
@property(nonatomic) BOOL IFA_saveButtonTapped;
@property(nonatomic) BOOL IFA_restoringNonEditingState;
@property(nonatomic) BOOL IFA_isManagedObject;
@property(nonatomic) BOOL IFA_createModeAutoFieldEditDone;

/* Public as readonly */
@property(nonatomic, strong) NSMutableDictionary *tagToPropertyName;
@property(nonatomic, strong) NSMutableDictionary *propertyNameToIndexPath;

@end

@implementation IFAFormViewController

static NSString* const k_TT_CELL_IDENTIFIER_SEGMENTED_CONTROL = @"segmentedControlCell";
static NSString* const k_TT_CELL_IDENTIFIER_VIEW_CONTROLLER = @"viewControllerCell";
static NSString* const k_TT_CELL_IDENTIFIER_CUSTOM = @"customCell";

#pragma mark - Private

- (id)initWithObject:(NSObject *)anObject readOnlyMode:(BOOL)aReadOnlyMode createMode:(BOOL)aCreateMode inForm:(NSString*)aFormName isSubForm:(BOOL)aSubFormFlag{

    //    NSLog(@"hello from init - form");

    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {

		self.readOnlyMode = aReadOnlyMode;
		self.createMode = aCreateMode;
		self.object = anObject;
		self.formName = aFormName;
		self.isSubForm = aSubFormFlag;

#ifdef IFA_AVAILABLE_Help
        self.helpTargetId = [IFAUIUtils helpTargetIdForName:[@"form" stringByAppendingString:self.createMode ? @".new" : @".existing"]];
#endif

    }
	
	return self;
	
}

-(IFAFormTableViewCell *)cellForTable:(UITableView *)a_tableView indexPath:(NSIndexPath*)a_indexPath className:(NSString*)a_className{
    
    NSString *l_propertyName = [self nameForIndexPath:a_indexPath];

    // Create reusable cell
    IFAFormTableViewCell *l_cell = [a_tableView dequeueReusableCellWithIdentifier:l_propertyName];
    if (l_cell == nil) {
        l_cell = [[NSClassFromString(a_className) alloc] initWithStyle:UITableViewCellStyleValue1
                                                       reuseIdentifier:l_propertyName object:self.object
                                                          propertyName:l_propertyName indexPath:a_indexPath];
        // Set appearance
        [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                       cell:l_cell];
    }
#ifdef IFA_AVAILABLE_Help
    l_cell.helpTargetId = [IFAHelpManager helpTargetIdForPropertyName:l_propertyName inObject:self.object];
#endif

    return l_cell;
    
}

- (NSString*) labelForIndexPath:(NSIndexPath*)anIndexPath{
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

- (void)onDeleteButtonTap:(id)sender{
	NSString *entityName = [[self.object ifa_entityLabel] lowercaseString];
	NSString *message = [NSString stringWithFormat:@"Are you sure you want to delete the %@?", entityName];
    [IFAUIUtils showActionSheetWithMessage:message
              destructiveButtonLabelSuffix:@"delete"
                            viewController:self
                             barButtonItem:nil
                                  delegate:self
                                       tag:IFAViewTagActionSheetDelete];
}

- (void)restoreNonEditingState{
    [[IFAPersistenceManager sharedInstance] rollback];
    self.IFA_restoringNonEditingState = YES;
    [self setEditing:NO animated:YES];
    self.IFA_restoringNonEditingState = NO;
    [self ifa_notifySessionCompletion];
}

- (void)onCancelButtonTap:(id)sender {
    [self quitEditing];
}

- (void)onDismissButtonTap:(id)sender {
    [self ifa_notifySessionCompletion];
}

- (UIViewController*) editorViewControllerForIndexPath:(NSIndexPath*)anIndexPath{
	
	NSString *propertyName = [self nameForIndexPath:anIndexPath];
	UIViewController *controller;
    
	NSUInteger editorType = [self editorTypeForIndexPath:anIndexPath];
#ifdef IFA_AVAILABLE_Help
    BOOL l_shouldSetHelpTargetId = YES;
#endif
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
            if (self.readOnlyMode) {
                controller = [[formViewControllerClass alloc] initWithReadOnlyObject:self.object inForm:propertyName
                                                                           isSubForm:YES];
            }else{
                controller = [[formViewControllerClass alloc] initWithObject:self.object createMode:self.editing
                                                                      inForm:propertyName isSubForm:YES];
            }
        }
			break;
		case IFAEditorTypeSelectionList:
        {
            NSAssert([self.object isKindOfClass:NSManagedObject.class], @"Selection list editor type not yet implemented for non-NSManagedObject instances");
            NSManagedObject *l_managedObject = (NSManagedObject*)self.object;
			if ([[IFAPersistenceManager sharedInstance].entityConfig isToManyRelationshipForProperty:propertyName inManagedObject:l_managedObject]) {
				controller = [[IFAMultiSelectionListViewController alloc] initWithManagedObject:l_managedObject propertyName:propertyName];
			}else {
				controller = [[IFASingleSelectionListViewController alloc] initWithManagedObject:l_managedObject propertyName:propertyName];
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
                        NSAssert(NO, @"Unexpected editor type - case 1: %u", editorType);
                        break;
                }
                controller = [[IFADatePickerViewController alloc] initWithObject:self.object propertyName:propertyName
                                                                   datePickerMode:l_datePickerMode
                                                                   showTimePicker:l_showTimePicker];
            }
			break;
		default:
			NSAssert(NO, @"Unexpected editor type - case 2: %u", editorType);
			break;
	}

#ifdef IFA_AVAILABLE_Help
    // Set the help target ID for the view controller, if required
    if (l_shouldSetHelpTargetId) {
        UITableViewCell *l_cell = [self visibleCellForIndexPath:anIndexPath];
        controller.helpTargetId = l_cell.helpTargetId;
    }
#endif

	return controller;
    
}

- (BOOL) hasOwnEditorViewForIndexPath:(NSIndexPath*)anIndexPath{
    
	NSUInteger editorType = [self editorTypeForIndexPath:anIndexPath];
	switch (editorType) {
		case IFAEditorTypeForm:
		case IFAEditorTypeDatePicker:
		case IFAEditorTypeSelectionList:
		case IFAEditorTypePicker:
		case IFAEditorTypeTimeInterval:
		case IFAEditorTypeFullDateAndTime:
			return YES;
		case IFAEditorTypeText:
		case IFAEditorTypeNumber:
		case IFAEditorTypeSegmented:
		case IFAEditorTypeSwitch:
		case IFAEditorTypeNotApplicable:
			return NO;
		default:
			NSAssert(NO, @"Unexpected editor type: %u", editorType);
			return NO;
	}
    
}

- (IFAEditorType) editorTypeForIndexPath:(NSIndexPath*)anIndexPath{
    
    IFAEntityConfig *l_entityConfig = [IFAPersistenceManager sharedInstance].entityConfig;
    if ([l_entityConfig isViewControllerFieldTypeForIndexPath:anIndexPath inObject:self.object inForm:self.formName
                                                   createMode:self.createMode] || [l_entityConfig isCustomFieldTypeForIndexPath:anIndexPath
                                                                                                                       inObject:self.object
                                                                                                                         inForm:self.formName
                                                                                                                     createMode:self.createMode]) {
        return IFAEditorTypeNotApplicable;
    }
    
	NSString *propertyName = [self nameForIndexPath:anIndexPath];
    
    // Introspection to get property type information
    objc_property_t l_property = class_getProperty(self.object.class, [propertyName UTF8String]);
    NSString *l_propertyDescription = @(property_getAttributes(l_property));
    //            NSLog(@"property attributes: %@: ", l_propertyDescription);
    
    //    NSLog(@"editorTypeForIndexPath: %@, propertyName: %@", [anIndexPath description], propertyName);
	
	if ([[IFAPersistenceManager sharedInstance].entityConfig isFormFieldTypeForIndexPath:anIndexPath inObject:self.object
                                                                                 inForm:self.formName
                                                                             createMode:self.createMode]) {
        
		return IFAEditorTypeForm;
        
    }else if ([[IFAPersistenceManager sharedInstance].entityConfig isEnumerationForProperty:propertyName
                                                                                  inObject:self.object]) {
        
        return IFAEditorTypePicker;
        
    }else if([l_propertyDescription hasPrefix:@"T@\"NSDate\","]){
        
        NSDictionary *l_propertyOptions = [[[IFAPersistenceManager sharedInstance] entityConfig] optionsForProperty:propertyName
                                                                                                          inObject:self.object];
        if ([l_propertyOptions[@"datePickerMode"] isEqualToString:@"fullDateAndTime"]) {
            return IFAEditorTypeFullDateAndTime;
        }else{
            return IFAEditorTypeDatePicker;
        }
        
	}else if ([self.object isKindOfClass:NSManagedObject.class]) {
        
        NSPropertyDescription *propertyDescription = [self.object ifa_descriptionForProperty:propertyName];
        //            NSLog(@"propertyDescription: %@", [propertyDescription validationPredicates]);
        
        if ([propertyDescription isKindOfClass:[NSAttributeDescription class]] && [(NSAttributeDescription*)propertyDescription attributeType]==NSBooleanAttributeType && ![self isReadOnlyForIndexPath:anIndexPath]) {
            
            return IFAEditorTypeSwitch;
            
        }else if ([propertyDescription isKindOfClass:[NSAttributeDescription class]] && [(NSAttributeDescription*)propertyDescription attributeType]==NSDoubleAttributeType && ![self isReadOnlyForIndexPath:anIndexPath]) {
            
            NSUInteger dataType = [[IFAPersistenceManager sharedInstance].entityConfig dataTypeForProperty:propertyName
                                                                                                 inObject:self.object];
            if (dataType== IFADataTypeTimeInterval) {
                return IFAEditorTypeTimeInterval;
            }else {
                return IFAEditorTypeNumber;
            }
            
        }else if ([[IFAPersistenceManager sharedInstance].entityConfig isRelationshipForProperty:propertyName
                                                                                inManagedObject:(NSManagedObject *) self.object]) {
            
            NSString *entityName = [[IFAPersistenceManager sharedInstance].entityConfig entityNameForProperty:propertyName
                                                                                                    inObject:self.object];
            IFAEditorType editorType = [[IFAPersistenceManager sharedInstance].entityConfig fieldEditorForEntity:entityName];
            if (editorType==NSNotFound) {
                // Attempt to infer editor type from target entity
                return [[IFAPersistenceManager sharedInstance] isSystemEntityForEntity:entityName] ? IFAEditorTypePicker : IFAEditorTypeSelectionList;
            }else {
                return editorType;
            }
            
        }else {
            
            return IFAEditorTypeText;
            
        }
        
    }else{
        
        return IFAEditorTypeText;
        
    }
    
}

- (void)onSegmentedControlAction:(id)aSender{
	IFASegmentedControl *segmentedControl = aSender;
	NSString *entityName = [self entityNameForProperty:segmentedControl.propertyName];
	NSManagedObject *selectedManagedObject = [[IFAPersistenceManager sharedInstance] findAllForEntity:entityName][(NSUInteger) [segmentedControl selectedSegmentIndex]];
    [self.object ifa_setValue:selectedManagedObject forProperty:segmentedControl.propertyName];
}

-(NSInteger)tagForIndexPath:(NSIndexPath*)a_indexPath{
    return (a_indexPath.section*100)+a_indexPath.row;
}

-(IFASwitchTableViewCell *)switchCellForTable:(UITableView *)a_tableView indexPath:(NSIndexPath*)a_indexPath{
    
    IFASwitchTableViewCell *l_cell = (IFASwitchTableViewCell *)[self cellForTable:a_tableView indexPath:a_indexPath className:@"IFASwitchTableViewCell"];
    NSString *propertyName = [self nameForIndexPath:a_indexPath];
    
    // Set up event handling
    l_cell.switchControl.tag = [self tagForIndexPath:a_indexPath];
    [l_cell.switchControl addTarget:self action:@selector(onSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [self.IFA_uiControlsWithTargets addObject:l_cell.switchControl];
    //                [l_cell addValueChangedEventHandlerWithTarget:self action:@selector(onSwitchAction:)];
    //                NSLog(@"indexpath: %@, property: %@", indexPath, propertyName);
    (self.tagToPropertyName)[@(l_cell.switchControl.tag)] = propertyName;
    
    return l_cell;
    
}

-(BOOL)isDependencyEnabledForIndexPath:(NSIndexPath*)l_indexPath{
//    NSLog(@"isDependencyEnabledForIndexPath: %@", [l_indexPath description]);
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

-(void)updateAndSaveBackingPreferences{
    [self updateBackingPreferences];
    [[IFAPersistenceManager sharedInstance] save];
//    NSLog(@"backing preferences saved");
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
        BOOL l_editing = self.editing && ![self isReadOnlyForIndexPath:a_indexPath];
//        NSLog(@"  l_editing: %u, self.editing: %u, [self isReadOnlyForIndexPath:[self.tableView indexPathForCell:l_textFieldCell]]: %u", l_editing, self.editing, [self isReadOnlyForIndexPath:[self.tableView indexPathForCell:l_textFieldCell]]);
        l_textFieldCell.rightLabel.hidden = l_editing;
        l_textFieldCell.textField.hidden = !l_editing;
        if ([l_textFieldCell isKindOfClass:[IFAFormNumberFieldTableViewCell class]]) {
            IFAFormNumberFieldTableViewCell *l_numberFieldCell = (IFAFormNumberFieldTableViewCell *)l_textFieldCell;
            l_numberFieldCell.stepper.hidden = !l_editing;
            l_numberFieldCell.slider.hidden = !l_editing;
//            l_numberFieldCell.minLabel.hidden = !l_editing;
//            l_numberFieldCell.maxLabel.hidden = !l_editing;
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

-(BOOL)IFA_shouldLinkToUrlForIndexPath:(NSIndexPath*)a_indexPath{
    BOOL l_b = [self IFA_urlPropertyNameForIndexPath:a_indexPath]!=nil;
//    NSLog(@"IFA_shouldLinkToUrlForIndexPath: %@, bool: %u", [a_indexPath description], l_b);
    return l_b;
}

#pragma mark - Public

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.readOnlyMode = NO;
        self.createMode = YES;
        self.formName = IFAEntityConfigFormNameDefault;
        self.isSubForm = NO;
    }
    return self;
}

/* Submission forms */

- (id)initWithObject:(NSObject *)anObject {
    return [self initWithObject:anObject readOnlyMode:NO createMode:YES inForm:IFAEntityConfigFormNameDefault
                      isSubForm:NO];
}

- (id)initWithObject:(NSObject *)anObject inForm:(NSString *)aFormName isSubForm:(BOOL)aSubFormFlag {
    return [self initWithObject:anObject readOnlyMode:NO createMode:YES inForm:aFormName isSubForm:aSubFormFlag];
}

/* CRUD forms */

- (id)initWithObject:(NSObject *)anObject createMode:(BOOL)aCreateMode inForm:(NSString*)aFormName isSubForm:(BOOL)aSubFormFlag{
	return [self initWithObject:anObject readOnlyMode:NO createMode:aCreateMode inForm:aFormName isSubForm:aSubFormFlag];
}

- (id)initWithObject:(NSObject *)anObject createMode:(BOOL)aCreateMode{
	return [self initWithObject:anObject createMode:aCreateMode inForm:IFAEntityConfigFormNameDefault
                      isSubForm:NO];
}

- (id)initWithReadOnlyObject:(NSObject *)anObject inForm:(NSString*)aFormName isSubForm:(BOOL)aSubFormFlag{
	return [self initWithObject:anObject readOnlyMode:YES createMode:NO inForm:aFormName isSubForm:aSubFormFlag];
}

- (id)initWithReadOnlyObject:(NSObject *)anObject{
	return [self initWithReadOnlyObject:anObject inForm:IFAEntityConfigFormNameDefault isSubForm:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[IFAPersistenceManager sharedInstance].entityConfig formSectionsCountForObject:self.object
                                                                                   inForm:self.formName
                                                                               createMode:self.createMode];
}

#ifdef IFA_AVAILABLE_Help
-(NSString *)ifa_editBarButtonItemHelpTargetId {
    if([[IFAPersistenceManager sharedInstance].entityConfig hasSubmitButtonForForm:self.formName inEntity:[self.object ifa_entityName]]) {
        return [self ifa_helpTargetIdForName:@"submitButton"];
    }else{
        return [super ifa_editBarButtonItemHelpTargetId];
    }
}
#endif

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
//    NSLog(@"setEditing: %u", editing);
    
    self.IFA_saveButtonTapped = NO;
    self.IFA_objectSaved = NO;
    self.doneButtonSaves = NO;

    BOOL l_contextSwitchRequestPending = self.contextSwitchRequestPending;    // save this value before the super class resets it
//    BOOL l_reloadData = !l_contextSwitchRequestPending;

	if(editing){

		[super setEditing:editing animated:animated];

		if (!self.isSubForm) {
            if([[IFAPersistenceManager sharedInstance].entityConfig hasSubmitButtonForForm:self.formName inEntity:[self.object ifa_entityName]]) {
                self.editButtonItem.title = [[IFAPersistenceManager sharedInstance].entityConfig submitButtonLabelForForm:self.formName inEntity:[self.object ifa_entityName]];
//                self.editButtonItem.accessibilityLabel = self.editButtonItem.title;
            }else{
                self.editButtonItem.title = IFAButtonLabelSave;
//                self.editButtonItem.accessibilityLabel = @"Save Button";
                self.doneButtonSaves = YES;
            }
            [self IFA_updateLeftBarButtonItemsStates];
		}

	}else {
        
        if (![self IFA_endTextFieldEditingWithCommit:!self.IFA_restoringNonEditingState]) {
            return;
        };
        
		if (!self.isSubForm) {   // does not execute this block if it's a context switching scenario for a sub-form
            
            self.IFA_saveButtonTapped = !self.IFA_restoringNonEditingState;
            
            if (self.IFA_isManagedObject) {
                
                NSManagedObject *l_managedObject = (NSManagedObject *) self.object;
                
                if ([l_managedObject isInserted] || [l_managedObject isUpdated]) {
                    
                    bool l_isInserted = [l_managedObject isInserted];
                    
                    [self updateBackingPreferences];
                    
                    // Persist changes
                    if (![[IFAPersistenceManager sharedInstance] saveObject:l_managedObject]) {
                        // If validation error occurs then simply redisplay screen (at this point, the error has already been handled from a UI POV)
                        return;
                    }
                    
                    self.IFA_objectSaved = YES;
                    
                    [IFAUIUtils showAndHideUserActionConfirmationHudWithText:[NSString stringWithFormat:@"%@ %@",
                                                                                                        self.title,
                                                                                                        l_isInserted ? @"created" : @"updated"]];
                    
                }
                
            }else{
                
                [self updateAndSaveBackingPreferences];
                
                if (!self.IFA_restoringNonEditingState) {
                    [self onSubmitButtonTap];
                    return;
                }
                
            }
            
        }

         self.skipEditingUiStateChange = YES;
        [super setEditing:editing animated:animated];

		if (!self.isSubForm) {   // does not execute this block if it's a context switching scenario for a sub-form
            
            if (!self.skipEditingUiStateChange) {
//                self.editButtonItem.accessibilityLabel = self.editButtonItem.title;
                [self IFA_updateLeftBarButtonItemsStates];
            }
            BOOL l_canDismissView = self.ifa_presentedAsModal || (self.navigationController.viewControllers)[0] !=self;
            if ((self.IFA_saveButtonTapped || self.createMode) && l_canDismissView && !self.IFA_restoringNonEditingState) {
                if (!l_contextSwitchRequestPending) {    // Make sure this controller has not already been popped by a context switch request somewhere else
                    [self ifa_notifySessionCompletionWithChangesMade:self.IFA_objectSaved data:nil];
                }
            }
            
        }

    }
    
    
    // Perform cell transition
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self reloadData];
    } completion:NULL];
    
}

-(BOOL)IFA_isFormEditorTypeForIndexPath:(NSIndexPath*)a_indexPath{
    return [self editorTypeForIndexPath:a_indexPath]== IFAEditorTypeForm;
}

-(IFAFormTableViewCell *)populateCell:(IFAFormTableViewCell *)a_cell{
    
    id l_value = [self.object valueForKey:a_cell.propertyName];
    
    if ([a_cell isMemberOfClass:[IFAFormTableViewCell class]] || [a_cell isMemberOfClass:[IFASwitchTableViewCell class]] || [a_cell isKindOfClass:[IFAFormTextFieldTableViewCell class]]) {
        
        NSString *l_label = [self labelForIndexPath:a_cell.indexPath];
        a_cell.leftLabel.text = l_label;
        NSString *l_valueFormat = [[IFAPersistenceManager sharedInstance].entityConfig valueFormatForProperty:a_cell.propertyName
                                                                                                    inObject:self.object];
        NSString *l_valueString = [self.object ifa_propertyStringValueForIndexPath:a_cell.indexPath
                                                                            inForm:self.formName
                                                                        createMode:self.createMode
                                                                          calendar:[self calendar]];
        a_cell.rightLabel.text = l_valueFormat ? [NSString stringWithFormat:l_valueFormat, l_valueString] : l_valueString;
        
        if ([a_cell isMemberOfClass:[IFAFormTableViewCell class]]) {

            if ([self IFA_isFormEditorTypeForIndexPath:a_cell.indexPath]) {
                a_cell.customAccessoryType = IFAFormTableViewCellAccessoryTypeDisclosureIndicatorRight;
            }else {
                if (self.editing) {
                    if ([self showDetailDisclosureInEditModeForIndexPath:a_cell.indexPath inForm:self.formName]) {
                        a_cell.customAccessoryType = IFAFormTableViewCellAccessoryTypeDisclosureIndicatorDown;
                    } else {
                        a_cell.customAccessoryType = IFAFormTableViewCellAccessoryTypeNone;
                    }
                }else{
                    a_cell.customAccessoryType = IFAFormTableViewCellAccessoryTypeNone;
                }
            }

        }else if([a_cell isMemberOfClass:[IFASwitchTableViewCell class]]){
            
            IFASwitchTableViewCell *l_cell = (IFASwitchTableViewCell *)a_cell;
            l_cell.switchControl.on = [(NSNumber*)l_value boolValue];
            if (!self.editing) {
                l_cell.switchControl.enabled = NO;
            }
            l_cell.enabledInEditing = [self isDependencyEnabledForIndexPath:a_cell.indexPath];
            
        }else {

            //wip: the below case probably deserves a new custom accessory image (e.g. a little globe?)
            a_cell.customAccessoryType = [self IFA_shouldLinkToUrlForIndexPath:a_cell.indexPath] ? IFAFormTableViewCellAccessoryTypeDisclosureIndicatorRight : IFAFormTableViewCellAccessoryTypeNone;
            IFAFormTextFieldTableViewCell *l_cell = (IFAFormTextFieldTableViewCell *)a_cell;
            [l_cell reloadData];

        }
        
    }else if([a_cell isMemberOfClass:[IFASegmentedControlTableViewCell class]]){
        
        IFASegmentedControlTableViewCell *l_cell = (IFASegmentedControlTableViewCell *)a_cell;
        l_cell.segmentedControl.selectedSegmentIndex = [((NSNumber*)[l_value valueForKey:@"index"]) intValue];
        l_cell.segmentedControl.enabled = self.editing;
        
    }else{
        NSAssert(false, @"Unexpected cell type: %@", [[a_cell class ] description]);
    }

    // Selection style
    a_cell.selectionStyle = a_cell.customAccessoryType==IFAFormTableViewCellAccessoryTypeNone ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;

    // Is cell selectable?
    BOOL l_isSelectable;
	if (self.editing) {
        //        NSLog(@"editing");
		l_isSelectable = [self allowUserInteractionInEditModeForIndexPath:a_cell.indexPath inForm:self.formName];
	}else {
        //        NSLog(@"NOT editing");
		l_isSelectable = [self IFA_isFormEditorTypeForIndexPath:a_cell.indexPath] || [self IFA_shouldLinkToUrlForIndexPath:a_cell.indexPath];
	}
    //    NSLog(@"l_isSelectable: %u", l_isSelectable);
    a_cell.userInteractionEnabled = l_isSelectable;
    
    return a_cell;
    
}

-(BOOL)isReadOnlyForIndexPath:(NSIndexPath*)anIndexPath{
    BOOL l_readOnly = [[IFAPersistenceManager sharedInstance].entityConfig isReadOnlyForIndexPath:anIndexPath
                                                                                        inObject:self.object
                                                                                          inForm:self.formName
                                                                                      createMode:self.createMode];
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
    NSString *l_propertyName = (self.tagToPropertyName)[@(a_switch.tag)];
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
//    NSLog(@"  About to reload: %@", [l_indexPathsToReload description]);
    [self.tableView reloadRowsAtIndexPaths:l_indexPathsToReload withRowAnimation:UITableViewRowAnimationNone];
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
    
    // Scroll to the next index path to make sure the next field will be visible
    [self.tableView scrollToRowAtIndexPath:l_nextIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    // The next text field
    UITextField *l_nextTextField = l_nextTextFieldCell.textField;
    
    // Move keyboard focus to the next text field
    [l_nextTextField becomeFirstResponder];

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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	switch (actionSheet.tag) {
		case IFAViewTagActionSheetCancel:
			if(buttonIndex==0){
				[self restoreNonEditingState];
			}else{
                // Notify that any pending context switch has been denied
                [self replyToContextSwitchRequestWithGranted:NO];
            }
			break;
		case IFAViewTagActionSheetDelete:
			if(buttonIndex==0){
                NSAssert([self.object isKindOfClass:NSManagedObject.class], @"Selection list editor type not yet implemented for non-NSManagedObject instances");
                NSManagedObject *l_managedObject = (NSManagedObject*)self.object;
				if (![[IFAPersistenceManager sharedInstance] deleteAndSaveObject:l_managedObject]) {
					return;
				}
                [self ifa_notifySessionCompletionWithChangesMade:YES data:nil ];
                [IFAUIUtils showAndHideUserActionConfirmationHudWithText:[NSString stringWithFormat:@"%@ deleted",
                                                                                                    self.title]];
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
	return [[IFAPersistenceManager sharedInstance].entityConfig fieldCountCountForSectionIndex:section
                                                                                     inObject:self.object
                                                                                       inForm:self.formName
                                                                                   createMode:self.createMode];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return [[IFAPersistenceManager sharedInstance].entityConfig headerForSectionIndex:section inObject:self.object
                                                                              inForm:self.formName
                                                                          createMode:self.createMode];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	return [[IFAPersistenceManager sharedInstance].entityConfig footerForSectionIndex:section inObject:self.object
                                                                              inForm:self.formName
                                                                          createMode:self.createMode];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSLog(@"cellForRowAtIndexPath: %@", [indexPath description]);

    IFAEntityConfig *l_entityConfig = [IFAPersistenceManager sharedInstance].entityConfig;
	if ([l_entityConfig isViewControllerFieldTypeForIndexPath:indexPath inObject:self.object inForm:self.formName
                                                   createMode:self.createMode]) {
        IFAFormTableViewCell *l_cell = [self.tableView dequeueReusableCellWithIdentifier:k_TT_CELL_IDENTIFIER_VIEW_CONTROLLER];
        if (!l_cell) {
            l_cell = [[IFAFormTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                            reuseIdentifier:k_TT_CELL_IDENTIFIER_VIEW_CONTROLLER];
            l_cell.customAccessoryType = IFAFormTableViewCellAccessoryTypeDisclosureIndicatorRight;
            l_cell.leftLabel.textColor = [[self ifa_appearanceTheme] tableCellTextColor];
            // Set appearance
            [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                           cell:l_cell];
        }
        l_cell.leftLabel.text = [l_entityConfig labelForViewControllerFieldTypeAtIndexPath:indexPath
                                                                                  inObject:self.object
                                                                                    inForm:self.formName
                                                                                createMode:self.createMode];
        return l_cell;
    }else if ([l_entityConfig isCustomFieldTypeForIndexPath:indexPath inObject:self.object inForm:self.formName
                                                 createMode:self.createMode]){
        UITableViewCell *l_cell = [self.tableView dequeueReusableCellWithIdentifier:k_TT_CELL_IDENTIFIER_CUSTOM];
        if (!l_cell) {
            l_cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:k_TT_CELL_IDENTIFIER_CUSTOM];
            l_cell.userInteractionEnabled = NO;
            // Set appearance
            [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                           cell:l_cell];
        }
        return l_cell;
    }
    
    // Property name
    NSString *propertyName = [self nameForIndexPath:indexPath];
    
//    NSLog(@"cellForRowAtIndexPath: %@, propertyName: %@", [indexPath description], propertyName);
    
    // The field editor type for this property
    NSUInteger editorType = [self editorTypeForIndexPath:indexPath];
    
    IFAFormTableViewCell *l_cellToReturn = nil;
	
    if ([self hasOwnEditorViewForIndexPath:indexPath]) {
        
		l_cellToReturn = [self cellForTable:tableView indexPath:indexPath className:@"IFAFormTableViewCell"];
		
	}else {
		
        switch (editorType) {
                
            case IFAEditorTypeText:
            {
                l_cellToReturn = (IFAFormTextFieldTableViewCell *) (self.IFA_indexPathToTextFieldCellDictionary)[indexPath];
                break;
            }
                
            case IFAEditorTypeNumber:
            {
                l_cellToReturn = (IFAFormNumberFieldTableViewCell *) (self.IFA_indexPathToTextFieldCellDictionary)[indexPath];
                break;
            }
                
            case IFAEditorTypeSwitch:
            {
                l_cellToReturn = [self switchCellForTable:tableView indexPath:indexPath];
                break;
            }
                
            case IFAEditorTypeSegmented:
                
            {
                
                // Create reusable cell
                NSString *cellIdentifier = [NSString stringWithFormat:@"%@+%@",
                                                                      k_TT_CELL_IDENTIFIER_SEGMENTED_CONTROL,
                                                                      propertyName];
                IFAFormTableViewCell *cell = (IFAFormTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {

                    // Load segmented UI control items
                    NSMutableArray *segmentControlItems = [NSMutableArray array];
                    for (NSManagedObject *mo in [[IFAPersistenceManager sharedInstance] findAllForEntity:[self entityNameForProperty:propertyName]]) {
                        [segmentControlItems addObject:[mo ifa_displayValue]];
                    }
                    
                    // Instantiate segmented UI control
                    IFASegmentedControl *segmentedControl = [[IFASegmentedControl alloc] initWithItems:segmentControlItems];
                    segmentedControl.propertyName = propertyName;
                    [segmentedControl addTarget:self action:@selector(onSegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
                    [self.IFA_uiControlsWithTargets addObject:segmentedControl];
                    
                    cell = [[IFASegmentedControlTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                    reuseIdentifier:cellIdentifier object:self.object
                                                                       propertyName:propertyName indexPath:indexPath
                                                                   segmentedControl:segmentedControl];
#ifdef IFA_AVAILABLE_Help
                    cell.helpTargetId = [IFAHelpManager helpTargetIdForPropertyName:propertyName
                                                                           inObject:self.object];
#endif
                    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

                    // Set appearance
                    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                                   cell:cell];
                    
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
    
    (self.IFA_propertyNameToCell)[propertyName] = l_cellToReturn;
    (self.propertyNameToIndexPath)[propertyName] = indexPath;
    
    l_cellToReturn.formViewController = self;
    return [self IFA_updateEditingStateForCell:[self populateCell:l_cellToReturn] indexPath:indexPath];
    
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    IFAEntityConfig *l_entityConfig = [IFAPersistenceManager sharedInstance].entityConfig;

	if ([self IFA_shouldLinkToUrlForIndexPath:indexPath]) {
        NSString *l_urlPropertyName = [self IFA_urlPropertyNameForIndexPath:indexPath];
        NSString *l_urlString = [self.object valueForKeyPath:l_urlPropertyName];
        NSURL *l_url = [NSURL URLWithString:l_urlString];
        [self ifa_openUrl:l_url];
        return;
    }
    
    if ([l_entityConfig isViewControllerFieldTypeForIndexPath:indexPath inObject:self.object inForm:self.formName
                                                   createMode:self.createMode]) {
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
        }else{
            [self.navigationController pushViewController:l_viewController animated:YES];
        }
        return;
    }

	if ([self showDetailDisclosureInEditModeForIndexPath:indexPath inForm:self.formName]) {

        if ([self IFA_isFormEditorTypeForIndexPath:indexPath]) {
            
            // Push appropriate editor view controller
            UIViewController *l_viewController = [self editorViewControllerForIndexPath:indexPath];
            [self.navigationController pushViewController:l_viewController animated:YES];
            
        }else{
            
            if ([self IFA_endTextFieldEditingWithCommit:YES]) {

                __weak IFAFormViewController *l_weakSelf = self;
                
                UIViewController *l_viewController = [self editorViewControllerForIndexPath:indexPath];
                l_viewController.ifa_presenter = l_weakSelf;
                
                self.IFA_indexPathForPopoverController = indexPath;
                CGRect l_fromPopoverRect = [self IFA_fromPopoverRectForIndexPath:self.IFA_indexPathForPopoverController];
                
                if ([l_viewController ifa_hasFixedSize]) {
                    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                }

                [self ifa_presentModalSelectionViewController:l_viewController fromRect:l_fromPopoverRect
                                                       inView:l_weakSelf.tableView];
                
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
    return self.editing && [self editorTypeForIndexPath:indexPath]== IFAEditorTypeNumber ? 68 : 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    IFATableSectionHeaderView *l_view = nil;
    NSString *l_title = [self tableView:tableView titleForHeaderInSection:section];
    if (l_title) {
        NSString *l_xibName = [IFAUtils infoPList][@"IFAThemeFormSectionHeaderViewXib"];
        if (l_xibName) {
            l_view = [[NSBundle mainBundle] loadNibNamed:l_xibName owner:self options:nil][0];
            l_view.titleLabel.text = l_title;
        }
    }
    return l_view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSString *l_title = [self tableView:tableView titleForHeaderInSection:section];
    return l_title ? IFAFormSectionHeaderDefaultHeight : 0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    
    // Set custom disclosure indicator for cell
    [[self ifa_appearanceTheme] setCustomDisclosureIndicatorForCell:cell tableViewController:self];

}

#pragma mark - IFAPresenter

-(void)changesMadeByViewController:(UIViewController *)a_viewController{
//    NSLog(@"changesMadeByViewController: %@", [a_viewController description]);
    [super changesMadeByViewController:a_viewController];
    [self reloadData];
}

- (void)sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                         data:(id)a_data {
//    NSLog(@"sessionDidCompleteForViewController in: %@, for: %@, changesMade: %u", [self description], [a_viewController description], a_changesMade);
    [super sessionDidCompleteForViewController:a_viewController changesMade:a_changesMade data:a_data];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark -
#pragma mark Overrides

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.IFA_isManagedObject = [self.object isKindOfClass:NSManagedObject.class];
    
    // Set managed object default values based on backing preferences
    if (self.createMode && !self.isSubForm) {
        [[IFAPersistenceManager sharedInstance].entityConfig setDefaultValuesFromBackingPreferencesForObject:self.object];
    }
    
    self.tagToPropertyName = [[NSMutableDictionary alloc] init];
    self.IFA_propertyNameToCell = [[NSMutableDictionary alloc] init];
    self.propertyNameToIndexPath = [[NSMutableDictionary alloc] init];
    
    if (!(self.title = [[IFAPersistenceManager sharedInstance].entityConfig labelForForm:self.formName
                                                                               inObject:self.object])) {
        self.title = [[IFAPersistenceManager sharedInstance].entityConfig labelForObject:self.object];
    }
    
    //		self.hidesBottomBarWhenPushed = YES;
    
    if (!self.isSubForm) {
        [[IFAPersistenceManager sharedInstance] resetEditSession];
    }
    
    self.IFA_uiControlsWithTargets = [NSMutableArray new];

	if (!self.readOnlyMode && !self.isSubForm) {
        self.editButtonItem.tag = IFABarItemTagEditButton;
        [self ifa_addRightBarButtonItem:self.editButtonItem];
	}
    
    //	self.tableView.allowsSelection = NO;
	self.tableView.allowsSelectionDuringEditing = YES;

	if(self.createMode){
		self.editing = YES;
	}
    
    // Form header
    NSString *l_formHeader = nil;
    if ((l_formHeader = [[IFAPersistenceManager sharedInstance].entityConfig headerForForm:self.formName
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
    if ((l_formFooter = [[IFAPersistenceManager sharedInstance].entityConfig footerForForm:self.formName
                                                                                 inObject:self.object])) {
        UILabel *l_label = [UILabel new];
        l_label.textAlignment = NSTextAlignmentCenter;
        l_label.backgroundColor = [UIColor clearColor];
        l_label.text = l_formFooter;
        l_label.textColor = [IFAUIUtils colorForInfoPlistKey:@"IFAThemeFormFooterTextColor"];
        [l_label sizeToFit];
        self.tableView.tableFooterView = l_label;
    }
    
    self.IFA_dismissModalFormBarButtonItem = [IFAUIUtils isIPad] ? [IFAUIUtils barButtonItemForType:IFABarButtonItemDismiss
                                                                                             target:self
                                                                                             action:@selector(onDismissButtonTap:)] : [IFAUIUtils barButtonItemForType:IFABarButtonItemBack
                                                                                                                                                                target:self
                                                                                                                                                                action:@selector(onDismissButtonTap:)];
    self.IFA_cancelBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemCancel target:self
                                                             action:@selector(onCancelButtonTap:)];
    
    // Instantiate text field cells that will be reused.
    //  Text fields, which are properties in the text field cells, must be know in advance to provide the functionality to cycle through text fields with the Return key.
    self.IFA_indexPathToTextFieldCellDictionary = [NSMutableDictionary new];
    self.IFA_editableTextFieldCells = [NSMutableArray new];
    for (int l_section=0; l_section<[self numberOfSectionsInTableView:self.tableView]; l_section++) {
        for (int l_row=0; l_row<[self tableView:self.tableView numberOfRowsInSection:l_section]; l_row++) {
            @autoreleasepool {
                NSIndexPath *l_indexPath = [NSIndexPath indexPathForRow:l_row inSection:l_section];
//                NSLog(@"l_indexPath: %@", [l_indexPath description]);
                NSUInteger l_editorType = [self editorTypeForIndexPath:l_indexPath];
                if (l_editorType== IFAEditorTypeText || l_editorType== IFAEditorTypeNumber) {
                    NSString *l_className = [(l_editorType== IFAEditorTypeText ?[IFAFormTextFieldTableViewCell class]:[IFAFormNumberFieldTableViewCell class]) description];
                    IFAFormTextFieldTableViewCell *l_cell = (IFAFormTextFieldTableViewCell *)[self cellForTable:self.tableView indexPath:l_indexPath className:l_className];
                    (self.IFA_indexPathToTextFieldCellDictionary)[l_indexPath] = l_cell;
                    if ([self isReadOnlyForIndexPath:l_indexPath]) {
                        [l_cell.textField removeFromSuperview];
                    }else {
                        [self.IFA_editableTextFieldCells addObject:l_cell];
                    }
                }
            }
        }
    }
//    NSLog(@"IFA_editableTextFieldCells: %@", [self.IFA_editableTextFieldCells description]);

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
    }else if(self.editing && ![self ifa_isReturningVisibleViewController] && [self contextSwitchRequestRequiredInEditMode]) {
        // If it's already in editing mode, need to make sure context switch request is required (e.g. the view controller could be cached by the menu)
        self.contextSwitchRequestRequired = YES;
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
    [super viewDidAppear:animated];
    if (self.createMode && !self.IFA_createModeAutoFieldEditDone) {
        NSIndexPath *l_indexPath = [[IFAPersistenceManager sharedInstance].entityConfig indexPathForProperty:@"name"
                                                                                                   inObject:self.object
                                                                                                     inForm:self.formName
                                                                                                 createMode:self.createMode];
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

}

- (NSArray*)ifa_editModeToolbarItems {
	if(!self.createMode){
		UIBarButtonItem *deleteButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemDelete target:self
                                                                      action:@selector(onDeleteButtonTap:)];
		return @[deleteButtonItem];
	}else {
		return nil;
	}

}

- (void)quitEditing{
	if (self.IFA_isManagedObject && ([IFAPersistenceManager sharedInstance].isCurrentManagedObjectDirty || self.IFA_textFieldTextChanged)) {
        [IFAUIUtils showActionSheetWithMessage:@"Are you sure you want to discard your changes?"
                  destructiveButtonLabelSuffix:@"discard"
                                viewController:self
                                 barButtonItem:nil
                                      delegate:self
                                           tag:IFAViewTagActionSheetCancel];
	}else{
		[self restoreNonEditingState];
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

-(BOOL)contextSwitchRequestRequired {
    if (self.IFA_isManagedObject) {
        return [super contextSwitchRequestRequired];
    }else{
        return NO;
    }
}

-(void)setContextSwitchRequestRequired:(BOOL)a_contextSwitchRequestRequired{
    [super setContextSwitchRequestRequired:self.IFA_isManagedObject ? a_contextSwitchRequestRequired : NO];
}

-(void)ifa_onKeyboardNotification:(NSNotification*)a_notification{

    [super ifa_onKeyboardNotification:a_notification];

//    NSLog(@"m_onKeyboardNotification");

    if ([a_notification.name isEqualToString:UIKeyboardDidShowNotification]) {

        [IFAUtils dispatchAsyncMainThreadBlock:^{
            [self.tableView flashScrollIndicators];

        }];

    }else if ([a_notification.name isEqualToString:UIKeyboardDidHideNotification]) {

        if (self.ifa_activePopoverController && !self.ifa_activePopoverControllerBarButtonItem) {

            CGRect l_fromPopoverRect = [self IFA_fromPopoverRectForIndexPath:self.IFA_indexPathForPopoverController];
            [self ifa_presentPopoverController:self.ifa_activePopoverController fromRect:l_fromPopoverRect
                                        inView:self.tableView];

        }

    }

}

@end
