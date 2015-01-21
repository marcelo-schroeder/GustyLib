//
// Created by Marcelo Schroeder on 21/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLib.h"

//wip: clean up comments
@interface IFAHudView ()
@property(nonatomic, strong) UIView *frameView;
@property(nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) NSMutableArray *IFA_contentHorizontalLayoutConstraints;
@property(nonatomic, strong) NSMutableArray *IFA_contentVerticalLayoutConstraints;
@property(nonatomic, strong) NSArray *IFA_frameViewSizeConstraints;
@end

@implementation IFAHudView {

}

#pragma mark - Public

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.hidden = YES;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];   //wip: move to theme?
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
        _detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];   //wip: move to theme?
    }
    return _detailTextLabel;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicatorView.hidden = YES;
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

- (void)setOverlayColour:(UIColor *)overlayColour {
    if (overlayColour) {
        _overlayColour = overlayColour;
    } else {
        _overlayColour = [UIColor clearColor];
    }
    _overlayColour = overlayColour;
    [self IFA_updateColours];
}

- (void)setFrameForegroundColour:(UIColor *)frameForegroundColour {
    if (frameForegroundColour) {
        _frameForegroundColour = frameForegroundColour;
    } else {
        _frameForegroundColour = [UIColor whiteColor];
    }
    [self IFA_updateColours];
}

- (void)setFrameBackgroundColour:(UIColor *)frameBackgroundColour {
    if (frameBackgroundColour) {
        _frameBackgroundColour = frameBackgroundColour;
    } else {
        _frameBackgroundColour = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    }
    [self IFA_updateColours];
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIView *)frameView {
    if (!_frameView) {
        _frameView = [UIView new];
        _frameView.translatesAutoresizingMaskIntoConstraints = NO;
        CALayer *layer = _frameView.layer;
        layer.cornerRadius = 9.0;
        layer.masksToBounds = YES;
    }
    return _frameView;
}

- (void)setCustomView:(UIView *)customView {
    [_customView removeFromSuperview];
    _customView = customView;
    _customView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_customView];
    [self IFA_updateLayout];
}

#pragma mark - Overrides

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frameViewLayoutFittingSize = UILayoutFittingCompressedSize;
        [self IFA_addObservers];
        [self IFA_configureViewHierarchy];
        [self IFA_addImmutableLayoutConstraints];
        [self IFA_updateColours];
        [self IFA_addMotionEffects];
    }
    return self;
}

- (void)dealloc {
    [self IFA_removeObservers];
}

