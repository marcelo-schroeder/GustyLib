//
//  UIView+IACategory.h
//  Gusty
//
//  Created by Marcelo Schroeder on 26/03/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

#import <UIKit/UIKit.h>
#import "IAHelpManager.h"

@protocol IAUIAppearanceTheme;

@interface UIView (IACategory) <IAHelpTarget>

@property (nonatomic, strong) NSString *p_helpTargetId;
@property (nonatomic, strong) NSString *p_appearanceId;

-(id)m_init;
-(void)m_awakeFromNib;
-(void)m_roundCorners;
-(void)m_roundCornersWithRadius:(CGFloat)a_radius;

-(NSArray*)m_helpTargets;
-(UIView*)m_helpModeToggleView;
-(UIView*)m_view;
-(void)m_didEnterHelpMode;
-(void)m_willExitHelpMode;

-(CGPoint)m_centerInSuperview:(UIView*)a_superview;

/*
    *** IMPORTANT: this did not work for the iPad ***
    It was a table view cell separator view, at the bottom
 */
-(void)m_changeFrameTo1PixelTall;

-(id<IAUIAppearanceTheme>)m_appearanceTheme;

- (NSArray *)m_addLayoutConstraintsToFillSuperview;

- (NSArray *)m_addLayoutConstraintsToCenterInSuperview;

- (NSLayoutConstraint *)m_addLayoutConstraintToCenterInSuperviewHorizontally;

- (NSLayoutConstraint *)m_addLayoutConstraintToCenterInSuperviewVertically;

- (NSLayoutConstraint *)m_newLayoutConstraintWithAttribute:(NSLayoutAttribute)a_attribute toItem:(id)a_item;

- (UIImage *)m_snapshotImage;

- (BOOL)m_frameIntersectsWithView:(UIView *)a_theOtherView;
@end
