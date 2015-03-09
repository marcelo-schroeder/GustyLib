//
//  IFADatePickerViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 12/03/12.
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

@interface IFADatePickerViewController ()

@property (nonatomic, strong) NSDate *IFA_dateAndTime;
@property (nonatomic) NSTimeInterval IFA_countDownDuration;
@property(nonatomic, strong) UIDatePicker *IFA_datePicker;
@property(nonatomic, strong) UIDatePicker *IFA_timePicker;
@property(nonatomic, strong) NSMutableArray *IFA_toolbarItems;
@property(nonatomic, strong) NSNumber *IFA_seconds;
@property(nonatomic, strong) UISegmentedControl *IFA_segmentedControl;
@property (nonatomic, strong) NSDateFormatter *IFA_dateFormatter;
@property (nonatomic, strong) NSDateFormatter *IFA_timeFormatter;
@property(nonatomic, strong) UIView *IFA_pickerContainerView;
@end

@implementation IFADatePickerViewController

#pragma mark - Private

-(void)IFA_onDatePickerValueChanged {
    if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {
        self.IFA_countDownDuration = self.IFA_datePicker.countDownDuration;
    }else{
        self.IFA_dateAndTime = self.IFA_datePicker.date;
    }
}

-(void)IFA_onTimePickerValueChanged {
    self.IFA_dateAndTime = self.IFA_timePicker.date;
}

-(void)IFA_onSelectNowButtonTap:(id)aSender{
    self.IFA_dateAndTime = [NSDate ifa_dateWithSecondPrecision];
}

-(void)IFA_onSelectTodayButtonTap:(id)aSender{
    self.IFA_dateAndTime = [[NSDate date] ifa_lastMidnightForCalendar:self.ifa_calendar] ;
}

-(void)IFA_onSelectDistantPastButtonTap:(id)aSender{
    self.IFA_dateAndTime = [NSDate distantPast];
}

-(void)IFA_onSelectDistantFutureButtonTap:(id)aSender{
    self.IFA_dateAndTime = [NSDate distantFuture];
}

-(void)IFA_onClearDateButtonTap:(id)aSender{
    self.IFA_dateAndTime = nil;
    [self done];
}

-(void)IFA_onResetCountDownButtonTap:(id)aSender{
    self.IFA_countDownDuration = 0;
    [self done];
}

