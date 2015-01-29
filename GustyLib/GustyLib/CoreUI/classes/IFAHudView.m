//
// Created by Marcelo Schroeder on 21/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLib.h"

static const CGFloat k_defaultChromeHorizontalPadding = 10;

static const CGFloat k_defaultChromeVerticalPadding = 10;

static const CGFloat k_defaultChromeVerticalInteritemSpacing = 8;

//wip: clean up comments
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
    UIColor *_overlayColour;
    UIColor *_chromeForegroundColour;
    UIColor *_chromeBackgroundColour;
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
        _style = [self.class IFA_defaultStyle];
        _blurEffectStyle = [self.class IFA_defaultBlurEffectStyle];
        _chromeViewLayoutFittingSize = [self.class IFA_defaultChromeViewLayoutFittingSize];
        _shouldAnimateLayoutChanges = [self.class IFA_defaultShouldAnimateLayoutChanges];
        _chromeHorizontalPadding = [self.class IFA_defaultChromeHorizontalPadding];
        _chromeVerticalPadding = [self.class IFA_defaultChromeVerticalPadding];
        _chromeVerticalInteritemSpacing = [self.class IFA_defaultChromeVerticalInteritemSpacing];

        [self IFA_addObservers];
        [self IFA_configureViewHierarchy];
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

+ (void)resetAppearanceForHudView:(IFAHudView *)a_hudView {
    a_hudView.style = [self IFA_defaultStyle];
    a_hudView.blurEffectStyle = [self IFA_defaultBlurEffectStyle];
    a_hudView.overlayColour = nil;
    a_hudView.chromeForegroundColour = nil;
    a_hudView.chromeBackgroundColour = nil;
    a_hudView.chromeViewLayoutFittingSize = [self.class IFA_defaultChromeViewLayoutFittingSize];
    a_hudView.shouldAnimateLayoutChanges = [self.class IFA_defaultShouldAnimateLayoutChanges];
    a_hudView.textLabelFontTextStyle = nil;
    a_hudView.detailTextLabelFontTextStyle = nil;
    a_hudView.textLabelFont = nil;
    a_hudView.detailTextLabelFont = nil;
    a_hudView.chromeHorizontalPadding = [self.class IFA_defaultChromeHorizontalPadding];
    a_hudView.chromeVerticalPadding = [self.class IFA_defaultChromeVerticalPadding];
    a_hudView.chromeVerticalInteritemSpacing = [self.class IFA_defaultChromeVerticalInteritemSpacing];
}

- (void)setStyle:(IFAHudViewStyle)style {
    _style = style;
    [self IFA_updateStyle];
}

- (void)setChromeViewLayoutFittingSize:(CGSize)chromeViewLayoutFittingSize {
    _chromeViewLayoutFittingSize = chromeViewLayoutFittingSize;
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
    [contentView.superview removeConstraints:self.IFA_contentViewSizeConstraints];
    [vibrancyEffectView.superview removeConstraints:self.IFA_vibrancyEffectViewSizeConstraints];
    [blurEffectView.superview removeConstraints:self.IFA_blurEffectViewSizeConstraints];
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
        self.IFA_blurEffectViewSizeConstraints = [blurEffectView ifa_addLayoutConstraintsToFillSuperview];  //wip: will this stay here

    }

    // Blur effect view size constraints
    if (vibrancyEffectView.superview) {
        self.IFA_vibrancyEffectViewSizeConstraints = [vibrancyEffectView ifa_addLayoutConstraintsToFillSuperview];  //wip: will this stay here
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
    [self IFA_updateFonts];
    [self setNeedsUpdateConstraints];
    if (self.shouldUpdateLayoutAutomaticallyOnContentChange) {  //wip: shouldn't other things be lazily done as well (e.g. update style)
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
    self.textLabel.font = self.textLabelFont ? : [UIFont preferredFontForTextStyle:self.textLabelFontTextStyle];   //wip: move to theme?
    self.detailTextLabel.font = self.detailTextLabelFont ? : [UIFont preferredFontForTextStyle:self.detailTextLabelFontTextStyle];   //wip: move to theme?
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

+ (IFAHudViewStyle)IFA_defaultStyle {
    return IFAHudViewStyleBlur;
}

+ (UIBlurEffectStyle)IFA_defaultBlurEffectStyle {
    return UIBlurEffectStyleDark;
}

+ (CGSize)IFA_defaultChromeViewLayoutFittingSize {
    return UILayoutFittingCompressedSize;
}

+ (BOOL)IFA_defaultShouldAnimateLayoutChanges {
    return NO;
}

+ (CGFloat)IFA_defaultChromeHorizontalPadding {
    return k_defaultChromeHorizontalPadding;
}

+ (CGFloat)IFA_defaultChromeVerticalPadding {
    return k_defaultChromeVerticalPadding;
}

+ (CGFloat)IFA_defaultChromeVerticalInteritemSpacing {
    return k_defaultChromeVerticalInteritemSpacing;
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

- (NSString *)IFA_defaultTextLabelFontTextStyle {
    return UIFontTextStyleHeadline;
}

- (NSString *)IFA_defaultDetailTextLabelFontTextStyle {
    return UIFontTextStyleSubheadline;
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
    [self IFA_configureViewHierarchy];  //wip: shouldn't this method be called IFA_updateViewHierarchy?
    [self IFA_updateColours];
    [self IFA_updateLayout];
}

- (NSString *)IFA_nameForContentSubviewId:(IFAHudContentSubviewId)a_contentSubviewId {
    return self.IFA_contentSubviewName[a_contentSubviewId];
}

@end