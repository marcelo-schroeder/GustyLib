//
//  IAEntityConfig.m
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

#import "IACommon.h"

@interface IAEntityConfig ()

@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) NSMutableDictionary *p_entityToDependencyParentChildrenDict;
@property (strong) NSMutableDictionary *p_entityToDependencyChildParentDict;

@end

@implementation IAEntityConfig


#pragma mark -
#pragma mark Private

- (NSDictionary*)entityConfigDictionary{
    NSMutableDictionary *l_dictionary = [[IADynamicCache sharedInstance] objectForKey:(IA_CACHE_KEY_ENTITY_CONFIG_DICTIONARY)];
	if(!l_dictionary){
        l_dictionary = [NSMutableDictionary dictionaryWithDictionary:[IAUtils getPlistAsDictionary:@"IAEntityConfig"]];
        [l_dictionary addEntriesFromDictionary:[IAUtils getPlistAsDictionary:@"EntityConfig"]];
		[[IADynamicCache sharedInstance] setObject:l_dictionary forKey:IA_CACHE_KEY_ENTITY_CONFIG_DICTIONARY];
	}
	return l_dictionary;
}

- (id) fieldForIndexPath:(NSIndexPath *)anIndexPath inObject:(NSObject *)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[[[self formSectionsForObject:anObject inForm:(NSString*)aFormName createMode:aCreateMode] objectAtIndex:anIndexPath.section] objectForKey:@"fields"] objectAtIndex:anIndexPath.row];
}

- (NSString*)typeForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[self fieldForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] valueForKey:@"type"];
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
	return [[[[self formSectionsForEntity:anEntityName inForm:(NSString*)aFormName] objectAtIndex:aSectionIndex] objectForKey:@"creationOnly"] boolValue];
}

- (id)submitButtonDictionaryForForm:(NSString *)aFormName inEntity:(NSString*)anEntityName{
    return [[self dictionaryForForm:aFormName forEntity:anEntityName] valueForKey:@"submitButton"];
}

- (NSDictionary*)dictionaryForEntity:(NSString*)anEntityName{
    return [[self entityConfigDictionary] valueForKey:anEntityName];
}

#pragma mark - Public

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext{
	
	if ((self=[super init])) {

		self.managedObjectContext = aManagedObjectContext;
        
        self.p_entityToDependencyParentChildrenDict = [[NSMutableDictionary alloc] init];
        self.p_entityToDependencyChildParentDict = [[NSMutableDictionary alloc] init];

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

            [self.p_entityToDependencyParentChildrenDict setValue:l_parentToChildrenDict forKey:l_entityName];
            [self.p_entityToDependencyChildParentDict setValue:l_childToParentDict forKey:l_entityName];
            
        
        }
        
        //        NSLog(@"p_entityToDependencyParentChildrenDict: %@", [p_entityToDependencyParentChildrenDict description]);
        //        NSLog(@"p_entityToDependencyChildParentDict: %@", [p_entityToDependencyChildParentDict description]);
    
    }
	
	return self;
	
}

- (NSString*)labelForForm:(NSString*)aFormName inEntity:(NSString*)anEntityName{
	return [[self dictionaryForForm:aFormName forEntity:anEntityName] valueForKey:@"label"];
}

- (NSString*)headerForForm:(NSString*)aFormName inObject:(NSObject*)anObject{
	return [[[[[self entityConfigDictionary] valueForKey:[anObject IFA_entityName]] valueForKey:@"forms"] valueForKey:aFormName] valueForKey:@"formHeader"];
}

- (NSString*)footerForForm:(NSString*)aFormName inObject:(NSObject*)anObject{
	return [[[[[self entityConfigDictionary] valueForKey:[anObject IFA_entityName]] valueForKey:@"forms"] valueForKey:aFormName] valueForKey:@"formFooter"];
}

- (NSString*)viewControllerForForm:(NSString*)aFormName inEntity:(NSString*)anEntityName{
	return [[self dictionaryForForm:aFormName forEntity:anEntityName] valueForKey:@"viewController"];
}

