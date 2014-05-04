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
#import "IFAHelpManager.h"

@protocol IFAAppearanceTheme;

@interface UIView (IFACategory) <IAHelpTarget>

@property (nonatomic, strong) NSString *helpTargetId;
@property (nonatomic, strong) NSString *IFA_appearanceId;

-(id)IFA_init;
-(void)IFA_awakeFromNib;
-(void)IFA_roundCorners;
-(void)IFA_roundCornersWithRadius:(CGFloat)a_radius;

-(NSArray*)IFA_helpTargets;
-(UIView*)IFA_helpModeToggleView;
-(UIView*)IFA_view;
-(void)IFA_didEnterHelpMode;
-(void)IFA_willExitHelpMode;

-(CGPoint)IFA_centerInSuperview:(UIView*)a_superview;

/*
    *** IMPORTANT: this did not work for the iPad ***
    It was a table view cell separator view, at the bottom
 */
-(void)IFA_changeFrameTo1PixelTall;

-(id<IFAAppearanceTheme>)IFA_appearanceTheme;

- (NSArray *)IFA_addLayoutConstraintsToFillSuperview;

- (NSArray *)IFA_addLayoutConstraintsToFillSuperviewHorizontally;

- (NSArray *)IFA_addLayoutConstraintsToFillSuperviewVertically;

- (NSArray *)IFA_addLayoutConstraintsToCenterInSuperview;

- (NSLayoutConstraint *)IFA_addLayoutConstraintToCenterInSuperviewHorizontally;

- (NSLayoutConstraint *)IFA_addLayoutConstraintToCenterInSuperviewVertically;

- (NSLayoutConstraint *)IFA_newLayoutConstraintWithAttribute:(NSLayoutAttribute)a_attribute toItem:(id)a_item;

- (UIImage *)IFA_snapshotImage;

- (UIImage *)IFA_snapshotImageFromRect:(CGRect)a_rectToSnapshot;

- (BOOL)IFA_frameIntersectsWithView:(UIView *)a_theOtherView;

- (void)IFA_traverseViewHierarchyWithBlock:(void (^) (UIView*))a_block;
@end
