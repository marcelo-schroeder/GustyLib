//
//  NSManagedObject+IFACategory.m
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

#import "GustyLibCoreUI.h"

@implementation NSManagedObject (IFACoreUI)

#pragma mark - Private

- (NSNumber*)validationPredicateParameterProperty:(NSString*)a_propertyName string:(NSString*)a_string{
    NSNumber *l_value = nil;
    for (NSPredicate *l_validationPredicate in [[self ifa_descriptionForProperty:a_propertyName] validationPredicates]) {
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

-(NSString*)ifa_stringId {
    return [self.ifa_urlId description];
}

-(NSURL*)ifa_urlId {
    return [[self objectID] URIRepresentation];
}

- (NSString*)ifa_labelForKeys:(NSArray*)aKeyArray{
	NSMutableString *label = [NSMutableString string];
	for (int i = 0; i < [aKeyArray count]; i++) {
		if (i>0) {
			if (i==([aKeyArray count]-1)) {
				[label appendString:@" and "];
			}else {
				[label appendString:@", "];
			}

		}
		[label appendString:[[IFAPersistenceManager sharedInstance].entityConfig labelForProperty:[aKeyArray objectAtIndex:i] inObject:self]];
	}
	return label;
}

- (BOOL)ifa_validateForSave:(NSError**)anError{
	// does nothing here, but the subclass can override and implement its own custom validation
	return YES;
}

- (void)ifa_willDelete {
	// does nothing here, but the subclass can override it
}

- (void)ifa_didDelete {
	// does nothing here, but the subclass can override it
}

- (BOOL)ifa_deleteWithValidationAlertPresenter:(UIViewController *)a_validationAlertPresenter {
	return [[IFAPersistenceManager sharedInstance] deleteObject:self validationAlertPresenter:a_validationAlertPresenter];
}

- (BOOL)ifa_deleteAndSaveWithValidationAlertPresenter:(UIViewController *)a_validationAlertPresenter {
	return [[IFAPersistenceManager sharedInstance] deleteAndSaveObject:self validationAlertPresenter:a_validationAlertPresenter];
}

- (BOOL)ifa_hasValueChangedForKey:(NSString*)a_key{
    return [self.changedValues objectForKey:a_key]!=nil;
}

- (NSNumber*)ifa_minimumValueForProperty:(NSString*)a_propertyName{
    return [self validationPredicateParameterProperty:a_propertyName string:@"SELF >= "];
}

- (NSNumber*)ifa_maximumValueForProperty:(NSString*)a_propertyName{
    return [self validationPredicateParameterProperty:a_propertyName string:@"SELF <= "];
}

+ (NSManagedObject*)ifa_instantiate {
	return [[IFAPersistenceManager sharedInstance] instantiate:[self description]];
}

+ (NSMutableArray *)ifa_findAll {
    return [[IFAPersistenceManager sharedInstance] findAllForEntity:[self ifa_entityName]];
}

+ (void)ifa_deleteAllWithValidationAlertPresenter:(UIViewController *)a_validationAlertPresenter {
    for (NSManagedObject *l_mo in [[IFAPersistenceManager sharedInstance] findAllForEntity:[self ifa_entityName]]) {
        [l_mo ifa_deleteWithValidationAlertPresenter:a_validationAlertPresenter];
    }
}

+ (void)ifa_deleteAllAndSaveWithValidationAlertPresenter:(UIViewController *)a_validationAlertPresenter {
    [self ifa_deleteAllWithValidationAlertPresenter:a_validationAlertPresenter];
    [[IFAPersistenceManager sharedInstance] save];
}

@end
