//
//  IFAHelpManager.h
//  GustyLib
//
//  Created by Marcelo Schroeder on 22/03/12.
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

#import <Foundation/Foundation.h>
#import "IFAPresenter.h"

/**
* Manages help mode and assists with retrieving help text used throughout the app.
*/
@interface IFAHelpManager : NSObject

/**
* Current help target view controller when in help mode.
*/
@property (nonatomic, strong, readonly) UIViewController *helpTargetViewController;

/**
* Toggles help mode on and off.
* @param a_viewController View controller help mode is targetting.
*/
-(void)toggleHelpModeForViewController:(UIViewController *)a_viewController;

/**
* @param a_viewController View controller help mode will target.
* @param a_selected YES for the selected version of the help button (i.e. help mode on). NO for the unselected version of the help button (i.e. help mode off).
* @returns Help button used on navigation bars.
*/
- (UIBarButtonItem *)newHelpBarButtonItemForViewController:(UIViewController *)a_viewController
                                                  selected:(BOOL)a_selected;

/**
* @param a_viewController View controller to check if help mode should be enabled for.
* @returns Indicates whether help should be available for the given view controller.
*/
-(BOOL)shouldEnableHelpForViewController:(UIViewController*)a_viewController;

/**
* Help text for section obtained from GustyLibHelpLocalizable.strings.
* GustyLibHelpLocalizable.strings entry key format:
*   entities.<entityName>.forms.<formName>.sections.<sectionName>.modes.(any|create).description
* @param a_sectionName Name of the section the help is for.
* @param a_formName Name of the form the help is for.
* @param a_entityName Name of the persistent entity the help is for.
* @param a_createMode Whether the help is for creation mode or not.
* @returns Form section help in plain text format.
*/
- (NSString *)helpForSectionNamed:(NSString *)a_sectionName
                      inFormNamed:(NSString *)a_formName
                       createMode:(BOOL)a_createMode
                      entityNamed:(NSString *)a_entityName;

/**
* Help text for property obtained from GustyLibHelpLocalizable.strings.
* GustyLibHelpLocalizable.strings entry key format at property level:
*   entities.<entityName>.properties.<propertyName>.description
* GustyLibHelpLocalizable.strings entry key format at property value level:
*   entities.<entityName>.properties.<propertyName>.values.<value>.description
* @param a_propertyName Name of the property to get the help text for.
* @param a_entityName Name of entity the property belongs to.
* @param a_value Optional. Provide if help for specific value is required. This is useful for input controls such as switches and pickers, where the help text may change depending on the value selected by the user.
* @returns Property help in plain text format.
*/
- (NSString *)helpForPropertyName:(NSString *)a_propertyName
                     inEntityName:(NSString *)a_entityName
                            value:(NSString *)a_value;

/**
* Help text for empty list obtained from GustyLibHelpLocalizable.strings.
* GustyLibHelpLocalizable.strings entry key format:
*   entities.<entityName>.list.placeholder.description
* @param a_entityName Name of the persistent entity the help text is for.
* @returns Empty list help in plain text format.
*/
- (NSString *)emptyListHelpForEntityName:(NSString *)a_entityName;

/**
* Help text for view controllers obtained from GustyLibHelpLocalizable.strings.
* This help text is presented in the modal view shown when tapping the help button.
* GustyLibHelpLocalizable.strings entry key format:
*   entities.<entityName>.description
* @param a_viewController View controller the help text is for.
* @returns View controller help in HTML format.
*/
- (NSString *)helpForViewController:(UIViewController *)a_viewController;

/**
* Provides the key prefix used for persistent entity related entries in GustyLibHelpLocalizable.strings.
* @param a_entityName Name of the entity to provide the help target ID for.
* @returns Help target ID for the given entity name.
*/
- (NSString *)helpTargetIdForEntityNamed:(NSString *)a_entityName;

+ (instancetype)sharedInstance;

@end
