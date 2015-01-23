//
// Created by Marcelo Schroeder on 21/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <GustyLib/IFAHudView.h>
#import "GustyLib.h"

//wip: make the blur style the default style (tried it quickly and had some auto layout errors)
//wip: test rotation again when some serious blurring is available (e.g. map view)
//wip: clean up comments
//wip: need to manage whether the background blocks user interaction or not (somehow I lost that ability)
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
@end

@implementation IFAHudView {
    UIColor *_overlayColour;
    UIColor *_chromeForegroundColour;
    UIColor *_chromeBackgroundColour;
}

#pragma mark - Public

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        // Set ivar's directly otherwise UIKit won't override via appearance API
        _style = IFAHudViewStylePlain;
        _chromeViewLayoutFittingSize = UILayoutFittingCompressedSize;
        _blurEffectStyle = UIBlurEffectStyleDark;

        [self IFA_addObservers];
        [self IFA_configureViewHierarchy];
        [self IFA_addGestureRecognisers];
        [self IFA_updateColours];
        [self IFA_addMotionEffects];
        [self IFA_updateLayout];    //wip: do I need this?

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
    _overlayColour = overlayColour;
    [self IFA_updateColours];
}

- (UIColor *)overlayColour {
    if (_overlayColour) {
        return _overlayColour;
    } else {
        return self.IFA_defaultOverlayColour;
    }
}

- (void)setChromeForegroundColour:(UIColor *)chromeForegroundColour {
    _chromeForegroundColour = chromeForegroundColour;
    [self IFA_updateColours];
}

- (UIColor *)chromeForegroundColour {
    if (_chromeForegroundColour) {
        return _chromeForegroundColour;
    } else {
        return self.IFA_defaultChromeForegroundColour;
    }
}

- (void)setChromeBackgroundColour:(UIColor *)chromeBackgroundColour {
    _chromeBackgroundColour = chromeBackgroundColour;
    [self IFA_updateColours];
}

- (UIColor *)chromeBackgroundColour {
    if (_chromeBackgroundColour) {
        return _chromeBackgroundColour;
    } else {
        return self.IFA_defaultChromeBackgroundColour;
    }
}

- (void)setBlurEffectStyle:(UIBlurEffectStyle)blurEffectStyle {
    _blurEffectStyle = blurEffectStyle;
    [self IFA_updateStyle];
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
//        NSLog(@"[_contentView description] = %@", [_contentView description]);    //wip: clean up
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (UIView *)chromeView {
    if (!_chromeView) {
        _chromeView = [UIView new];
//        NSLog(@"[_chromeView description] = %@", [_chromeView description]);    //wip: clean up
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
    [self.contentView addSubview:_customView];
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
    NSMutableDictionary *views = [NSDictionaryOfVariableBindings(activityIndicatorView, progressView, textLabel, detailTextLabel) mutableCopy];
    if (customView) {
        views[@"customView"] = customView;
    }

    // Remove existing constraints
    [contentView.superview removeConstraints:self.IFA_contentViewSizeConstraints];
    [contentView removeConstraints:self.IFA_contentHorizontalLayoutConstraints];
    [contentView removeConstraints:self.IFA_contentVerticalLayoutConstraints];
    [chromeView.superview removeConstraints:self.IFA_chromeViewCentreConstraints];
    [chromeView removeConstraints:self.IFA_chromeViewSizeConstraints];

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
            [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8@999)-[textLabel]-(>=8@999)-|"
                                                                                                                     options:(NSLayoutFormatOptions) 0
                                                                                                                     metrics:nil
                                                                                                                       views:views]];
        }
        if (!activityIndicatorView.hidden) {
            [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8@999)-[activityIndicatorView]-(>=8@999)-|"
                                                                                                                     options:(NSLayoutFormatOptions) 0
                                                                                                                     metrics:nil
                                                                                                                       views:views]];
        }
        if (!progressView.hidden) {
            [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8@999)-[progressView]-(>=8@999)-|"
                                                                                                                     options:(NSLayoutFormatOptions) 0
                                                                                                                     metrics:nil
                                                                                                                       views:views]];
        }
        if (customView && !customView.hidden) {
            [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8@999)-[customView]-(>=8@999)-|"
                                                                                                                     options:(NSLayoutFormatOptions) 0
                                                                                                                     metrics:nil
                                                                                                                       views:views]];
        }
        if (!detailTextLabel.hidden) {
            [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8@999)-[detailTextLabel]-(>=8@999)-|"
                                                                                                                     options:(NSLayoutFormatOptions) 0
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
                                                                                                               options:(NSLayoutFormatOptions) 0
                                                                                                               metrics:nil
                                                                                                                 views:views]];
        [contentView addConstraints:self.IFA_contentVerticalLayoutConstraints];

    }

    // Content view size constraints
    self.IFA_contentViewSizeConstraints = [self.contentView ifa_addLayoutConstraintsToFillSuperview];   //wip: review

    // Chrome view centre constraints
    self.IFA_chromeViewCentreConstraints = [self.chromeView ifa_addLayoutConstraintsToCenterInSuperview];   //wip: review

    // Chrome view size constraints
    CGFloat referenceScreenWidth = 320;   //wip: hardcoded - maybe this should be exposed?
    if (self.bounds.size.width < referenceScreenWidth) {
        referenceScreenWidth = self.bounds.size.width;
    }
    CGFloat horizontalMargin = 20 + 20;   //wip: hardcoded - maybe this should be exposed?
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
//    NSLog(@"NSStringFromCGSize(newChromeViewSize) = %@", NSStringFromCGSize(newChromeViewSize));    //wip: clean up
    [chromeView removeConstraint:chromeViewMaxWidthConstraint];
    self.IFA_chromeViewSizeConstraints = [chromeView ifa_addLayoutConstraintsForSize:newChromeViewSize];

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
    [self.chromeView addMotionEffect:group];
}

