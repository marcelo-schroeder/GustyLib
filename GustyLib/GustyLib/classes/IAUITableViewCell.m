//
//  IAUITableViewCell.m
//  Gusty
//
//  Created by Marcelo Schroeder on 12/10/10.
//  Copyright 2010 InfoAccent Pty Limited. All rights reserved.
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


@implementation IAUITableViewCell{
    
}


#pragma mark - Public

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier object:(NSObject*)a_object propertyName:(NSString*)a_propertyName{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier object:a_object propertyName:a_propertyName indexPath:nil];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier object:(NSObject*)a_object propertyName:(NSString*)a_propertyName indexPath:(NSIndexPath*)a_indexPath{
    if ((self=[super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.p_object = a_object;
        self.p_propertyName = a_propertyName;
        self.p_indexPath = a_indexPath;
    }
    return self;
}

#pragma mark - Overrides

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    return [[super initWithStyle:style reuseIdentifier:reuseIdentifier] IFA_init];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    return [[super initWithCoder:aDecoder] IFA_init];
}

-(void)awakeFromNib{
    [self IFA_awakeFromNib];
}

-(void)willTransitionToState:(UITableViewCellStateMask)state{
    [super willTransitionToState:state];
//    NSLog(@"willTransitionToState: %u", state);
    self.p_swipedToDelete = (state == UITableViewCellStateShowingDeleteConfirmationMask);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self IFA_prepareForReuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [[self IFA_appearanceTheme] setAppearanceOnSetSelectedForCell:self animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [[self IFA_appearanceTheme] setAppearanceOnSetHighlightedForCell:self animated:animated];
}

@end
