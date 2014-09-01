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
@property (nonatomic, weak) IFAFormViewController *formViewController;
@end

@implementation IFAFormTableViewCell


#pragma mark - Public

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier object:(NSObject *)a_object
                 propertyName:(NSString *)a_propertyName indexPath:(NSIndexPath *)a_indexPath
           formViewController:(IFAFormViewController *)a_formViewController {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier object:a_object
                   propertyName:a_propertyName indexPath:a_indexPath];
    if (self) {
        self.formViewController = a_formViewController;
        [[NSBundle mainBundle] loadNibNamed:@"IFAFormTableViewCellContentView" owner:self options:nil];
        self.centeredLabel.hidden = YES;
        [self.contentView addSubview:self.customContentView];
        [self.customContentView ifa_addLayoutConstraintsToFillSuperview];
    }
    return self;
}

- (void)setCustomAccessoryType:(IFAFormTableViewCellAccessoryType)a_customAccessoryType {
    _customAccessoryType = a_customAccessoryType;
    [((IFADefaultAppearanceTheme *) self.ifa_appearanceTheme) setCustomAccessoryViewAppearanceForFormTableViewCell:self];
}

#pragma mark - Overrides

- (void)willTransitionToState:(UITableViewCellStateMask)state{
    [super willTransitionToState:state];
//    NSLog(@"willTransitionToState: %u, indexPath: %@", state, [self.indexPath description]);
    [self.formViewController populateCell:self];
}

- (void)layoutSubviews {
    CGFloat l_horizontalSpace = self.leftLabelLeftConstraint.constant;
    self.rightLabelRightConstraint.constant = self.customAccessoryImageView.hidden ? l_horizontalSpace : (l_horizontalSpace * 2 + self.customAccessoryImageView.bounds.size.width);
    [super layoutSubviews];
}

@end
