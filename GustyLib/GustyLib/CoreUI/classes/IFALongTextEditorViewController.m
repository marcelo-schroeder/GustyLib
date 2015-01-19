//
//  IFALongTextEditorViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 2/06/12.
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

@interface IFALongTextEditorViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation IFALongTextEditorViewController


#pragma mark - Private

#pragma mark - Overrides

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName
useButtonForDismissal:(BOOL)a_useButtonForDismissal presenter:(id <IFAPresenter>)a_presenter {
    
    if (self= [super initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:a_useButtonForDismissal
                          presenter:a_presenter]) {
        
        // Configure text view
        self.textView = [UITextView new];
        self.textView.text = [self.object valueForKey:self.propertyName];
        self.textView.autoresizingMask = [IFAUIUtils fullAutoresizingMask];
        self.textView.font = [self.textView.font fontWithSize:14];
        [self.view addSubview:self.textView];
        
    }
    
    return self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.textView.frame = self.view.frame;
    [self.textView becomeFirstResponder];
}

-(id)editedValue {
    return self.textView.text;
}

-(BOOL)ifa_hasFixedSize {
    return NO;
}

- (BOOL)hasValueChanged {
	NSString* l_oldText = self.originalValue;
	NSString* l_newText = [self editedValue];
    return ( l_oldText==nil && [l_newText isEqualToString:@""] ? NO : ![l_newText isEqualToString:l_oldText] );
}

@end
