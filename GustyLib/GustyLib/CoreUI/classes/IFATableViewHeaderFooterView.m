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


@implementation IFATableViewHeaderFooterView {

}

#pragma mark - Overrides

-(id)init{
    return [[super init] ifa_init];
}

-(id)initWithFrame:(CGRect)frame{
    return [[super initWithFrame:frame] ifa_init];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    return [[super initWithCoder:aDecoder] ifa_init];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    return [[super initWithReuseIdentifier:reuseIdentifier] ifa_init];
}

-(void)awakeFromNib{
    [self ifa_awakeFromNib];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self ifa_appearanceTheme] setAppearanceOnPrepareForReuseForTableViewHeaderFooterView:self];
}

@end