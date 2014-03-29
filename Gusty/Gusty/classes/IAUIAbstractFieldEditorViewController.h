//
//  IAUIFieldEditorViewController.h
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

#import "IAUIViewController.h"

@protocol IAUIPresenter;

@interface IAUIAbstractFieldEditorViewController : IAUIViewController <UIPopoverControllerDelegate> {
}

@property (nonatomic) BOOL p_useButtonForDismissal;
@property (nonatomic, strong, readonly) NSObject *p_object;
@property (nonatomic, strong, readonly) NSString *p_propertyName;

@property (nonatomic, strong, readonly) id p_originalValue;

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName;

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName
useButtonForDismissal:(BOOL)a_useButtonForDismissal presenter:(id <IAUIPresenter>)a_presenter;
-(void)m_done;
-(void)m_updateModel;
-(BOOL)m_hasValueChanged;

// To be overriden by subclasses
-(id)m_editedValue;

@end
