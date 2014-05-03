//
//  IAUIFormNumberFieldTableViewCell.m
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

#import "IACommon.h"

@interface IAUIFormNumberFieldTableViewCell()

@property (nonatomic, strong) NSNumber *p_roundingIncrement;
@property (nonatomic, strong) NSNumber *p_sliderIncrement;

@end

@implementation IAUIFormNumberFieldTableViewCell

////
#pragma mark - Private

-(void)m_onStepperValueChange{
    //    NSLog(@"onStepperValueChange: %f", v_stepper.value);
    NSNumber *l_value = @(self.p_stepper.value);
    [self.p_object IFA_setValue:l_value forProperty:self.p_propertyName];
    [self reloadData];
}

-(void)m_onTextFieldDidChangeNotification:(NSNotification*)a_notification{
    NSNumber *l_value = [self parsedValue];
    self.p_slider.value = [l_value floatValue];
    self.p_stepper.value = [l_value doubleValue];
}

- (void)m_onSliderAction:(id)aSender{
	UISlider *l_slider = aSender;
    NSNumber *l_value = @(l_slider.value);
    if (self.p_sliderIncrement) {
        NSNumberFormatter *l_numberFormatter = [self.p_object IFA_numberFormatterForProperty:self.p_propertyName];
        [l_numberFormatter setRoundingIncrement:self.p_sliderIncrement];
        NSString *l_formattedValue = [l_numberFormatter stringFromNumber:l_value];
        l_value = [l_numberFormatter numberFromString:l_formattedValue];
        if ([l_value compare:@(l_slider.minimumValue)]==NSOrderedAscending) {
            l_value = @(l_slider.minimumValue);
        }
        if ([l_value compare:@(l_slider.maximumValue)]==NSOrderedDescending) {
            l_value = @(l_slider.maximumValue);
        }
    }
    [self.p_object IFA_setValue:l_value forProperty:self.p_propertyName];
    [self reloadData];
}

#pragma mark - Overrides

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier object:(NSObject*)a_object propertyName:(NSString*)a_propertyName indexPath:(NSIndexPath*)a_indexPath{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier object:a_object propertyName:a_propertyName indexPath:a_indexPath];
    
    NSDictionary *l_options = [[IAPersistenceManager sharedInstance].entityConfig optionsForProperty:self.p_propertyName inObject:self.p_object];
    self.p_roundingIncrement = [l_options valueForKey:@"roundingIncrement"];
    self.p_sliderIncrement = [l_options valueForKey:@"sliderIncrement"];
    
    // Configure the text field
    if (![IAUIUtils isIPad]) {
        self.p_textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    // Min & max values
    NSNumber *l_minValue = [self.p_object IFA_minimumValueForProperty:self.p_propertyName];
    NSNumber *l_maxValue = [self.p_object IFA_maximumValueForProperty:self.p_propertyName];

    // Configure stepper
    self.p_stepper = [UIStepper new];
    self.p_stepper.minimumValue = [l_minValue doubleValue];
    self.p_stepper.maximumValue = [l_maxValue doubleValue];
    self.p_stepper.stepValue = [self.p_roundingIncrement doubleValue];
    [self.p_stepper addTarget:self action:@selector(m_onStepperValueChange) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.p_stepper];

    // Configure slider
    self.p_slider = [UISlider new];
    self.p_slider.minimumValue = [l_minValue floatValue];
    self.p_slider.maximumValue = [l_maxValue floatValue];
    [self.p_slider addTarget:self action:@selector(m_onSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.p_slider];

//    // Configure slider labels
//    self.p_minLabel = [UILabel new];
//    self.p_minLabel.backgroundColor = [UIColor clearColor];
//    self.p_minLabel.textAlignment = UITextAlignmentRight;
//    self.p_minLabel.text = @"100";
//    [self.contentView addSubview:self.p_minLabel];
//    self.p_maxLabel = [UILabel new];
//    self.p_maxLabel.backgroundColor = [UIColor clearColor];
//    self.p_maxLabel.textAlignment = UITextAlignmentLeft;
//    self.p_maxLabel.text = @"10,000";
//    [self.contentView addSubview:self.p_maxLabel];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(m_onTextFieldDidChangeNotification:) 
                                                 name:UITextFieldTextDidChangeNotification 
                                               object:nil];
    
    return self;
    
}

