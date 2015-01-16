//
//  IFAEntityConfig.m
//  Gusty
//
//  Created by Marcelo Schroeder on 26/07/10.
//  Copyright 2010 InfoAccent Pty Limited. All rights reserved.
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

@interface IFAEntityConfig ()

@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSMutableDictionary *IFA_entityToDependencyParentChildrenDict;
@property (strong) NSMutableDictionary *IFA_entityToDependencyChildParentDict;

@end

@implementation IFAEntityConfig


#pragma mark -
#pragma mark Private

- (NSDictionary*)entityConfigDictionary{
    NSMutableDictionary *l_dictionary = [[IFADynamicCache sharedInstance] objectForKey:(IFACacheKeyEntityConfigDictionary)];
	if(!l_dictionary){
        l_dictionary = [NSMutableDictionary dictionaryWithDictionary:[IFAUtils getPlistAsDictionary:@"IFAEntityConfig"]];
        [l_dictionary addEntriesFromDictionary:[IFAUtils getPlistAsDictionary:@"EntityConfig"]];
        [[IFADynamicCache sharedInstance] setObject:l_dictionary forKey:IFACacheKeyEntityConfigDictionary];
	}
	return l_dictionary;
}

- (id) fieldForIndexPath:(NSIndexPath *)anIndexPath inObject:(NSObject *)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[[self formSectionsForObject:anObject inForm:aFormName
                              createMode:aCreateMode][(NSUInteger) anIndexPath.section] objectForKey:@"fields"] objectAtIndex:(NSUInteger) anIndexPath.row];
}

- (NSString*)fieldTypePListValueForIndexPath:(NSIndexPath *)anIndexPath inObject:(NSObject *)anObject
                                      inForm:(NSString *)aFormName
                                  createMode:(BOOL)aCreateMode{
	return [[self fieldForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] valueForKey:@"type"];
}

- (BOOL)shouldShowSectionAtIndex:(NSUInteger)a_sectionIndex
                          object:(NSObject *)a_object
                        formName:(NSString *)a_formName
                      createMode:(BOOL)a_createMode {
    NSString *entityName = a_object.ifa_entityName;
    NSArray *sections = [self formSectionsForEntity:entityName inForm:a_formName];
    NSDictionary *section = sections[a_sectionIndex];
    NSString *visibilityIndicatorPropertyName = [section valueForKey:@"visibilityIndicatorPropertyName"];
    BOOL shouldShowSection;
    if (visibilityIndicatorPropertyName) {
        NSNumber *visibilityIndicatorPropertyValue = [a_object valueForKey:visibilityIndicatorPropertyName];
        shouldShowSection = visibilityIndicatorPropertyValue ? visibilityIndicatorPropertyValue.boolValue : YES;
    }else{
        shouldShowSection = YES;
    }
    BOOL isCreationOnlySection = [self isCreationOnlyForSectionIndex:a_sectionIndex entity:entityName inForm:a_formName];
    return shouldShowSection && !(!a_createMode && isCreationOnlySection);
}

- (NSEntityDescription*)descriptionForEntity:(NSString*)anEntityName{
	return [NSEntityDescription entityForName:anEntityName inManagedObjectContext:self.managedObjectContext];
}

- (NSDictionary*)dictionaryForForm:(NSString*)aFormName forEntity:(NSString*)anEntityName{
    return [[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"forms"] valueForKey:aFormName];
}

- (NSArray*)formSectionsForEntity:(NSString*)anEntityName inForm:(NSString*)aFormName{
    return [[self dictionaryForForm:aFormName forEntity:anEntityName] valueForKey:@"sections"];
}

- (BOOL)isCreationOnlyForSectionIndex:(NSUInteger)aSectionIndex entity:(NSString*)anEntityName inForm:(NSString*)aFormName{
	return [[[self formSectionsForEntity:anEntityName
                                  inForm:aFormName][aSectionIndex] objectForKey:@"creationOnly"] boolValue];
}

- (id)navigationBarSubmitButtonDictionaryForForm:(NSString *)aFormName inEntity:(NSString*)anEntityName{
    return [[self dictionaryForForm:aFormName forEntity:anEntityName] valueForKey:@"navigationBarSubmitButton"];
}

