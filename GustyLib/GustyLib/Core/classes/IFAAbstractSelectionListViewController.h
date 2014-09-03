//
//  IFAAbstractSelectionListViewController.h
//  Gusty
//
//  Created by Marcelo Schroeder on 10/01/11.
//  Copyright 2011 InfoAccent Pty Limited. All rights reserved.
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

#import "IFAListViewController.h"

@interface IFAAbstractSelectionListViewController : IFAListViewController <UIPopoverControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *selectNoneButtonItem;

@property(nonatomic, weak, readonly) NSManagedObject *managedObject;
@property(nonatomic, strong, readonly) NSString *propertyName;
@property(nonatomic, weak, readonly) IFAFormViewController *formViewController;

- (id)initWithManagedObject:(NSManagedObject *)a_managedObject propertyName:(NSString *)a_propertyName
         formViewController:(IFAFormViewController *)a_formViewController;

- (void)onSelectNoneButtonTap:(id)sender;
- (void)done;
- (void)updateUiState;

@end
