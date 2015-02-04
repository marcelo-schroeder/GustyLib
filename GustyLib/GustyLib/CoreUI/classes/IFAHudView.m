//
// Created by Marcelo Schroeder on 21/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
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

@interface IFAHudView ()
@property(nonatomic, strong) UIView *chromeView;
@property(nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) NSMutableArray *IFA_contentHorizontalLayoutConstraints;
@property(nonatomic, strong) NSMutableArray *IFA_contentVerticalLayoutConstraints;
@property(nonatomic, strong) NSArray *IFA_chromeViewSizeConstraints;
@property(nonatomic, strong) UIVisualEffectView *IFA_blurEffectView;
@property(nonatomic, strong) UIVisualEffectView *IFA_vibrancyEffectView;
@property(nonatomic, strong) NSArray *IFA_contentViewSizeConstraints;
@property(nonatomic, strong) NSArray *IFA_chromeViewCentreConstraints;
@property (nonatomic, strong) UITapGestureRecognizer *IFA_chromeTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *IFA_overlayTapGestureRecognizer;
@property(nonatomic, strong) NSArray *IFA_blurEffectViewSizeConstraints;
@property(nonatomic, strong) NSArray *IFA_vibrancyEffectViewSizeConstraints;
@property(nonatomic, strong) id <NSObject> IFA_contentSizeCategoryChangeObserver;
@property (nonatomic, strong) NSMutableArray *contentSubviewVerticalOrder;
@property (nonatomic, strong) NSMutableArray *IFA_contentSubviewName;
@end

@implementation IFAHudView {
    UIColor *_nonModalOverlayColour;
    UIColor *_nonModalChromeForegroundColour;
    UIColor *_nonModalChromeBackgroundColour;
    UIColor *_nonModalProgressViewTrackTintColour;
    UIColor *_modalOverlayColour;
    UIColor *_modalChromeForegroundColour;
    UIColor *_modalChromeBackgroundColour;
    UIColor *_modalProgressViewTrackTintColour;
    NSString *_textLabelFontTextStyle;
    NSString *_detailTextLabelFontTextStyle;
    UIFont *_textLabelFont;
    UIFont *_detailTextLabelFont;
}

#pragma mark - Public

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        // Set ivar's directly otherwise UIKit won't override via appearance API
        _modalStyle = [self IFA_defaultStyleModal];
        _nonModalStyle = [self IFA_defaultStyleNonModal];
        _modalBlurEffectStyle = [self IFA_defaultBlurEffectStyleModal];
        _nonModalBlurEffectStyle = [self IFA_defaultBlurEffectStyleNonModal];
        _chromeViewLayoutFittingSize = [self IFA_defaultChromeViewLayoutFittingSize];
        _shouldAnimateLayoutChanges = [self IFA_defaultShouldAnimateLayoutChanges];
        _chromeHorizontalPadding = [self IFA_defaultChromeHorizontalPadding];
        _chromeVerticalPadding = [self IFA_defaultChromeVerticalPadding];
        _chromeVerticalInteritemSpacing = [self IFA_defaultChromeVerticalInteritemSpacing];
        _chromeViewMaximumLayoutWidth = [self IFA_defaultChromeViewMaximumLayoutWidth];
        _chromeHorizontalMargin = [self IFA_defaultChromeHorizontalMargin];

        self.modal = YES;

        [self IFA_addObservers];
        [self IFA_updateViewHierarchy];
        [self IFA_addGestureRecognisers];
        [self IFA_updateColours];
        [self IFA_addMotionEffects];

    }
    return self;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.hidden = YES;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

- (UILabel *)detailTextLabel {
    if (!_detailTextLabel) {
        _detailTextLabel = [UILabel new];
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTextLabel.hidden = YES;
        _detailTextLabel.textAlignment = NSTextAlignmentCenter;
        _detailTextLabel.numberOfLines = 0;
    }
    return _detailTextLabel;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicatorView.hidden = YES;
        _activityIndicatorView.hidesWhenStopped = NO;
    }
    return _activityIndicatorView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.hidden = YES;
    }
    return _progressView;
}

- (void)setNonModalOverlayColour:(UIColor *)nonModalOverlayColour {
    _nonModalOverlayColour = nonModalOverlayColour;
    [self IFA_updateColours];
}

- (UIColor *)nonModalOverlayColour {
    if (_nonModalOverlayColour) {
        return _nonModalOverlayColour;
    } else {
        return self.IFA_defaultOverlayColourNonModal;
    }
}

