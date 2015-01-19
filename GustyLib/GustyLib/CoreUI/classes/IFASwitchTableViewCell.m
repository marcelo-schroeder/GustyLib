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

#import "GustyLibCoreUI.h"


@interface IFASwitchTableViewCell ()
@property(nonatomic, strong) NSLayoutConstraint *IFA_switchControlLeftLayoutConstraint;
@property(nonatomic, strong) NSLayoutConstraint *IFA_switchControlRightLayoutConstraint;
@end

@implementation IFASwitchTableViewCell


#pragma mark - Overrides

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier propertyName:(NSString *)a_propertyName
                    indexPath:(NSIndexPath *)a_indexPath
           formViewController:(IFAFormViewController *)a_formViewController {
    if ((self= [super initWithReuseIdentifier:reuseIdentifier propertyName:a_propertyName indexPath:a_indexPath
                           formViewController:a_formViewController])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.customAccessoryType = IFAFormTableViewCellAccessoryTypeNone;
        self.switchControl = [[UISwitch alloc] init];
        self.switchControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self.customContentView addSubview:self.switchControl];
        [self.switchControl ifa_addLayoutConstraintToCenterInSuperviewVertically];
        [self.customContentView addConstraint:self.IFA_switchControlLeftLayoutConstraint];
        [self.customContentView addConstraint:self.IFA_switchControlRightLayoutConstraint];
        self.rightLabel.hidden = YES;
        NSAssert([self.customContentView.constraints containsObject:self.leftAndRightLabelsSpacingConstraint], @"Constraint not found");
        [self.customContentView removeConstraint:self.leftAndRightLabelsSpacingConstraint];
        [self.leftLabel setContentHuggingPriority:[self.leftLabel contentHuggingPriorityForAxis:UILayoutConstraintAxisHorizontal] + 1
                                          forAxis:UILayoutConstraintAxisHorizontal];
        [self.leftLabel setContentCompressionResistancePriority:[self.leftLabel contentCompressionResistancePriorityForAxis:UILayoutConstraintAxisHorizontal] + 1
                                                        forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)setLeftLabelText:(NSString *)a_leftLabelText rightLabelText:(NSString *)a_rightLabelText {

    self.leftLabel.text = a_leftLabelText;
    self.rightLabel.text = a_rightLabelText;

    CGFloat leftLabelPreferredMaxLayoutWidth = [self.leftLabel.text sizeWithAttributes:@{NSFontAttributeName:self.leftLabel.font}].width;
    CGFloat switchControlWidth = self.switchControl.bounds.size.width;

    CGFloat contentWidth = leftLabelPreferredMaxLayoutWidth + switchControlWidth;
    CGFloat spacingWidth = self.leftLabelLeftConstraint.constant
            + self.leftAndRightLabelsSpacingConstraint.constant
            + self.rightLabelRightConstraint.constant;    // The initial value of the right label's right constraint is the largest possible value, which is ok for the purpose of this calculation
    CGFloat usedWidth = contentWidth + spacingWidth;

    if (usedWidth > self.formViewController.view.bounds.size.width) {
        leftLabelPreferredMaxLayoutWidth = self.formViewController.view.bounds.size.width - (usedWidth - leftLabelPreferredMaxLayoutWidth);
    }
    self.leftLabel.preferredMaxLayoutWidth = leftLabelPreferredMaxLayoutWidth;

}

#pragma mark - Private

- (NSLayoutConstraint *)IFA_switchControlLeftLayoutConstraint {
    if (!_IFA_switchControlLeftLayoutConstraint) {
        _IFA_switchControlLeftLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.switchControl
                                                                              attribute:NSLayoutAttributeLeft
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.leftLabel
                                                                              attribute:NSLayoutAttributeRight
                                                                             multiplier:1
                                                                               constant:self.leftAndRightLabelsSpacingConstraint.constant];
    }
    return _IFA_switchControlLeftLayoutConstraint;
}

- (NSLayoutConstraint *)IFA_switchControlRightLayoutConstraint {
    if (!_IFA_switchControlRightLayoutConstraint) {
        _IFA_switchControlRightLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.switchControl
                                                                               attribute:NSLayoutAttributeRight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.customContentView
                                                                               attribute:NSLayoutAttributeRight
                                                                              multiplier:1
                                                                                constant:-self.leftLabelLeftConstraint.constant];
    }
    return _IFA_switchControlRightLayoutConstraint;
}

@end
