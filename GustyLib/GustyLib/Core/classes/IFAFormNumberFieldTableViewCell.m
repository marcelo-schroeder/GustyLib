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

    // Min & max values
    NSNumber *l_minValue = [self.object ifa_minimumValueForProperty:self.propertyName];
    NSNumber *l_maxValue = [self.object ifa_maximumValueForProperty:self.propertyName];

    // Configure input control container
    UIView *l_inputControlContainer = [UIView new];
    l_inputControlContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.customContentView addSubview:l_inputControlContainer];
    [l_inputControlContainer ifa_addLayoutConstraintsToFillSuperviewVertically];
    NSLayoutConstraint *l_leftConstraint = [NSLayoutConstraint constraintWithItem:l_inputControlContainer
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.rightLabel
                                                                        attribute:NSLayoutAttributeLeft
                                                                       multiplier:1
                                                                         constant:0];
    NSLayoutConstraint *l_rightConstraint = [NSLayoutConstraint constraintWithItem:l_inputControlContainer
                                                                         attribute:NSLayoutAttributeRight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.rightLabel
                                                                         attribute:NSLayoutAttributeRight
                                                                        multiplier:1
                                                                          constant:0];
    [l_inputControlContainer.superview addConstraints:@[
            l_leftConstraint,
            l_rightConstraint,
    ]];

    // Configure the text field
    if (![IFAUIUtils isIPad]) {
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    [l_inputControlContainer addSubview:self.textField];

    // Configure stepper
    self.stepper = [UIStepper new];
    self.stepper.translatesAutoresizingMaskIntoConstraints = NO;
    self.stepper.minimumValue = [l_minValue doubleValue];
    self.stepper.maximumValue = [l_maxValue doubleValue];
    self.stepper.stepValue = [self.IFA_roundingIncrement doubleValue];
    [self.stepper addTarget:self action:@selector(IFA_onStepperValueChange)
           forControlEvents:UIControlEventValueChanged];
    [l_inputControlContainer addSubview:self.stepper];

    // Configure slider
    self.slider = [UISlider new];
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;
    self.slider.minimumValue = [l_minValue floatValue];
    self.slider.maximumValue = [l_maxValue floatValue];
    [self.slider addTarget:self action:@selector(IFA_onSliderAction:) forControlEvents:UIControlEventValueChanged];
    [l_inputControlContainer addSubview:self.slider];

    id l_textField = self.textField;
    id l_stepper = self.stepper;
    id l_slider = self.slider;
    NSDictionary *l_views = NSDictionaryOfVariableBindings(l_textField, l_stepper, l_slider);
    NSMutableArray *l_horizontalConstraints = [[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[l_textField]-8-[l_stepper]|"
                                                                                       options:NSLayoutFormatAlignAllCenterY
                                                                                       metrics:nil
                                                                                         views:l_views] mutableCopy];
    [l_horizontalConstraints addObject:[NSLayoutConstraint constraintWithItem:l_stepper
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:l_slider
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1
                                                                     constant:0]];
    [self.customContentView addConstraints:l_horizontalConstraints];
    NSArray *l_verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[l_textField]-7-[l_slider]"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil
                                                                               views:l_views];
    [self.customContentView addConstraints:l_verticalConstraints];

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

- (void)addTextFieldLayoutConstraints {
    // Do not add the constraints added by the superclass
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