- (void)setNonModalChromeForegroundColour:(UIColor *)nonModalChromeForegroundColour {
    _nonModalChromeForegroundColour = nonModalChromeForegroundColour;
    [self IFA_updateColours];
}

- (UIColor *)nonModalChromeForegroundColour {
    if (_nonModalChromeForegroundColour) {
        return _nonModalChromeForegroundColour;
    } else {
        return self.IFA_defaultChromeForegroundColourNonModal;
    }
}

- (void)setNonModalChromeBackgroundColour:(UIColor *)nonModalChromeBackgroundColour {
    _nonModalChromeBackgroundColour = nonModalChromeBackgroundColour;
    [self IFA_updateColours];
}

- (UIColor *)nonModalChromeBackgroundColour {
    if (_nonModalChromeBackgroundColour) {
        return _nonModalChromeBackgroundColour;
    } else {
        return self.IFA_defaultChromeBackgroundColourNonModal;
    }
}

- (void)setNonModalProgressViewTrackTintColour:(UIColor *)nonModalProgressViewTrackTintColour {
    _nonModalProgressViewTrackTintColour = nonModalProgressViewTrackTintColour;
    [self IFA_updateColours];
}

- (UIColor *)nonModalProgressViewTrackTintColour {
    if (_nonModalProgressViewTrackTintColour) {
        return _nonModalProgressViewTrackTintColour;
    } else {
        return self.IFA_defaultProgressViewTrackTintColourNonModal;
    }
}

- (void)setModalOverlayColour:(UIColor *)modalOverlayColour {
    _modalOverlayColour = modalOverlayColour;
    [self IFA_updateColours];
}

- (UIColor *)modalOverlayColour {
    if (_modalOverlayColour) {
        return _modalOverlayColour;
    } else {
        return self.IFA_defaultOverlayColourModal;
    }
}

- (void)setModalChromeForegroundColour:(UIColor *)modalChromeForegroundColour {
    _modalChromeForegroundColour = modalChromeForegroundColour;
    [self IFA_updateColours];
}

- (UIColor *)modalChromeForegroundColour {
    if (_modalChromeForegroundColour) {
        return _modalChromeForegroundColour;
    } else {
        return self.IFA_defaultChromeForegroundColourModal;
    }
}

- (void)setModalChromeBackgroundColour:(UIColor *)modalChromeBackgroundColour {
    _modalChromeBackgroundColour = modalChromeBackgroundColour;
    [self IFA_updateColours];
}

- (UIColor *)modalChromeBackgroundColour {
    if (_modalChromeBackgroundColour) {
        return _modalChromeBackgroundColour;
    } else {
        return self.IFA_defaultChromeBackgroundColourModal;
    }
}

- (void)setModalProgressViewTrackTintColour:(UIColor *)modalProgressViewTrackTintColour {
    _modalProgressViewTrackTintColour = modalProgressViewTrackTintColour;
    [self IFA_updateColours];
}

- (UIColor *)modalProgressViewTrackTintColour {
    if (_modalProgressViewTrackTintColour) {
        return _modalProgressViewTrackTintColour;
    } else {
        return self.IFA_defaultProgressViewTrackTintColourModal;
    }
}

- (void)setNonModalBlurEffectStyle:(UIBlurEffectStyle)nonModalBlurEffectStyle {
    _nonModalBlurEffectStyle = nonModalBlurEffectStyle;
    [self IFA_updateStyle];
}

- (void)setModalBlurEffectStyle:(UIBlurEffectStyle)modalBlurEffectStyle {
    _modalBlurEffectStyle = modalBlurEffectStyle;
    [self IFA_updateStyle];
}

- (NSString *)textLabelFontTextStyle {
    if (_textLabelFontTextStyle) {
        return _textLabelFontTextStyle;
    } else {
        return self.IFA_defaultTextLabelFontTextStyle;
    }
}

- (void)setTextLabelFontTextStyle:(NSString *)textLabelFontTextStyle {
    _textLabelFontTextStyle = textLabelFontTextStyle;
    [self IFA_updateLayout];
}

- (NSString *)detailTextLabelFontTextStyle {
    if (_detailTextLabelFontTextStyle) {
        return _detailTextLabelFontTextStyle;
    } else {
        return self.IFA_defaultDetailTextLabelFontTextStyle;
    }
}

