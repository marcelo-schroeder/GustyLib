//
//  IFAFormTableViewCell.m
//  Gusty
//
//  Created by Marcelo Schroeder on 28/10/11.
//  Copyright (c) 2011 InfoAccent Pty Limited. All rights reserved.
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

@interface IFAFormTableViewCell ()
@property (nonatomic, strong) NSString *propertyName;
@property (nonatomic, weak) IFAFormViewController *formViewController;
@property(nonatomic) CGFloat IFA_originalLeftAndRightLabelsSpacingConstraintConstant;
@end

@implementation IFAFormTableViewCell


#pragma mark - Public

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier propertyName:(NSString *)a_propertyName
                    indexPath:(NSIndexPath *)a_indexPath
           formViewController:(IFAFormViewController *)a_formViewController {
//    NSLog(@"     initWithReuseIdentifier reuseIdentifier = %@", reuseIdentifier);
//    NSLog(@"       a_propertyName = %@", a_propertyName);
//    NSLog(@"       [a_indexPath description] = %@", [a_indexPath description]);
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.propertyName = a_propertyName;
        self.indexPath = a_indexPath;
        self.formViewController = a_formViewController;
        [[NSBundle mainBundle] loadNibNamed:@"IFAFormTableViewCellContentView" owner:self options:nil];
        self.IFA_originalLeftAndRightLabelsSpacingConstraintConstant = self.leftAndRightLabelsSpacingConstraint.constant;
        self.centeredLabel.hidden = YES;
        [self.contentView addSubview:self.customContentView];
        [self.customContentView ifa_addLayoutConstraintsToFillSuperview];
        // Dynamic type support - this guarantees that the table cell will have the minimum tap dimension for height
        [self.customContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.customContentView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                              toItem:nil
                                                                           attribute:0
                                                                          multiplier:1
                                                                            constant:IFAMinimumTapAreaDimension]];
        [self.ifa_appearanceTheme setAppearanceOnInitForView:self];
    }
    return self;
}

- (IBAction)onCustomAccessoryButtonTap {
    [self.formViewController.tableView.delegate tableView:self.formViewController.tableView
                                  didSelectRowAtIndexPath:self.indexPath];
}

- (NSObject *)object {
    return self.formViewController.object;
}


- (void)setCustomAccessoryType:(IFAFormTableViewCellAccessoryType)a_customAccessoryType {
    _customAccessoryType = a_customAccessoryType;
    [((IFADefaultAppearanceTheme *) self.ifa_appearanceTheme) setCustomAccessoryViewAppearanceForFormTableViewCell:self];
}

- (void)setLeftLabelText:(NSString *)a_leftLabelText rightLabelText:(NSString *)a_rightLabelText {

    self.leftLabel.text = a_leftLabelText;
    self.rightLabel.text = a_rightLabelText;

    if (a_rightLabelText) {
        self.leftAndRightLabelsSpacingConstraint.constant = self.IFA_originalLeftAndRightLabelsSpacingConstraintConstant;
    } else {
        self.leftAndRightLabelsSpacingConstraint.constant = 0;
    }

    CGFloat leftLabelPreferredMaxLayoutWidth = ceilf([self.leftLabel.text sizeWithAttributes:@{NSFontAttributeName:self.leftLabel.font}].width);
    CGFloat rightLabelPreferredMaxLayoutWidth = ceilf([self.rightLabel.text sizeWithAttributes:@{NSFontAttributeName:self.rightLabel.font}].width);

    CGFloat contentWidth = leftLabelPreferredMaxLayoutWidth + rightLabelPreferredMaxLayoutWidth;
    CGFloat spacingWidth = self.leftLabelLeftConstraint.constant
            + self.leftAndRightLabelsSpacingConstraint.constant
            + self.rightLabelRightConstraint.constant;    // The initial value of the right label's right constraint is the largest possible value, which is ok for the purpose of this calculation
    CGFloat usedWidth = contentWidth + spacingWidth;

//    NSLog(@"self.indexPath = %@", self.indexPath);
//    NSLog(@"  self.leftLabel.text = %@", self.leftLabel.text);
//    NSLog(@"  self.rightLabel.text = %@", self.rightLabel.text);
//    NSLog(@"  self.leftLabelLeftConstraint.constant = %f", self.leftLabelLeftConstraint.constant);
//    NSLog(@"  self.leftAndRightLabelsSpacingConstraint.constant = %f", self.leftAndRightLabelsSpacingConstraint.constant);
//    NSLog(@"  self.rightLabelRightConstraint.constant = %f", self.rightLabelRightConstraint.constant);
//    NSLog(@"  leftLabelPreferredMaxLayoutWidth = %f", leftLabelPreferredMaxLayoutWidth);
//    NSLog(@"  rightLabelPreferredMaxLayoutWidth = %f", rightLabelPreferredMaxLayoutWidth);
//    NSLog(@"  contentWidth = %f", contentWidth);
//    NSLog(@"  spacingWidth = %f", spacingWidth);
//    NSLog(@"  usedWidth = %f", usedWidth);
//    NSLog(@"  self.formViewController.view.bounds.size.width = %f", self.formViewController.view.bounds.size.width);

    if (usedWidth > self.formViewController.view.bounds.size.width) {
        CGFloat maximumContentWidth = self.formViewController.view.bounds.size.width - spacingWidth;
        CGFloat maximumLabelWidth = maximumContentWidth / 2;
//        NSLog(@"  maximumContentWidth = %f", maximumContentWidth);
//        NSLog(@"  maximumLabelWidth = %f", maximumLabelWidth);
        if (leftLabelPreferredMaxLayoutWidth > maximumLabelWidth && rightLabelPreferredMaxLayoutWidth > maximumLabelWidth) {
//            NSLog(@"  ADJUSTMENT CASE 1");
            leftLabelPreferredMaxLayoutWidth = maximumLabelWidth;
            rightLabelPreferredMaxLayoutWidth = leftLabelPreferredMaxLayoutWidth;
        }else if (leftLabelPreferredMaxLayoutWidth > maximumLabelWidth) {
//            NSLog(@"  ADJUSTMENT CASE 2");
            leftLabelPreferredMaxLayoutWidth = maximumContentWidth - rightLabelPreferredMaxLayoutWidth;
        }else if (rightLabelPreferredMaxLayoutWidth > maximumLabelWidth) {
//            NSLog(@"  ADJUSTMENT CASE 3");
            rightLabelPreferredMaxLayoutWidth = maximumContentWidth - leftLabelPreferredMaxLayoutWidth;
        }
//        NSLog(@"  ADJUSTED leftLabelPreferredMaxLayoutWidth = %f", leftLabelPreferredMaxLayoutWidth);
//        NSLog(@"  ADJUSTED rightLabelPreferredMaxLayoutWidth = %f", rightLabelPreferredMaxLayoutWidth);
    }
    self.leftLabel.preferredMaxLayoutWidth = leftLabelPreferredMaxLayoutWidth;
    self.rightLabel.preferredMaxLayoutWidth = rightLabelPreferredMaxLayoutWidth;

}

@end
