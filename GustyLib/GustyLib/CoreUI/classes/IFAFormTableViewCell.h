//
//  IFAFormTableViewCell.h
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

#import "IFATableViewCell.h"

typedef NS_ENUM(NSUInteger, IFAFormTableViewCellAccessoryType){
    IFAFormTableViewCellAccessoryTypeNone,
    IFAFormTableViewCellAccessoryTypeDisclosureIndicatorRight,
    IFAFormTableViewCellAccessoryTypeDisclosureIndicatorDown,
    IFAFormTableViewCellAccessoryTypeDisclosureIndicatorInfo,
};

@class IFAFormViewController;
@class IFAFormTableViewCellContentView;

@interface IFAFormTableViewCell : IFATableViewCell

@property (nonatomic, strong, readonly) NSString *propertyName;
@property (nonatomic, weak, readonly) IFAFormViewController *formViewController;

@property (strong, nonatomic) IBOutlet IFAFormTableViewCellContentView *customContentView;
@property (strong, nonatomic) IBOutlet UILabel *leftLabel;
@property (strong, nonatomic) IBOutlet UILabel *rightLabel;
@property (strong, nonatomic) IBOutlet UIImageView *customAccessoryImageView;
@property (strong, nonatomic) IBOutlet UIImageView *bottomSeparatorImageView;
@property (strong, nonatomic) IBOutlet UIImageView *topSeparatorImageView;
@property (strong, nonatomic) IBOutlet UILabel *centeredLabel;
@property (strong, nonatomic) IBOutlet UIButton *customAccessoryButton;

/* Layout constraints */
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftLabelLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightLabelRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftAndRightLabelsSpacingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomSeparatorLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topSeparatorLeftConstraint;

@property (nonatomic) IFAFormTableViewCellAccessoryType customAccessoryType;

- (id)initWithReuseIdentifier:(NSString *)a_reuseIdentifier propertyName:(NSString *)a_propertyName
                    indexPath:(NSIndexPath *)a_indexPath
           formViewController:(IFAFormViewController *)a_formViewController;

- (IBAction)onCustomAccessoryButtonTap;

- (NSObject *)object;

/**
* Use this method to set the text for the left and right labels.
* It will manage the preferred max layout width for the labels based on the content.
* @param a_leftLabelText Left label text.
* @param a_rightLabelText Right label text.
*/
- (void)setLeftLabelText:(NSString *)a_leftLabelText rightLabelText:(NSString *)a_rightLabelText;
@end