- (void)setDetailTextLabelFontTextStyle:(NSString *)detailTextLabelFontTextStyle {
    _detailTextLabelFontTextStyle = detailTextLabelFontTextStyle;
    [self IFA_updateLayout];
}

- (UIFont *)textLabelFont {
    return _textLabelFont;
}

- (void)setTextLabelFont:(UIFont *)textLabelFont {
    _textLabelFont = textLabelFont;
    [self IFA_updateLayout];
}

- (UIFont *)detailTextLabelFont {
    return _detailTextLabelFont;
}

- (void)setDetailTextLabelFont:(UIFont *)detailTextLabelFont {
    _detailTextLabelFont = detailTextLabelFont;
    [self IFA_updateLayout];
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIView *)chromeView {
    if (!_chromeView) {
        _chromeView = [UIView new];
        _chromeView.translatesAutoresizingMaskIntoConstraints = NO;
        CALayer *layer = _chromeView.layer;
        layer.cornerRadius = 9.0;
        layer.masksToBounds = YES;
    }
    return _chromeView;
}

- (void)setCustomView:(UIView *)customView {
    [_customView removeFromSuperview];
    _customView = customView;
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView insertSubview:_customView belowSubview:self.detailTextLabel];
    [self IFA_updateLayout];
    [self IFA_updateColours];
}

- (BOOL)modal {
    return self.userInteractionEnabled;
}

- (void)setModal:(BOOL)modal {
    self.userInteractionEnabled = modal;
    [self IFA_updateColours];
    [self IFA_updateStyle];
}

- (void)setModalStyle:(IFAHudViewStyle)modalStyle {
    _modalStyle = modalStyle;
    [self IFA_updateStyle];
}

- (void)setNonModalStyle:(IFAHudViewStyle)nonModalStyle {
    _nonModalStyle = nonModalStyle;
    [self IFA_updateStyle];
}

- (void)setChromeViewLayoutFittingSize:(CGSize)chromeViewLayoutFittingSize {
    _chromeViewLayoutFittingSize = chromeViewLayoutFittingSize;
    [self IFA_updateLayout];
}

- (void)setChromeViewMaximumLayoutWidth:(CGFloat)chromeViewMaximumLayoutWidth {
    _chromeViewMaximumLayoutWidth = chromeViewMaximumLayoutWidth;
    [self IFA_updateLayout];
}

- (NSMutableArray *)contentSubviewVerticalOrder {
    if (!_contentSubviewVerticalOrder) {
        _contentSubviewVerticalOrder = [@[] mutableCopy];
        [_contentSubviewVerticalOrder addObject:@(IFAHudContentSubviewIdTextLabel)];
        [_contentSubviewVerticalOrder addObject:@(IFAHudContentSubviewIdActivityIndicatorView)];
        [_contentSubviewVerticalOrder addObject:@(IFAHudContentSubviewIdProgressView)];
        [_contentSubviewVerticalOrder addObject:@(IFAHudContentSubviewIdCustomView)];
        [_contentSubviewVerticalOrder addObject:@(IFAHudContentSubviewIdDetailTextLabel)];
    }
    return _contentSubviewVerticalOrder;
}

- (IFAHudViewStyle)style {
    return self.modal ? self.modalStyle : self.nonModalStyle;
}

- (UIBlurEffectStyle)blurEffectStyle {
    return self.modal ? self.modalBlurEffectStyle : self.nonModalBlurEffectStyle;
}

- (UIColor *)overlayColour {
    return self.modal ? self.modalOverlayColour : self.nonModalOverlayColour;
}

- (UIColor *)chromeForegroundColour {
    return self.modal ? self.modalChromeForegroundColour : self.nonModalChromeForegroundColour;
}

- (UIColor *)chromeBackgroundColour {
    return self.modal ? self.modalChromeBackgroundColour : self.nonModalChromeBackgroundColour;
}

- (UIColor *)progressViewTrackTintColour {
    return self.modal ? self.modalProgressViewTrackTintColour : self.nonModalProgressViewTrackTintColour;
}


- (NSMutableArray *)IFA_contentSubviewName {
    if (!_IFA_contentSubviewName) {
        _IFA_contentSubviewName = [@[] mutableCopy];
        [_IFA_contentSubviewName addObject:@"textLabel"];
        [_IFA_contentSubviewName addObject:@"detailTextLabel"];
        [_IFA_contentSubviewName addObject:@"activityIndicatorView"];
        [_IFA_contentSubviewName addObject:@"progressView"];
        [_IFA_contentSubviewName addObject:@"customView"];
    }
    return _IFA_contentSubviewName;
}

