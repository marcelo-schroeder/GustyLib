//
// Created by Marcelo Schroeder on 18/03/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
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

#import <Foundation/Foundation.h>

/**
* This class tracks changes to the main parent managed object context and offers convenient ways to check if changes occurred.
*/
@interface IFAPersistenceChangeDetector : NSObject

/**
* Returns YES if changes occurred since the first time <enabled> was set to YES or since the <reset> method was called, otherwise NO.
*/
@property(nonatomic, readonly) BOOL changed;

/**
* Dictionary containing all changes tracked since the first time <enabled> was set to YES or since the <reset> method was called, otherwise NO.
* Dictionary entries are structured as follows:
* 
* - key: persistent entity name
* - value: NSArray instance containing changes in the same format as the userInfo dictionary provided by the IFANotificationPersistentEntityChange notification.
*/
@property(nonatomic, readonly) NSMutableDictionary *persistentEntityChangeNotificationUserInfoDictionariesByEntityName;

/**
* Set to YES to enable change tracking.
* Default value: NO.
*/
@property (nonatomic) BOOL enabled;

/**
* Call this method to "forget" any changes tracked so far. 
*/
- (void)reset;

/**
* Determines if changes for a given NSManagedObject instance have occurred since the first time <enabled> was set to YES or since the <reset> method was called.
* @param a_managedObject Managed object instance being enquired about.
* @returns YES if changes for a_managedObject have occurred since the first time <enabled> was set to YES or since the <reset> method was called.
*/
- (BOOL)changedForManagedObject:(NSManagedObject *)a_managedObject;

@end