//
//  IFACoreUiConstants.m
//  Gusty
//
//  Created by Marcelo Schroeder on 24/06/10.
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

@implementation IFACoreUiConstants

CGFloat const IFAMinimumTapAreaDimension = 44;
CGFloat const IFATableViewEditingCellXOffset = 38;
CGFloat const IFATableViewCellContentViewRightOffsetWhenStandardAccessoryIsVisible = -33;
CGFloat const IFAFormSectionHeaderDefaultHeight = 39;
CGFloat const IFATableViewCellSeparatorDefaultInsetLeft = 15;
CGFloat const IFAIPhoneStatusBarDoubleHeight = 40;
NSTimeInterval const IFAAnimationDuration = 0.5;

NSString* const IFAButtonLabelSave = @"Save";
NSString* const IFAButtonLabelCancel = @"Cancel";

NSString* const IFACacheKeyEntityConfigDictionary = @"ifa.entityConfigDictionary";
NSString* const IFACacheKeyMenuViewControllersDictionary = @"ifa.menuViewControllersDictionary";

// Notifications
NSString* const IFANotificationPersistentEntityChange = @"ifa.persistentEntityChange";
NSString* const IFANotificationContextSwitchRequest = @"ifa.contextSwitchRequest";
NSString* const IFANotificationContextSwitchRequestGranted = @"ifa.contextSwitchRequestGranted";
NSString* const IFANotificationContextSwitchRequestDenied = @"ifa.contextSwitchRequestDenied";
NSString* const IFANotificationMenuBarButtonItemInvalidated = @"ifa.menuBarButtonItemInvalidated";
NSString* const IFANotificationLocationAuthorizationStatusChange = @"ifa.locationAuthorizationStatusChange";

// Dictionary Keys
NSString* const IFAKeyInsertedObjects = @"ifa.key.insertedObjects";
NSString* const IFAKeyUpdatedObjects = @"ifa.key.updatedObjects";
NSString* const IFAKeyDeletedObjects = @"ifa.key.deletedObjects";
NSString* const IFAKeyUpdatedProperties = @"ifa.key.updatedProperties";
NSString* const IFAKeyOriginalProperties = @"ifa.key.originalProperties";
NSString* const IFAKeySerialQueueManagedObjectContext = @"ifa.key.serialQueueManagedObjectContext";

// Entity Config
NSString* const IFAEntityConfigFormNameDefault = @"main";
NSString* const IFAEntityConfigFormNameCreationShortcut = @"creationShortcut";

// Entity Config
NSString* const IFAInfoPListPreferencesClassName = @"IFAPreferencesClassName";

@end
