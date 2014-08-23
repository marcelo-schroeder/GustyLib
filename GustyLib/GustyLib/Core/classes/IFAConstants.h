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

static CGFloat const IFATableViewEditingCellXOffset = 38;
static CGFloat const IFATableSectionHeaderDefaultHeight = 22;
static CGFloat const IFAFormSectionHeaderDefaultHeight = 39;
static CGFloat const IFAMinimumTapAreaDimension = 44;
static CGFloat const IFATableViewCellSeparatorDefaultInsetLeft = 15;
static NSTimeInterval const IFAAnimationDuration = 0.3;

@interface IFAConstants : NSObject {

}

extern NSString* const IFAButtonLabelSave;
extern NSString* const IFAButtonLabelCancel;

extern NSString* const IFAErrorDomainCommon;

extern NSString* const IFACacheKeyEntityConfigDictionary;
extern NSString* const IFACacheKeyMenuViewControllersDictionary;

// Notifications
extern NSString* const IFANotificationPersistentEntityChange;
extern NSString* const IFANotificationContextSwitchRequest;
extern NSString* const IFANotificationContextSwitchRequestGranted;
extern NSString* const IFANotificationContextSwitchRequestDenied;
extern NSString* const IFANotificationNavigationEvent;
extern NSString* const IFANotificationMenuBarButtonItemInvalidated;
extern NSString* const IFANotificationLocationAuthorizationStatusChange;

// Dictionary Keys
extern NSString* const IFAKeyInsertedObjects;
extern NSString* const IFAKeyUpdatedObjects;
extern NSString* const IFAKeyDeletedObjects;
extern NSString* const IFAKeyUpdatedProperties;
extern NSString* const IFAKeyOriginalProperties;
extern NSString* const IFAKeyThreadSafeCalendar;
extern NSString* const IFAKeySerialQueueManagedObjectContext;

// Entity Config
extern NSString* const IFAEntityConfigFormNameDefault;
extern NSString* const IFAEntityConfigFormNameCreationShortcut;

// Info Plist
extern NSString* const IFAInfoPListPreferencesClassName;

/* enums */

enum {

    IFAErrorPersistenceValidation = 1000,
    IFAErrorPersistenceDuplicateKey = 1010,

    IFAViewTagActionSheetCancel = 2000,
    IFAViewTagActionSheetDelete = 2010,
    IFAViewTagHelpBackground = 2020,
    IFAViewTagHelpForeground = 2030,
    IFAViewTagHelpPopTip = 2040,
    IFAViewTagHelpButton = 2050,

    IFABarItemTagHelpButton = 2500,
    IFABarItemTagEditButton = 2510,
    IFABarItemTagBackButton = 2520, // custom back button
    IFABarItemTagLeftSlidingPaneButton = 2530, // split view controller master on iPad, left under view on iPhone
    IFABarItemTagAutomatedSpacingButton = 2540, // bar button item spacing automation

    IFABarButtonItemAdd = 3000,
    IFABarButtonItemDelete = 3010,
    IFABarButtonItemSelectNone = 3020,
    IFABarButtonItemCancel = 3030,
    IFABarButtonItemFlexibleSpace = 3040,
    IFABarButtonItemDone = 3050,
    IFABarButtonItemPreviousPage = 3080,
    IFABarButtonItemNextPage = 3090,
    IFABarButtonItemSelectNow = 3120,
    IFABarButtonItemFixedSpace = 3170,
    IFABarButtonItemSelectAll = 3180,
    IFABarButtonItemAction = 3210,
    IFABarButtonItemSelectToday = 3220,
    IFABarButtonItemRefresh = 3230,
    IFABarButtonItemDismiss = 3240,
    IFABarButtonItemBack = 3250,
	
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
