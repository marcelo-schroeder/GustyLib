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

#ifdef IFA_AVAILABLE_Help
#import "UIViewController+IFAHelp.h"
#endif

@interface IFADatePickerViewController ()

@property (nonatomic, strong) NSDate *IFA_dateAndTime;
@property (nonatomic) NSTimeInterval IFA_countDownDuration;
@property (nonatomic, strong) UIBarButtonItem *IFA_showDatePickerBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *IFA_showTimePickerBarButtonItem;
@property (nonatomic, strong) UILabel *IFA_dateAndTimeLabel;

@property(nonatomic, strong) UIDatePicker *IFA_datePicker;
@property(nonatomic, strong) UIDatePicker *IFA_timePicker;
@property(nonatomic, strong) NSMutableArray *IFA_toolbarItems;
@property(nonatomic, strong) NSNumber *IFA_seconds;
@end

@implementation IFADatePickerViewController


static NSString * const k_valueCellId = @"valueCell";

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
    self.IFA_dateAndTime = [[NSDate date] ifa_lastMidnightForCalendar:[self calendar]] ;
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

-(void)IFA_updateToolbarLabelForDate:(NSDate *)a_date shouldShowTime:(BOOL)a_shouldShowTime{
    NSDateFormatter *l_dateFormatter = [[NSDateFormatter alloc] init];
    [l_dateFormatter setDateStyle:(a_shouldShowTime ? NSDateFormatterNoStyle : NSDateFormatterMediumStyle)];
    [l_dateFormatter setTimeStyle:(a_shouldShowTime ? NSDateFormatterMediumStyle : NSDateFormatterNoStyle)];
    self.IFA_dateAndTimeLabel.text = [l_dateFormatter stringFromDate:a_date];
    [self.IFA_dateAndTimeLabel sizeToFit];
}

-(void)IFA_updateToolbarLabel {
    [self IFA_updateToolbarLabelForDate:self.IFA_dateAndTime shouldShowTime:self.IFA_timePicker.hidden];
}

-(void)IFA_onDateAndTimeToggleButtonTap:(UIBarButtonItem*)a_barButtonItem{
    self.IFA_datePicker.hidden = self.IFA_timePicker.hidden;
    self.IFA_timePicker.hidden = !self.IFA_datePicker.hidden;
    NSMutableArray *l_tooolbarItems = [self.toolbarItems mutableCopy];
    [l_tooolbarItems removeObject:a_barButtonItem];
    [l_tooolbarItems insertObject:(self.IFA_datePicker.hidden?self.IFA_showDatePickerBarButtonItem :self.IFA_showTimePickerBarButtonItem) atIndex:0];
    [self IFA_updateToolbarLabel];
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
                                                                     action:@selector(IFA_onSelectNowButtonTap:)];
        [l_toolbarItems addObject:selectNowButton];
    }
    if (l_showSelectTodayButton) {
        UIBarButtonItem *selectTodayButton = [IFAUIUtils barButtonItemForType:IFABarButtonItemSelectToday
                                                                       target:a_target
                                                                       action:@selector(IFA_onSelectTodayButtonTap:)];
        [l_toolbarItems addObject:selectTodayButton];
    }
    if (l_showResetCountDownButton) {
        UIBarButtonItem *l_resetCountDownButton = [[UIBarButtonItem alloc] initWithTitle:@"Set To Zero"
                                                                                   style:UIBarButtonItemStyleBordered
                                                                                  target:a_target
                                                                                  action:@selector(IFA_onResetCountDownButtonTap:)];
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
                                                                               action:@selector(IFA_onClearDateButtonTap:)];
//            clearDateButton.accessibilityLabel = @"Clear Date";
            [l_toolbarItems addObjectsFromArray:@[flexibleSpace, clearDateButton]];
        }
        if (l_showSelectDistantPastButton) {
            UIBarButtonItem *l_selectDistantPastButton = [[UIBarButtonItem alloc] initWithTitle:@"Distant Past"
                                                                                          style:UIBarButtonItemStyleBordered
                                                                                         target:a_target
                                                                                         action:@selector(IFA_onSelectDistantPastButtonTap:)];
//            l_selectDistantPastButton.accessibilityLabel = @"Distant Past";
            [l_toolbarItems addObjectsFromArray:@[flexibleSpace, l_selectDistantPastButton]];
        }
        if (l_showSelectDistantFutureButton) {
            UIBarButtonItem *l_selectDistantFutureButton = [[UIBarButtonItem alloc] initWithTitle:@"Distant Future"
                                                                                            style:UIBarButtonItemStyleBordered
                                                                                           target:a_target
                                                                                           action:@selector(IFA_onSelectDistantFutureButtonTap:)];
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
            
            self.IFA_timePicker = [self newDatePickerForProperty:aPropertyName inObject:anObject pickerMode:UIDatePickerModeTime];
//            v_timePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            self.IFA_timePicker.hidden = YES;
            [self.IFA_timePicker addTarget:self action:@selector(IFA_onTimePickerValueChanged)
                          forControlEvents:UIControlEventValueChanged];

        }

        self.IFA_datePicker = [self newDatePickerForProperty:aPropertyName inObject:anObject pickerMode:self.datePickerMode];