- (NSDateFormatter *)IFA_dateFormatter {
    if (!_IFA_dateFormatter) {
        _IFA_dateFormatter = [[NSDateFormatter alloc] init];
        [_IFA_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_IFA_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return _IFA_dateFormatter;
}

- (NSDateFormatter *)IFA_timeFormatter {
    if (!_IFA_timeFormatter) {
        _IFA_timeFormatter = [[NSDateFormatter alloc] init];
        [_IFA_timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [_IFA_timeFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return _IFA_timeFormatter;
}

-(UIDatePicker*)IFA_newDatePickerForProperty:(NSString *)a_propertyName inObject:(NSObject *)a_object pickerMode:(UIDatePickerMode)a_pickerMode{
	UIDatePicker *l_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    l_datePicker.datePickerMode = a_pickerMode;
    if (l_datePicker.datePickerMode!=UIDatePickerModeCountDownTimer) {
        NSDictionary *l_optionsDict = [[IFAPersistenceManager sharedInstance].entityConfig optionsForProperty:a_propertyName inObject:a_object];
        l_datePicker.minimumDate = [NSDate distantPast];
        BOOL l_preventFutureDateSelection = [l_optionsDict[@"preventFutureDateSelection"] boolValue];
        BOOL l_preventFutureDateSelectionExceptTomorrow = [l_optionsDict[@"preventFutureDateSelectionExceptTomorrow"] boolValue];
        if (l_preventFutureDateSelection || l_preventFutureDateSelectionExceptTomorrow) {
            if (l_preventFutureDateSelection) {
                l_datePicker.maximumDate = [[NSDate date] ifa_lastMidnightForCalendar:[NSCalendar ifa_threadSafeCalendar]];
            }else{
                l_datePicker.maximumDate = [[NSDate date] ifa_nextMidnightForCalendar:[NSCalendar ifa_threadSafeCalendar]];
            }
        }else{
            l_datePicker.maximumDate = [NSDate distantFuture];
        }
    }
    return l_datePicker;
}

-(NSArray*)IFA_datePickerToolbarItemsForProperty:(NSString *)a_propertyName inObject:(NSObject *)a_object target:(id)a_target{
    
    NSDictionary *l_optionsDict = [[IFAPersistenceManager sharedInstance].entityConfig optionsForProperty:a_propertyName inObject:a_object];
	BOOL l_showSelectNowButton = [l_optionsDict[@"showSelectNowButton"] boolValue];
	BOOL l_showSelectTodayButton = [l_optionsDict[@"showSelectTodayButton"] boolValue];
	BOOL l_showClearDateButton = [l_optionsDict[@"showClearDateButton"] boolValue];
	BOOL l_showResetCountDownButton = [l_optionsDict[@"showResetCountDownButton"] boolValue];
	BOOL l_showSelectDistantPastButton = [l_optionsDict[@"showSelectDistantPastButton"] boolValue];
	BOOL l_showSelectDistantFutureButton = [l_optionsDict[@"showSelectDistantFutureButton"] boolValue];
	
    NSMutableArray *l_toolbarItems = [NSMutableArray array];
    if (l_showSelectNowButton) {
        UIBarButtonItem *selectNowButton = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeSelectNow
                                                                     target:a_target
                                                                     action:@selector(IFA_onSelectNowButtonTap:)];
        [l_toolbarItems addObject:selectNowButton];
    }
    if (l_showSelectTodayButton) {
        UIBarButtonItem *selectTodayButton = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeSelectToday
                                                                       target:a_target
                                                                       action:@selector(IFA_onSelectTodayButtonTap:)];
        [l_toolbarItems addObject:selectTodayButton];
    }
    if (l_showResetCountDownButton) {
        UIBarButtonItem *l_resetCountDownButton = [[UIBarButtonItem alloc] initWithTitle:@"Set To Zero"
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:a_target
                                                                                  action:@selector(IFA_onResetCountDownButtonTap:)];
//        l_resetCountDownButton.accessibilityLabel = @"Set To Zero";
        [l_toolbarItems addObject:l_resetCountDownButton];
    }
    if (l_showClearDateButton || l_showSelectDistantPastButton || l_showSelectDistantFutureButton) {
        UIBarButtonItem *flexibleSpace = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeFlexibleSpace
                                                                   target:nil
                                                                   action:nil];
        if (l_showClearDateButton) {
            UIBarButtonItem *clearDateButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear Date"
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:a_target
                                                                               action:@selector(IFA_onClearDateButtonTap:)];
//            clearDateButton.accessibilityLabel = @"Clear Date";
            [l_toolbarItems addObjectsFromArray:@[flexibleSpace, clearDateButton]];
        }
        if (l_showSelectDistantPastButton) {
            UIBarButtonItem *l_selectDistantPastButton = [[UIBarButtonItem alloc] initWithTitle:@"Distant Past"
                                                                                          style:UIBarButtonItemStylePlain
                                                                                         target:a_target
                                                                                         action:@selector(IFA_onSelectDistantPastButtonTap:)];
//            l_selectDistantPastButton.accessibilityLabel = @"Distant Past";
            [l_toolbarItems addObjectsFromArray:@[flexibleSpace, l_selectDistantPastButton]];
        }
        if (l_showSelectDistantFutureButton) {
            UIBarButtonItem *l_selectDistantFutureButton = [[UIBarButtonItem alloc] initWithTitle:@"Distant Future"
                                                                                            style:UIBarButtonItemStylePlain
                                                                                           target:a_target
                                                                                           action:@selector(IFA_onSelectDistantFutureButtonTap:)];
//            l_selectDistantFutureButton.accessibilityLabel = @"Distant Future";
            [l_toolbarItems addObjectsFromArray:@[flexibleSpace, l_selectDistantFutureButton]];
        }
    }
    
    return l_toolbarItems;
    
}

- (void)IFA_onSegmentedControlValueChanged {
    [self IFA_updatePickersVisibilityState];
}

- (void)IFA_updatePickersVisibilityState{
    self.IFA_datePicker.hidden = !self.IFA_segmentedControl.selectedSegmentIndex==0;
    self.IFA_timePicker.hidden = !self.IFA_datePicker.hidden;
}

- (void)IFA_updateSegmentedControlTitles {
    if (self.showTimePicker) {
        NSDate *l_dateAndTime = self.IFA_dateAndTime;
        [self.IFA_segmentedControl setTitle:[self.IFA_dateFormatter stringFromDate:l_dateAndTime] forSegmentAtIndex:0];
        [self.IFA_segmentedControl setTitle:[self.IFA_timeFormatter stringFromDate:l_dateAndTime] forSegmentAtIndex:1];
    }
}

- (UISegmentedControl *)IFA_segmentedControl {
    if (!_IFA_segmentedControl) {
        _IFA_segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"date placeholder", @"time placeholder"]];
        [_IFA_segmentedControl addTarget:self action:@selector(IFA_onSegmentedControlValueChanged)
                        forControlEvents:UIControlEventValueChanged];
        _IFA_segmentedControl.selectedSegmentIndex = 0;
    }
    return _IFA_segmentedControl;
}

