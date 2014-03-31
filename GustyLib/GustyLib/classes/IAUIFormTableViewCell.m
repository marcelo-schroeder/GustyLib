//
//  IAUIFormTableViewCell.m
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

#import "IACommon.h"

@implementation IAUIFormTableViewCell


#pragma mark - Public

-(CGFloat)m_calculateFieldX{
    return self.textLabel.frame.origin.x + self.textLabel.frame.size.width + 10;
}

-(CGFloat)m_calculateFieldWidth{
    return self.contentView.frame.size.width - [self m_calculateFieldX] - 10;
}

#pragma mark - Overrides

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier object:(NSObject*)a_object propertyName:(NSString*)a_propertyName indexPath:(NSIndexPath*)a_indexPath{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier object:a_object propertyName:a_propertyName indexPath:a_indexPath];

    // Configure standard text labels
    self.textLabel.numberOfLines = 2;
    [[[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme] m_setAppearanceForView:self.detailTextLabel];
    self.detailTextLabel.font = [UIFont systemFontOfSize:16];

    return self;

}

- (void)willTransitionToState:(UITableViewCellStateMask)state{
    [super willTransitionToState:state];
//    NSLog(@"willTransitionToState: %u, indexPath: %@", state, [self.p_indexPath description]);
    [self.p_formViewController populateCell:self];
}

-(void)layoutSubviews{

    [super layoutSubviews];
    
    // Fine tune labels frames to distribute form elements better
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y-2, self.frame.size.width/4, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake([self m_calculateFieldX], 11, [self m_calculateFieldWidth], self.detailTextLabel.frame.size.height);

}

@end