//        v_datePicker.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        self.IFA_datePicker.hidden = NO;
        [self.IFA_datePicker addTarget:self action:@selector(IFA_onDatePickerValueChanged)
                      forControlEvents:UIControlEventValueChanged];
        
        // Customise toolbar items
        self.IFA_toolbarItems = [NSMutableArray arrayWithArray:[self IFA_datePickerToolbarItemsForProperty:aPropertyName
                                                                                           inObject:anObject
                                                                                             target:self]];
        if (self.showTimePicker) {

            NSAssert([self.IFA_toolbarItems count]==3, @"Unexpected array count: %u", [self.IFA_toolbarItems count]);

            UIBarButtonItem *l_flexibleSpace = [self.IFA_toolbarItems objectAtIndex:1];

            self.IFA_showDatePickerBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Calendar-Month.png"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(IFA_onDateAndTimeToggleButtonTap:)];
#ifdef IFA_AVAILABLE_Help
            self.IFA_showDatePickerBarButtonItem.accessibilityLabel = [self ifa_accessibilityLabelForName:@"showDatePickerButton"];
#endif

            self.IFA_showTimePickerBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"11-clock.png"]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(IFA_onDateAndTimeToggleButtonTap:)];
#ifdef IFA_AVAILABLE_Help
            self.IFA_showTimePickerBarButtonItem.accessibilityLabel = [self ifa_accessibilityLabelForName:@"showTimePickerButton"];
#endif

            self.IFA_dateAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            self.IFA_dateAndTimeLabel.backgroundColor = [UIColor clearColor];
            self.IFA_dateAndTimeLabel.textColor = [UIColor whiteColor];
            [[self ifa_appearanceTheme] setAppearanceForView:self.IFA_dateAndTimeLabel];
            self.IFA_dateAndTimeLabel.textAlignment = NSTextAlignmentCenter;
            
            UIBarButtonItem *l_dateAndTimeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.IFA_dateAndTimeLabel];
            [self.IFA_toolbarItems removeObject:l_flexibleSpace];
            [self.IFA_toolbarItems insertObject:self.IFA_showTimePickerBarButtonItem atIndex:0];
            [self.IFA_toolbarItems insertObject:l_dateAndTimeBarButtonItem atIndex:1];
            [self.IFA_toolbarItems insertObject:l_flexibleSpace atIndex:2];

        }
        
        if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {
            [self addObserver:self forKeyPath:@"IFA_countDownDuration" options:0 context:nil];
            self.IFA_countDownDuration = [[self.object valueForKey:self.propertyName] doubleValue];
        }else{
            [self addObserver:self forKeyPath:@"IFA_dateAndTime" options:0 context:nil];
            self.IFA_dateAndTime = [self.object valueForKey:self.propertyName];
        }

        NSDictionary *l_options = [[IFAPersistenceManager sharedInstance].entityConfig optionsForProperty:self.propertyName
                                                                                                inObject:self.object];
        self.IFA_seconds = [l_options objectForKey:@"seconds"];
        
        // Configure view
        [self.view addSubview:self.IFA_datePicker];
        [self.view addSubview:self.IFA_timePicker];
        self.view.frame = self.IFA_datePicker.frame;

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

#pragma mark - NSKeyValueObserving

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
//    NSLog(@"observeValueForKeyPath");
    
    if (self.datePickerMode ==UIDatePickerModeCountDownTimer) {

        self.IFA_datePicker.countDownDuration = self.IFA_countDownDuration;
    
    }else {

        if (self.IFA_seconds) {
            unsigned l_unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *l_dateComponents = [[NSCalendar ifa_threadSafeCalendar] components:l_unitFlags
                                                                                        fromDate:self.IFA_dateAndTime];
            [l_dateComponents setSecond:[self.IFA_seconds intValue]];
            _IFA_dateAndTime = [[NSCalendar ifa_threadSafeCalendar] dateFromComponents:l_dateComponents];
        }
        
        self.IFA_datePicker.date = self.IFA_dateAndTime;
        self.IFA_timePicker.date = self.IFA_dateAndTime;

        [self IFA_updateToolbarLabel];

    }

    [self updateModel];

}

@end