- (UIDatePicker *)IFA_datePicker {
    if (!_IFA_datePicker) {
        _IFA_datePicker = [self IFA_newDatePickerForProperty:self.propertyName inObject:self.object
                                                  pickerMode:self.datePickerMode];
        _IFA_datePicker.hidden = NO;
        [_IFA_datePicker addTarget:self action:@selector(IFA_onDatePickerValueChanged)
                  forControlEvents:UIControlEventValueChanged];
    }
    return _IFA_datePicker;
}

- (UIDatePicker *)IFA_timePicker {
    if (!_IFA_timePicker) {
        _IFA_timePicker = [self IFA_newDatePickerForProperty:self.propertyName inObject:self.object
                                                  pickerMode:UIDatePickerModeTime];
        _IFA_timePicker.hidden = YES;
        [_IFA_timePicker addTarget:self action:@selector(IFA_onTimePickerValueChanged)
                  forControlEvents:UIControlEventValueChanged];
    }
    return _IFA_timePicker;
}

- (void)IFA_configureLayout {

    self.IFA_pickerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    CGSize l_pickerContainerViewSize = CGSizeMake(self.IFA_datePicker.bounds.size.width, self.IFA_datePicker.bounds.size.height);
    [self.IFA_pickerContainerView ifa_addLayoutConstraintsForSize:l_pickerContainerViewSize];
    [self.IFA_datePicker ifa_addLayoutConstraintsToCenterInSuperview];

    NSDictionary *l_views;
    NSString *l_visualFormatConstraints;
    id l_pickerContainerView = self.IFA_pickerContainerView;
    if (self.showTimePicker) {
        self.IFA_segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self.IFA_timePicker ifa_addLayoutConstraintsToCenterInSuperview];
        [self.IFA_segmentedControl ifa_addLayoutConstraintToCenterInSuperviewHorizontally];
        id l_segmentedControl = self.IFA_segmentedControl;
        l_views = NSDictionaryOfVariableBindings(l_segmentedControl, l_pickerContainerView);
        l_visualFormatConstraints = @"V:|-15-[l_segmentedControl][l_pickerContainerView]|";
    }else{
        l_views = NSDictionaryOfVariableBindings(l_pickerContainerView);
        l_visualFormatConstraints = @"V:|[l_pickerContainerView]|";
    }
    NSArray *l_verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:l_visualFormatConstraints
                                                                                   options:NSLayoutFormatAlignAllCenterX
                                                                                   metrics:nil
                                                                                     views:l_views];
    [self.view addConstraints:l_verticalLayoutConstraints];

    CGRect l_viewFrame = CGRectZero;
    l_viewFrame.size = [self.view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.view.frame = l_viewFrame;

}

- (void)IFA_configureViewHierarchy {
    [self.IFA_pickerContainerView addSubview:self.IFA_datePicker];
    [self.view addSubview:self.IFA_pickerContainerView];
    if (self.showTimePicker) {
        [self.IFA_pickerContainerView addSubview:self.IFA_timePicker];
        [self.view addSubview:self.IFA_segmentedControl];
    }
}