- (NSDictionary*)dictionaryForEntity:(NSString*)anEntityName{
    return [[self entityConfigDictionary] valueForKey:anEntityName];
}

#pragma mark - Public

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext{
	
	if ((self=[super init])) {

		self.managedObjectContext = aManagedObjectContext;
        
        self.IFA_entityToDependencyParentChildrenDict = [[NSMutableDictionary alloc] init];
        self.IFA_entityToDependencyChildParentDict = [[NSMutableDictionary alloc] init];

        for (NSString *l_entityName in [[self entityConfigDictionary] allKeys]) {

            NSMutableDictionary *l_parentToChildrenDict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *l_childToParentDict = [[NSMutableDictionary alloc] init];

            NSDictionary *l_propertiesDict = [[[self entityConfigDictionary] valueForKey:l_entityName] valueForKey:@"properties"];
            
            for (NSString *l_propertyName in [l_propertiesDict allKeys]) {
                
                NSDictionary *l_propertyDict = [l_propertiesDict valueForKey:l_propertyName];
                NSArray *l_dependentPropertyNames = [l_propertyDict valueForKey:@"dependentProperties"];
                [l_parentToChildrenDict setValue:l_dependentPropertyNames forKey:l_propertyName];
                
                for (NSString *l_dependentPropertyName in l_dependentPropertyNames) {
                    [l_childToParentDict setValue:l_propertyName forKey:l_dependentPropertyName];
                }
            
            }

            [self.IFA_entityToDependencyParentChildrenDict setValue:l_parentToChildrenDict forKey:l_entityName];
            [self.IFA_entityToDependencyChildParentDict setValue:l_childToParentDict forKey:l_entityName];
            
        
        }
        
        //        NSLog(@"IFA_entityToDependencyParentChildrenDict: %@", [IFA_entityToDependencyParentChildrenDict description]);
        //        NSLog(@"IFA_entityToDependencyChildParentDict: %@", [IFA_entityToDependencyChildParentDict description]);
    
    }
	
	return self;
	
}

- (NSString*)labelForForm:(NSString*)aFormName inEntity:(NSString*)anEntityName{
	return [[self dictionaryForForm:aFormName forEntity:anEntityName] valueForKey:@"label"];
}

- (NSString *)headerForForm:(NSString *)aFormName inObject:(NSObject *)anObject {
    return [[[[[self entityConfigDictionary] valueForKey:[anObject ifa_entityName]] valueForKey:@"forms"] valueForKey:aFormName] valueForKey:@"formHeader"];
}

- (NSString *)footerForForm:(NSString *)aFormName inObject:(NSObject *)anObject {
    return [[[[[self entityConfigDictionary] valueForKey:[anObject ifa_entityName]] valueForKey:@"forms"] valueForKey:aFormName] valueForKey:@"formFooter"];
}

- (NSString*)viewControllerForForm:(NSString*)aFormName inEntity:(NSString*)anEntityName{
	return [[self dictionaryForForm:aFormName forEntity:anEntityName] valueForKey:@"viewController"];
}

- (NSIndexPath*)indexPathForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
    NSArray *l_sections = [self formSectionsForObject:anObject inForm:aFormName createMode:aCreateMode];
    NSUInteger l_section = 0;
    for (NSDictionary *l_sectionDict in l_sections) {
        NSArray *l_fields = l_sectionDict[@"fields"];
        NSUInteger l_row = 0;
        for (NSDictionary *l_fieldDict in l_fields) {
            if ([l_fieldDict[@"name"] isEqualToString:aPropertyName]) {
                return [NSIndexPath indexPathForRow:l_row inSection:l_section];
            }
            l_row++;
        }
        l_section++;
    }
    return nil;
}

