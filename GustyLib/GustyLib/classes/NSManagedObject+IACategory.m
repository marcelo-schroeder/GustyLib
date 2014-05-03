//
//  NSManagedObject+IACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 30/07/10.
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

@implementation NSManagedObject (IACategory)

#pragma mark - Private

- (NSNumber*)validationPredicateParameterProperty:(NSString*)a_propertyName string:(NSString*)a_string{
    NSNumber *l_value = nil;
    for (NSPredicate *l_validationPredicate in [[self descriptionForProperty:a_propertyName] validationPredicates]) {
        NSString *l_predicateFormat = [l_validationPredicate predicateFormat];
        NSRange l_range = [l_predicateFormat rangeOfString:a_string];
        if (l_range.location!=NSNotFound) {
            NSNumberFormatter *l_numberFormatter = [[NSNumberFormatter alloc] init];
            [l_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            l_value = [l_numberFormatter numberFromString:[l_predicateFormat substringFromIndex:[a_string length]]];
        }
    }
    return l_value;
}

#pragma mark - Public

-(NSString*)p_stringId{
    return [self.p_urlId description];
}

-(NSURL*)p_urlId{
    return [[self objectID] URIRepresentation];
}

- (NSString*)m_labelForKeys:(NSArray*)aKeyArray{
	NSMutableString *label = [NSMutableString string];
	for (int i = 0; i < [aKeyArray count]; i++) {
		if (i>0) {
			if (i==([aKeyArray count]-1)) {
				[label appendString:@" and "];
			}else {
				[label appendString:@", "];
			}

		}
		[label appendString:[[IAPersistenceManager sharedInstance].entityConfig labelForProperty:[aKeyArray objectAtIndex:i] inObject:self]];
	}
	return label;
}

- (BOOL)m_validateForSave:(NSError**)anError{
	// does nothing here, but the subclass can override and implement its own custom validation
	return YES;
}

- (void)m_willDelete{
	// does nothing here, but the subclass can override it
}

- (void)m_didDelete{
	// does nothing here, but the subclass can override it
}

- (BOOL) m_delete{
	return [[IAPersistenceManager sharedInstance] deleteObject:self];
}

- (BOOL) m_deleteAndSave{
	return [[IAPersistenceManager sharedInstance] deleteAndSaveObject:self];
}

- (BOOL)m_hasValueChangedForKey:(NSString*)a_key{
    return [self.changedValues objectForKey:a_key]!=nil;
}

- (NSNumber*)minimumValueForProperty:(NSString*)a_propertyName{
    return [self validationPredicateParameterProperty:a_propertyName string:@"SELF >= "];
}

- (NSNumber*)maximumValueForProperty:(NSString*)a_propertyName{
    return [self validationPredicateParameterProperty:a_propertyName string:@"SELF <= "];
}

+ (NSManagedObject*)m_instantiate{
	return [[IAPersistenceManager sharedInstance] instantiate:[self description]];
}

+ (NSMutableArray *)m_findAll{
    return [[IAPersistenceManager sharedInstance] findAllForEntity:[self entityName]];
}

+ (void)m_deleteAll{
    for (NSManagedObject *l_mo in [[IAPersistenceManager sharedInstance] findAllForEntity:[self entityName]]) {
        [l_mo m_delete];
    }
}

+ (void)m_deleteAllAndSave{
    [self m_deleteAll];
    [[IAPersistenceManager sharedInstance] save];
}

@end
