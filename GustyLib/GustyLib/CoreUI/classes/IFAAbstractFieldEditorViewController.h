//
//  IFAAbstractFieldEditorViewController.h
//  Gusty
//
//  Created by Marcelo Schroeder on 12/03/12.
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

#import "IFAViewController.h"
#import "UIViewController+IFA_KNSemiModal.h"

@protocol IFAPresenter;

@interface IFAAbstractFieldEditorViewController : IFAViewController <UIPopoverControllerDelegate, IFASemiModalViewDelegate> {
}

@property (nonatomic) BOOL useButtonForDismissal;
@property (nonatomic, strong, readonly) NSObject *object;
@property (nonatomic, strong, readonly) NSString *propertyName;

@property (nonatomic, strong, readonly) id originalValue;

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName;

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName
useButtonForDismissal:(BOOL)a_useButtonForDismissal presenter:(id <IFAPresenter>)a_presenter;
-(void)done;
-(void)updateModel;
-(BOOL)hasValueChanged;

// To be overriden by subclasses
-(id)editedValue;

@end
