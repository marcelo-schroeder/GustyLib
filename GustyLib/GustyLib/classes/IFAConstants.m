//
//  IFAConstants.m
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

#import "IFACommon.h"


@implementation IFAConstants

NSString* const IA_BUTTON_LABEL_SAVE = @"Save";
NSString* const IA_BUTTON_LABEL_CANCEL = @"Cancel";

NSString* const IA_ERROR_DOMAIN_COMMON = @"IaCommonErrorDomain";

NSString* const IA_CACHE_KEY_ENTITY_CONFIG_DICTIONARY = @"ia.entityConfigDictionary";
NSString* const IA_CACHE_KEY_MENU_VIEW_CONTROLLERS_DICTIONARY = @"ia.menuViewControllersDictionary";

// Notifications
NSString* const IA_NOTIFICATION_PERSISTENT_ENTITY_CHANGE = @"ia.persistentEntityChange";
NSString* const IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST = @"ia.contextSwitchRequest";
NSString* const IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST_GRANTED = @"ia.contextSwitchRequestGranted";
NSString* const IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST_DENIED = @"ia.contextSwitchRequestDenied";
NSString* const IA_NOTIFICATION_NAVIGATION_EVENT = @"ia.navigationEvent";
NSString* const IA_NOTIFICATION_MENU_BAR_BUTTON_ITEM_INVALIDATED = @"ia.menuBarButtonItemInvalidated";
NSString* const IA_NOTIFICATION_LOCATION_AUTHORIZATION_STATUS_CHANGE = @"ia.locationAuthorizationStatusChange";
NSString* const IA_NOTIFICATION_ADS_SUSPEND_REQUEST = @"ia.adsSuspendRequest";
NSString* const IA_NOTIFICATION_ADS_RESUME_REQUEST = @"ia.adsResumeRequest";

// Dictionary Keys
NSString* const IA_KEY_INSERTED_OBJECTS = @"ia.key.insertedObjects";
NSString* const IA_KEY_UPDATED_OBJECTS = @"ia.key.updatedObjects";
NSString* const IA_KEY_DELETED_OBJECTS = @"ia.key.deletedObjects";
NSString* const IA_KEY_UPDATED_PROPERTIES = @"ia.key.updatedProperties";
NSString* const IA_KEY_ORIGINAL_PROPERTIES = @"ia.key.originalProperties";
NSString* const IA_KEY_THREAD_SAFE_CALENDAR = @"ia.key.threadSafeCalendar";
NSString* const IA_KEY_SERIAL_QUEUE_MANAGED_OBJECT_CONTEXT = @"ia.key.serialQueueManagedObjectContext";

// Entity Config
NSString* const IA_ENTITY_CONFIG_FORM_NAME_DEFAULT = @"main";
NSString* const IA_ENTITY_CONFIG_FORM_NAME_CREATION_SHORTCUT = @"creationShortcut";

// Entity Config
NSString* const IA_INFOPLIST_PREFERENCES_CLASS_NAME = @"IAPreferencesClassName";

@end
