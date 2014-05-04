//
//  IAUIFormTextFieldTableViewCellView.m
//  TimeNBill
//
//  Created by Marcelo Schroeder on 18/05/12.
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

#import "IFACommon.h"

@interface IFAFormTextFieldTableViewCell ()

@end

@implementation IFAFormTextFieldTableViewCell


#pragma mark - Public

-(void)reloadData {
    self.textField.text = [self.object IFA_propertyStringValueForName:self.propertyName
                                                             calendar:[NSCalendar IFA_threadSafeCalendar]];
}

-(BOOL)valueChanged {
    
	// Old text
	NSString* l_oldText = [self.object IFA_propertyStringValueForName:self.propertyName
                                                             calendar:[NSCalendar IFA_threadSafeCalendar]];
    
	// New text
	NSString* l_newText = self.textField.text;
    
	BOOL l_valueChanged = ( l_oldText==nil && [l_newText isEqualToString:@""] ? NO : ![l_newText isEqualToString:l_oldText] );
    
    return l_valueChanged;

}

-(id)parsedValue {

    NSString *l_trimmedValue = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    id l_value;
    if ([l_trimmedValue isEqualToString:@""]) {
        l_value = nil;
        self.textField.text = @"";
    }else {
        l_value = self.textField.text;
    }
    
    return l_value;

}

#pragma mark - Overrides

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier object:(NSObject*)a_object propertyName:(NSString*)a_propertyName indexPath:(NSIndexPath*)a_indexPath{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier object:a_object propertyName:a_propertyName indexPath:a_indexPath];
    
    // Configure the text field
    //    NSLog(@"self.contentView.frame: %@", NSStringFromCGRect(self.contentView.frame));
    //    NSLog(@"self.textLabel.frame: %@", NSStringFromCGRect(self.textLabel.frame));
    //    NSLog(@"self.detailTextLabel.frame: %@", NSStringFromCGRect(self.detailTextLabel.frame));
    self.textField = [[IFATextField alloc] init];
    self.textField.font = self.detailTextLabel.font;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
//    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.hidden = YES;
    self.textField.delegate = self;
    self.textField.placeholder = [[[IFAPersistenceManager sharedInstance] entityConfig] editorTipTextForProperty:self.propertyName
                                                                                                       inObject:self.object];
//    self.textField.p_textPaddingEnabled = YES;
//    self.textField.p_leftTextPadding = 7;
//    self.textField.p_topTextPadding = 3;
//    self.textField.p_editingPaddingEnabled = self.textField.p_textPaddingEnabled;
//    self.textField.p_leftEditingPadding = self.textField.p_leftTextPadding;
//    self.textField.p_topEditingPadding = self.textField.p_topTextPadding;
//    self.textField.p_rightEditingPadding = 32;    // Account for the clear button width when editing
    //    [self.textField setFont:[UIFont fontWithName:@"Helvetica" size:30.0]];
    self.textField.adjustsFontSizeToFitWidth = YES;
    self.textField.minimumFontSize = 10;
    //    self.textField.backgroundColor = [UIColor redColor];
    //    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    self.textField.frame = CGRectMake(100, 12, 150, 15);
    [self.contentView addSubview:self.textField];
    
    return self;
    
}

-(void)layoutSubviews{
    
    [super layoutSubviews];

    // Set the text field's frame in relation to the standard text label
    self.textField.frame = CGRectMake([self calculateFieldX], 8, [self calculateFieldWidth], 27);
    
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField{

//    NSLog(@"textFieldDidEndEditing: %@", [textField description]);

    if (!self.formViewController.textFieldCommitSuspended && [self valueChanged]) {

        [self.object IFA_setValue:[self parsedValue] forProperty:self.propertyName];
//        NSLog(@"  value set: %@", [self.object valueForKey:self.propertyName]);

    }

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.formViewController handleReturnKeyForTextFieldCell:self];
    return NO;
}

@end