- (void)setChromeHorizontalPadding:(CGFloat)chromeHorizontalPadding {
    _chromeHorizontalPadding = chromeHorizontalPadding;
    [self IFA_updateLayout];
}

- (void)setChromeHorizontalMargin:(CGFloat)chromeHorizontalMargin {
    _chromeHorizontalMargin = chromeHorizontalMargin;
    [self IFA_updateLayout];
}

- (void)setChromeVerticalPadding:(CGFloat)chromeVerticalPadding {
    _chromeVerticalPadding = chromeVerticalPadding;
    [self IFA_updateLayout];
}

- (void)setChromeVerticalInteritemSpacing:(CGFloat)chromeVerticalInteritemSpacing {
    _chromeVerticalInteritemSpacing = chromeVerticalInteritemSpacing;
    [self IFA_updateLayout];
}

#pragma mark - Overrides

- (void)dealloc {
    [self IFA_removeObservers];
}

- (void)updateConstraints {

    UIView *contentView = self.contentView;
    UIView *chromeView = self.chromeView;
    UIActivityIndicatorView *activityIndicatorView = self.activityIndicatorView;
    UIProgressView *progressView = self.progressView;
    UIView *customView = self.customView;
    UILabel *textLabel = self.textLabel;
    UILabel *detailTextLabel = self.detailTextLabel;
    UIVisualEffectView *vibrancyEffectView = self.IFA_vibrancyEffectView;
    UIVisualEffectView *blurEffectView = self.IFA_blurEffectView;
    NSMutableDictionary *views = [NSDictionaryOfVariableBindings(activityIndicatorView, progressView, textLabel, detailTextLabel) mutableCopy];
    if (customView) {
        views[@"customView"] = customView;
    }

    // Remove existing constraints
    if (self.IFA_contentViewSizeConstraints) {
        [contentView.superview removeConstraints:self.IFA_contentViewSizeConstraints];
    }
    if (self.IFA_vibrancyEffectViewSizeConstraints) {
        [vibrancyEffectView.superview removeConstraints:self.IFA_vibrancyEffectViewSizeConstraints];
    }
    if (self.IFA_blurEffectViewSizeConstraints) {
        [blurEffectView.superview removeConstraints:self.IFA_blurEffectViewSizeConstraints];
    }
    if (self.IFA_contentHorizontalLayoutConstraints) {
        [contentView removeConstraints:self.IFA_contentHorizontalLayoutConstraints];
    }
    if (self.IFA_contentVerticalLayoutConstraints) {
        [contentView removeConstraints:self.IFA_contentVerticalLayoutConstraints];
    }
    if (self.IFA_chromeViewCentreConstraints) {
        [chromeView.superview removeConstraints:self.IFA_chromeViewCentreConstraints];
    }
    if (self.IFA_chromeViewSizeConstraints) {
        [chromeView removeConstraints:self.IFA_chromeViewSizeConstraints];
    }

    BOOL allContentItemsHidden =
            activityIndicatorView.hidden
                    && progressView.hidden
                    && (!customView || customView.hidden)
                    && textLabel.hidden
                    && detailTextLabel.hidden;
    if (!allContentItemsHidden) {

        // Content horizontal layout constraints
        [self.IFA_contentHorizontalLayoutConstraints removeAllObjects];
        for (id subviewIdObj in self.contentSubviewVerticalOrder) {
            IFAHudContentSubviewId subviewId = (IFAHudContentSubviewId) ((NSNumber *)subviewIdObj).unsignedIntegerValue;
            NSString *viewName = [self IFA_nameForContentSubviewId:subviewId];
            UIView *subview = views[viewName];
            if (subview && !subview.hidden) {
                NSString *paddingConstraintsVisualFormatRelation = subview==progressView ? @"" : @">=";
                NSString *paddingConstraintsVisualFormatConstant = @(self.chromeHorizontalPadding).stringValue;
                NSString *constraintsVisualFormat = [NSString stringWithFormat:@"H:|-(%@%@@999)-[%@]-(%@%@@999)-|",
                                                                               paddingConstraintsVisualFormatRelation,
                                                                               paddingConstraintsVisualFormatConstant,
                                                                               viewName,
                                                                               paddingConstraintsVisualFormatRelation,
                                                                               paddingConstraintsVisualFormatConstant];
                [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:constraintsVisualFormat
                                                                                                                         options:(NSLayoutFormatOptions) 0
                                                                                                                         metrics:nil
                                                                                                                           views:views]];
            }
        }
        [contentView addConstraints:self.IFA_contentHorizontalLayoutConstraints];

        // Content vertical layout constraints
        [self.IFA_contentVerticalLayoutConstraints removeAllObjects];
        NSString *paddingConstraintsVisualFormatConstant = @(self.chromeVerticalPadding).stringValue;
        NSString *interitemSpacingConstraintsVisualFormatConstant = @(self.chromeVerticalInteritemSpacing).stringValue;
        NSMutableString *contentVerticalLayoutConstraintsVisualFormat = [@"V:|" mutableCopy];
        BOOL isTopSubview = YES;
        for (id subviewIdObj in self.contentSubviewVerticalOrder) {
            IFAHudContentSubviewId subviewId = (IFAHudContentSubviewId) ((NSNumber *)subviewIdObj).unsignedIntegerValue;
            NSString *viewName = [self IFA_nameForContentSubviewId:subviewId];
            UIView *subview = views[viewName];
            if (subview && !subview.hidden) {
                NSString *spacingConstraintConstant;
                if (isTopSubview) {
                    spacingConstraintConstant = paddingConstraintsVisualFormatConstant;
                    isTopSubview = NO;
                } else {
                    spacingConstraintConstant = interitemSpacingConstraintsVisualFormatConstant;
                }
                NSString *stringToAppendToVisualFormat = [NSString stringWithFormat:@"-(%@)-[%@]",
                                                                                    spacingConstraintConstant, viewName];
                [contentVerticalLayoutConstraintsVisualFormat appendString:stringToAppendToVisualFormat];
                [self.IFA_contentVerticalLayoutConstraints addObject:[subview ifa_addLayoutConstraintToCenterInSuperviewHorizontally]];
            }
        }
        NSString *stringToAppendToVisualFormat = [NSString stringWithFormat:@"-(%@)-|", paddingConstraintsVisualFormatConstant];
        [contentVerticalLayoutConstraintsVisualFormat appendString:stringToAppendToVisualFormat];
        [self.IFA_contentVerticalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:contentVerticalLayoutConstraintsVisualFormat
                                                                                                               options:(NSLayoutFormatOptions) 0
                                                                                                               metrics:nil
                                                                                                                 views:views]];
        [contentView addConstraints:self.IFA_contentVerticalLayoutConstraints];

    }

    // Vibrancy effect view size constraints
    if (blurEffectView.superview) {
        self.IFA_blurEffectViewSizeConstraints = [blurEffectView ifa_addLayoutConstraintsToFillSuperview];

    }

    // Blur effect view size constraints
    if (vibrancyEffectView.superview) {
        self.IFA_vibrancyEffectViewSizeConstraints = [vibrancyEffectView ifa_addLayoutConstraintsToFillSuperview];
    }
    
    // Content view size constraints
    self.IFA_contentViewSizeConstraints = [self.contentView ifa_addLayoutConstraintsToFillSuperview];

    // Chrome view centre constraints
    self.IFA_chromeViewCentreConstraints = [self.chromeView ifa_addLayoutConstraintsToCenterInSuperview];

    // Chrome view size constraints
    CGFloat referenceScreenWidth = self.chromeViewMaximumLayoutWidth;
    if (self.bounds.size.width < referenceScreenWidth) {
        referenceScreenWidth = self.bounds.size.width;
    }
    CGFloat horizontalMargin = self.chromeHorizontalMargin * 2;   //both left and right
    if (referenceScreenWidth <= horizontalMargin) {
        horizontalMargin = 0;
    }
    CGFloat chromeViewMaxWidth = referenceScreenWidth - horizontalMargin;
    NSLayoutConstraint *chromeViewMaxWidthConstraint = [NSLayoutConstraint constraintWithItem:chromeView
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                   relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                      toItem:nil
                                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                                  multiplier:1
                                                                                    constant:chromeViewMaxWidth];
    [chromeView addConstraint:chromeViewMaxWidthConstraint];
    CGSize newChromeViewSize = [chromeView systemLayoutSizeFittingSize:self.chromeViewLayoutFittingSize];
    [chromeView removeConstraint:chromeViewMaxWidthConstraint];
    self.IFA_chromeViewSizeConstraints = [chromeView ifa_addLayoutConstraintsForSize:newChromeViewSize];

    [super updateConstraints];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"text"]) {
        UILabel *label = object;
        label.hidden = change[NSKeyValueChangeNewKey] == [NSNull null]; // This should trigger another call to this method as "hidden" is also being observed
    } else if ([keyPath isEqualToString:@"hidden"]) {
        [self IFA_updateLayout];
    }
}

