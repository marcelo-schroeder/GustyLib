//
//  IFAAbstractFieldEditorViewController.m
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

#import "GustyLibCoreUI.h"

@interface IFAAbstractFieldEditorViewController ()

@property (nonatomic, strong) id originalValue;
@property (nonatomic, strong) NSObject *object;
@property (nonatomic, strong) NSString *propertyName;

@end

@implementation IFAAbstractFieldEditorViewController


#pragma mark - Private

#pragma mark - Public

- (id)initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName{
    return [self initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:YES presenter:nil];
}

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName
useButtonForDismissal:(BOOL)a_useButtonForDismissal presenter:(id <IFAPresenter>)a_presenter {
    
    if ((self = [super init])) {
		
        self.ifa_presenter = a_presenter;
		self.object = anObject;
		self.propertyName = aPropertyName;
        self.useButtonForDismissal = a_useButtonForDismissal;
        
        self.originalValue = [self.object valueForKey:self.propertyName];
		
		self.editing = YES;
        
        self.title = [[IFAPersistenceManager sharedInstance].entityConfig labelForProperty:self.propertyName
                                                                                 inObject:self.object];
        
        self.modalInPopover = self.useButtonForDismissal;
        
	}
    
	return self;
    
}

-(void)updateModel {
    [self.object ifa_setValue:[self editedValue] forProperty:self.propertyName];
    [self.ifa_presenter changesMadeByViewController:self];
}

- (BOOL)hasValueChanged {
//    NSLog(@"hasValueChanged - old: %@, new: %@", [self.originalValue description], [[self editedValue] description]);
    return ![self.originalValue isEqual:[self editedValue]];
}

-(void)done {
    [self ifa_notifySessionCompletionWithChangesMade:[self hasValueChanged] data:nil ];
}

// To be overriden by subclasses
-(id)editedValue {
    return nil;
}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (![IFAUIUtils isIPad] && self.useButtonForDismissal) {
        self.editButtonItem.tag = IFABarItemTagEditButton;
        [self ifa_addLeftBarButtonItem:[self editButtonItem]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
	if(editing){
		[super setEditing:editing animated:animated];
        [[self ifa_appearanceTheme] setAppearanceForBarButtonItem:self.editButtonItem viewController:nil important:YES ];
//		self.navigationItem.rightBarButtonItem.accessibilityLabel = self.navigationItem.rightBarButtonItem.title;
	}else{
        [self done];
	}
}

#pragma mark - UIPopoverControllerDelegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [self done];
}

#pragma mark - IFASemiModalViewDelegate

- (BOOL)shouldDismissOnTapOutsideForSemiModalView:(UIView *)a_semiModalView {
    return NO;
}

@end
