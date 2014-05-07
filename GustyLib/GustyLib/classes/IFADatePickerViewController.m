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

#import "IFACommon.h"

@interface IFADatePickerViewController ()

@property (nonatomic, strong) NSDate *XYZ_dateAndTime;
@property (nonatomic) NSTimeInterval XYZ_countDownDuration;
@property (nonatomic, strong) UIBarButtonItem *XYZ_showDatePickerBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *XYZ_showTimePickerBarButtonItem;
@property (nonatomic, strong) UILabel *XYZ_dateAndTimeLabel;

@end

@implementation IFADatePickerViewController {

    @private
	UIDatePicker *v_datePicker;
	UIDatePicker *v_timePicker;
    NSMutableArray *v_toolbarItems;
	NSNumber *v_seconds;

}


static NSString * const k_valueCellId = @"valueCell";

#pragma mark - Private

-(void)XYZ_onDatePickerValueChanged {
    if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {
        self.XYZ_countDownDuration = v_datePicker.countDownDuration;
    }else{
        self.XYZ_dateAndTime = v_datePicker.date;
    }
}

-(void)XYZ_onTimePickerValueChanged {
    self.XYZ_dateAndTime = v_timePicker.date;
}

-(void)XYZ_onSelectNowButtonTap:(id)aSender{
    self.XYZ_dateAndTime = [NSDate IFA_dateWithSecondPrecision];
}

-(void)XYZ_onSelectTodayButtonTap:(id)aSender{
    self.XYZ_dateAndTime = [[NSDate date] IFA_lastMidnightForCalendar:[self calendar]] ;
}

-(void)XYZ_onSelectDistantPastButtonTap:(id)aSender{
    self.XYZ_dateAndTime = [NSDate distantPast];
}

-(void)XYZ_onSelectDistantFutureButtonTap:(id)aSender{
    self.XYZ_dateAndTime = [NSDate distantFuture];
}

-(void)XYZ_onClearDateButtonTap:(id)aSender{
    self.XYZ_dateAndTime = nil;
    [self done];
}

-(void)XYZ_onResetCountDownButtonTap:(id)aSender{
    self.XYZ_countDownDuration = 0;
    [self done];
}

-(void)XYZ_updateToolbarLabelForDate:(NSDate *)a_date shouldShowTime:(BOOL)a_shouldShowTime{
    NSDateFormatter *l_dateFormatter = [[NSDateFormatter alloc] init];
    [l_dateFormatter setDateStyle:(a_shouldShowTime ? NSDateFormatterNoStyle : NSDateFormatterMediumStyle)];
    [l_dateFormatter setTimeStyle:(a_shouldShowTime ? NSDateFormatterMediumStyle : NSDateFormatterNoStyle)];
    self.XYZ_dateAndTimeLabel.text = [l_dateFormatter stringFromDate:a_date];
    [self.XYZ_dateAndTimeLabel sizeToFit];
}

-(void)XYZ_updateToolbarLabel {
    [self XYZ_updateToolbarLabelForDate:self.XYZ_dateAndTime shouldShowTime:v_timePicker.hidden];
}

-(void)XYZ_onDateAndTimeToggleButtonTap:(UIBarButtonItem*)a_barButtonItem{
    v_datePicker.hidden = v_timePicker.hidden;
    v_timePicker.hidden = !v_datePicker.hidden;
    NSMutableArray *l_tooolbarItems = [self.toolbarItems mutableCopy];
    [l_tooolbarItems removeObject:a_barButtonItem];
    [l_tooolbarItems insertObject:(v_datePicker.hidden?self.XYZ_showDatePickerBarButtonItem :self.XYZ_showTimePickerBarButtonItem) atIndex:0];
    [self XYZ_updateToolbarLabel];
    [self setToolbarItems:l_tooolbarItems animated:YES];
}

-(UIDatePicker*)newDatePickerForProperty:(NSString*)a_propertyName inObject:(NSObject*)a_object pickerMode:(UIDatePickerMode)a_pickerMode{
	UIDatePicker *l_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    l_datePicker.datePickerMode = a_pickerMode;
    if (l_datePicker.datePickerMode!=UIDatePickerModeCountDownTimer) {
        NSDictionary *l_optionsDict = [[IFAPersistenceManager sharedInstance].entityConfig optionsForProperty:a_propertyName inObject:a_object];
        l_datePicker.minimumDate = [NSDate distantPast];
        BOOL l_preventFutureDateSelection = [[l_optionsDict objectForKey:@"preventFutureDateSelection"] boolValue];
        BOOL l_preventFutureDateSelectionExceptTomorrow = [[l_optionsDict objectForKey:@"preventFutureDateSelectionExceptTomorrow"] boolValue];
        if (l_preventFutureDateSelection || l_preventFutureDateSelectionExceptTomorrow) {
            if (l_preventFutureDateSelection) {
                l_datePicker.maximumDate = [[NSDate date] IFA_lastMidnightForCalendar:[NSCalendar IFA_threadSafeCalendar]];
            }else{
                l_datePicker.maximumDate = [[NSDate date] IFA_nextMidnightForCalendar:[NSCalendar IFA_threadSafeCalendar]];
            }
        }else{
            l_datePicker.maximumDate = [NSDate distantFuture];
        }
    }
    return l_datePicker;
}

