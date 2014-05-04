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

#import "IFACommon.h"

static NSString *const k_layoutConstraintVisualFormatOrientationHorizontal = @"H";
static NSString *const k_layoutConstraintVisualFormatOrientationVertical = @"V";
static char c_helpTargetIdKey;
static char c_appearanceIdKey;

@implementation UIView (IFACategory)

#pragma mark - Private

-(NSArray *)ifa_addLayoutConstraintsToFillSuperviewForOrientation:(NSString *)a_orientation{
    UIView *l_self = self;
    NSDictionary *l_views = NSDictionaryOfVariableBindings(l_self);
    NSArray *l_layoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:|[l_self]|", a_orientation]
                                                                           options:(NSLayoutFormatOptions) nil
                                                                           metrics:nil
                                                                             views:l_views];
    [self.superview addConstraints:l_layoutConstraints];
    return l_layoutConstraints;
}

- (NSLayoutConstraint *)ifa_addSuperviewEqualityLayoutConstraintForAttribute:(NSLayoutAttribute)a_attribute {
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

-(id)IFA_init {
    
    // Set appearance
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitForView:self];

    return self;

}

-(void)IFA_awakeFromNib {
    
    // Set appearance
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnAwakeFromNibForView:self];
    
}

-(void)IFA_roundCorners {
    [self IFA_roundCornersWithRadius:8];
}

-(void)IFA_roundCornersWithRadius:(CGFloat)a_radius{
    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = a_radius;
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(5, 5);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shadowRadius = a_radius;
}

-(CGPoint)IFA_centerInSuperview:(UIView*)a_superview{
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
- (void)IFA_changeFrameTo1PixelTall {
    CGFloat l_screenScale = [UIScreen mainScreen].scale;
    if (l_screenScale!=1) {
        CGRect l_newFrame = self.frame;
        l_newFrame.size.height = 1 / l_screenScale;
        l_newFrame.origin.y += l_newFrame.size.height / 2;
        self.frame = l_newFrame;
    }
}

- (id <IFAAppearanceTheme>)IFA_appearanceTheme {
    return [[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme];
}

-(void)setIFA_appearanceId:(NSString *)a_appearanceId{
    objc_setAssociatedObject(self, &c_appearanceIdKey, a_appearanceId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)IFA_appearanceId {
    return objc_getAssociatedObject(self, &c_appearanceIdKey);
}

-(NSArray *)IFA_addLayoutConstraintsToFillSuperview {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *l_horizontalConstraints = [self ifa_addLayoutConstraintsToFillSuperviewForOrientation:k_layoutConstraintVisualFormatOrientationHorizontal];
    NSArray *l_verticalConstraints = [self ifa_addLayoutConstraintsToFillSuperviewForOrientation:k_layoutConstraintVisualFormatOrientationVertical];
    NSMutableArray *l_constraints = [@[] mutableCopy];
    [l_constraints addObjectsFromArray:l_horizontalConstraints];
    [l_constraints addObjectsFromArray:l_verticalConstraints];
    return l_constraints;
}

-(NSArray *)IFA_addLayoutConstraintsToFillSuperviewHorizontally {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [self ifa_addLayoutConstraintsToFillSuperviewForOrientation:k_layoutConstraintVisualFormatOrientationHorizontal];
}

-(NSArray *)IFA_addLayoutConstraintsToFillSuperviewVertically {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return [self ifa_addLayoutConstraintsToFillSuperviewForOrientation:k_layoutConstraintVisualFormatOrientationVertical];
}

-(NSArray *)IFA_addLayoutConstraintsToCenterInSuperview {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *l_constraints = [@[] mutableCopy];
    NSLayoutConstraint *l_horizontalLayoutConstraint = [self IFA_addLayoutConstraintToCenterInSuperviewHorizontally];
    [l_constraints addObject:l_horizontalLayoutConstraint];
    NSLayoutConstraint *l_verticalLayoutConstraint = [self IFA_addLayoutConstraintToCenterInSuperviewVertically];
    [l_constraints addObject:l_verticalLayoutConstraint];
    return l_constraints;
}

- (NSLayoutConstraint *)IFA_addLayoutConstraintToCenterInSuperviewHorizontally {
    return [self ifa_addSuperviewEqualityLayoutConstraintForAttribute:NSLayoutAttributeCenterX];
}

- (NSLayoutConstraint *)IFA_addLayoutConstraintToCenterInSuperviewVertically {
    return [self ifa_addSuperviewEqualityLayoutConstraintForAttribute:NSLayoutAttributeCenterY];
}

- (NSLayoutConstraint *)IFA_newLayoutConstraintWithAttribute:(NSLayoutAttribute)a_attribute toItem:(id)a_item {
    return [NSLayoutConstraint constraintWithItem:self
                                        attribute:a_attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:a_item
                                        attribute:a_attribute
                                       multiplier:1 constant:0];
}

- (UIImage *)IFA_snapshotImage {
    CGRect l_rectToSnapshot = self.bounds;
    return [self IFA_snapshotImageFromRect:l_rectToSnapshot];
}

- (UIImage *)IFA_snapshotImageFromRect:(CGRect)a_rectToSnapshot {
    UIGraphicsBeginImageContextWithOptions(a_rectToSnapshot.size, YES, 0.0);
    [self drawViewHierarchyInRect:a_rectToSnapshot afterScreenUpdates:NO];
    UIImage *l_snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return l_snapshotImage;
}

- (BOOL)IFA_frameIntersectsWithView:(UIView *)a_theOtherView{
    CGRect l_frame1 = [self.superview convertRect:self.frame toView:nil];
    CGRect l_frame2 = [a_theOtherView.superview convertRect:a_theOtherView.frame toView:nil];
    return CGRectIntersectsRect(l_frame1, l_frame2);
}

- (void)IFA_traverseViewHierarchyWithBlock:(void (^) (UIView *))a_block {
    [IFAUIUtils traverseHierarchyForView:self withBlock:a_block];
}

#pragma mark - IFAHelpTarget protocol

-(void)setHelpTargetId:(NSString *)a_helpTargetId{
    objc_setAssociatedObject(self, &c_helpTargetIdKey, a_helpTargetId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self isKindOfClass:[UIButton class]]) {
        NSString *l_accessibilityLabel = [[IFAHelpManager sharedInstance] accessibilityLabelForKeyPath:a_helpTargetId];
        if (l_accessibilityLabel) {
            self.accessibilityLabel = l_accessibilityLabel;
        }
    }
}

-(NSString *)helpTargetId {
    return objc_getAssociatedObject(self, &c_helpTargetIdKey);
}

#pragma mark - IFAHelpTargetContainer

-(NSArray*)IFA_helpTargets {
    return nil;
}

-(UIView*)IFA_helpModeToggleView {
    return nil;
}

-(UIView*)IFA_view {
    return nil;
}

-(void)IFA_didEnterHelpMode {
    // does nothing
}

-(void)IFA_willExitHelpMode {
    // does nothing
}

@end