#pragma mark - Private

- (NSMutableArray *)IFA_contentHorizontalLayoutConstraints {
    if (!_IFA_contentHorizontalLayoutConstraints) {
        _IFA_contentHorizontalLayoutConstraints = [@[] mutableCopy];
    }
    return _IFA_contentHorizontalLayoutConstraints;
}

- (NSMutableArray *)IFA_contentVerticalLayoutConstraints {
    if (!_IFA_contentVerticalLayoutConstraints) {
        _IFA_contentVerticalLayoutConstraints = [@[] mutableCopy];
    }
    return _IFA_contentVerticalLayoutConstraints;
}

- (void)IFA_addMotionEffects {

    BOOL shouldAddMotionEffects = YES;
    if (&UIAccessibilityIsReduceMotionEnabled != NULL && UIAccessibilityIsReduceMotionEnabled()) {  // iOS 8 backwards compatibility
        shouldAddMotionEffects = NO;
    }
    if (shouldAddMotionEffects) {
        CGFloat offset = 20.0;
        UIInterpolatingMotionEffect *motionEffectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        motionEffectX.maximumRelativeValue = @(offset);
        motionEffectX.minimumRelativeValue = @(-offset);
        UIInterpolatingMotionEffect *motionEffectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        motionEffectY.maximumRelativeValue = @(offset);
        motionEffectY.minimumRelativeValue = @(-offset);
        UIMotionEffectGroup *group = [UIMotionEffectGroup new];
        group.motionEffects = @[motionEffectX, motionEffectY];
        [self.chromeView addMotionEffect:group];
    }

}

