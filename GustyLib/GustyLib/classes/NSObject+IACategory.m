//
//  NSObject+IACategory.m
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

#import "IACommon.h"

@implementation NSObject (IACategory)

#pragma mark - Public

- (void)m_commonInit {
    // Subclasses can override this.
}

- (id)propertyValueForIndexPath:(NSIndexPath*)anIndexPath inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
    //	return [self performSelector:NSSelectorFromString([self propertyNameForIndexPath:anIndexPath inForm:aFormName])];
	return objc_msgSend(self, NSSelectorFromString([self propertyNameForIndexPath:anIndexPath inForm:aFormName createMode:aCreateMode]));
}

- (NSString*)propertyNameForIndexPath:(NSIndexPath*)anIndexPath inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode{
	return [[IAPersistenceManager sharedInstance].entityConfig nameForIndexPath:anIndexPath inObject:self inForm:aFormName createMode:aCreateMode];
}

- (NSString*)propertyStringValueForName:(NSString*)a_propertyName calendar:(NSCalendar*)a_calendar{
    return [self propertyStringValueForName:a_propertyName calendar:a_calendar value:[self valueForKey:a_propertyName]];
}

- (NSString *)stringValueForNumberPropertyNamed:(NSString *)a_propertyName a_calendar:(NSCalendar *)a_calendar a_value:(id)a_value {
    NSString *l_stringValue = nil;
    NSUInteger dataType = [[IAPersistenceManager sharedInstance].entityConfig dataTypeForProperty:a_propertyName inObject:self];
    if (dataType==IA_DATA_TYPE_TIME_INTERVAL) {
        l_stringValue = [IADateRange durationStringForInterval:[a_value doubleValue] format:IA_DURATION_FORMAT_HOURS_MINUTES_LONG calendar:a_calendar];
    }else {
        l_stringValue = [[self numberFormatterForProperty:a_propertyName] stringFromNumber:a_value];
    }
    return l_stringValue;
}

- (NSString*)propertyStringValueForName:(NSString*)a_propertyName calendar:(NSCalendar*)a_calendar value:(id)a_value{
    NSPropertyDescription *l_propertyDescription = [self descriptionForProperty:a_propertyName];
    if (l_propertyDescription) {
        if ([l_propertyDescription isKindOfClass:[NSRelationshipDescription class]]) {
            if (a_value && [a_value isKindOfClass:[NSManagedObject class]]){
                NSString *l_displayValueProperty = [[[IAPersistenceManager sharedInstance] entityConfig] displayValuePropertyForEntityProperty:a_propertyName inObject:self];
                if (l_displayValueProperty) {
                    return [a_value valueForKey:l_displayValueProperty];
                }
            }
            return [IAUIUtils stringValueForObject:a_value];
        }else if([[IAPersistenceManager sharedInstance].entityConfig isEnumerationForProperty:a_propertyName inObject:self]){
            NSString *l_enumerationSource = [[IAPersistenceManager sharedInstance].entityConfig enumerationSourceForProperty:a_propertyName inObject:self];
            return [IAEnumerationEntity enumerationEntityForId:a_value entities:[self valueForKey:l_enumerationSource]].p_name;
        }else if([l_propertyDescription isKindOfClass:[NSAttributeDescription class]]){
            NSAttributeDescription *l_attributeDescription = (NSAttributeDescription*)l_propertyDescription;
            switch ([l_attributeDescription attributeType]) {
                case NSStringAttributeType:
                case NSDateAttributeType:
                    return [IAUIUtils stringValueForObject:a_value];
                case NSBooleanAttributeType:
                    return [IAUIUtils stringValueForBoolean:[(NSNumber*)a_value boolValue]];
                case NSDoubleAttributeType:
                    return [self stringValueForNumberPropertyNamed:a_propertyName a_calendar:a_calendar a_value:a_value];
                default:
                    NSAssert(NO, @"Unexpected attribute type: %u", [l_attributeDescription attributeType]);
                    return @"***UNKNOWN***";
                    break;
            }
        }else{
            NSAssert(NO, @"Unexpected property description class: %@", [[l_propertyDescription class] description]);
            return @"***UNKNOWN***";
        }
    }else{
        if ([a_value isKindOfClass:NSNumber.class]) {
            return [self stringValueForNumberPropertyNamed:a_propertyName a_calendar:a_calendar a_value:a_value];
        }else{
            return [IAUIUtils stringValueForObject:a_value];
        }
    }
}

- (NSString*)propertyStringValueForIndexPath:(NSIndexPath*)anIndexPath inForm:(NSString*)aFormName createMode:(BOOL)aCreateMode calendar:(NSCalendar*)a_calendar{
    return [self propertyStringValueForName:[self propertyNameForIndexPath:anIndexPath inForm:aFormName createMode:aCreateMode] calendar:a_calendar];
}

- (NSString*)displayValue{
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

- (NSString*)longDisplayValue{
    return [self displayValue];
}

- (NSString*)entityLabel{
	return [[IAPersistenceManager sharedInstance].entityConfig labelForEntity:[[self class] description]];
}

- (void) setValue:(id)aValue forProperty:(NSString *)aKey{
	id oldValue = [self valueForKey:aKey];
	if (![aValue isEqual:oldValue]) {
		[self setValue:aValue forKey:aKey];
        [IAPersistenceManager sharedInstance].isCurrentManagedObjectDirty = YES;
	}
}

- (NSString*)entityName{
	return [[self class] description];
}

- (NSPropertyDescription*)descriptionForProperty:(NSString*)aPropertyName{
	return [[IAPersistenceManager sharedInstance].entityConfig descriptionForProperty:aPropertyName inObject:self];
}

- (NSString*)labelForProperty:(NSString*)aPropertyName{
	return [[IAPersistenceManager sharedInstance].entityConfig labelForProperty:aPropertyName inObject:self];
}

- (NSUInteger)fractionDigitsForProperty:(NSString*)aPropertyName{
	return [[IAPersistenceManager sharedInstance].entityConfig fractionDigitsForProperty:aPropertyName inObject:self];
}

- (NSNumberFormatter*)numberFormatterForProperty:(NSString*)aPropertyName{
    NSNumberFormatter *l_numberFormatter = [[NSNumberFormatter alloc] init];
    [l_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [l_numberFormatter setMaximumFractionDigits:[self fractionDigitsForProperty:aPropertyName]];
    return l_numberFormatter;
}

- (NSNumber*)minimumValueForProperty:(NSString*)a_propertyName{
    return nil;
}

- (NSNumber*)maximumValueForProperty:(NSString*)a_propertyName{
    return nil;
}

+ (NSString*)entityName{
	return [[self class] description];
}

+ (NSString*)displayValueForNil{
    return [NSString stringWithFormat:@"(no %@)", [[[IAPersistenceManager sharedInstance].entityConfig labelForEntity:[self entityName]] lowercaseString]];
}

@end
