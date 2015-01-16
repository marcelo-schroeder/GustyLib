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

@interface UIView (IFACoreUI)

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

/**
* Add top, left, bottom and right layout constraints to the receiver's superview so that the receiver frame is always equal to the superview frame.
* @returns Array containing NSLayoutConstraint instances created.
*/
- (NSArray *)ifa_addLayoutConstraintsToFillSuperview;

/**
* Add left and right constraints to the receiver's superview so that the receiver fills the superview frame horizontally.
* @returns Array containing NSLayoutConstraint instances created.
*/
- (NSArray *)ifa_addLayoutConstraintsToFillSuperviewHorizontally;

/**
* Add top and bottom layout constraints to the receiver's superview so that the receiver fills the superview frame vertically.
* @returns Array containing NSLayoutConstraint instances created.
*/
- (NSArray *)ifa_addLayoutConstraintsToFillSuperviewVertically;

/**
* Add center X and center Y layout constraints to the receiver's superview so that the receiver frame is centered in the superview frame.
* @returns Array containing NSLayoutConstraint instances created.
*/
- (NSArray *)ifa_addLayoutConstraintsToCenterInSuperview;

/**
* Add width and height layout constraints to the receiver to match the size provided.
* @param a_size Size the width and height for the layout constraints will be derived from.
* @returns Array containing NSLayoutConstraint instances created.
*/
- (NSArray *)ifa_addLayoutConstraintsForSize:(CGSize)a_size;

/**
* Add a center X layout constraint to the receiver's superview so that the receiver frame is horizontally centered in the superview frame.
* @returns NSLayoutConstraint instance created.
*/
- (NSLayoutConstraint *)ifa_addLayoutConstraintToCenterInSuperviewHorizontally;

/**
* Add a center Y layout constraint to the receiver's superview so that the receiver frame is vertically centered in the superview frame.
* @returns NSLayoutConstraint instance created.
*/
- (NSLayoutConstraint *)ifa_addLayoutConstraintToCenterInSuperviewVertically;

/**
* Convenience method to add a layout constraint to the receiver in relation to another item.
* Items will be related by NSLayoutRelationEqual.
* The multiplier value will be 1 and the constant will be 0.
* @param a_attribute NSLayoutAttribute enum to be used when creating the layout constraint.
* @param a_toItem The other item the layout constraint relates to.
* @return Layout constraint instance created matching the specifications provided.
*/
- (NSLayoutConstraint *)ifa_newLayoutConstraintWithAttribute:(NSLayoutAttribute)a_attribute toItem:(id)a_toItem;

/**
* Removes layout constraints from the receiver matching specifications provided.
* @param a_attribute The attribute provided here must match both first and second attributes a layout constraint for that constraint to be removed.
* @param a_item The item provided here must match the first item or the second item of a layout constraint for that constraint to be removed.
*/
- (void)ifa_removeLayoutConstraintsMatchingFirstAndSecondAttribute:(NSLayoutAttribute)a_attribute firstOrSecondItem:(id)a_item;

- (UIImage *)ifa_snapshotImage;

- (UIImage *)ifa_snapshotImageFromRect:(CGRect)a_rectToSnapshot;

- (BOOL)ifa_frameIntersectsWithView:(UIView *)a_theOtherView;

- (void)ifa_traverseViewHierarchyWithBlock:(void (^) (UIView*))a_block;

/**
* Calculates the height of the view given a width constraint using auto layout.
* @param a_width Width constraint to be temporarily added to the view for height calculation.
*/
- (CGFloat)ifa_calculateHeightForWidth:(CGFloat)a_width;
@end
