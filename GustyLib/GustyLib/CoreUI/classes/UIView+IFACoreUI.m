//
//  UIView+IFACategory.m
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

#import "GustyLibCoreUI.h"

static NSString *const k_layoutConstraintVisualFormatOrientationHorizontal = @"H";
static NSString *const k_layoutConstraintVisualFormatOrientationVertical = @"V";
static char c_appearanceIdKey;

@implementation UIView (IFACoreUI)

#pragma mark - Private

-(NSArray *)IFA_addLayoutConstraintsToFillSuperviewForOrientation:(NSString *)a_orientation{
    UIView *l_self = self;
    NSDictionary *l_views = NSDictionaryOfVariableBindings(l_self);
    NSArray *l_layoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:|[l_self]|", a_orientation]
                                                                           options:(NSLayoutFormatOptions) nil
                                                                           metrics:nil
                                                                             views:l_views];
    [self.superview addConstraints:l_layoutConstraints];
    return l_layoutConstraints;
}

- (NSLayoutConstraint *)IFA_addSuperviewEqualityLayoutConstraintForAttribute:(NSLayoutAttribute)a_attribute {
    NSLayoutConstraint *l_layoutConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:a_attribute
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.superview
                                                                          attribute:a_attribute
                                                                         multiplier:1
                                                                           constant:0];
    [self.superview addConstraint:l_layoutConstraint];
    return l_layoutConstraint;
}

#pragma mark - Public

-(id)ifa_init {
    
    // Set appearance
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitForView:self];

    return self;

}

-(void)ifa_awakeFromNib {
    
    // Set appearance
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnAwakeFromNibForView:self];
    
}

-(void)ifa_roundCorners {
    [self ifa_roundCornersWithRadius:8];
}

-(void)ifa_roundCornersWithRadius:(CGFloat)a_radius{
    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = a_radius;
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(5, 5);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shadowRadius = a_radius;
}

-(CGPoint)ifa_centerInSuperview:(UIView*)a_superview{
    return [a_superview convertPoint:a_superview.center fromView:a_superview.superview];
}

/*
    The rationale behind the implementation of this method was obtained from here: http://developer.apple.com/library/ios/#documentation/2DDrawing/Conceptual/DrawingPrintingiOS/GraphicsDrawingOverview/GraphicsDrawingOverview.html
    Key points from the text are:

    (1) On a low-resolution display (with a scale factor of 1.0), a one-point-wide line is one pixel wide.
    To avoid antialiasing when you draw a one-point-wide horizontal or vertical line,
    if the line is an odd number of pixels in width, you must offset the position by 0.5 points to either side of a whole-numbered position.
    If the line is an even number of points in width, to avoid a fuzzy line, you must not do so.

    (2) On a high-resolution display (with a scale factor of 2.0), a line that is one point wide is not antialiased at all because it occupies two full pixels (from -0.5 to +0.5).
    To draw a line that covers only a single physical pixel, you would need to make it 0.5 points in thickness and offset its position by 0.25 points.
    A comparison between the two types of screens is shown in Figure 1-4.

    *** IMPORTANT: this did not work for the iPad ***
    It was a table view cell separator view, at the bottom

 */
- (void)ifa_changeFrameTo1PixelTall {
    CGFloat l_screenScale = [UIScreen mainScreen].scale;
    if (l_screenScale!=1) {
        CGRect l_newFrame = self.frame;
        l_newFrame.size.height = 1 / l_screenScale;
        l_newFrame.origin.y += l_newFrame.size.height / 2;
        self.frame = l_newFrame;
    }
}

