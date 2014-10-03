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

#import "GustyLibCore.h"

@interface IFAFormTableViewCell ()
@property (nonatomic, strong) NSString *propertyName;
@property (nonatomic, weak) IFAFormViewController *formViewController;
@end

@implementation IFAFormTableViewCell


#pragma mark - Public

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier propertyName:(NSString *)a_propertyName
                    indexPath:(NSIndexPath *)a_indexPath
           formViewController:(IFAFormViewController *)a_formViewController {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.propertyName = a_propertyName;
        self.indexPath = a_indexPath;
        self.formViewController = a_formViewController;
        [[NSBundle mainBundle] loadNibNamed:@"IFAFormTableViewCellContentView" owner:self options:nil];
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

#pragma mark - Overrides

- (void)layoutSubviews {
    CGFloat l_horizontalSpace = self.leftLabelLeftConstraint.constant;
    BOOL l_areCustomAccessoryViewsHidden = self.customAccessoryImageView.hidden && self.customAccessoryButton.hidden;
    if (l_areCustomAccessoryViewsHidden) {
        self.rightLabelRightConstraint.constant = l_horizontalSpace;
    }
    else {
        UIView *l_visibleCustomAccessoryView = self.customAccessoryImageView.hidden ? self.customAccessoryButton : self.customAccessoryImageView;
        CGFloat l_customAccessoryViewWidth = l_visibleCustomAccessoryView.bounds.size.width;
        self.rightLabelRightConstraint.constant = l_horizontalSpace * 2 + l_customAccessoryViewWidth;
    }
    [super layoutSubviews];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    //wip: review - this should probably be moved to the appearance theme
    self.leftLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.centeredLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.rightLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

@end
