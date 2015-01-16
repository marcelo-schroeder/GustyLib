//
//  NSObject+IFACategory.h
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

@class NSPropertyDescription;

@interface NSObject (IFACoreUI)

/**
* Used for common initialisation.
* To be called by init methods.
* Subclasses can override this.
*/
- (void)ifa_commonInit;

- (id)ifa_propertyValueForIndexPath:(NSIndexPath *)anIndexPath inForm:(NSString *)aFormName createMode:(BOOL)aCreateMode;
- (NSString*)ifa_propertyNameForIndexPath:(NSIndexPath *)anIndexPath inForm:(NSString *)aFormName createMode:(BOOL)aCreateMode;
- (NSString*)ifa_propertyStringValueForName:(NSString *)a_propertyName calendar:(NSCalendar *)a_calendar value:(id)a_value;
- (NSString*)ifa_propertyStringValueForName:(NSString *)a_propertyName calendar:(NSCalendar*)a_calendar;
- (NSString*)ifa_propertyStringValueForIndexPath:(NSIndexPath *)anIndexPath inForm:(NSString *)aFormName
                                      createMode:(BOOL)aCreateMode calendar:(NSCalendar*)a_calendar;
- (NSString*)ifa_displayValue;
- (NSString*)ifa_longDisplayValue;
- (NSString*)ifa_entityLabel;
- (void)ifa_setValue:(id)aValue forProperty:(NSString *)aKey;
- (NSString*)ifa_entityName;
- (NSPropertyDescription*)ifa_descriptionForProperty:(NSString*)aPropertyName;
- (NSString*)ifa_labelForProperty:(NSString*)aPropertyName;
- (NSUInteger)ifa_fractionDigitsForProperty:(NSString*)aPropertyName;
- (NSNumberFormatter*)ifa_numberFormatterForProperty:(NSString*)aPropertyName;
- (NSNumber*)ifa_minimumValueForProperty:(NSString*)a_propertyName;
- (NSNumber*)ifa_maximumValueForProperty:(NSString*)a_propertyName;

+ (NSString*)ifa_displayValueForNil;

@end