- (UIView *)IFA_pickerContainerView {
    if (!_IFA_pickerContainerView) {
        _IFA_pickerContainerView = [[UIView alloc] initWithFrame:self.IFA_datePicker.frame];
    }
    return _IFA_pickerContainerView;
}

#pragma mark - Public

-(id)initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName datePickerMode:(UIDatePickerMode)aDatePickerMode showTimePicker:(BOOL)aShowTimePickerFlag{
    return [self initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:YES
                                                                           datePickerMode:aDatePickerMode
                                                                           showTimePicker:aShowTimePickerFlag];
}

-(id)initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName useButtonForDismissal:(BOOL)a_useButtonForDismissal datePickerMode:(UIDatePickerMode)aDatePickerMode showTimePicker:(BOOL)aShowTimePickerFlag{

    if (self= [super initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:a_useButtonForDismissal
                          presenter:nil ]) {
        
        self.datePickerMode = aDatePickerMode;
        self.showTimePicker = aShowTimePickerFlag;

        // Customise toolbar items
        self.IFA_toolbarItems = [NSMutableArray arrayWithArray:[self IFA_datePickerToolbarItemsForProperty:aPropertyName
                                                                                           inObject:anObject
                                                                                             target:self]];

        if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {
            [self addObserver:self forKeyPath:@"IFA_countDownDuration" options:0 context:nil];
            self.IFA_countDownDuration = [[self.object valueForKey:self.propertyName] doubleValue];
        }else{
            [self addObserver:self forKeyPath:@"IFA_dateAndTime" options:0 context:nil];
            self.IFA_dateAndTime = [self.object valueForKey:self.propertyName];
        }

        NSDictionary *l_options = [[IFAPersistenceManager sharedInstance].entityConfig optionsForProperty:self.propertyName
                                                                                                inObject:self.object];
        self.IFA_seconds = l_options[@"seconds"];

        [self IFA_configureViewHierarchy];
        [self IFA_configureLayout];

    }

    return self;

}

#pragma mark - Overrides

-(id)initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName{
    return [self initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:NO presenter:nil ];
}

- (id) initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName
useButtonForDismissal:(BOOL)a_useButtonForDismissal presenter:(id <IFAPresenter>)a_presenter {
    return [self initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:a_useButtonForDismissal datePickerMode:UIDatePickerModeDate showTimePicker:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self IFA_updateSegmentedControlTitles];
    [self IFA_updatePickersVisibilityState];
}

- (NSArray*)ifa_editModeToolbarItems {
    return self.IFA_toolbarItems;
}

-(id)editedValue {
    if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {
        return @(self.IFA_countDownDuration);
    }else{
        return self.IFA_dateAndTime;
    }
}

-(void)dealloc{
    if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {
        [self removeObserver:self forKeyPath:@"IFA_countDownDuration"];
    }else {
        [self removeObserver:self forKeyPath:@"IFA_dateAndTime"];
    }
}

-(BOOL)ifa_hasFixedSize {
    return YES;
}

#pragma mark - NSKeyValueObserving

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
//    NSLog(@"observeValueForKeyPath");
    
    if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {

        // Workaround for UIKit bug introduced in iOS 7: had to dispatch the code below to the main thread asynchronously as a workaround.
        // Workaround inspired by this: http://stackoverflow.com/questions/20181980/uidatepicker-bug-uicontroleventvaluechanged-after-hitting-minimum-internal
        [IFAUtils dispatchAsyncMainThreadBlock:^{
            self.IFA_datePicker.countDownDuration = self.IFA_countDownDuration;
        }];

    }else {

        if (self.IFA_seconds) {
            NSCalendarUnit l_unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSDateComponents *l_dateComponents = [[NSCalendar ifa_threadSafeCalendar] components:l_unitFlags
                                                                                        fromDate:self.IFA_dateAndTime];
            [l_dateComponents setSecond:[self.IFA_seconds intValue]];
            _IFA_dateAndTime = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_dateComponents];
        }
        
        self.IFA_datePicker.date = self.IFA_dateAndTime;
        self.IFA_timePicker.date = self.IFA_dateAndTime;

        [self IFA_updateSegmentedControlTitles];

    }

    [self updateModel];

}

@end
