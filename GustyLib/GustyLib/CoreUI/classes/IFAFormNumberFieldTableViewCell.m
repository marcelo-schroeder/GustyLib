//
//  IFAFormNumberFieldTableViewCell.m
//  Gusty
//
//  Created by Marcelo Schroeder on 19/05/12.
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

@interface IFAFormNumberFieldTableViewCell ()

@end

@implementation IFAFormNumberFieldTableViewCell

#pragma mark - Overrides

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier propertyName:(NSString *)a_propertyName
                    indexPath:(NSIndexPath *)a_indexPath
           formViewController:(IFAFormViewController *)a_formViewController {
    
    self = [super initWithReuseIdentifier:reuseIdentifier propertyName:a_propertyName indexPath:a_indexPath
                       formViewController:a_formViewController];

    // Configure the text field
    if (![IFAUIUtils isIPad]) {
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
    }

    return self;
    
}

-(id)parsedValue {

    NSNumberFormatter *l_numberFormatter = [self.object ifa_numberFormatterForProperty:self.propertyName];
    return [l_numberFormatter numberFromString:self.textField.text];
    
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    if (self.formViewController.textFieldCommitSuspended) {

        return YES;

    }else {
        
        if ([self parsedValue]) {
            return YES;
        }else {
            NSString *l_propertyLabel = [[IFAPersistenceManager sharedInstance].entityConfig labelForProperty:self.propertyName
                                                                                                     inObject:self.object];
            NSString *alertTitle = @"Validation Error";
            NSString *alertMessage = [NSString stringWithFormat:@"Invalid number entered for %@.", l_propertyLabel];
            [self.formViewController ifa_presentAlertControllerWithTitle:alertTitle message:alertMessage];
            return NO;
        }

    }
    
}


@end
