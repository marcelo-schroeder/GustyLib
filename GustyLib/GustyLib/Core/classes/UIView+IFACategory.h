//
//  UIView+IFACategory.h
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

@protocol IFAAppearanceTheme;

@interface UIView (IFACategory)

@property (nonatomic, strong) NSString *ifa_appearanceId;

-(id)ifa_init;
-(void)ifa_awakeFromNib;
-(void)ifa_roundCorners;
-(void)ifa_roundCornersWithRadius:(CGFloat)a_radius;

-(CGPoint)ifa_centerInSuperview:(UIView*)a_superview;

/*
    *** IMPORTANT: this did not work for the iPad ***
    It was a table view cell separator view, at the bottom
 */
-(void)ifa_changeFrameTo1PixelTall;

-(id<IFAAppearanceTheme>)ifa_appearanceTheme;

- (NSArray *)ifa_addLayoutConstraintsToFillSuperview;

- (NSArray *)ifa_addLayoutConstraintsToFillSuperviewHorizontally;

- (NSArray *)ifa_addLayoutConstraintsToFillSuperviewVertically;

- (NSArray *)ifa_addLayoutConstraintsToCenterInSuperview;

- (NSLayoutConstraint *)ifa_addLayoutConstraintToCenterInSuperviewHorizontally;

- (NSLayoutConstraint *)ifa_addLayoutConstraintToCenterInSuperviewVertically;

- (NSLayoutConstraint *)ifa_newLayoutConstraintWithAttribute:(NSLayoutAttribute)a_attribute toItem:(id)a_item;

- (UIImage *)ifa_snapshotImage;

- (UIImage *)ifa_snapshotImageFromRect:(CGRect)a_rectToSnapshot;

- (BOOL)ifa_frameIntersectsWithView:(UIView *)a_theOtherView;

- (void)ifa_traverseViewHierarchyWithBlock:(void (^) (UIView*))a_block;
@end
