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

#import "IACommon.h"

@interface IAUIFormTextFieldTableViewCell ()

@end

@implementation IAUIFormTextFieldTableViewCell


#pragma mark - Public

-(void)reloadData {
    self.p_textField.text = [self.p_object IFA_propertyStringValueForName:self.p_propertyName
                                                                 calendar:[NSCalendar IFA_threadSafeCalendar]];
}

-(BOOL)valueChanged {
    
	// Old text
	NSString* l_oldText = [self.p_object IFA_propertyStringValueForName:self.p_propertyName
                                                               calendar:[NSCalendar IFA_threadSafeCalendar]];
    
	// New text
	NSString* l_newText = self.p_textField.text;
    
	BOOL l_valueChanged = ( l_oldText==nil && [l_newText isEqualToString:@""] ? NO : ![l_newText isEqualToString:l_oldText] );
    
    return l_valueChanged;

}

-(id)parsedValue {

    NSString *l_trimmedValue = [self.p_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    id l_value;
    if ([l_trimmedValue isEqualToString:@""]) {
        l_value = nil;
        self.p_textField.text = @"";
    }else {
        l_value = self.p_textField.text;
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
    self.p_textField = [[IAUITextField alloc] init];
    self.p_textField.font = self.detailTextLabel.font;
    self.p_textField.borderStyle = UITextBorderStyleRoundedRect;
//    self.p_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.p_textField.hidden = YES;
    self.p_textField.delegate = self;
    self.p_textField.placeholder = [[[IAPersistenceManager sharedInstance] entityConfig] editorTipTextForProperty:self.p_propertyName inObject:self.p_object];
//    self.p_textField.p_textPaddingEnabled = YES;
//    self.p_textField.p_leftTextPadding = 7;
//    self.p_textField.p_topTextPadding = 3;
//    self.p_textField.p_editingPaddingEnabled = self.p_textField.p_textPaddingEnabled;
//    self.p_textField.p_leftEditingPadding = self.p_textField.p_leftTextPadding;
//    self.p_textField.p_topEditingPadding = self.p_textField.p_topTextPadding;
//    self.p_textField.p_rightEditingPadding = 32;    // Account for the clear button width when editing
    //    [self.p_textField setFont:[UIFont fontWithName:@"Helvetica" size:30.0]];
    self.p_textField.adjustsFontSizeToFitWidth = YES;
    self.p_textField.minimumFontSize = 10;
    //    self.p_textField.backgroundColor = [UIColor redColor];
    //    self.p_textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    self.p_textField.frame = CGRectMake(100, 12, 150, 15);
    [self.contentView addSubview:self.p_textField];
    
    return self;
    
}

-(void)layoutSubviews{
    
    [super layoutSubviews];

    // Set the text field's frame in relation to the standard text label
    self.p_textField.frame = CGRectMake([self calculateFieldX], 8, [self calculateFieldWidth], 27);
    
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField{

//    NSLog(@"textFieldDidEndEditing: %@", [textField description]);

    if (!self.p_formViewController.p_textFieldCommitSuspended && [self valueChanged]) {

        [self.p_object IFA_setValue:[self parsedValue] forProperty:self.p_propertyName];
//        NSLog(@"  value set: %@", [self.p_object valueForKey:self.p_propertyName]);

    }

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.p_formViewController handleReturnKeyForTextFieldCell:self];
    return NO;
}

@end