-(NSArray*)XYZ_datePickerToolbarItemsForProperty:(NSString *)a_propertyName inObject:(NSObject *)a_object target:(id)a_target{
    
    NSDictionary *l_optionsDict = [[IFAPersistenceManager sharedInstance].entityConfig optionsForProperty:a_propertyName inObject:a_object];
	BOOL l_showSelectNowButton = [[l_optionsDict objectForKey:@"showSelectNowButton"] boolValue];
	BOOL l_showSelectTodayButton = [[l_optionsDict objectForKey:@"showSelectTodayButton"] boolValue];
	BOOL l_showClearDateButton = [[l_optionsDict objectForKey:@"showClearDateButton"] boolValue];
	BOOL l_showResetCountDownButton = [[l_optionsDict objectForKey:@"showResetCountDownButton"] boolValue];
	BOOL l_showSelectDistantPastButton = [[l_optionsDict objectForKey:@"showSelectDistantPastButton"] boolValue];
	BOOL l_showSelectDistantFutureButton = [[l_optionsDict objectForKey:@"showSelectDistantFutureButton"] boolValue];
	
    NSMutableArray *l_toolbarItems = [NSMutableArray array];
    if (l_showSelectNowButton) {
        UIBarButtonItem *selectNowButton = [IFAUIUtils barButtonItemForType:IFABarButtonItemSelectNow
                                                                     target:a_target
                                                                     action:@selector(XYZ_onSelectNowButtonTap:)];
        [l_toolbarItems addObject:selectNowButton];
    }
    if (l_showSelectTodayButton) {
        UIBarButtonItem *selectTodayButton = [IFAUIUtils barButtonItemForType:IFABarButtonItemSelectToday
                                                                       target:a_target
                                                                       action:@selector(XYZ_onSelectTodayButtonTap:)];
        [l_toolbarItems addObject:selectTodayButton];
    }
    if (l_showResetCountDownButton) {
        UIBarButtonItem *l_resetCountDownButton = [[UIBarButtonItem alloc] initWithTitle:@"Set To Zero"
                                                                                   style:UIBarButtonItemStyleBordered
                                                                                  target:a_target
                                                                                  action:@selector(XYZ_onResetCountDownButtonTap:)];
//        l_resetCountDownButton.accessibilityLabel = @"Set To Zero";
        [l_toolbarItems addObject:l_resetCountDownButton];
    }
    if (l_showClearDateButton || l_showSelectDistantPastButton || l_showSelectDistantFutureButton) {
        UIBarButtonItem *flexibleSpace = [IFAUIUtils barButtonItemForType:IFABarButtonItemFlexibleSpace
                                                                   target:nil
                                                                   action:nil];
        if (l_showClearDateButton) {
            UIBarButtonItem *clearDateButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear Date"
                                                                                style:UIBarButtonItemStyleBordered
                                                                               target:a_target
                                                                               action:@selector(XYZ_onClearDateButtonTap:)];
//            clearDateButton.accessibilityLabel = @"Clear Date";
            [l_toolbarItems addObjectsFromArray:@[flexibleSpace, clearDateButton]];
        }
        if (l_showSelectDistantPastButton) {
            UIBarButtonItem *l_selectDistantPastButton = [[UIBarButtonItem alloc] initWithTitle:@"Distant Past"
                                                                                          style:UIBarButtonItemStyleBordered
                                                                                         target:a_target
                                                                                         action:@selector(XYZ_onSelectDistantPastButtonTap:)];
//            l_selectDistantPastButton.accessibilityLabel = @"Distant Past";
            [l_toolbarItems addObjectsFromArray:@[flexibleSpace, l_selectDistantPastButton]];
        }
        if (l_showSelectDistantFutureButton) {
            UIBarButtonItem *l_selectDistantFutureButton = [[UIBarButtonItem alloc] initWithTitle:@"Distant Future"
                                                                                            style:UIBarButtonItemStyleBordered
                                                                                           target:a_target
                                                                                           action:@selector(XYZ_onSelectDistantFutureButtonTap:)];
//            l_selectDistantFutureButton.accessibilityLabel = @"Distant Future";
            [l_toolbarItems addObjectsFromArray:@[flexibleSpace, l_selectDistantFutureButton]];
        }
    }
    
    return l_toolbarItems;
    
}

#pragma mark - Public

-(id)initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName datePickerMode:(UIDatePickerMode)aDatePickerMode showTimePicker:(BOOL)aShowTimePickerFlag{
    return [self initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:NO datePickerMode:aDatePickerMode showTimePicker:aShowTimePickerFlag];
}