- (NSString*)labelForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
	NSString *label;
	if ([self isRelationshipForProperty:aPropertyName inEntity:anEntityName]){
        if ([self isToManyRelationshipForProperty:aPropertyName inEntity:anEntityName]) {
            NSRelationshipDescription *l_relationshipDescription = [[[NSEntityDescription entityForName:anEntityName inManagedObjectContext:self.managedObjectContext] relationshipsByName] valueForKey:aPropertyName];
            NSString *l_destinationEntityName = [l_relationshipDescription destinationEntity].name;
            label = [self listLabelForEntity:l_destinationEntityName];
        }else{
            label = [self labelForEntity:[self entityNameForProperty:aPropertyName inEntity:anEntityName]];
        }
	}else{
		label = [[[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"label"];
        if (!label) {
            label = [self labelForEntity:[self entityNameForProperty:aPropertyName inEntity:anEntityName]];
        }
	}
	return label;
}

- (IFADataType)dataTypeForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
	NSString *dataTypeName = [[[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"dataType"];
	IFADataType dataType = (IFADataType) NSNotFound;
	if (dataTypeName) {
		if ([dataTypeName isEqualToString:@"timeInterval"]) {
			dataType = IFADataTypeTimeInterval;
		}else {
			NSAssert(NO, @"Unexpected data type name: %@", dataTypeName);
		}
	}
	return dataType;
}

- (IFADataType)dataTypeForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
	return [self dataTypeForProperty:aPropertyName inEntity:[[anObject class] description]];
}

- (NSString*)controlForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [[[[[self entityConfigDictionary] valueForKey:[[anObject class] description]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"control"];
}

- (NSUInteger)fractionDigitsForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [((NSNumber*)[[[[[self entityConfigDictionary] valueForKey:[[anObject class] description]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"fractionDigits"]) unsignedIntegerValue];
}

- (NSArray*)dependentsForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [[self.IFA_entityToDependencyParentChildrenDict valueForKey:[anObject ifa_entityName]] valueForKey:aPropertyName];
}

- (NSString*)displayValuePropertyForEntityProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [[[[[self entityConfigDictionary] valueForKey:[[anObject class] description]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"displayValueProperty"];
}

- (NSString*)parentPropertyForDependent:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [[self.IFA_entityToDependencyChildParentDict valueForKey:[anObject ifa_entityName]] valueForKey:aPropertyName];
}

- (NSString*)labelForForm:(NSString*)aFormName inObject:(NSObject*)anObject{
	return [self labelForForm:aFormName inEntity:[[anObject class] description]];
}

- (NSString*)viewControllerForForm:(NSString*)aFormName inObject:(NSObject*)anObject{
	return [self viewControllerForForm:aFormName inEntity:[[anObject class] description]];
}

- (NSString*)labelForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
	return [self labelForProperty:aPropertyName inEntity:[[anObject class] description]];
}

- (NSString*)valueFormatForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [[[[[self entityConfigDictionary] valueForKey:[[anObject class] description]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"valueFormat"];
}

- (NSString*)editorTipTextForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [[[[[self entityConfigDictionary] valueForKey:[[anObject class] description]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"editorTipText"];
}

- (NSString*)listLabelForEntity:(NSString*)anEntityName{
	return [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"listLabel"];
}

- (Class)formViewControllerClassForEntity:(NSString*)anEntityName{
	return NSClassFromString([[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"formViewControllerClass"]);
}

- (BOOL)listReorderAllowedForEntity:(NSString*)anEntityName{
	return [[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"listReorderAllowed"] boolValue];
}

- (BOOL)listReorderAllowedForObject:(NSObject*)anObject{
	return [self listReorderAllowedForEntity:[[anObject class] description]];
}

- (BOOL)disallowDetailDisclosureForEntity:(NSString*)anEntityName{
	return [[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"disallowDetailDisclosure"] boolValue];
}

- (BOOL)disallowDetailDisclosureForObject:(NSObject*)anObject{
	return [self disallowDetailDisclosureForObject:[[anObject class] description]];
}

- (BOOL)disallowUserAdditionForEntity:(NSString*)anEntityName{
	return [[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"disallowUserAddition"] boolValue];
}

- (BOOL)disallowUserAdditionForObject:(NSObject*)anObject{
	return [self disallowUserAdditionForEntity:[[anObject class] description]];
}

- (NSString*)listGroupedByForEntity:(NSString*)anEntityName{
	return [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"listGroupedBy"];
}

- (NSString *)listFetchedResultsControllerSectionNameKeyPathForEntity:(NSString *)anEntityName {
    return [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"listFetchedResultsControllerSectionNameKeyPath"];
}

- (NSString*)labelForEntity:(NSString*)anEntityName{
	return [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"label"];
}

- (NSString*)indefiniteArticleForEntity:(NSString*)anEntityName{
	return [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"indefiniteArticle"];
}

- (IFAEditorType)fieldEditorForEntity:(NSString*)anEntityName{
	NSString *fieldEditorName = [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"fieldEditor"];
	IFAEditorType fieldEditor = (IFAEditorType) NSNotFound;
	if (fieldEditorName) {
		if ([fieldEditorName isEqualToString:@"selectionList"]) {
			fieldEditor = IFAEditorTypeSelectionList;
		}else if ([fieldEditorName isEqualToString:@"segmented"]) {
			fieldEditor = IFAEditorTypeSegmented;
		}else if ([fieldEditorName isEqualToString:@"picker"]) {
			fieldEditor = IFAEditorTypePicker;
		}else {
			NSAssert(NO, @"Unexpected field editor name: %@", fieldEditorName);
		}
	}
	return fieldEditor;
}

- (NSString*)labelForObject:(NSObject*)anObject{
	return [self labelForEntity:[[anObject class] description]]; 
}

- (NSString*)entityNameForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
	return [self entityNameForProperty:aPropertyName inEntity:[[anObject class] description]]; 
}

- (NSString*)entityNameForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
//    NSLog(@"[self entityConfigDictionary]: %@", [self entityConfigDictionary]);
	return [[[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"entity"];
}

- (NSString*)enumerationSourceForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
	return [self enumerationSourceForProperty:aPropertyName inEntity:[[anObject class] description]]; 
}

- (NSString*)enumerationSourceForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
	return [[[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"enumerationSource"];
}

- (BOOL)isEnumerationForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [self isEnumerationForProperty:aPropertyName inEntity:[anObject ifa_entityName]];
}

- (BOOL)isEnumerationForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
    return [self enumerationSourceForProperty:aPropertyName inEntity:anEntityName]!=nil;
}

- (BOOL)shouldTriggerChangeNotificationForProperty:(NSString*)aPropertyName inManagedObject:(NSManagedObject*)aManagedObject{
    return [self shouldTriggerChangeNotificationForProperty:aPropertyName inEntity:[aManagedObject ifa_entityName]];
}

- (BOOL)shouldTriggerChangeNotificationForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{

//    NSLog(@"shouldTriggerChangeNotificationForProperty - aPropertyName: %@, anEntityName: %@", aPropertyName, anEntityName);

    id l_propertyValue = [[[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"shouldTriggerChangeNotification"];
    BOOL l_shouldTriggerChangeNotification = l_propertyValue ? [l_propertyValue boolValue] : [self shouldTriggerChangeNotificationForEntity:anEntityName];
//    NSLog(@" final: %u", l_shouldTriggerChangeNotification);
    
    return l_shouldTriggerChangeNotification;

}

- (BOOL)shouldTriggerChangeNotificationForManagedObject:(NSManagedObject*)aManagedObject{
    return [self shouldTriggerChangeNotificationForEntity:[aManagedObject ifa_entityName]];
}

- (BOOL)shouldTriggerChangeNotificationForEntity:(NSString*)anEntityName{
    id l_propertyValue = [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"shouldTriggerChangeNotification"];
    BOOL l_shouldTriggerChangeNotification = l_propertyValue ? [l_propertyValue boolValue] : YES;
    //    NSLog(@" entity: %u", l_shouldTriggerChangeNotification);
    return l_shouldTriggerChangeNotification;
}

- (NSArray *)formSectionsForObject:(NSObject *)a_object
                            inForm:(NSString *)a_formName
                        createMode:(BOOL)a_createMode {
    NSString *entityName = a_object.ifa_entityName;
    NSArray *formSections = [self formSectionsForEntity:entityName inForm:a_formName];
    NSMutableArray *modFormSections = [NSMutableArray new];
    for (NSUInteger i = 0; i < [formSections count]; i++) {
        if ([self shouldShowSectionAtIndex:i object:a_object
                                  formName:a_formName createMode:a_createMode]) {
            [modFormSections addObject:formSections[i]];
        }
    }
//        NSLog(@"modFormSections: %u", [modFormSections count]);
    return modFormSections;
}

- (NSUInteger)formSectionsCountForObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
    NSArray *sections = [self formSectionsForObject:anObject inForm:aFormName createMode:aCreateMode];
    return sections.count;
}

- (NSUInteger)fieldCountCountForSectionIndex:(NSInteger)aSectionIndex inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
    NSArray *sections = [self formSectionsForObject:anObject inForm:aFormName
                                  createMode:aCreateMode];
    NSArray *fields = [sections[(NSUInteger) aSectionIndex] objectForKey:@"fields"];
    return fields.count;
}

- (NSString *)headerForSectionIndex:(NSInteger)aSectionIndex inObject:(NSObject *)anObject inForm:(NSString *)aFormName createMode:(BOOL)aCreateMode {
    NSArray *formSections = [self formSectionsForObject:anObject inForm:aFormName createMode:aCreateMode];
    NSDictionary *formSection = formSections[(NSUInteger) aSectionIndex];
    return formSection[@"sectionHeader"];
}

- (NSString *)footerForSectionIndex:(NSInteger)a_sectionIndex
                           inObject:(NSObject *)a_object
                             inForm:(NSString *)a_formName
                         createMode:(BOOL)a_createMode {
    NSArray *formSections = [self formSectionsForObject:a_object inForm:a_formName createMode:a_createMode];
    NSDictionary *formSection = formSections[(NSUInteger) a_sectionIndex];
#ifdef IFA_AVAILABLE_Help
    NSString *help = nil;
    NSUInteger fieldCount = [self fieldCountCountForSectionIndex:a_sectionIndex
                                                        inObject:a_object inForm:a_formName
                                                      createMode:a_createMode];
    // If there is only one field in the section, then check if there is help available specifically for that field's property
    if (fieldCount == 1) {
        NSIndexPath *fieldIndexPath = [NSIndexPath indexPathForRow:0 inSection:a_sectionIndex];
        NSDictionary *field = [self fieldForIndexPath:fieldIndexPath
                                             inObject:a_object
                                               inForm:a_formName
                                           createMode:a_createMode];
        NSString *propertyHelpValue = nil;
        NSString *propertyName = field[@"name"];
        IFAEntityConfigFieldType fieldType = [self fieldTypeForIndexPath:fieldIndexPath inObject:a_object
                                                                  inForm:a_formName createMode:a_createMode];
        if (fieldType==IFAEntityConfigFieldTypeProperty) {
            id propertyValue = [a_object valueForKey:propertyName];
            if ([propertyValue isKindOfClass:[NSNumber class]]) {
                NSNumber *number = propertyValue;
                propertyHelpValue = number.stringValue;
            }else if ([propertyValue isKindOfClass:[IFASystemEntity class]]) {
                IFASystemEntity *systemEntity = propertyValue;
                propertyHelpValue = systemEntity.systemEntityId.stringValue;
            }
            help = [[IFAHelpManager sharedInstance] helpForPropertyName:propertyName
                                                           inEntityName:a_object.ifa_entityName
                                                                  value:propertyHelpValue];
        }
        // If there is no help for a specific property value, try help for the property itself
        if (!help) {
            help = [[IFAHelpManager sharedInstance] helpForPropertyName:propertyName
                                                           inEntityName:a_object.ifa_entityName
                                                                  value:nil];
        }
    }
    // If there is no help available yet, try to get help for the section
    if (!help) {
        help = [[IFAHelpManager sharedInstance] helpForSectionNamed:formSection[@"name"]
                                                        inFormNamed:a_formName
                                                         createMode:a_createMode
                                                        entityNamed:a_object.ifa_entityName];

    }
    if (help) {
        return help;
    } else {
#endif
        return formSection[@"sectionFooter"];
#ifdef IFA_AVAILABLE_Help
    }
#endif
}

- (NSString*)labelForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject *)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	NSString *fieldName = [self nameForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode];
    BOOL l_isFormFieldType = [self fieldTypeForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode]==IFAEntityConfigFieldTypeForm;
    if (l_isFormFieldType) {
		return [self labelForForm:fieldName inObject:anObject];
	}else {	// it's a property
		return [self labelForProperty:fieldName inObject:anObject];
	}
}

- (NSString*)nameForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[self fieldForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] valueForKey:@"name"];
}

- (BOOL)isRelationshipForProperty:(NSString*)aPropertyName inManagedObject:(NSManagedObject*)aManagedObject{
	return [self isRelationshipForProperty:aPropertyName inEntity:[[aManagedObject class] description]];
}
 
- (BOOL)isRelationshipForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
	return [[[NSEntityDescription entityForName:anEntityName inManagedObjectContext:self.managedObjectContext] relationshipsByName] valueForKey:aPropertyName]!=nil;
}

- (BOOL)isToManyRelationshipForProperty:(NSString*)aPropertyName inManagedObject:(NSManagedObject*)aManagedObject{
	return [self isToManyRelationshipForProperty:aPropertyName inEntity:[[aManagedObject class] description]];
}

- (BOOL)isToManyRelationshipForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
	NSRelationshipDescription *relationshipDescription = [[[NSEntityDescription entityForName:anEntityName inManagedObjectContext:self.managedObjectContext] relationshipsByName] valueForKey:aPropertyName];
	if (relationshipDescription) {
		return [relationshipDescription isToMany];
	}else{
		return NO;
	}
}

- (NSArray*)listSortPropertiesForEntity:(NSString*)anEntityName{
	return [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"listSortProperties"];
}

- (BOOL)isInMemoryListSortForEntity:(NSString*)anEntityName{
    return [[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"listSortInMemory"] boolValue];
}

- (NSArray*)uniqueKeysForManagedObject:(NSManagedObject*)aManagedObject{
	return [[[self entityConfigDictionary] valueForKey:[[aManagedObject class] description]] valueForKey:@"uniqueKeys"];
}

- (NSString*)labelForViewControllerFieldTypeAtIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[self fieldForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] valueForKey:@"label"];
}