- (void)IFA_updateViewHierarchy {

    // Content subviews
    [self.contentView addSubview:self.textLabel];
    [self.contentView addSubview:self.activityIndicatorView];
    [self.contentView addSubview:self.progressView];
    [self.contentView addSubview:self.detailTextLabel];

    // Chrome subviews
    [self IFA_updateChromeViewHierarchy];

    // Chrome view
    [self addSubview:self.chromeView];

}

- (void)IFA_updateChromeViewHierarchy {

    [self.IFA_vibrancyEffectView removeFromSuperview];
    [self.IFA_blurEffectView removeFromSuperview];
    [self.contentView removeFromSuperview];

    // Forces the blur effect view to be re-initialised with the current blur effect style (in case it has changed)
    self.IFA_blurEffectView = nil;

    IFAHudViewStyle style = [UIVisualEffectView class] ? self.style : IFAHudViewStylePlain; // iOS 8 backwards compatibility
    switch (style) {

        case IFAHudViewStylePlain:

            // Content container view
            [self.chromeView addSubview:self.contentView];

            break;

        case IFAHudViewStyleBlur:

            // Content container view
            [self.IFA_blurEffectView.contentView addSubview:self.contentView];

            // Blur effect view
            [self.chromeView addSubview:self.IFA_blurEffectView];

            break;

        case IFAHudViewStyleBlurAndVibrancy:

            // Content container view
            [self.IFA_vibrancyEffectView.contentView addSubview:self.contentView];

            // Vibrancy effect view
            [self.IFA_blurEffectView.contentView addSubview:self.IFA_vibrancyEffectView];

            // Blur effect view
            [self.chromeView addSubview:self.IFA_blurEffectView];

            break;

    }

}

- (void)IFA_updateColours {

    // Chrome foreground
    UIColor *foregroundColour = self.chromeForegroundColour;
    self.textLabel.textColor = foregroundColour;
    self.detailTextLabel.textColor = foregroundColour;
    self.activityIndicatorView.color = foregroundColour;
    self.progressView.progressTintColor = foregroundColour;
    self.customView.tintColor = foregroundColour;

    // Chrome background
    self.chromeView.backgroundColor = self.chromeBackgroundColour;

    // Overlay
    self.backgroundColor = self.overlayColour;

    // Progress view track
    self.progressView.trackTintColor = self.progressViewTrackTintColour;

}