- (NSIndexPath*)indexPathForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
    NSArray *l_sections = [self formSectionsForObject:anObject inForm:aFormName createMode:aCreateMode];
    NSUInteger l_section = 0;
    for (NSDictionary *l_sectionDict in l_sections) {
        NSArray *l_fields = [l_sectionDict objectForKey:@"fields"];
        NSUInteger l_row = 0;
        for (NSDictionary *l_fieldDict in l_fields) {
            if ([[l_fieldDict objectForKey:@"name"] isEqualToString:aPropertyName]) {
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

- (IADataType)dataTypeForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
	NSString *dataTypeName = [[[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"dataType"];
	IADataType dataType = NSNotFound;
	if (dataTypeName) {
		if ([dataTypeName isEqualToString:@"timeInterval"]) {
			dataType = IA_DATA_TYPE_TIME_INTERVAL;
		}else {
			NSAssert(NO, @"Unexpected data type name: %@", dataTypeName);
		}
	}
	return dataType;
}

- (IADataType)dataTypeForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
	return [self dataTypeForProperty:aPropertyName inEntity:[[anObject class] description]];
}

- (NSString*)controlForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [[[[[self entityConfigDictionary] valueForKey:[[anObject class] description]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"control"];
}

- (NSUInteger)fractionDigitsForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [((NSNumber*)[[[[[self entityConfigDictionary] valueForKey:[[anObject class] description]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"fractionDigits"]) unsignedIntegerValue];
}

- (NSArray*)dependentsForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [[self.p_entityToDependencyParentChildrenDict valueForKey:[anObject IFA_entityName]] valueForKey:aPropertyName];
}

- (NSString*)displayValuePropertyForEntityProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [[[[[self entityConfigDictionary] valueForKey:[[anObject class] description]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"displayValueProperty"];
}

- (NSString*)parentPropertyForDependent:(NSString*)aPropertyName inObject:(NSObject*)anObject{
    return [[self.p_entityToDependencyChildParentDict valueForKey:[anObject IFA_entityName]] valueForKey:aPropertyName];
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
    
- (NSString*)labelForEntity:(NSString*)anEntityName{
	return [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"label"];
}

- (NSString*)indefiniteArticleForEntity:(NSString*)anEntityName{
	return [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"indefiniteArticle"];
}

- (IAEditorType)fieldEditorForEntity:(NSString*)anEntityName{
	NSString *fieldEditorName = [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"fieldEditor"];
	IAEditorType fieldEditor = NSNotFound;
	if (fieldEditorName) {
		if ([fieldEditorName isEqualToString:@"selectionList"]) {
			fieldEditor = IA_EDITOR_TYPE_SELECTION_LIST;
		}else if ([fieldEditorName isEqualToString:@"segmented"]) {
			fieldEditor = IA_EDITOR_TYPE_SEGMENTED;
		}else if ([fieldEditorName isEqualToString:@"picker"]) {
			fieldEditor = IA_EDITOR_TYPE_PICKER;
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
    return [self isEnumerationForProperty:aPropertyName inEntity:[anObject IFA_entityName]];
}

- (BOOL)isEnumerationForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
    return [self enumerationSourceForProperty:aPropertyName inEntity:anEntityName]!=nil;
}

- (BOOL)shouldTriggerChangeNotificationForProperty:(NSString*)aPropertyName inManagedObject:(NSManagedObject*)aManagedObject{
    return [self shouldTriggerChangeNotificationForProperty:aPropertyName inEntity:[aManagedObject IFA_entityName]];
}

- (BOOL)shouldTriggerChangeNotificationForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{

//    NSLog(@"shouldTriggerChangeNotificationForProperty - aPropertyName: %@, anEntityName: %@", aPropertyName, anEntityName);

    id l_propertyValue = [[[[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"shouldTriggerChangeNotification"];
    BOOL l_shouldTriggerChangeNotification = l_propertyValue ? [l_propertyValue boolValue] : [self shouldTriggerChangeNotificationForEntity:anEntityName];
//    NSLog(@" final: %u", l_shouldTriggerChangeNotification);
    
    return l_shouldTriggerChangeNotification;

}

- (BOOL)shouldTriggerChangeNotificationForManagedObject:(NSManagedObject*)aManagedObject{
    return [self shouldTriggerChangeNotificationForEntity:[aManagedObject IFA_entityName]];
}

- (BOOL)shouldTriggerChangeNotificationForEntity:(NSString*)anEntityName{
    id l_propertyValue = [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"shouldTriggerChangeNotification"];
    BOOL l_shouldTriggerChangeNotification = l_propertyValue ? [l_propertyValue boolValue] : YES;
    //    NSLog(@" entity: %u", l_shouldTriggerChangeNotification);
    return l_shouldTriggerChangeNotification;
}

- (NSArray*)formSectionsForEntity:(NSString*)anEntityName inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
    NSArray *l_formSections = [self formSectionsForEntity:anEntityName inForm:aFormName];
    if (aCreateMode) {
//        NSLog(@"l_formSections: %u", [l_formSections count]);
        return l_formSections;
    }else{
        NSMutableArray *l_modFormSections = [NSMutableArray new];
        for (NSUInteger i=0; i<[l_formSections count]; i++) {
            if (![self isCreationOnlyForSectionIndex:i entity:anEntityName inForm:aFormName]) {
                [l_modFormSections addObject:[l_formSections objectAtIndex:i]];
            }
        }
//        NSLog(@"l_modFormSections: %u", [l_modFormSections count]);
        return l_modFormSections;
    }
}

- (NSArray*)formSectionsForObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [self formSectionsForEntity:[[anObject class] description] inForm:aFormName createMode:aCreateMode]; 
}

- (NSUInteger)formSectionsCountForObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[self formSectionsForObject:anObject inForm:aFormName createMode:aCreateMode] count];
}

- (NSUInteger)fieldCountCountForSectionIndex:(NSUInteger)aSectionIndex inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[[[self formSectionsForObject:anObject inForm:aFormName createMode:aCreateMode] objectAtIndex:aSectionIndex] objectForKey:@"fields"] count];
}

- (NSString *)headerForSectionIndex:(NSUInteger)aSectionIndex inObject:(NSObject *)anObject inForm:(NSString *)aFormName createMode:(BOOL)aCreateMode {
	return [[[self formSectionsForObject:anObject inForm:(NSString*)aFormName createMode:aCreateMode] objectAtIndex:aSectionIndex] objectForKey:@"sectionHeader"];
}

- (NSString *)footerForSectionIndex:(NSUInteger)aSectionIndex inObject:(NSObject *)anObject inForm:(NSString *)aFormName createMode:(BOOL)aCreateMode {
	return [[[self formSectionsForObject:anObject inForm:(NSString*)aFormName createMode:aCreateMode] objectAtIndex:aSectionIndex] objectForKey:@"sectionFooter"];
}

- (NSString*)labelForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSManagedObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	NSString *fieldName = [self nameForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode];
	if ([self isFormFieldTypeForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode]) {
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

- (BOOL)isFormFieldTypeForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[self typeForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] isEqualToString:@"form"];
}

- (BOOL)isViewControllerFieldTypeForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[self typeForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] isEqualToString:@"viewController"];
}

- (BOOL)isCustomFieldTypeForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[self typeForIndexPath:anIndexPath inObject:anObject inForm:aFormName createMode:aCreateMode] isEqualToString:@"custom"];
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
	return [self descriptionForProperty:aPropertyName inEntity:[anObject IFA_entityName]];
}

- (NSPropertyDescription*)descriptionForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName{
	return [[[self descriptionForEntity:anEntityName] propertiesByName] objectForKey:aPropertyName];
}

- (NSDictionary*) relationshipDictionaryForEntity:(NSString*)anEntityName{
	return [[NSEntityDescription entityForName:anEntityName inManagedObjectContext:self.managedObjectContext] relationshipsByName];
}

- (NSDictionary*)optionsForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject{
	return [[[[[self entityConfigDictionary] valueForKey:[[anObject class] description]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"options"];
}

- (NSArray*)propertiesWithBackingPreferencesForObject:(NSObject*)anObject{
    NSMutableArray *l_propertiesWithBackingPreferences = [NSMutableArray array];
    NSDictionary *l_propertiesDict = [[[self entityConfigDictionary] valueForKey:[anObject IFA_entityName]] valueForKey:@"properties"];
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
	return [[[[[self entityConfigDictionary] valueForKey:[anObject IFA_entityName]] valueForKey:@"properties"] valueForKey:aPropertyName] valueForKey:@"backingPreferencesProperty"];
}

- (NSString*)backingPreferencesPropertyForEntity:(NSString*)anEntityName{
	return [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"backingPreferencesProperty"];
}

- (void)setDefaultValuesFromBackingPreferencesForObject:(NSObject*)anObject{
    for (NSString *l_propertyWithBackingPreferencesProperty in [[IAPersistenceManager sharedInstance].entityConfig propertiesWithBackingPreferencesForObject:anObject]) {
        //        NSLog(@"l_propertyWithBackingPreferencesProperty: %@", l_propertyWithBackingPreferencesProperty);
        NSString *l_backingPreferencesProperty = [[IAPersistenceManager sharedInstance].entityConfig backingPreferencesPropertyForProperty:l_propertyWithBackingPreferencesProperty inObject:anObject];
        id l_preferencesValue = [[[IAPreferencesManager sharedInstance] preferences] valueForKey:l_backingPreferencesProperty];
        [anObject setValue:l_preferencesValue forKey:l_propertyWithBackingPreferencesProperty];
    }
}

-(BOOL)containsForm:(NSString*)aFormName forEntity:(NSString*)anEntityName{
    return [self dictionaryForForm:aFormName forEntity:anEntityName]!=nil;
}

- (BOOL)hasSubmitButtonForForm:(NSString*)aFormName inEntity:(NSString*)anEntityName{
	return [self submitButtonDictionaryForForm:aFormName inEntity:anEntityName]!=nil;
}

- (NSString*)submitButtonLabelForForm:(NSString*)aFormName inEntity:(NSString*)anEntityName{
    return [[self submitButtonDictionaryForForm:aFormName inEntity:anEntityName] valueForKey:@"label"];
}

- (BOOL)shouldShowAddButtonInSelectionForEntity:(NSString*)anEntityName{
    NSNumber *l_boolObj = [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"shouldShowAddButtonInSelection"];
    return l_boolObj ? l_boolObj.boolValue : YES;   // Default value is YES.
}

- (BOOL)shouldShowSelectNoneButtonInSelectionForEntity:(NSString*)anEntityName{
    NSNumber *l_boolObj = [[[self entityConfigDictionary] valueForKey:anEntityName] valueForKey:@"shouldShowSelectNoneButtonInSelection"];
    return l_boolObj ? l_boolObj.boolValue : YES;   // Default value is YES.
}

//+ (IAEntityConfig*)sharedInstance {
//    static dispatch_once_t c_dispatchOncePredicate;
//    static IAEntityConfig *c_instance = nil;
//    dispatch_once(&c_dispatchOncePredicate, ^{
//        c_instance = [self new];
//    });
//    return c_instance;
//}

@end
