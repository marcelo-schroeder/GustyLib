//
//  IFAConstants.h
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

@interface IFAConstants : NSObject {

}

extern CGFloat const IFA_k_TABLE_VIEW_EDITING_CELL_X_OFFSET;
extern CGFloat const IFA_k_TABLE_SECTION_HEADER_DEFAULT_HEIGHT;
extern CGFloat const IFA_k_FORM_SECTION_HEADER_DEFAULT_HEIGHT;
extern CGFloat const IFA_k_MINIMUM_TAP_AREA_DIMENSION;
extern CGFloat const IFA_k_TABLE_VIEW_CELL_SEPARATOR_DEFAULT_INSET_LEFT;
extern NSTimeInterval const IFA_k_UI_ANIMATION_DURATION;

extern NSString* const IFA_k_BUTTON_LABEL_SAVE;
extern NSString* const IFA_k_BUTTON_LABEL_CANCEL;

extern NSString* const IFA_k_ERROR_DOMAIN_COMMON;

extern NSString* const IFA_k_CACHE_KEY_ENTITY_CONFIG_DICTIONARY;
extern NSString* const IFA_k_CACHE_KEY_MENU_VIEW_CONTROLLERS_DICTIONARY;

// Notifications
extern NSString* const IFA_k_NOTIFICATION_PERSISTENT_ENTITY_CHANGE;
extern NSString* const IFA_k_NOTIFICATION_CONTEXT_SWITCH_REQUEST;
extern NSString* const IFA_k_NOTIFICATION_CONTEXT_SWITCH_REQUEST_GRANTED;
extern NSString* const IFA_k_NOTIFICATION_CONTEXT_SWITCH_REQUEST_DENIED;
extern NSString* const IFA_k_NOTIFICATION_NAVIGATION_EVENT;
extern NSString* const IFA_k_NOTIFICATION_MENU_BAR_BUTTON_ITEM_INVALIDATED;
extern NSString* const IFA_k_NOTIFICATION_LOCATION_AUTHORIZATION_STATUS_CHANGE;
extern NSString* const IFA_k_NOTIFICATION_ADS_SUSPEND_REQUEST;
extern NSString* const IFA_k_NOTIFICATION_ADS_RESUME_REQUEST;

// Dictionary Keys
extern NSString* const IFA_k_KEY_INSERTED_OBJECTS;
extern NSString* const IFA_k_KEY_UPDATED_OBJECTS;
extern NSString* const IFA_k_KEY_DELETED_OBJECTS;
extern NSString* const IFA_k_KEY_UPDATED_PROPERTIES;
extern NSString* const IFA_k_KEY_ORIGINAL_PROPERTIES;
extern NSString* const IFA_k_KEY_THREAD_SAFE_CALENDAR;
extern NSString* const IFA_k_KEY_SERIAL_QUEUE_MANAGED_OBJECT_CONTEXT;

// Entity Config
extern NSString* const IFA_k_ENTITY_CONFIG_FORM_NAME_DEFAULT;
extern NSString* const IFA_k_ENTITY_CONFIG_FORM_NAME_CREATION_SHORTCUT;

// Info Plist
extern NSString* const IFA_k_INFOPLIST_PREFERENCES_CLASS_NAME;

/* enums */

enum {

    IFA_k_ERROR_PERSISTENCE_VALIDATION = 1000,
    IFA_k_ERROR_PERSISTENCE_DUPLICATE_KEY = 1010,

    IFA_k_UIVIEW_TAG_ACTION_SHEET_CANCEL = 2000,
    IFA_k_UIVIEW_TAG_ACTION_SHEET_DELETE = 2010,
    IFA_k_UIVIEW_TAG_HELP_BACKGROUND = 2020,
    IFA_k_UIVIEW_TAG_HELP_FOREGROUND = 2030,
    IFA_k_UIVIEW_TAG_HELP_POP_TIP = 2040,
    IFA_k_UIVIEW_TAG_HELP_BUTTON = 2050,

    IFA_k_UIBAR_ITEM_TAG_HELP_BUTTON = 2500,
    IFA_k_UIBAR_ITEM_TAG_EDIT_BUTTON = 2510,
    IFA_k_UIBAR_ITEM_TAG_BACK_BUTTON = 2520, // custom back button
    IFA_k_UIBAR_ITEM_TAG_LEFT_SLIDING_PANE_BUTTON = 2530, // split view controller master on iPad, left under view on iPhone
    IFA_k_UIBAR_ITEM_TAG_FIXED_SPACE_BUTTON = 2540, // bar button item spacing automation

    IFA_k_UIBAR_BUTTON_ITEM_ADD = 3000,
    IFA_k_UIBAR_BUTTON_ITEM_DELETE = 3010,
    IFA_k_UIBAR_BUTTON_ITEM_SELECT_NONE = 3020,
    IFA_k_UIBAR_BUTTON_ITEM_CANCEL = 3030,
    IFA_k_UIBAR_BUTTON_ITEM_FLEXIBLE_SPACE = 3040,
    IFA_k_UIBAR_BUTTON_ITEM_DONE = 3050,
    IFA_k_UIBAR_BUTTON_PREVIOUS_PAGE = 3080,
    IFA_k_UIBAR_BUTTON_NEXT_PAGE = 3090,
    IFA_k_UIBAR_BUTTON_ITEM_SELECT_NOW = 3120,
    IFA_k_UIBAR_BUTTON_ITEM_FIXED_SPACE = 3170,
    IFA_k_UIBAR_BUTTON_ITEM_SELECT_ALL = 3180,
    IFA_k_UIBAR_BUTTON_ITEM_ACTION = 3210,
    IFA_k_UIBAR_BUTTON_ITEM_SELECT_TODAY = 3220,
    IFA_k_UIBAR_BUTTON_ITEM_REFRESH = 3230,
    IFA_k_UIBAR_BUTTON_ITEM_DISMISS = 3240,
    IFA_k_UIBAR_BUTTON_ITEM_BACK = 3250,
	
};

/* typedefs */

typedef enum {

    IFADurationFormatDecimalHours,
    IFADurationFormatHoursMinutes,
    IFADurationFormatHoursMinutesSeconds,
    IFADurationFormatFull,
    IFADurationFormatHoursMinutesLong,
    IFADurationFormatHoursMinutesSecondsLong,
    IFADurationFormatFullLong,

} IFADurationFormat;

typedef enum {

    IFAEditorTypeText,
    IFAEditorTypeDatePicker,
    IFAEditorTypeSelectionList,
    IFAEditorTypeForm,
    IFAEditorTypeSegmented,
    IFAEditorTypePicker,
    IFAEditorTypeSwitch,
    IFAEditorTypeNumber,
    IFAEditorTypeTimeInterval,
    IFAEditorTypeFullDateAndTime,
    IFAEditorTypeNotApplicable,

} IFAEditorType;

typedef enum {

    IFADataTypeTimeInterval,
    
} IFADataType;

typedef enum {
    IFAScrollPageLeftFar,
    IFAScrollPageLeftNear,
    IFAScrollPageCentre,
    IFAScrollPageRightNear,
    IFAScrollPageRightFar,
    IFAScrollPageInit,
} IFAScrollPage;

typedef enum IFATableSectionHeaderType : NSUInteger {
    IFATableSectionHeaderTypeList,
    IFATableSectionHeaderTypeForm,
} IFATableSectionHeaderType;

@end
