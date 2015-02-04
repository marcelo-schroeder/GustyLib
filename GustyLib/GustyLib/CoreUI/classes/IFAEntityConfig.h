//
//  IFAEntityConfig.h
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

#import "IFACoreUiConstants.h"

@class NSManagedObject;
@class NSManagedObjectContext;

static NSString *const IFAEntityConfigPropertyNameDeleteButton = @"IFAEntityConfig.propertyName.deleteButton";

typedef NS_ENUM(NSUInteger, IFAEntityConfigFieldType){
    IFAEntityConfigFieldTypeProperty,       // type = "property"
    IFAEntityConfigFieldTypeForm,           // type = "form"
    IFAEntityConfigFieldTypeViewController, // type = "viewController"
    IFAEntityConfigFieldTypeButton,         // type = "button"
    IFAEntityConfigFieldTypeCustom,         // type = "custom"
};

@interface IFAEntityConfig : NSObject

@property (strong, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext;

- (NSIndexPath*)indexPathForProperty:(NSString*)aPropertyName inObject:(NSObject*)aObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (NSString*)labelForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName;
- (NSString*)labelForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (IFADataType)dataTypeForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName;
- (IFADataType)dataTypeForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSString*)valueFormatForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSString*)editorTipTextForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSString*)controlForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSUInteger)fractionDigitsForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSArray*)dependentsForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSString*)displayValuePropertyForEntityProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSString*)parentPropertyForDependent:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSString*)listLabelForEntity:(NSString*)anEntityName;
- (Class)formViewControllerClassForEntity:(NSString*)anEntityName;
- (BOOL)listReorderAllowedForEntity:(NSString*)anEntityName;
- (BOOL)listReorderAllowedForObject:(NSObject*)anObject;
- (BOOL)disallowDetailDisclosureForEntity:(NSString*)anEntityName;
- (BOOL)disallowDetailDisclosureForObject:(NSObject*)anObject;
- (BOOL)disallowUserAdditionForEntity:(NSString*)anEntityName;
- (BOOL)disallowUserAdditionForObject:(NSObject*)anObject;
- (NSString*)listGroupedByForEntity:(NSString*)anEntityName;
- (NSString*)listFetchedResultsControllerSectionNameKeyPathForEntity:(NSString*)anEntityName;
- (NSString*)labelForEntity:(NSString*)anEntityName;
- (NSString*)indefiniteArticleForEntity:(NSString*)anEntityName;
- (IFAEditorType)fieldEditorForEntity:(NSString*)anEntityName;
- (NSString*)labelForObject:(NSObject*)anObject;
- (NSString*)labelForViewControllerFieldTypeAtIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (BOOL)isModalForViewControllerFieldTypeAtIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (NSString*)classNameForViewControllerFieldTypeAtIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (NSDictionary*)propertiesForViewControllerFieldTypeAtIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (BOOL)isReadOnlyForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (NSString*)urlPropertyNameForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (NSArray*)propertiesWithBackingPreferencesForObject:(NSObject*)anObject;
- (NSString*)backingPreferencesPropertyForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSString*)backingPreferencesPropertyForEntity:(NSString*)anEntityName;

- (NSString*)entityNameForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSString*)entityNameForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName;
- (NSString*)enumerationSourceForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSString*)enumerationSourceForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName;
- (BOOL)isEnumerationForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (BOOL)isEnumerationForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName;
- (BOOL)shouldTriggerChangeNotificationForProperty:(NSString*)aPropertyName inManagedObject:(NSManagedObject*)aManagedObject;
- (BOOL)shouldTriggerChangeNotificationForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName;
- (BOOL)shouldTriggerChangeNotificationForManagedObject:(NSManagedObject*)aManagedObject;
- (BOOL)shouldTriggerChangeNotificationForEntity:(NSString*)anEntityName;

- (NSArray*)formSectionsForObject:(NSObject*)a_object inForm:(NSString*)a_formName createMode:(BOOL)a_createMode;
- (NSUInteger)formSectionsCountForObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (NSUInteger)fieldCountCountForSectionIndex:(NSInteger)aSectionIndex inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (NSString *)headerForSectionIndex:(NSInteger)aSectionIndex inObject:(NSObject *)anObject inForm:(NSString *)aFormName createMode:(BOOL)aCreateMode;
- (NSString *)footerForSectionIndex:(NSInteger)a_sectionIndex inObject:(NSObject *)a_object inForm:(NSString *)a_formName
                                                                                        createMode:(BOOL)a_createMode;

- (NSString*)labelForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (NSString*)nameForIndexPath:(NSIndexPath*)anIndexPath inObject:(NSObject*)anObject inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode;
- (NSString*)labelForForm:(NSString*)aFormName inObject:(NSObject*)anObject;
- (NSString*)headerForForm:(NSString*)aFormName inObject:(NSObject*)anObject;
- (NSString*)footerForForm:(NSString*)aFormName inObject:(NSObject*)anObject;
- (NSString*)viewControllerForForm:(NSString*)aFormName inObject:(NSObject*)anObject;

- (BOOL)hasNavigationBarSubmitButtonForForm:(NSString *)aFormName inEntity:(NSString*)anEntityName;
- (NSString*)navigationBarSubmitButtonLabelForForm:(NSString *)aFormName inEntity:(NSString*)anEntityName;

- (BOOL)isRelationshipForProperty:(NSString*)aPropertyName inManagedObject:(NSManagedObject*)aManagedObject;
- (BOOL)isRelationshipForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName;

- (BOOL)isToManyRelationshipForProperty:(NSString*)aPropertyName inManagedObject:(NSManagedObject*)aManagedObject;
- (BOOL)isToManyRelationshipForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName;

- (NSArray*)listSortPropertiesForEntity:(NSString*)anEntityName;
- (BOOL)isInMemoryListSortForEntity:(NSString*)anEntityName;

- (NSArray*)uniqueKeysForManagedObject:(NSManagedObject*)aManagedObject;

- (NSPropertyDescription*)descriptionForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSPropertyDescription*)descriptionForProperty:(NSString*)aPropertyName inEntity:(NSString*)anEntityName;

- (NSDictionary*) relationshipDictionaryForEntity:(NSString*)anEntityName;

- (NSDictionary*)optionsForProperty:(NSString*)aPropertyName inObject:(NSObject*)anObject;
- (NSDictionary*)dictionaryForEntity:(NSString*)anEntityName;

- (void)setDefaultValuesFromBackingPreferencesForObject:(NSObject*)a_nObject;

-(BOOL)containsForm:(NSString*)aFormName forEntity:(NSString*)anEntityName;

- (BOOL)shouldShowAddButtonInSelectionForEntity:(NSString*)anEntityName;

//+ (IFAEntityConfig*)sharedInstance;

- (BOOL)shouldShowSelectNoneButtonInSelectionForEntity:(NSString *)anEntityName;

- (IFAEntityConfigFieldType)fieldTypeForIndexPath:(NSIndexPath *)a_indexPath inObject:(NSObject *)a_object
                                                                               inForm:(NSString *)a_formName createMode:(BOOL)a_createMode;

- (BOOL)isDestructiveButtonAtIndexPath:(NSIndexPath *)a_indexPath inObject:(NSObject *)a_object
                                inForm:(NSString *)a_formName createMode:(BOOL)a_createMode;
@end
