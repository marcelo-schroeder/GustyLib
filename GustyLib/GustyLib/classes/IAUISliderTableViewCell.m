//
//  IAUISliderTableViewCell.m
//  Gusty
//
//  Created by Marcelo Schroeder on 18/05/11.
//  Copyright 2011 InfoAccent Pty Limited. All rights reserved.
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


@implementation IAUISliderTableViewCell

#pragma mark -
#pragma mark Overrides

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier object:(NSObject*)a_object propertyName:(NSString*)a_propertyName{
    if ((self=[super initWithStyle:style reuseIdentifier:reuseIdentifier object:a_object propertyName:a_propertyName])) {
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
//        self.selectionStyle = UITableViewCellEditingStyleNone;
        [[NSBundle mainBundle] loadNibNamed:@"IAUISliderView" owner:self options:nil];
//        NSDictionary *l_options = [[IAPersistenceManager sharedInstance].entityConfig optionsForProperty:a_propertyName inManagedObject:a_managedObject];
//        self.p_minLabel.text = [l_options valueForKey:@"minimumValueLabel"];
//        self.p_maxLabel.text = [l_options valueForKey:@"maximumValueLabel"];
//        self.p_slider.minimumValue = [[l_options valueForKey:@"minimumValue"] floatValue];
//        self.p_slider.maximumValue = [[l_options valueForKey:@"maximumValue"] floatValue];
        NSNumberFormatter *l_numberFormatter = [self.p_object numberFormatterForProperty:self.p_propertyName];
        NSNumber *l_minValue = [self.p_object minimumValueForProperty:self.p_propertyName];
        NSNumber *l_maxValue = [self.p_object maximumValueForProperty:self.p_propertyName];
        self.p_minLabel.text = [l_numberFormatter stringFromNumber:l_minValue];
        self.p_maxLabel.text = [l_numberFormatter stringFromNumber:l_maxValue];
        self.p_slider.minimumValue = [l_minValue floatValue];
        self.p_slider.maximumValue = [l_maxValue floatValue];
//		[self.p_slider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:NULL];
//        v_minimumValueDisplay = [[l_options valueForKey:@"minimumValueDisplay"] retain];
        self.p_nibView.center = self.center;
        CGRect l_frame = self.p_nibView.frame;
        l_frame.size.width = self.contentView.frame.size.width;
        self.p_nibView.frame = l_frame;
        [self.contentView addSubview:self.p_nibView];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

//-(void)willTransitionToState:(UITableViewCellStateMask)state{
//    [super willTransitionToState:state];
//    switch (state) {
//        case UITableViewCellStateDefaultMask:
//            self.p_slider.enabled = NO;
//            break;
//        case UITableViewCellStateShowingEditControlMask:
//            self.p_slider.enabled = YES;
//            break;
//        default:
//            break;
//    }
//}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    NSNumber *l_newValue = [object valueForKey:keyPath];
//    if (self.p_slider.minimumValue==[l_newValue floatValue] && v_minimumValueDisplay) {
//        self.detailTextLabel.text = v_minimumValueDisplay;
//    }else{
//        [super observeValueForKeyPath:self.p_propertyName ofObject:self.p_managedObject change:change context:context];
//    }
//}


@end