- (void)IFA_configureViewHierarchy {

    // Content subviews
    [self.contentView addSubview:self.activityIndicatorView];
    [self.contentView addSubview:self.progressView];
    [self.contentView addSubview:self.textLabel];
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

    switch (self.style) {

        case IFAHudViewStylePlain:

            // Content container view
            [self.chromeView addSubview:self.contentView];

            break;

        case IFAHudViewStyleBlur:

            // Content container view
            [self.IFA_blurEffectView.contentView addSubview:self.contentView];

            // Blur effect view
            [self.chromeView addSubview:self.IFA_blurEffectView];
            [self.IFA_blurEffectView ifa_addLayoutConstraintsToFillSuperview];  //wip: will this stay here

            break;

        case IFAHudViewStyleBlurAndVibrancy:

            // Content container view
            [self.IFA_vibrancyEffectView.contentView addSubview:self.contentView];

            // Vibrancy effect view
            [self.IFA_blurEffectView.contentView addSubview:self.IFA_vibrancyEffectView];
            [self.IFA_vibrancyEffectView ifa_addLayoutConstraintsToFillSuperview];  //wip: will this stay here

            // Blur effect view
            [self.chromeView addSubview:self.IFA_blurEffectView];
            [self.IFA_blurEffectView ifa_addLayoutConstraintsToFillSuperview];  //wip: will this stay here

            break;

    }

}

- (void)IFA_updateColours {

    // Chrome foreground
    UIColor *foregroundColour = self.chromeForegroundColour;
    self.textLabel.textColor = foregroundColour;   //wip: move to theme?
    self.detailTextLabel.textColor = foregroundColour;   //wip: move to theme?
    self.activityIndicatorView.color = foregroundColour;  //wip: move to theme?
    self.progressView.progressTintColor = foregroundColour;   //wip: move to theme?
    self.progressView.trackTintColor = [UIColor lightGrayColor];    //wip: move to theme? (ALSO: VALUE HARDCODED)
    self.customView.tintColor = foregroundColour;   //wip: move to theme?

    // Chrome background
    self.chromeView.backgroundColor = self.chromeBackgroundColour;    //wip: move to theme

    // Overlay
    self.backgroundColor = self.overlayColour;    //wip: move to theme

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

- (void)setStyle:(IFAHudViewStyle)style {
    _style = style;
    [self IFA_updateStyle];
}

- (void)setChromeViewLayoutFittingSize:(CGSize)chromeViewLayoutFittingSize {
    _chromeViewLayoutFittingSize = chromeViewLayoutFittingSize;
    [self IFA_updateLayout];
}

- (UIColor *)IFA_defaultOverlayColour {
    return [UIColor clearColor];
}

- (UIColor *)IFA_defaultChromeForegroundColour {
    return [UIColor whiteColor];
}

- (UIColor *)IFA_defaultChromeBackgroundColour {
    UIColor *color;
    switch (self.style) {
        case IFAHudViewStylePlain:
            color = [[UIColor blackColor] colorWithAlphaComponent:0.75];
            break;
        case IFAHudViewStyleBlur:
        case IFAHudViewStyleBlurAndVibrancy:
            color = [UIColor clearColor];
            break;
    }
    return color;
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
    [self IFA_updateChromeViewHierarchy];
    [self IFA_updateColours];
    [self IFA_updateLayout];
}

@end