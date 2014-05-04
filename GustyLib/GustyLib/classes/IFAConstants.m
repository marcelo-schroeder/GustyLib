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

CGFloat const IFA_k_TABLE_VIEW_EDITING_CELL_X_OFFSET = 32;
CGFloat const IFA_k_TABLE_SECTION_HEADER_DEFAULT_HEIGHT = 22;
CGFloat const IFA_k_FORM_SECTION_HEADER_DEFAULT_HEIGHT = 39;
CGFloat const IFA_k_MINIMUM_TAP_AREA_DIMENSION = 44;
CGFloat const IFA_k_TABLE_VIEW_CELL_SEPARATOR_DEFAULT_INSET_LEFT = 15;
NSTimeInterval const IFA_k_UI_ANIMATION_DURATION = 0.3;

NSString* const IFA_k_BUTTON_LABEL_SAVE = @"Save";
NSString* const IFA_k_BUTTON_LABEL_CANCEL = @"Cancel";

NSString* const IFA_k_ERROR_DOMAIN_COMMON = @"IaCommonErrorDomain";

NSString* const IFA_k_CACHE_KEY_ENTITY_CONFIG_DICTIONARY = @"ia.entityConfigDictionary";
NSString* const IFA_k_CACHE_KEY_MENU_VIEW_CONTROLLERS_DICTIONARY = @"ia.menuViewControllersDictionary";

// Notifications
NSString* const IFA_k_NOTIFICATION_PERSISTENT_ENTITY_CHANGE = @"ia.persistentEntityChange";
NSString* const IFA_k_NOTIFICATION_CONTEXT_SWITCH_REQUEST = @"ia.contextSwitchRequest";
NSString* const IFA_k_NOTIFICATION_CONTEXT_SWITCH_REQUEST_GRANTED = @"ia.contextSwitchRequestGranted";
NSString* const IFA_k_NOTIFICATION_CONTEXT_SWITCH_REQUEST_DENIED = @"ia.contextSwitchRequestDenied";
NSString* const IFA_k_NOTIFICATION_NAVIGATION_EVENT = @"ia.navigationEvent";
NSString* const IFA_k_NOTIFICATION_MENU_BAR_BUTTON_ITEM_INVALIDATED = @"ia.menuBarButtonItemInvalidated";
NSString* const IFA_k_NOTIFICATION_LOCATION_AUTHORIZATION_STATUS_CHANGE = @"ia.locationAuthorizationStatusChange";
NSString* const IFA_k_NOTIFICATION_ADS_SUSPEND_REQUEST = @"ia.adsSuspendRequest";
NSString* const IFA_k_NOTIFICATION_ADS_RESUME_REQUEST = @"ia.adsResumeRequest";

// Dictionary Keys
NSString* const IFA_k_KEY_INSERTED_OBJECTS = @"ia.key.insertedObjects";
NSString* const IFA_k_KEY_UPDATED_OBJECTS = @"ia.key.updatedObjects";
NSString* const IFA_k_KEY_DELETED_OBJECTS = @"ia.key.deletedObjects";
NSString* const IFA_k_KEY_UPDATED_PROPERTIES = @"ia.key.updatedProperties";
NSString* const IFA_k_KEY_ORIGINAL_PROPERTIES = @"ia.key.originalProperties";
NSString* const IFA_k_KEY_THREAD_SAFE_CALENDAR = @"ia.key.threadSafeCalendar";
NSString* const IFA_k_KEY_SERIAL_QUEUE_MANAGED_OBJECT_CONTEXT = @"ia.key.serialQueueManagedObjectContext";

// Entity Config
NSString* const IFA_k_ENTITY_CONFIG_FORM_NAME_DEFAULT = @"main";
NSString* const IFA_k_ENTITY_CONFIG_FORM_NAME_CREATION_SHORTCUT = @"creationShortcut";

// Entity Config
NSString* const IFA_k_INFOPLIST_PREFERENCES_CLASS_NAME = @"IAPreferencesClassName";

@end
