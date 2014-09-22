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

//wip: add missing documentation
//wip: clean up
#import <Foundation/Foundation.h>

typedef enum {
    IFAFormHelpTypeHeader,
    IFAFormHelpTypeFooter,
}IFAFormHelpType;

typedef enum {
    IFAFormSectionHelpTypeHeader,
    IFAFormSectionHelpTypeFooter,
}IFAFormSectionHelpType;

@interface IFAHelpManager : NSObject

@property (nonatomic, strong, readonly) UIViewController *helpTargetViewController;

-(void)toggleHelpModeForViewController:(UIViewController *)a_viewController;

-(UIBarButtonItem*)newHelpBarButtonItemForViewController:(UIViewController *)a_viewController;
-(BOOL)isHelpEnabledForViewController:(UIViewController*)a_viewController;

//wip: do I really need the complexity of having the type here? (header/footer) - doesn't the help make sense only as a footer?
/**
* @returns Form section help text.
*/
- (NSString *)formSectionHelpForType:(IFAFormSectionHelpType)a_helpType entityName:(NSString *)a_entityName
                            formName:(NSString *)a_formName sectionName:(NSString *)a_sectionName
                          createMode:(BOOL)a_createMode;

/**
* @returns Help text for a given property in a given entity.
*/
- (NSString *)helpForPropertyName:(NSString *)a_propertyName inEntityName:(NSString *)a_entityName;

- (NSString *)emptyListHelpForEntityName:(NSString *)a_entityName;

//wip: do I still need this? Have I encountered any cases of help at the form level?
- (NSString *)formHelpForType:(IFAFormHelpType)a_helpType
                   entityName:(NSString *)a_entityName
                     formName:(NSString *)a_formName;

+ (instancetype)sharedInstance;

@end
