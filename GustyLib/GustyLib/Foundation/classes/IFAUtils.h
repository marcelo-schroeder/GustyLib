//
//  IFAUtils.h
//  Gusty
//
//  Created by Marcelo Schroeder on 14/08/09.
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

@class CLLocation;

@interface IFAUtils : NSObject {

}

+ (NSArray*) getPlistAsArray:(NSString *)pListName;
+ (NSArray*) getPlistAsArray:(NSString *)pListName bundle:(NSBundle*)a_bundle;
+ (NSDictionary*) getPlistAsDictionary:(NSString *)pListName;
+ (NSDictionary*) getPlistAsDictionary:(NSString *)pListName bundle:(NSBundle*)a_bundle;
+ (NSString*) getSetterNameFromPropertyName:(NSString *)propertyName;
+ (void) logBooleanWithLabel:(NSString*)a_label value:(BOOL)a_value;

+(NSDictionary*)infoPList;
+(NSDictionary*)infoPListForBundle:(NSBundle*)a_bundle;
+(NSString*)appName;
+(NSString*)appEdition;
+(NSString*)appVersion;
+(NSString*)appBuildNumber;
+(NSString*)appNameAndEdition;
+(NSString*)appVersionAndBuildNumber;
+(NSString*)appFullName;
+(NSString*)generateUuid;
+(void)forceCrash;
+(NSString*)stringFromResource:(NSString *)a_resourceName type:(NSString*)a_resourceType;
+(NSArray*)toArrayIfRequiredFromObject:(id)a_object;
+(BOOL)deviceSupportsVibration;
+(BOOL)nilOrEmptyForString:(NSString*)a_string;

/* the methods below are based on GCD main thread dispatch queues */
+(void)dispatchAsyncMainThreadBlock:(dispatch_block_t)a_block;
+(void)dispatchAsyncMainThreadBlock:(dispatch_block_t)a_block afterDelay:(NSTimeInterval)a_delay;
+(void)dispatchSyncMainThreadBlock:(dispatch_block_t)a_block;
+ (void)dispatchAsyncGlobalDefaultPriorityQueueBlock:(dispatch_block_t)a_block;
+ (void)dispatchAsyncGlobalQueueBlock:(dispatch_block_t)a_block priority:(dispatch_queue_priority_t)a_priority;

+(Class)classForPropertyNamed:(NSString *)a_propertyName inClass:(Class)a_class;
+(Class)classForPropertyNamed:(NSString *)a_propertyName inClassNamed:(NSString*)a_className;

// Inspect the provisioning profile "aps-environment" entry and determine whether it is running "development" or "production"
+(BOOL)isProductionAps;

+ (BOOL)isIOS7OrGreater;

+ (NSString *)hardwareType;

+ (NSString *)encodeForUrlByAddingPercentEscapesWithOriginalString:(NSString *)a_originalString;
+ (NSString *)encodeForUrlByAddingPercentEscapesIncludingReservedCharactersWithOriginalString:(NSString *)a_originalString;

@end
