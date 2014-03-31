//
//  IAUILongTextEditorViewController.m
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

#import "IAUILongTextEditorViewController.h"

@interface IAUILongTextEditorViewController ()

@property (nonatomic, strong) UITextView *p_textView;

@end

@implementation IAUILongTextEditorViewController


#pragma mark - Private

#pragma mark - Overrides

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName
useButtonForDismissal:(BOOL)a_useButtonForDismissal presenter:(id <IAUIPresenter>)a_presenter {
    
    if (self= [super initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:a_useButtonForDismissal
                          presenter:a_presenter]) {
        
        // Configure text view
        self.p_textView = [UITextView new];
        self.p_textView.text = [self.p_object valueForKey:self.p_propertyName];
        self.p_textView.autoresizingMask = [IAUIUtils m_fullAutoresizingMask];
        self.p_textView.font = [self.p_textView.font fontWithSize:14];
        [self.view addSubview:self.p_textView];
        
    }
    
    return self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.p_textView.frame = self.view.frame;
    [self.p_textView becomeFirstResponder];
}

-(id)m_editedValue{
    return self.p_textView.text;
}

-(BOOL)m_hasFixedSize{
    return NO;
}

- (BOOL)m_hasValueChanged {
	NSString* l_oldText = self.p_originalValue;
	NSString* l_newText = [self m_editedValue];
    return ( l_oldText==nil && [l_newText isEqualToString:@""] ? NO : ![l_newText isEqualToString:l_oldText] );
}

@end
