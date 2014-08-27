//
//  IFAFormTextFieldTableViewCell.m
//  GustyLib
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

#import "GustyLibCore.h"

@interface IFAFormTextFieldTableViewCell ()

@end

@implementation IFAFormTextFieldTableViewCell


#pragma mark - Public

-(void)reloadData {
    self.textField.text = [self.object ifa_propertyStringValueForName:self.propertyName
                                                             calendar:[NSCalendar ifa_threadSafeCalendar]];
}

-(BOOL)valueChanged {
    
	// Old text
	NSString* l_oldText = [self.object ifa_propertyStringValueForName:self.propertyName
                                                             calendar:[NSCalendar ifa_threadSafeCalendar]];
    
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
    
    self.textField = [[IFATextField alloc] init];
    self.textField.font = self.rightLabel.font;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.hidden = YES;
    self.textField.delegate = self;
    self.textField.placeholder = [[[IFAPersistenceManager sharedInstance] entityConfig] editorTipTextForProperty:self.propertyName
                                                                                                       inObject:self.object];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.customContentView addSubview:self.textField];
    [self.textField ifa_addLayoutConstraintToCenterInSuperviewVertically];
    NSLayoutConstraint *l_leftConstraint = [NSLayoutConstraint constraintWithItem:self.textField
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.rightLabel
                                                                        attribute:NSLayoutAttributeLeft
                                                                       multiplier:1
                                                                         constant:0];
    NSLayoutConstraint *l_rightConstraint = [NSLayoutConstraint constraintWithItem:self.textField
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.rightLabel
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1
                                                                         constant:0];
    [self.textField.superview addConstraints:@[
            l_leftConstraint,
            l_rightConstraint,
    ]];

    return self;
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //wip: this could be done via notification to decouple
    //wip: should style active input field?
    if ([self.formViewController.inputAccessoryView isKindOfClass:[IFAFormInputAccessoryView class]]) {
        [(IFAFormInputAccessoryView *) self.formViewController.inputAccessoryView notifyOfCurrentInputFieldIndexPath:self.indexPath];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

//    NSLog(@"textFieldDidEndEditing: %@", [textField description]);

    if (!self.formViewController.textFieldCommitSuspended && [self valueChanged]) {

        [self.object ifa_setValue:[self parsedValue] forProperty:self.propertyName];
//        NSLog(@"  value set: %@", [self.object valueForKey:self.propertyName]);

    }

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.formViewController handleReturnKeyForTextFieldCell:self];
    return NO;
}

@end