-(id)initWithObject:(NSObject *)anObject propertyName:(NSString *)aPropertyName useButtonForDismissal:(BOOL)a_useButtonForDismissal datePickerMode:(UIDatePickerMode)aDatePickerMode showTimePicker:(BOOL)aShowTimePickerFlag{

    if (self= [super initWithObject:anObject propertyName:aPropertyName useButtonForDismissal:a_useButtonForDismissal
                          presenter:nil ]) {
        
        self.datePickerMode = aDatePickerMode;
        self.showTimePicker = aShowTimePickerFlag;

        if (self.showTimePicker) {
            
            v_timePicker = [self newDatePickerForProperty:aPropertyName inObject:anObject pickerMode:UIDatePickerModeTime];
//            v_timePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            v_timePicker.hidden = YES;
            [v_timePicker addTarget:self action:@selector(XYZ_onTimePickerValueChanged)
                   forControlEvents:UIControlEventValueChanged];

        }

        v_datePicker = [self newDatePickerForProperty:aPropertyName inObject:anObject pickerMode:self.datePickerMode];
//        v_datePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        v_datePicker.hidden = NO;
        [v_datePicker addTarget:self action:@selector(XYZ_onDatePickerValueChanged)
               forControlEvents:UIControlEventValueChanged];
        
        // Customise toolbar items
        v_toolbarItems = [NSMutableArray arrayWithArray:[self XYZ_datePickerToolbarItemsForProperty:aPropertyName
                                                                                           inObject:anObject
                                                                                             target:self]];
        if (self.showTimePicker) {

            NSAssert([v_toolbarItems count]==3, @"Unexpected array count: %u", [v_toolbarItems count]);

            UIBarButtonItem *l_flexibleSpace = [v_toolbarItems objectAtIndex:1];

            self.XYZ_showDatePickerBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Calendar-Month.png"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(XYZ_onDateAndTimeToggleButtonTap:)];
            self.XYZ_showDatePickerBarButtonItem.accessibilityLabel = [self IFA_accessibilityLabelForName:@"showDatePickerButton"];

            self.XYZ_showTimePickerBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"11-clock.png"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(XYZ_onDateAndTimeToggleButtonTap:)];
            self.XYZ_showTimePickerBarButtonItem.accessibilityLabel = [self IFA_accessibilityLabelForName:@"showTimePickerButton"];
            
            self.XYZ_dateAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            self.XYZ_dateAndTimeLabel.backgroundColor = [UIColor clearColor];
            self.XYZ_dateAndTimeLabel.textColor = [UIColor whiteColor];
            [[self IFA_appearanceTheme] setAppearanceForView:self.XYZ_dateAndTimeLabel];
            self.XYZ_dateAndTimeLabel.textAlignment = NSTextAlignmentCenter;
            
            UIBarButtonItem *l_dateAndTimeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.XYZ_dateAndTimeLabel];
            [v_toolbarItems removeObject:l_flexibleSpace];
            [v_toolbarItems insertObject:self.XYZ_showTimePickerBarButtonItem atIndex:0];
            [v_toolbarItems insertObject:l_dateAndTimeBarButtonItem atIndex:1];
            [v_toolbarItems insertObject:l_flexibleSpace atIndex:2];

        }
        
        if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {
            [self addObserver:self forKeyPath:@"XYZ_countDownDuration" options:0 context:nil];
            self.XYZ_countDownDuration = [[self.object valueForKey:self.propertyName] doubleValue];
        }else{
            [self addObserver:self forKeyPath:@"XYZ_dateAndTime" options:0 context:nil];
            self.XYZ_dateAndTime = [self.object valueForKey:self.propertyName];
        }

        NSDictionary *l_options = [[IFAPersistenceManager sharedInstance].entityConfig optionsForProperty:self.propertyName
                                                                                                inObject:self.object];
        v_seconds = [l_options objectForKey:@"seconds"];
        
        // Configure view
        [self.view addSubview:v_datePicker];
        [self.view addSubview:v_timePicker];
        self.view.frame = v_datePicker.frame;

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

- (NSArray*)IFA_editModeToolbarItems {
    return v_toolbarItems;
}

-(id)editedValue {
    if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {
        return @(self.XYZ_countDownDuration);
    }else{
        return self.XYZ_dateAndTime;
    }
}

-(void)dealloc{
    if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {
        [self removeObserver:self forKeyPath:@"XYZ_countDownDuration"];
    }else {
        [self removeObserver:self forKeyPath:@"XYZ_dateAndTime"];
    }
}

-(BOOL)IFA_hasFixedSize {
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

#pragma mark - NSKeyValueObserving

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
//    NSLog(@"observeValueForKeyPath");
    
    if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {

        v_datePicker.countDownDuration = self.XYZ_countDownDuration;
    
    }else {

        if (v_seconds) {
            unsigned l_unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *l_dateComponents = [[NSCalendar IFA_threadSafeCalendar] components:l_unitFlags
                                                                                        fromDate:self.XYZ_dateAndTime];
            [l_dateComponents setSecond:[v_seconds intValue]];
            _XYZ_dateAndTime = [[NSCalendar IFA_threadSafeCalendar] dateFromComponents:l_dateComponents];
        }
        
        v_datePicker.date = self.XYZ_dateAndTime;
        v_timePicker.date = self.XYZ_dateAndTime;

        [self XYZ_updateToolbarLabel];

    }

    [self updateModel];

}

@end
