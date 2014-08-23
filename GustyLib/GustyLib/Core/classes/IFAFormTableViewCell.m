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

@implementation IFAFormTableViewCell


#pragma mark - Public

//-(CGFloat)calculateFieldX {
//    return self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 10;
//}
//
//-(CGFloat)calculateFieldWidth {
//    return self.contentView.frame.size.width - [self calculateFieldX] - 10;
//}

- (void)setCustomAccessoryType:(IFAFormTableViewCellAccessoryType)a_customAccessoryType {
    NSString *l_imageName;
    switch (a_customAccessoryType){
        case IFAFormTableViewCellAccessoryTypeNone:
            l_imageName = nil;
            break;
        case IFAFormTableViewCellAccessoryTypeDisclosureIndicatorRight:
            l_imageName = @"IFA_Icon_DisclosureIndicatorRight";
            break;
        case IFAFormTableViewCellAccessoryTypeDisclosureIndicatorDown:
            l_imageName = @"IFA_Icon_DisclosureIndicatorDown";
            break;
    }
    self.customAccessoryImageView.image = l_imageName ? [UIImage imageNamed:l_imageName] : nil;
    self.customAccessoryImageView.hidden = l_imageName == nil;
    _customAccessoryType = a_customAccessoryType;
}

#pragma mark - Overrides

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier object:(NSObject*)a_object propertyName:(NSString*)a_propertyName indexPath:(NSIndexPath*)a_indexPath{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier object:a_object propertyName:a_propertyName indexPath:a_indexPath];

    [[NSBundle mainBundle] loadNibNamed:@"IFAFormTableViewCellContentView" owner:self options:nil];
    [self.contentView addSubview:self.customContentView];
    [self.customContentView ifa_addLayoutConstraintsToFillSuperview];

    // Configure standard text labels
//    self.textLabel.numberOfLines = 2;
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceForView:self.detailTextLabel];
//    self.detailTextLabel.font = [UIFont systemFontOfSize:16];

    return self;

}

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

//-(void)layoutSubviews{
//
//    [super layoutSubviews];
//
//    // Fine tune labels frames to distribute form elements better
//    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y-2, self.frame.size.width/4, self.textLabel.frame.size.height);
//    self.detailTextLabel.frame = CGRectMake([self calculateFieldX], 11, [self calculateFieldWidth], self.detailTextLabel.frame.size.height);
//
//}

@end
