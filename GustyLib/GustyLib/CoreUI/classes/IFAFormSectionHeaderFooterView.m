//
// Created by Marcelo Schroeder on 2/10/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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


@implementation IFAFormSectionHeaderFooterView {

}

#pragma mark - Overrides

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"IFAFormSectionFooterContentView" owner:self options:nil];
        [self.ifa_appearanceTheme setAppearanceForView:self];
        self.customContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.customContentView];
        UIView *customContentView = self.customContentView;
        NSDictionary *views = NSDictionaryOfVariableBindings(customContentView);
        NSArray *horizontalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[customContentView]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:views];
        NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[customContentView]|"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:views];
        [self.customContentView.superview addConstraints:horizontalLayoutConstraints];
        [self.customContentView.superview addConstraints:verticalLayoutConstraints];
    }
    return self;
}

@end