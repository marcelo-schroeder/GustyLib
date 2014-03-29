//
//  IAUIFieldEditorViewController.m
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

#import "IACommon.h"

@interface IAUIAbstractFieldEditorViewController ()

@property (nonatomic, strong) id p_originalValue;
@property (nonatomic, strong) NSObject *p_object;
@property (nonatomic, strong) NSString *p_propertyName;

@end

@implementation IAUIAbstractFieldEditorViewController


#pragma mark - Private

#pragma mark - Public

- (id)initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName{
    return [self initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:NO presenter:nil ];
}

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName
useButtonForDismissal:(BOOL)a_useButtonForDismissal presenter:(id <IAUIPresenter>)a_presenter {
    
    if ((self = [super init])) {
		
        self.p_presenter = a_presenter;
		self.p_object = anObject;
		self.p_propertyName = aPropertyName;
        self.p_useButtonForDismissal = a_useButtonForDismissal;
        
        self.p_originalValue = [self.p_object valueForKey:self.p_propertyName];
		
		self.editing = YES;
        
        self.title = [[IAPersistenceManager instance].entityConfig labelForProperty:self.p_propertyName inObject:self.p_object];
        
        self.modalInPopover = self.p_useButtonForDismissal;
        
	}
    
	return self;
    
}

-(void)m_updateModel{
    [self.p_object setValue:[self m_editedValue] forProperty:self.p_propertyName];
    [self.p_presenter m_changesMadeByViewController:self];
}

- (BOOL)m_hasValueChanged {
//    NSLog(@"m_hasValueChanged - old: %@, new: %@", [self.p_originalValue description], [[self m_editedValue] description]);
    return ![self.p_originalValue isEqual:[self m_editedValue]];
}

-(void)m_done{
    [self m_notifySessionCompletionWithChangesMade:[self m_hasValueChanged] data:nil ];
}

// To be overriden by subclasses
-(id)m_editedValue{
    return nil;
}

#pragma mark - Overrides

- (BOOL)contextSwitchRequestRequiredInEditMode{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![IAUIUtils m_isIPad] && self.p_useButtonForDismissal) {
        self.editButtonItem.tag = IA_UIBAR_ITEM_TAG_EDIT_BUTTON;
        [self m_addRightBarButtonItem:[self editButtonItem]];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
	if(editing){
		[super setEditing:editing animated:animated];
        [[self m_appearanceTheme] m_setAppearanceForBarButtonItem:self.editButtonItem viewController:nil important:YES ];
//		self.navigationItem.rightBarButtonItem.accessibilityLabel = self.navigationItem.rightBarButtonItem.title;
	}else{
        [self m_done];
	}
}

#pragma mark - UIPopoverControllerDelegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [self m_done];
}

@end