-(id)parsedValue {

    NSNumberFormatter *l_numberFormatter = [self.p_object IFA_numberFormatterForProperty:self.p_propertyName];
    [l_numberFormatter setRoundingIncrement:self.p_roundingIncrement];
    return [l_numberFormatter numberFromString:self.p_textField.text];
    
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.p_stepper.frame = CGRectMake(self.p_textField.frame.origin.x + self.p_textField.frame.size.width - self.p_stepper.frame.size.width, 8, self.p_stepper.frame.size.width, self.p_stepper.frame.size.height);
    self.p_textField.frame = CGRectMake(self.p_textField.frame.origin.x, self.p_textField.frame.origin.y, self.p_textField.frame.size.width - self.p_stepper.frame.size.width - 10, self.p_textField.frame.size.height);
//    self.p_minLabel.frame = CGRectMake(self.p_textField.frame.origin.x, self.p_textField.frame.origin.y + self.p_textField.frame.size.height + 3, self.contentView.frame.size.width/10, self.p_slider.frame.size.height);
//    self.p_maxLabel.frame = CGRectMake(self.p_stepper.frame.origin.x + self.p_stepper.frame.size.width - self.p_minLabel.frame.size.width, self.p_minLabel.frame.origin.y, self.p_minLabel.frame.size.width, self.p_minLabel.frame.size.height);
//    NSLog(@"self.detailTextLabel.frame: %@", NSStringFromCGRect(self.detailTextLabel.frame));
//    NSLog(@"self.p_stepper.frame: %@", NSStringFromCGRect(self.p_stepper.frame));
//    NSLog(@"self.p_slider.frame: %@", NSStringFromCGRect(self.p_slider.frame));
//    NSLog(@"self.p_minLabel.frame: %@", NSStringFromCGRect(self.p_minLabel.frame));
//    NSLog(@"self.p_maxLabel.frame: %@", NSStringFromCGRect(self.p_maxLabel.frame));
//    CGFloat l_x = self.p_minLabel.frame.origin.x + self.p_minLabel.frame.size.width + 10;
//    self.p_slider.frame = CGRectMake(l_x, self.p_textField.frame.origin.y + self.p_textField.frame.size.height + 5, self.detailTextLabel.frame.size.width - (l_x - self.p_minLabel.frame.origin.x) - self.p_maxLabel.frame.size.width - 10, self.p_slider.frame.size.height);
    self.p_slider.frame = CGRectMake(self.p_textField.frame.origin.x, self.p_textField.frame.origin.y + self.p_textField.frame.size.height + 5, self.detailTextLabel.frame.size.width, self.p_slider.frame.size.height);
    
}

-(void)reloadData {
    [super reloadData];
    NSNumber *l_value = [self.p_object valueForKey:self.p_propertyName];
    self.p_stepper.value = [l_value doubleValue];
    self.p_slider.value = [l_value floatValue];
}

-(void)dealloc{

    // Remove targets
    [self.p_stepper removeTarget:self action:@selector(m_onStepperValueChange) forControlEvents:UIControlEventValueChanged];
    [self.p_slider removeTarget:self action:@selector(m_onSliderAction:) forControlEvents:UIControlEventValueChanged];
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];

}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    if (self.p_formViewController.p_textFieldCommitSuspended) {

        return YES;

    }else {
        
        if ([self parsedValue]) {
            return YES;
        }else {
            NSString *l_propertyLabel = [[IAPersistenceManager sharedInstance].entityConfig labelForProperty:self.p_propertyName inObject:self.p_object];
            [IAUIUtils showAlertWithMessage:[NSString stringWithFormat:@"Invalid number entered for %@.", l_propertyLabel] title:@"Validation Error"];
            return NO;
        }

    }
    
}


@end
