//
//  IFAPickerViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 8/05/12.
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

@interface IFAPickerViewController ()

@property (nonatomic, strong) UIPickerView *XYZ_pickerView;
@property (nonatomic, strong) NSMutableArray *XYZ_entities;
@property (nonatomic) BOOL XYZ_isEnumeration;
@property (nonatomic, strong) NSObject *XYZ_selectedObject;

@end

@implementation IFAPickerViewController


static NSString * const k_valueCellId = @"valueCell";

#pragma mark - Private

- (UIPickerView*) newPickerView{
	UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
	picker.showsSelectionIndicator = YES;	// note this is default to NO
	picker.delegate = self;
	picker.dataSource = self;
//    picker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
	return picker;
}

- (void) setPickerValue:(id)aValue{
//    NSLog(@"aValue: %@", aValue);
//    NSLog(@"[self.entities indexOfObject:aValue]: %u", [self.entities indexOfObject:aValue]);
//    NSLog(@"self.XYZ_pickerView: %@", [self.XYZ_pickerView description]);
    id l_value = nil;
    if (self.XYZ_isEnumeration) {
        l_value = [IFAEnumerationEntity enumerationEntityForId:aValue entities:self.XYZ_entities];
    }else{
        l_value = aValue;
    }
    [self.XYZ_pickerView selectRow:[self.XYZ_entities indexOfObject:l_value] inComponent:0 animated:NO];
    self.XYZ_selectedObject = l_value;
}

- (id) pickerValue{
    //    NSLog(@"[((UIPickerView*)pickerView) selectedRowInComponent:0]: %u", [((UIPickerView*)pickerView) selectedRowInComponent:0]);
    if (self.XYZ_isEnumeration) {
        return ((IFAEnumerationEntity *)self.XYZ_selectedObject).enumerationEntityId;
    }else{
        return self.XYZ_selectedObject;
    }
}

#pragma mark - Overrides

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName
useButtonForDismissal:(BOOL)a_useButtonForDismissal presenter:(id <IFAPresenter>)a_presenter {
    
    if (self= [super initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:a_useButtonForDismissal
                          presenter:a_presenter]) {
        
        self.XYZ_pickerView = [self newPickerView];
        
        self.XYZ_isEnumeration = [[IFAPersistenceManager sharedInstance].entityConfig isEnumerationForProperty:aPropertyName inObject:anObject];
        NSString *l_entityName = [[IFAPersistenceManager sharedInstance].entityConfig entityNameForProperty:aPropertyName inObject:anObject];
        //    NSLog(@"parent managed object name: %@", [aManagedObject ifa_entityName]);
        if (self.XYZ_isEnumeration) {
            NSString *l_enumerationSource = [[IFAPersistenceManager sharedInstance].entityConfig enumerationSourceForProperty:aPropertyName inObject:anObject];
//            NSLog(@"enumeration entity! source: %@", l_enumerationSource);
            self.XYZ_entities = [anObject valueForKey:l_enumerationSource];
        }else{
//            NSLog(@"persistent entity!");
            self.XYZ_entities = [[IFAPersistenceManager sharedInstance] findAllForEntity:l_entityName];
        }
//        NSLog(@"entities: %@", self.entities);
        
        [(UIPickerView*)self.XYZ_pickerView reloadAllComponents];

        [self setPickerValue:[self.object valueForKey:self.propertyName]];

        // Configure view
        [self.view addSubview:self.XYZ_pickerView];
        self.view.frame = self.XYZ_pickerView.frame;

        if (self.title) {
            self.title = [NSString stringWithFormat:@"%@ Selection", self.title];
        }

    }
    
    return self;
    
}

-(id)editedValue {
    if (self.XYZ_isEnumeration) {
        return ((IFAEnumerationEntity *)self.XYZ_selectedObject).enumerationEntityId;
    }else{
        return self.XYZ_selectedObject;
    }
}

-(BOOL)ifa_hasFixedSize {
    return YES;
}

#pragma mark - UIPickerViewDataSource protocol

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return [self.XYZ_entities count];
}

#pragma mark - UIPickerViewDelegate protocol

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	return [((NSObject *) [self.XYZ_entities objectAtIndex:row]) ifa_displayValue];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.XYZ_selectedObject = [self.XYZ_entities objectAtIndex:row];
    [self updateModel];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

@end
