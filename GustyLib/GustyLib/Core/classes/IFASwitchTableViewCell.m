//
//  IFASwitchTableViewCell.m
//  Gusty
//
//  Created by Marcelo Schroeder on 20/05/11.
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

#import "IFACommon.h"


@implementation IFASwitchTableViewCell


#pragma mark - Overrides

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier object:(NSObject*)a_object propertyName:(NSString*)a_propertyName indexPath:(NSIndexPath *)a_indexPath{
    if ((self=[super initWithStyle:style reuseIdentifier:reuseIdentifier object:a_object propertyName:a_propertyName indexPath:a_indexPath])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.customAccessoryType = IFAFormTableViewCellAccessoryTypeNone;
        self.switchControl = [[UISwitch alloc] init];
        self.switchControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.switchControl];
        [self.switchControl ifa_addLayoutConstraintToCenterInSuperviewVertically];
        NSLayoutConstraint *l_leftLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.switchControl
                                                                                   attribute:NSLayoutAttributeRight
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.rightLabel
                                                                                   attribute:NSLayoutAttributeRight
                                                                                  multiplier:1
                                                                                    constant:0];
        [self.contentView addConstraint:l_leftLayoutConstraint];
        self.rightLabel.hidden = YES;
    }
    return self;
}

-(void)willTransitionToState:(UITableViewCellStateMask)state{
    [super willTransitionToState:state];
    switch (state) {
        case UITableViewCellStateDefaultMask:
            self.switchControl.enabled = NO;
            break;
        case UITableViewCellStateShowingEditControlMask:
            self.switchControl.enabled = self.enabledInEditing;
            break;
        default:
            break;
    }
}

@end
