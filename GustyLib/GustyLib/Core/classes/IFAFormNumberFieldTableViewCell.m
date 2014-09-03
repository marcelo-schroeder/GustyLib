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

#import "GustyLibCore.h"

@interface IFAFormNumberFieldTableViewCell ()

@property (nonatomic, strong) NSNumber *IFA_roundingIncrement;
@property (nonatomic, strong) NSNumber *IFA_sliderIncrement;

@end

@implementation IFAFormNumberFieldTableViewCell

////
#pragma mark - Private

-(void)IFA_onStepperValueChange {
    //    NSLog(@"onStepperValueChange: %f", v_stepper.value);
    NSNumber *l_value = @(self.stepper.value);
    [self.object ifa_setValue:l_value forProperty:self.propertyName];
    [self reloadData];
}

-(void)IFA_onTextFieldDidChangeNotification:(NSNotification*)a_notification{
    NSNumber *l_value = [self parsedValue];
    self.slider.value = [l_value floatValue];
    self.stepper.value = [l_value doubleValue];
}

- (void)IFA_onSliderAction:(id)aSender{
	UISlider *l_slider = aSender;
    NSNumber *l_value = @(l_slider.value);
    if (self.IFA_sliderIncrement) {
        NSNumberFormatter *l_numberFormatter = [self.object ifa_numberFormatterForProperty:self.propertyName];
        [l_numberFormatter setRoundingIncrement:self.IFA_sliderIncrement];
        NSString *l_formattedValue = [l_numberFormatter stringFromNumber:l_value];
        l_value = [l_numberFormatter numberFromString:l_formattedValue];
        if ([l_value compare:@(l_slider.minimumValue)]==NSOrderedAscending) {
            l_value = @(l_slider.minimumValue);
        }
        if ([l_value compare:@(l_slider.maximumValue)]==NSOrderedDescending) {
            l_value = @(l_slider.maximumValue);
        }
    }
    [self.object ifa_setValue:l_value forProperty:self.propertyName];
    [self reloadData];
}

#pragma mark - Overrides

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier propertyName:(NSString *)a_propertyName
                    indexPath:(NSIndexPath *)a_indexPath
           formViewController:(IFAFormViewController *)a_formViewController {
    
    self = [super initWithReuseIdentifier:reuseIdentifier propertyName:a_propertyName indexPath:a_indexPath
                       formViewController:a_formViewController];
    
    NSDictionary *l_options = [[IFAPersistenceManager sharedInstance].entityConfig optionsForProperty:self.propertyName
                                                                                            inObject:self.object];
    self.IFA_roundingIncrement = [l_options valueForKey:@"roundingIncrement"];
    self.IFA_sliderIncrement = [l_options valueForKey:@"sliderIncrement"];
    
    // Configure the text field
    if (![IFAUIUtils isIPad]) {
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    // Min & max values
    NSNumber *l_minValue = [self.object ifa_minimumValueForProperty:self.propertyName];
    NSNumber *l_maxValue = [self.object ifa_maximumValueForProperty:self.propertyName];

    // Configure stepper
    self.stepper = [UIStepper new];
    self.stepper.minimumValue = [l_minValue doubleValue];
    self.stepper.maximumValue = [l_maxValue doubleValue];
    self.stepper.stepValue = [self.IFA_roundingIncrement doubleValue];
    [self.stepper addTarget:self action:@selector(IFA_onStepperValueChange)
           forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.stepper];

    // Configure slider
    self.slider = [UISlider new];
    self.slider.minimumValue = [l_minValue floatValue];
    self.slider.maximumValue = [l_maxValue floatValue];
    [self.slider addTarget:self action:@selector(IFA_onSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.slider];

//    // Configure slider labels
//    self.minLabel = [UILabel new];
//    self.minLabel.backgroundColor = [UIColor clearColor];
//    self.minLabel.textAlignment = UITextAlignmentRight;
//    self.minLabel.text = @"100";
//    [self.contentView addSubview:self.minLabel];
//    self.maxLabel = [UILabel new];
//    self.maxLabel.backgroundColor = [UIColor clearColor];
//    self.maxLabel.textAlignment = UITextAlignmentLeft;
//    self.maxLabel.text = @"10,000";
//    [self.contentView addSubview:self.maxLabel];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(IFA_onTextFieldDidChangeNotification:)
                                                 name:UITextFieldTextDidChangeNotification 
                                               object:nil];
    
    return self;
    
}

-(id)parsedValue {

    NSNumberFormatter *l_numberFormatter = [self.object ifa_numberFormatterForProperty:self.propertyName];
    [l_numberFormatter setRoundingIncrement:self.IFA_roundingIncrement];
    return [l_numberFormatter numberFromString:self.textField.text];
    
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.stepper.frame = CGRectMake(self.textField.frame.origin.x + self.textField.frame.size.width - self.stepper.frame.size.width, 8, self.stepper.frame.size.width, self.stepper.frame.size.height);
    self.textField.frame = CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, self.textField.frame.size.width - self.stepper.frame.size.width - 10, self.textField.frame.size.height);
//    self.minLabel.frame = CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y + self.textField.frame.size.height + 3, self.contentView.frame.size.width/10, self.slider.frame.size.height);
//    self.maxLabel.frame = CGRectMake(self.p_stepper.frame.origin.x + self.p_stepper.frame.size.width - self.minLabel.frame.size.width, self.minLabel.frame.origin.y, self.minLabel.frame.size.width, self.minLabel.frame.size.height);
//    NSLog(@"self.detailTextLabel.frame: %@", NSStringFromCGRect(self.detailTextLabel.frame));
//    NSLog(@"self.p_stepper.frame: %@", NSStringFromCGRect(self.p_stepper.frame));
//    NSLog(@"self.slider.frame: %@", NSStringFromCGRect(self.slider.frame));
//    NSLog(@"self.minLabel.frame: %@", NSStringFromCGRect(self.minLabel.frame));
//    NSLog(@"self.maxLabel.frame: %@", NSStringFromCGRect(self.maxLabel.frame));
//    CGFloat l_x = self.minLabel.frame.origin.x + self.minLabel.frame.size.width + 10;
//    self.slider.frame = CGRectMake(l_x, self.textField.frame.origin.y + self.textField.frame.size.height + 5, self.detailTextLabel.frame.size.width - (l_x - self.minLabel.frame.origin.x) - self.maxLabel.frame.size.width - 10, self.slider.frame.size.height);
    self.slider.frame = CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y + self.textField.frame.size.height + 5, self.detailTextLabel.frame.size.width, self.slider.frame.size.height);
    
}

-(void)reloadData {
    [super reloadData];
    NSNumber *l_value = [self.object valueForKey:self.propertyName];
    self.stepper.value = [l_value doubleValue];
    self.slider.value = [l_value floatValue];
}

-(void)dealloc{

    // Remove targets
    [self.stepper removeTarget:self action:@selector(IFA_onStepperValueChange)
              forControlEvents:UIControlEventValueChanged];
    [self.slider removeTarget:self action:@selector(IFA_onSliderAction:) forControlEvents:UIControlEventValueChanged];
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

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
            [IFAUIUtils showAlertWithMessage:[NSString stringWithFormat:@"Invalid number entered for %@.",
                                                                        l_propertyLabel]
                    title:@"Validation Error"];
            return NO;
        }

    }
    
}


@end