- (BOOL)isModalForViewControllerFieldTypeAtIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[[self fieldForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] valueForKey:@"isModalViewController"] boolValue];
}

- (NSString*)classNameForViewControllerFieldTypeAtIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[self fieldForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] valueForKey:@"viewController"];
}

- (NSDictionary*)propertiesForViewControllerFieldTypeAtIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[self fieldForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] valueForKey:@"viewControllerProperties"];
}

- (BOOL)isReadOnlyForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
    return [[[self fieldForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] valueForKey:@"readOnly"] boolValue];
}

- (NSString*)urlPropertyNameForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
    return [[self fieldForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] valueForKey:@"urlProperty"];
}

- (NSPropertyDescription*)descriptionForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
	return [self descriptionForProperty:aPropertyName inEntity:[anObject ifa_entityName]];
}

- (NSPropertyDescription*)descriptionForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
	return [[self descriptionForEntity:anEntityName] propertiesByName][aPropertyName];
}

- (NSDictionary*) relationshipDictionaryForEntity:(NSString*)anEntityName{
	return [[NSEntityDescription entityForName:anEntityName inManagedObjectContext:self.managedObjectContext] relationshipsByName];
}

- (NSDictionary*)optionsForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
	return [[[[[self entityConfigDictionary] valueForKey:[[anObject class] description]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"options"];
}

- (NSArray*)propertiesWithBackingPreferencesForObject:(NSObject*)anObject{
    NSMutableArray *l_propertiesWithBackingPreferences = [NSMutableArray array];
    NSDictionary *l_propertiesDict = [[[self entityConfigDictionary] valueForKey:[anObject ifa_entityName]] valueForKey:@"properties"];
    for (NSString *l_propertyName in [l_propertiesDict allKeys]) {
        NSDictionary *l_propertyDict = [l_propertiesDict valueForKey:l_propertyName];
        NSArray *l_backingPreferencesProperty = [l_propertyDict valueForKey:@"backingPreferencesProperty"];
        if (l_backingPreferencesProperty) {
            [l_propertiesWithBackingPreferences addObject:l_propertyName];
        }
    }
    return l_propertiesWithBackingPreferences;
}

- (NSString*)backingPreferencesPropertyForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
	return [[[[[self entityConfigDictionary] valueForKey:[anObject ifa_entityName]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"backingPreferencesProperty"];
}

- (NSString*)backingPreferencesPropertyForEntity:(NSString*)anEntityName{
	return [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"backingPreferencesProperty"];
}

- (void)setDefaultValuesFromBackingPreferencesForObject:(NSObject*)anObject{
    for (NSString *l_propertyWithBackingPreferencesProperty in [[IFAPersistenceManager sharedInstance].entityConfig propertiesWithBackingPreferencesForObject:anObject]) {
        //        NSLog(@"l_propertyWithBackingPreferencesProperty: %@", l_propertyWithBackingPreferencesProperty);
        NSString *l_backingPreferencesProperty = [[IFAPersistenceManager sharedInstance].entityConfig backingPreferencesPropertyForProperty:l_propertyWithBackingPreferencesProperty inObject:anObject];
        id l_preferencesValue = [[[IFAPreferencesManager sharedInstance] preferences] valueForKey:l_backingPreferencesProperty];
        [anObject setValue:l_preferencesValue forKey:l_propertyWithBackingPreferencesProperty];
    }
}

-(BOOL)containsForm:(NSString*)aFormName forEntity:(NSString*)anEntityName{
    return [self dictionaryForForm:aFormName forEntity:anEntityName]!=nil;
}

- (BOOL)hasNavigationBarSubmitButtonForForm:(NSString *)aFormName inEntity:(NSString*)anEntityName{
	return [self navigationBarSubmitButtonDictionaryForForm:aFormName inEntity:anEntityName]!=nil;
}

- (NSString*)navigationBarSubmitButtonLabelForForm:(NSString *)aFormName inEntity:(NSString*)anEntityName{
    return [[self navigationBarSubmitButtonDictionaryForForm:aFormName inEntity:anEntityName] valueForKey:@"label"];
}

- (BOOL)shouldShowAddButtonInSelectionForEntity:(NSString*)anEntityName{
    NSNumber *l_boolObj = [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"shouldShowAddButtonInSelection"];
    return l_boolObj ? l_boolObj.boolValue : YES;   // Default value is YES.
}

- (BOOL)shouldShowSelectNoneButtonInSelectionForEntity:(NSString*)anEntityName{
    NSNumber *l_boolObj = [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"shouldShowSelectNoneButtonInSelection"];
    return l_boolObj ? l_boolObj.boolValue : YES;   // Default value is YES.
}

- (IFAEntityConfigFieldType)fieldTypeForIndexPath:(NSIndexPath *)a_indexPath inObject:(NSObject *)a_object
                                                                               inForm:(NSString *)a_formName
                                       createMode:(BOOL)a_createMode {
    IFAEntityConfigFieldType l_fieldType = IFAEntityConfigFieldTypeProperty;
    NSString *l_pListValue = [self fieldTypePListValueForIndexPath:a_indexPath
                                                          inObject:a_object
                                                            inForm:a_formName
                                                        createMode:a_createMode];
    if ([l_pListValue isEqualToString:@"property"]) {
        l_fieldType = IFAEntityConfigFieldTypeProperty;
    }else if ([l_pListValue isEqualToString:@"form"]) {
        l_fieldType = IFAEntityConfigFieldTypeForm;
    }else if ([l_pListValue isEqualToString:@"viewController"]) {
        l_fieldType = IFAEntityConfigFieldTypeViewController;
    }else if ([l_pListValue isEqualToString:@"button"]) {
        l_fieldType = IFAEntityConfigFieldTypeButton;
    }else if ([l_pListValue isEqualToString:@"custom"]) {
        l_fieldType = IFAEntityConfigFieldTypeCustom;
    }else{
        NSAssert(NO, @"Unexpected field type plist value: %@", l_pListValue);
    }
    return l_fieldType;
}

- (BOOL)isDestructiveButtonAtIndexPath:(NSIndexPath *)a_indexPath
                              inObject:(NSObject *)a_object
                                inForm:(NSString *)a_formName
                            createMode:(BOOL)a_createMode {
    return ((NSNumber *) [[self fieldForIndexPath:a_indexPath inObject:a_object inForm:a_formName
                                       createMode:a_createMode] valueForKey:@"destructive"]).boolValue;
}

//+ (IFAEntityConfig*)sharedInstance {
//    static dispatch_once_t c_dispatchOncePredicate;
//    static IFAEntityConfig *c_instance = nil;
//    dispatch_once(&c_dispatchOncePredicate, ^{
//        c_instance = [self new];
//    });
//    return c_instance;
//}

@end
