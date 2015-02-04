//
//  IFACoreUiConstants.h
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

@interface IFACoreUiConstants : NSObject {

}

extern CGFloat const IFAMinimumTapAreaDimension;

/**
* Table view cell horizontal indentation in points when in edit mode.
*/
extern CGFloat const IFATableViewEditingCellXOffset;

/**
* Offset applied to a table view cell content view right side when a standard accessory view is visible.
*/
extern CGFloat const IFATableViewCellContentViewRightOffsetWhenStandardAccessoryIsVisible;

extern CGFloat const IFAFormSectionHeaderDefaultHeight;
extern CGFloat const IFATableViewCellSeparatorDefaultInsetLeft;
extern CGFloat const IFAIPhoneStatusBarDoubleHeight;
extern NSTimeInterval const IFAAnimationDuration;

extern NSString* const IFAButtonLabelSave;
extern NSString* const IFAButtonLabelCancel;

extern NSString* const IFACacheKeyEntityConfigDictionary;
extern NSString* const IFACacheKeyMenuViewControllersDictionary;

// Notifications
extern NSString* const IFANotificationPersistentEntityChange;
extern NSString* const IFANotificationContextSwitchRequest;
extern NSString* const IFANotificationContextSwitchRequestGranted;
extern NSString* const IFANotificationContextSwitchRequestDenied;
extern NSString* const IFANotificationMenuBarButtonItemInvalidated;
extern NSString* const IFANotificationLocationAuthorizationStatusChange;

// Dictionary Keys
extern NSString* const IFAKeyInsertedObjects;
extern NSString* const IFAKeyUpdatedObjects;
extern NSString* const IFAKeyDeletedObjects;
extern NSString* const IFAKeyUpdatedProperties;
extern NSString* const IFAKeyOriginalProperties;
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
    IFAViewTagHelpButton = 2050,

    IFABarItemTagHelpButton = 2500,
    IFABarItemTagEditButton = 2510,
    IFABarItemTagBackButton = 2520, // custom back button
    IFABarItemTagLeftSlidingPaneButton = 2530, // split view controller master on iPad, left under view on iPhone
    IFABarItemTagAutomatedSpacingButton = 2540, // bar button item spacing automation

};

/* typedefs */

typedef NS_ENUM(NSUInteger, IFABarButtonItemType){
    IFABarButtonItemTypeAdd,
    IFABarButtonItemTypeDelete,
    IFABarButtonItemTypeSelectNone,
    IFABarButtonItemTypeCancel,
    IFABarButtonItemTypeFlexibleSpace,
    IFABarButtonItemTypeDone,
    IFABarButtonItemTypePreviousPage,
    IFABarButtonItemTypeNextPage,
    IFABarButtonItemTypeSelectNow,
    IFABarButtonItemTypeFixedSpace,
    IFABarButtonItemTypeSelectAll,
    IFABarButtonItemTypeAction,
    IFABarButtonItemTypeSelectToday,
    IFABarButtonItemTypeRefresh,
    IFABarButtonItemTypeDismiss,
    IFABarButtonItemTypeBack,
    IFABarButtonItemTypeInfo,
    IFABarButtonItemTypeUserLocation,
    IFABarButtonItemTypeList,
};

typedef NS_ENUM(NSUInteger, IFAEditorType) {

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

};

typedef NS_ENUM(NSUInteger, IFADataType) {

    IFADataTypeTimeInterval,
    
};

typedef NS_ENUM(NSUInteger, IFAScrollPage) {
    IFAScrollPageLeftFar,
    IFAScrollPageLeftNear,
    IFAScrollPageCentre,
    IFAScrollPageRightNear,
    IFAScrollPageRightFar,
    IFAScrollPageInit,
};

@end