- (void)updateConstraints {

    UIView *contentView = self.contentView;
    UIView *frameView = self.frameView;
    UIActivityIndicatorView *activityIndicatorView = self.activityIndicatorView;
    UIProgressView *progressView = self.progressView;
    UIView *customView = self.customView;
    UILabel *textLabel = self.textLabel;
    UILabel *detailTextLabel = self.detailTextLabel;
    NSMutableDictionary *views = [NSDictionaryOfVariableBindings(activityIndicatorView, progressView, textLabel, detailTextLabel) mutableCopy];
    if (customView) {
        views[@"customView"] = customView;
    }

    // Update label sizes
    [textLabel sizeToFit];
    [detailTextLabel sizeToFit];

    // Remove existing constraints
    [contentView removeConstraints:self.IFA_contentHorizontalLayoutConstraints];
    [contentView removeConstraints:self.IFA_contentVerticalLayoutConstraints];
    [frameView removeConstraints:self.IFA_frameViewSizeConstraints];

    BOOL allContentItemsHidden =
            activityIndicatorView.hidden
                    && progressView.hidden
                    && (!customView || customView.hidden)
                    && textLabel.hidden
                    && detailTextLabel.hidden;
    if (!allContentItemsHidden) {

        // Content horizontal layout constraints
        [self.IFA_contentHorizontalLayoutConstraints removeAllObjects];
        if (!textLabel.hidden) {
            [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8)-[textLabel]-(>=8)-|"
                                                                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                                                                     metrics:nil
                                                                                                                       views:views]];
        }
        if (!activityIndicatorView.hidden) {
            [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8)-[activityIndicatorView]-(>=8)-|"
                                                                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                                                                     metrics:nil
                                                                                                                       views:views]];
        }
        if (!progressView.hidden) {
            [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[progressView]-|"
                                                                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                                                                     metrics:nil
                                                                                                                       views:views]];
        }
        if (customView && !customView.hidden) {
            [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8)-[customView]-(>=8)-|"
                                                                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                                                                     metrics:nil
                                                                                                                       views:views]];
        }
        if (!detailTextLabel.hidden) {
            [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8)-[detailTextLabel]-(>=8)-|"
                                                                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                                                                     metrics:nil
                                                                                                                       views:views]];
        }
        [contentView addConstraints:self.IFA_contentHorizontalLayoutConstraints];

        // Content vertical layout constraints
        [self.IFA_contentVerticalLayoutConstraints removeAllObjects];
        NSMutableString *contentVerticalLayoutConstraintsVisualFormat = [@"V:|" mutableCopy];
        if (!textLabel.hidden) {
            [contentVerticalLayoutConstraintsVisualFormat appendString:@"-[textLabel]"];
            [self.IFA_contentVerticalLayoutConstraints addObject:[textLabel ifa_addLayoutConstraintToCenterInSuperviewHorizontally]];
        }
        if (!activityIndicatorView.hidden) {
            [contentVerticalLayoutConstraintsVisualFormat appendString:@"-[activityIndicatorView]"];
            [self.IFA_contentVerticalLayoutConstraints addObject:[activityIndicatorView ifa_addLayoutConstraintToCenterInSuperviewHorizontally]];
        }
        if (!progressView.hidden) {
            [contentVerticalLayoutConstraintsVisualFormat appendString:@"-[progressView]"];
            [self.IFA_contentVerticalLayoutConstraints addObject:[progressView ifa_addLayoutConstraintToCenterInSuperviewHorizontally]];
        }
        if (customView && !customView.hidden) {
            [contentVerticalLayoutConstraintsVisualFormat appendString:@"-[customView]"];
            [self.IFA_contentVerticalLayoutConstraints addObject:[customView ifa_addLayoutConstraintToCenterInSuperviewHorizontally]];
        }
        if (!detailTextLabel.hidden) {
            [contentVerticalLayoutConstraintsVisualFormat appendString:@"-[detailTextLabel]"];
            [self.IFA_contentVerticalLayoutConstraints addObject:[detailTextLabel ifa_addLayoutConstraintToCenterInSuperviewHorizontally]];
        }
        [contentVerticalLayoutConstraintsVisualFormat appendString:@"-|"];
        [self.IFA_contentVerticalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:contentVerticalLayoutConstraintsVisualFormat
                                                                                                               options:NSLayoutFormatAlignAllCenterX
                                                                                                               metrics:nil
                                                                                                                 views:views]];
        [contentView addConstraints:self.IFA_contentVerticalLayoutConstraints];

    }

    // Frame view size constraints
    CGFloat referenceScreenWidth = 320;   //wip: hardcoded - maybe this should be exposed?
    if (self.bounds.size.width < referenceScreenWidth) {
        referenceScreenWidth = self.bounds.size.width;
    }
    CGFloat horizontalMargin = 20 + 20;   //wip: hardcoded - maybe this should be exposed?
    if (referenceScreenWidth <= horizontalMargin) {
        horizontalMargin = 0;
    }
    CGFloat frameViewMaxWidth = referenceScreenWidth - horizontalMargin;
    NSLayoutConstraint *frameViewMaxWidthConstraint = [NSLayoutConstraint constraintWithItem:frameView
                                                                                   attribute:NSLayoutAttributeWidth
                                                                                   relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                      toItem:nil
                                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                                  multiplier:1
                                                                                    constant:frameViewMaxWidth];
    [frameView addConstraint:frameViewMaxWidthConstraint];
    CGSize newFrameViewSize = [frameView systemLayoutSizeFittingSize:self.frameViewLayoutFittingSize];
    [frameView removeConstraint:frameViewMaxWidthConstraint];
    self.IFA_frameViewSizeConstraints = [frameView ifa_addLayoutConstraintsForSize:newFrameViewSize];

    [super updateConstraints];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"text"] || [keyPath isEqualToString:@"hidden"]) {
        if ([keyPath isEqualToString:@"text"]) {
            UILabel *label = object;
            label.hidden = change[NSKeyValueChangeNewKey]==[NSNull null];
        }
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
    [self.frameView addMotionEffect:group];
}

- (void)IFA_configureViewHierarchy {

    // Content views
    [self.contentView addSubview:self.activityIndicatorView];
    [self.contentView addSubview:self.progressView];
    [self.contentView addSubview:self.textLabel];
    [self.contentView addSubview:self.detailTextLabel];

    // Content container view
    [self.frameView addSubview:self.contentView];

//    // Content container view
//    [self.IFA_vibrancyEffectView.contentView addSubview:self.contentView];
//    [self.contentView ifa_addLayoutConstraintsToFillSuperview];

//    // Vibrancy effect view
//    [self.IFA_blurEffectView.contentView addSubview:self.IFA_vibrancyEffectView];
//    [self.IFA_vibrancyEffectView ifa_addLayoutConstraintsToFillSuperview];

//    // Blur effect view
//    [self.frameView addSubview:self.IFA_blurEffectView];
//    [self.IFA_blurEffectView ifa_addLayoutConstraintsToFillSuperview];

    // Frame view
    [self addSubview:self.frameView];

}

- (void)IFA_addImmutableLayoutConstraints{

    // Content container view
    [self.contentView ifa_addLayoutConstraintsToFillSuperview];

    // Frame view
    [self.frameView ifa_addLayoutConstraintsToCenterInSuperview];

}

- (void)IFA_updateColours {

    // Overlay
    self.backgroundColor = self.overlayColour;    //wip: move to theme

    // Frame foreground
    UIColor *foregroundColour = self.frameForegroundColour;
    self.textLabel.textColor = foregroundColour;   //wip: move to theme?
    self.detailTextLabel.textColor = foregroundColour;   //wip: move to theme?
    self.activityIndicatorView.color = foregroundColour;  //wip: move to theme?
    self.progressView.progressTintColor = foregroundColour;   //wip: move to theme?
    self.progressView.trackTintColor = [UIColor lightGrayColor];    //wip: move to theme? (ALSO: VALUE HARDCODED)
    self.customView.tintColor = foregroundColour;   //wip: move to theme?

    // Frame background
    self.frameView.backgroundColor = self.frameBackgroundColour;    //wip: move to theme

}

- (void)IFA_updateLayout {
    [self setNeedsUpdateConstraints];
    if (self.shouldAnimateLayoutChanges) {
        [UIView animateWithDuration:0.1 animations:^{
            [self layoutIfNeeded];
        }];
    } else {
        [self layoutIfNeeded];
    }
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

}

@end