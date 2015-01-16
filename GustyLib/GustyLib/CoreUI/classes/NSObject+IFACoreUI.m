//
//  NSObject+IFACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 28/02/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

@implementation NSObject (IFACoreUI)

#pragma mark - Public

- (void)ifa_commonInit {
    // Subclasses can override this.
}

- (id)ifa_propertyValueForIndexPath:(NSIndexPath *)anIndexPath inForm:(NSString *)aFormName createMode:(BOOL)aCreateMode{
    //	return [self performSelector:NSSelectorFromString([self propertyNameForIndexPath:anIndexPath inForm:aFormName])];
	return objc_msgSend(self, NSSelectorFromString([self ifa_propertyNameForIndexPath:anIndexPath inForm:aFormName
                                                                           createMode:aCreateMode]));
}

- (NSString*)ifa_propertyNameForIndexPath:(NSIndexPath *)anIndexPath inForm:(NSString *)aFormName createMode:(BOOL)aCreateMode{
	return [[IFAPersistenceManager sharedInstance].entityConfig nameForIndexPath:anIndexPath inObject:self inForm:aFormName createMode:aCreateMode];
}

- (NSString*)ifa_propertyStringValueForName:(NSString *)a_propertyName calendar:(NSCalendar*)a_calendar{
    return [self ifa_propertyStringValueForName:a_propertyName calendar:a_calendar
                                          value:[self valueForKey:a_propertyName]];
}

- (NSString *)stringValueForNumberPropertyNamed:(NSString *)a_propertyName a_calendar:(NSCalendar *)a_calendar a_value:(id)a_value {
    NSString *l_stringValue = nil;
    NSUInteger dataType = [[IFAPersistenceManager sharedInstance].entityConfig dataTypeForProperty:a_propertyName inObject:self];
    if (dataType== IFADataTypeTimeInterval) {
        l_stringValue = [IFADateRange durationStringForInterval:[a_value doubleValue]
                                                         format:IFADurationFormatHoursMinutesLong
                                                       calendar:a_calendar];
    }else {
        l_stringValue = [[self ifa_numberFormatterForProperty:a_propertyName] stringFromNumber:a_value];
    }
    return l_stringValue;
}

- (NSString*)ifa_propertyStringValueForName:(NSString *)a_propertyName calendar:(NSCalendar *)a_calendar value:(id)a_value{
    NSPropertyDescription *l_propertyDescription = [self ifa_descriptionForProperty:a_propertyName];
    if (l_propertyDescription) {
        if ([l_propertyDescription isKindOfClass:[NSRelationshipDescription class]]) {
            if (a_value && [a_value isKindOfClass:[NSManagedObject class]]){
                NSString *l_displayValueProperty = [[[IFAPersistenceManager sharedInstance] entityConfig] displayValuePropertyForEntityProperty:a_propertyName inObject:self];
                if (l_displayValueProperty) {
                    return [a_value valueForKey:l_displayValueProperty];
                }
            }
            return [IFAUIUtils stringValueForObject:a_value];
        }else if([[IFAPersistenceManager sharedInstance].entityConfig isEnumerationForProperty:a_propertyName inObject:self]){
            NSString *l_enumerationSource = [[IFAPersistenceManager sharedInstance].entityConfig enumerationSourceForProperty:a_propertyName inObject:self];
            return [IFAEnumerationEntity enumerationEntityForId:a_value entities:[self valueForKey:l_enumerationSource]].name;
        }else if([l_propertyDescription isKindOfClass:[NSAttributeDescription class]]){
            NSAttributeDescription *l_attributeDescription = (NSAttributeDescription*)l_propertyDescription;
            switch ([l_attributeDescription attributeType]) {
                case NSStringAttributeType:
                case NSDateAttributeType:
                    return [IFAUIUtils stringValueForObject:a_value];
                case NSBooleanAttributeType:
                    return [IFAUIUtils stringValueForBoolean:[(NSNumber *) a_value boolValue]];
                case NSDoubleAttributeType:
                    return [self stringValueForNumberPropertyNamed:a_propertyName a_calendar:a_calendar a_value:a_value];
                default:
                    NSAssert(NO, @"Unexpected attribute type: %lu", (unsigned long)[l_attributeDescription attributeType]);
                    return @"***UNKNOWN***";
            }
        }else{
            NSAssert(NO, @"Unexpected property description class: %@", [[l_propertyDescription class] description]);
            return @"***UNKNOWN***";
        }
    }else{
        if ([a_value isKindOfClass:NSNumber.class]) {
            return [self stringValueForNumberPropertyNamed:a_propertyName a_calendar:a_calendar a_value:a_value];
        }else{
            return [IFAUIUtils stringValueForObject:a_value];
        }
    }
}