- (void)IFA_updateLayout {
    [self IFA_updateFonts];
    [self setNeedsUpdateConstraints];
    if (self.shouldUpdateLayoutAutomaticallyOnContentChange) {
        if (self.shouldAnimateLayoutChanges) {
            [UIView animateWithDuration:0.1 animations:^{
                [self layoutIfNeeded];
            }];
        } else {
            [self layoutIfNeeded];
        }
    }
}

- (void)IFA_updateFonts {
    self.textLabel.font = self.textLabelFont ? : [UIFont preferredFontForTextStyle:self.textLabelFontTextStyle];
    self.detailTextLabel.font = self.detailTextLabelFont ? : [UIFont preferredFontForTextStyle:self.detailTextLabelFontTextStyle];
}

- (void)IFA_addObservers {

    // "text" observations
    [self.textLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [self.detailTextLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];

    // "hidden" observations
    [self.activityIndicatorView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    [self.progressView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    [self.textLabel addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    [self.detailTextLabel addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];

    // Content size category change
    __weak __typeof(self) weakSelf = self;
    self.IFA_contentSizeCategoryChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification
                                                                                               object:nil
                                                                                                queue:nil
                                                                                           usingBlock:^(NSNotification *note) {
                                                                                               [weakSelf IFA_updateLayout];
                                                                                           }];

}

- (void)IFA_removeObservers {

    // "text" observations
    [self.textLabel removeObserver:self forKeyPath:@"text" context:nil];
    [self.detailTextLabel removeObserver:self forKeyPath:@"text" context:nil];

    // "hidden" observations
    [self.activityIndicatorView removeObserver:self forKeyPath:@"hidden" context:nil];
    [self.progressView removeObserver:self forKeyPath:@"hidden" context:nil];
    [self.textLabel removeObserver:self forKeyPath:@"hidden" context:nil];
    [self.detailTextLabel removeObserver:self forKeyPath:@"hidden" context:nil];

    // Content size category change
    [[NSNotificationCenter defaultCenter] removeObserver:self.IFA_contentSizeCategoryChangeObserver];

}

- (UIVisualEffectView *)IFA_blurEffectView {
    if (!_IFA_blurEffectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        _IFA_blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _IFA_blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _IFA_blurEffectView;
}

- (UIVisualEffectView *)IFA_vibrancyEffectView {
    if (!_IFA_vibrancyEffectView) {
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:(UIBlurEffect *) self.IFA_blurEffectView.effect];
        _IFA_vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        _IFA_vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _IFA_vibrancyEffectView;
}

- (IFAHudViewStyle)IFA_defaultStyleModal {
    return (IFAHudViewStyle) ((NSNumber *) [self IFA_defaultValueForAppearancePropertyNamed:@"modalStyle"]).unsignedIntegerValue;
}

- (IFAHudViewStyle)IFA_defaultStyleNonModal {
    return (IFAHudViewStyle) ((NSNumber *) [self IFA_defaultValueForAppearancePropertyNamed:@"nonModalStyle"]).unsignedIntegerValue;
}

- (UIBlurEffectStyle)IFA_defaultBlurEffectStyleModal {
    return (UIBlurEffectStyle) ((NSNumber *) [self IFA_defaultValueForAppearancePropertyNamed:@"modalBlurEffectStyle"]).unsignedIntegerValue;
}

- (UIBlurEffectStyle)IFA_defaultBlurEffectStyleNonModal {
    return (UIBlurEffectStyle) ((NSNumber *) [self IFA_defaultValueForAppearancePropertyNamed:@"nonModalBlurEffectStyle"]).unsignedIntegerValue;
}

- (CGSize)IFA_defaultChromeViewLayoutFittingSize {
    return ((NSValue *) [self IFA_defaultValueForAppearancePropertyNamed:@"chromeViewLayoutFittingSize"]).CGSizeValue;
}

- (BOOL)IFA_defaultShouldAnimateLayoutChanges {
    return ((NSNumber *) [self IFA_defaultValueForAppearancePropertyNamed:@"shouldAnimateLayoutChanges"]).boolValue;
}

- (CGFloat)IFA_defaultChromeHorizontalPadding {
    return ((NSNumber *) [self IFA_defaultValueForAppearancePropertyNamed:@"chromeHorizontalPadding"]).floatValue;
}

- (CGFloat)IFA_defaultChromeHorizontalMargin {
    return ((NSNumber *) [self IFA_defaultValueForAppearancePropertyNamed:@"chromeHorizontalMargin"]).floatValue;
}

- (CGFloat)IFA_defaultChromeVerticalPadding {
    return ((NSNumber *) [self IFA_defaultValueForAppearancePropertyNamed:@"chromeVerticalPadding"]).floatValue;
}

- (CGFloat)IFA_defaultChromeVerticalInteritemSpacing {
    return ((NSNumber *) [self IFA_defaultValueForAppearancePropertyNamed:@"chromeVerticalInteritemSpacing"]).floatValue;
}

- (UIColor *)IFA_defaultOverlayColourNonModal {
    return [self IFA_defaultValueForAppearancePropertyNamed:@"nonModalOverlayColour"];
}

- (UIColor *)IFA_defaultChromeForegroundColourNonModal {
    return [self IFA_defaultValueForAppearancePropertyNamed:@"nonModalChromeForegroundColour"];
}

- (UIColor *)IFA_defaultChromeBackgroundColourNonModal {
    return [self IFA_defaultValueForAppearancePropertyNamed:@"nonModalChromeBackgroundColour"];
}

- (UIColor *)IFA_defaultProgressViewTrackTintColourNonModal {
    return [self IFA_defaultValueForAppearancePropertyNamed:@"nonModalProgressViewTrackTintColour"];
}

- (UIColor *)IFA_defaultOverlayColourModal {
    return [self IFA_defaultValueForAppearancePropertyNamed:@"modalOverlayColour"];
}

- (UIColor *)IFA_defaultChromeForegroundColourModal {
    return [self IFA_defaultValueForAppearancePropertyNamed:@"modalChromeForegroundColour"];
}

- (UIColor *)IFA_defaultChromeBackgroundColourModal {
    return [self IFA_defaultValueForAppearancePropertyNamed:@"modalChromeBackgroundColour"];
}

- (UIColor *)IFA_defaultProgressViewTrackTintColourModal {
    return [self IFA_defaultValueForAppearancePropertyNamed:@"modalProgressViewTrackTintColour"];
}

- (NSString *)IFA_defaultTextLabelFontTextStyle {
    return [self IFA_defaultValueForAppearancePropertyNamed:@"textLabelFontTextStyle"];
}

- (NSString *)IFA_defaultDetailTextLabelFontTextStyle {
    return [self IFA_defaultValueForAppearancePropertyNamed:@"detailTextLabelFontTextStyle"];
}

- (CGFloat)IFA_defaultChromeViewMaximumLayoutWidth {
    return ((NSNumber *) [self IFA_defaultValueForAppearancePropertyNamed:@"chromeViewMaximumLayoutWidth"]).floatValue;
}

- (UITapGestureRecognizer *)IFA_chromeTapGestureRecognizer {
    if (!_IFA_chromeTapGestureRecognizer) {
        _IFA_chromeTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(IFA_onChromeTapGestureRecognizerAction)];
    }
    return _IFA_chromeTapGestureRecognizer;
}

- (UITapGestureRecognizer *)IFA_overlayTapGestureRecognizer {
    if (!_IFA_overlayTapGestureRecognizer) {
        _IFA_overlayTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(IFA_onOverlayTapGestureRecognizerAction)];
    }
    return _IFA_overlayTapGestureRecognizer;
}

- (void)IFA_onChromeTapGestureRecognizerAction {
    if (self.chromeTapActionBlock) {
        self.chromeTapActionBlock();
    }
}

- (void)IFA_onOverlayTapGestureRecognizerAction {
    if (self.overlayTapActionBlock) {
        self.overlayTapActionBlock();
    }
}

- (void)IFA_addGestureRecognisers {
    [self.chromeView addGestureRecognizer:self.IFA_chromeTapGestureRecognizer];
    [self addGestureRecognizer:self.IFA_overlayTapGestureRecognizer];
}

- (void)IFA_updateStyle {
    [self IFA_updateViewHierarchy];
    [self IFA_updateColours];
    [self IFA_updateLayout];
}

- (NSString *)IFA_nameForContentSubviewId:(IFAHudContentSubviewId)a_contentSubviewId {
    return self.IFA_contentSubviewName[a_contentSubviewId];
}

- (id)IFA_defaultValueForAppearancePropertyNamed:(NSString *)a_propertyName {
    return self.IFA_defaultAppearanceProperties[a_propertyName];
}

- (NSDictionary *)IFA_defaultAppearanceProperties {
    return [IFADefaultAppearanceTheme defaultAppearancePropertiesForHudView:self];
}

@end