//
//  IAUIPickerViewController.m
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

#import "IACommon.h"

@interface IAUIPickerViewController ()

@property (nonatomic, strong) UIPickerView *p_pickerView;
@property (nonatomic, strong) NSMutableArray *p_entities;
@property (nonatomic) BOOL p_isEnumeration;
@property (nonatomic, strong) NSObject *p_selectedObject;

@end

@implementation IAUIPickerViewController


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
//    NSLog(@"[self.p_entities indexOfObject:aValue]: %u", [self.p_entities indexOfObject:aValue]);
//    NSLog(@"self.p_pickerView: %@", [self.p_pickerView description]);
    id l_value = nil;
    if (self.p_isEnumeration) {
        l_value = [IAEnumerationEntity enumerationEntityForId:aValue entities:self.p_entities];
    }else{
        l_value = aValue;
    }
    [self.p_pickerView selectRow:[self.p_entities indexOfObject:l_value] inComponent:0 animated:NO];
    self.p_selectedObject = l_value;
}

- (id) pickerValue{
    //    NSLog(@"[((UIPickerView*)pickerView) selectedRowInComponent:0]: %u", [((UIPickerView*)pickerView) selectedRowInComponent:0]);
    if (self.p_isEnumeration) {
        return ((IAEnumerationEntity*)self.p_selectedObject).p_id;
    }else{
        return self.p_selectedObject;
    }
}

#pragma mark - Overrides

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName
useButtonForDismissal:(BOOL)a_useButtonForDismissal presenter:(id <IAUIPresenter>)a_presenter {
    
    if (self= [super initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:a_useButtonForDismissal
                          presenter:a_presenter]) {
        
        self.p_pickerView = [self newPickerView];
        
        self.p_isEnumeration = [[IAPersistenceManager sharedInstance].entityConfig isEnumerationForProperty:aPropertyName inObject:anObject];
        NSString *l_entityName = [[IAPersistenceManager sharedInstance].entityConfig entityNameForProperty:aPropertyName inObject:anObject];
        //    NSLog(@"parent managed object name: %@", [aManagedObject entityName]);
        if (self.p_isEnumeration) {
            NSString *l_enumerationSource = [[IAPersistenceManager sharedInstance].entityConfig enumerationSourceForProperty:aPropertyName inObject:anObject];
//            NSLog(@"enumeration entity! source: %@", l_enumerationSource);
            self.p_entities = [anObject valueForKey:l_enumerationSource];
        }else{
//            NSLog(@"persistent entity!");
            self.p_entities = [[IAPersistenceManager sharedInstance] findAllForEntity:l_entityName];
        }
//        NSLog(@"entities: %@", self.p_entities);
        
        [(UIPickerView*)self.p_pickerView reloadAllComponents];

        [self setPickerValue:[self.p_object valueForKey:self.p_propertyName]];

        // Configure view
        [self.view addSubview:self.p_pickerView];
        self.view.frame = self.p_pickerView.frame;

        if (self.title) {
            self.title = [NSString stringWithFormat:@"%@ Selection", self.title];
        }

    }
    
    return self;
    
}

-(id)editedValue {
    if (self.p_isEnumeration) {
        return ((IAEnumerationEntity*)self.p_selectedObject).p_id;
    }else{
        return self.p_selectedObject;
    }
}

-(BOOL)m_hasFixedSize{
    return YES;
}

#pragma mark - UIPickerViewDataSource protocol

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return [self.p_entities count];
}

#pragma mark - UIPickerViewDelegate protocol

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	return [((NSObject*)[self.p_entities objectAtIndex:row]) displayValue];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.p_selectedObject = [self.p_entities objectAtIndex:row];
    [self updateModel];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

@end