- (NSString*)ifa_propertyStringValueForIndexPath:(NSIndexPath *)anIndexPath inForm:(NSString *)aFormName
                                      createMode:(BOOL)aCreateMode calendar:(NSCalendar*)a_calendar{
    return [self ifa_propertyStringValueForName:[self ifa_propertyNameForIndexPath:anIndexPath inForm:aFormName
                                                                        createMode:aCreateMode]
                                       calendar:a_calendar];
}

- (NSString*)ifa_displayValue {
	SEL selector = NSSelectorFromString(@"name");
	if ([self respondsToSelector:selector]) {
		return objc_msgSend(self, selector);
	}else{
        selector = NSSelectorFromString(@"title");
        if ([self respondsToSelector:selector]) {
            return objc_msgSend(self, selector);
        }else{
            selector = NSSelectorFromString(@"p_name");
            if ([self respondsToSelector:selector]) {
                return objc_msgSend(self, selector);
            }else{
                NSSelectorFromString(@"p_title");
                if ([self respondsToSelector:selector]) {
                    return objc_msgSend(self, selector);
                }else{
                    NSAssert(NO, @"Object does not respond to any of the expected selectors");
                    return @"***UNKNOWN***";
                }
            }
        }
	}
}

- (NSString*)ifa_longDisplayValue {
    return [self ifa_displayValue];
}

- (NSString*)ifa_entityLabel {
	return [[IFAPersistenceManager sharedInstance].entityConfig labelForEntity:[[self class] description]];
}

- (void)ifa_setValue:(id)aValue forProperty:(NSString *)aKey{
	id oldValue = [self valueForKey:aKey];
	if (![aValue isEqual:oldValue]) {
		[self setValue:aValue forKey:aKey];
        [IFAPersistenceManager sharedInstance].isCurrentManagedObjectDirty = YES;
	}
}

- (NSString*)ifa_entityName {
	return [[self class] description];
}

- (NSPropertyDescription*)ifa_descriptionForProperty:(NSString*)aPropertyName{
	return [[IFAPersistenceManager sharedInstance].entityConfig descriptionForProperty:aPropertyName inObject:self];
}

- (NSString*)ifa_labelForProperty:(NSString*)aPropertyName{
	return [[IFAPersistenceManager sharedInstance].entityConfig labelForProperty:aPropertyName inObject:self];
}

- (NSUInteger)ifa_fractionDigitsForProperty:(NSString*)aPropertyName{
	return [[IFAPersistenceManager sharedInstance].entityConfig fractionDigitsForProperty:aPropertyName inObject:self];
}

- (NSNumberFormatter*)ifa_numberFormatterForProperty:(NSString*)aPropertyName{
    NSNumberFormatter *l_numberFormatter = [[NSNumberFormatter alloc] init];
    [l_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [l_numberFormatter setMaximumFractionDigits:[self ifa_fractionDigitsForProperty:aPropertyName]];
    return l_numberFormatter;
}

- (NSNumber*)ifa_minimumValueForProperty:(NSString*)a_propertyName{
    return nil;
}

- (NSNumber*)ifa_maximumValueForProperty:(NSString*)a_propertyName{
    return nil;
}

+ (NSString*)ifa_displayValueForNil {
    return [NSString stringWithFormat:@"(no %@)", [[[IFAPersistenceManager sharedInstance].entityConfig labelForEntity:[self ifa_entityName]] lowercaseString]];
}

@end