- (id <IFAAppearanceTheme>)ifa_appearanceTheme {
    return [[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme];
}

-(void)setIfa_appearanceId:(NSString *)a_appearanceId{
    objc_setAssociatedObject(self, &c_appearanceIdKey, a_appearanceId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)ifa_appearanceId {
    return objc_getAssociatedObject(self, &c_appearanceIdKey);
}

-(NSArray *)ifa_addLayoutConstraintsToFillSuperview {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *l_horizontalConstraints = [self IFA_addLayoutConstraintsToFillSuperviewForOrientation:k_layoutConstraintVisualFormatOrientationHorizontal];
    NSArray *l_verticalConstraints = [self IFA_addLayoutConstraintsToFillSuperviewForOrientation:k_layoutConstraintVisualFormatOrientationVertical];
    NSMutableArray *l_constraints = [@[] mutableCopy];
    [l_constraints addObjectsFromArray:l_horizontalConstraints];
    [l_constraints addObjectsFromArray:l_verticalConstraints];
    return l_constraints;
}

-(NSArray *)ifa_addLayoutConstraintsToFillSuperviewHorizontally {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [self IFA_addLayoutConstraintsToFillSuperviewForOrientation:k_layoutConstraintVisualFormatOrientationHorizontal];
}

-(NSArray *)ifa_addLayoutConstraintsToFillSuperviewVertically {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [self IFA_addLayoutConstraintsToFillSuperviewForOrientation:k_layoutConstraintVisualFormatOrientationVertical];
}

-(NSArray *)ifa_addLayoutConstraintsToCenterInSuperview {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *l_constraints = [@[] mutableCopy];
    NSLayoutConstraint *l_horizontalLayoutConstraint = [self ifa_addLayoutConstraintToCenterInSuperviewHorizontally];
    [l_constraints addObject:l_horizontalLayoutConstraint];
    NSLayoutConstraint *l_verticalLayoutConstraint = [self ifa_addLayoutConstraintToCenterInSuperviewVertically];
    [l_constraints addObject:l_verticalLayoutConstraint];
    return l_constraints;
}

- (NSArray *)ifa_addLayoutConstraintsForSize:(CGSize)a_size {
    NSArray *l_constraints = @[
            [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1
                                          constant:a_size.width],
            [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1
                                          constant:a_size.height],
    ];
    [self addConstraints:l_constraints];
    return l_constraints;
}

- (NSLayoutConstraint *)ifa_addLayoutConstraintToCenterInSuperviewHorizontally {
    return [self IFA_addSuperviewEqualityLayoutConstraintForAttribute:NSLayoutAttributeCenterX];
}

- (NSLayoutConstraint *)ifa_addLayoutConstraintToCenterInSuperviewVertically {
    return [self IFA_addSuperviewEqualityLayoutConstraintForAttribute:NSLayoutAttributeCenterY];
}

- (NSLayoutConstraint *)ifa_newLayoutConstraintWithAttribute:(NSLayoutAttribute)a_attribute toItem:(id)a_toItem {
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:a_attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:a_toItem
                                        attribute:a_attribute
                                       multiplier:1 constant:0];
}

- (void)ifa_removeLayoutConstraintsMatchingFirstAndSecondAttribute:(NSLayoutAttribute)a_attribute firstOrSecondItem:(id)a_item {
    for (NSLayoutConstraint *l_layoutConstraint in self.constraints) {
        if (l_layoutConstraint.firstAttribute==a_attribute
                && l_layoutConstraint.secondAttribute==a_attribute
                && (l_layoutConstraint.firstItem==a_item || l_layoutConstraint.secondItem==a_item)) {
            [self removeConstraint:l_layoutConstraint];
        }
    }
}

- (UIImage *)ifa_snapshotImage {
    CGRect l_rectToSnapshot = self.bounds;
    return [self ifa_snapshotImageFromRect:l_rectToSnapshot];
}

- (UIImage *)ifa_snapshotImageFromRect:(CGRect)a_rectToSnapshot {
    UIGraphicsBeginImageContextWithOptions(a_rectToSnapshot.size, YES, 0.0);
    [self drawViewHierarchyInRect:a_rectToSnapshot afterScreenUpdates:NO];
    UIImage *l_snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return l_snapshotImage;
}

- (BOOL)ifa_frameIntersectsWithView:(UIView *)a_theOtherView{
    CGRect l_frame1 = [self.superview convertRect:self.frame toView:nil];
    CGRect l_frame2 = [a_theOtherView.superview convertRect:a_theOtherView.frame toView:nil];
    return CGRectIntersectsRect(l_frame1, l_frame2);
}

- (void)ifa_traverseViewHierarchyWithBlock:(void (^) (UIView *))a_block {
    [IFAUIUtils traverseHierarchyForView:self withBlock:a_block];
}

- (CGFloat)ifa_calculateHeightForWidth:(CGFloat)a_width{
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1
                                                                        constant:a_width];
    [self addConstraint:widthConstraint];
    CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [self removeConstraint:widthConstraint];
    return size.height;
}

@end
