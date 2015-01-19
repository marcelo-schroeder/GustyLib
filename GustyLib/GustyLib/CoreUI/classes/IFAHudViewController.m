//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCoreUI.h"

//wip: does the dynamic font stuff work?
//wip: test rotation again when some serious blurring is available (e.g. map view)
//wip: I'm relying on the dimming plumming - I am going to use a dimmed bg? Clean up.
//wip: does the motion stuff has to respect accessibility settings?
@interface IFAHudViewController ()
@property(nonatomic, strong) IFAViewControllerTransitioningDelegate *viewControllerTransitioningDelegate;
@property(nonatomic, strong) UIView *IFA_frameView;
//@property(nonatomic, strong) UIVisualEffectView *IFA_blurEffectView;  //wip: clean up stuff related to visual effects (lots of comments)
//@property(nonatomic, strong) UIVisualEffectView *IFA_vibrancyEffectView;
@property(nonatomic, strong) UIView *IFA_contentView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailTextLabel;
@property(nonatomic, strong) NSMutableArray *IFA_contentHorizontalLayoutConstraints;
@property(nonatomic, strong) NSMutableArray *IFA_contentVerticalLayoutConstraints;
@property(nonatomic, strong) NSArray *IFA_frameViewSizeConstraints;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UITapGestureRecognizer *IFA_tapGestureRecognizer;
@end

@implementation IFAHudViewController {

}

#pragma mark - Public

- (void)setTapActionBlock:(void (^)())tapActionBlock {
    _tapActionBlock = tapActionBlock;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel new];
        _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textLabel.hidden = YES;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 0;
        _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];   //wip: move to theme?
        _textLabel.textColor = [self IFA_foregroundColour];   //wip: move to theme?
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
        _detailTextLabel.textColor = [self IFA_foregroundColour];   //wip: move to theme?
    }
    return _detailTextLabel;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicatorView.hidden = YES;
        _activityIndicatorView.color = [self IFA_foregroundColour];  //wip: move to theme?
    }
    return _activityIndicatorView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.hidden = YES;
        _progressView.progressTintColor = [self IFA_foregroundColour];   //wip: move to theme?
        _progressView.trackTintColor = [UIColor lightGrayColor];    //wip: move to theme?
    }
    return _progressView;
}

#pragma mark - Overrides

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.frameViewLayoutFittingSize = UILayoutFittingCompressedSize;

        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.viewControllerTransitioningDelegate;

        [self IFA_addObservers];

        [self IFA_configureViewHierarchy];
        [self IFA_addImmutableLayoutConstraints];

    }
    return self;
}

- (void)dealloc {
    [self IFA_removeObservers];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self IFA_updateContentViewLayoutConstraints];
    [self IFA_addMotionEffects];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"text"] || [keyPath isEqualToString:@"hidden"]) {
        if ([keyPath isEqualToString:@"text"]) {
            UILabel *label = object;
            label.hidden = change[NSKeyValueChangeNewKey]==[NSNull null];
        }
        [self IFA_updateContentViewLayoutConstraints];
    }
}

#pragma mark - Private

- (IFAViewControllerTransitioningDelegate *)viewControllerTransitioningDelegate {
    if (!_viewControllerTransitioningDelegate) {
        _viewControllerTransitioningDelegate = [IFADimmedFadingOverlayViewControllerTransitioningDelegate new];
        _viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.presentationTransitionDuration = 0.3;
        _viewControllerTransitioningDelegate.viewControllerAnimatedTransitioning.dismissalTransitionDuration = 1;
    }
    return _viewControllerTransitioningDelegate;
}

- (UIView *)IFA_contentView {
    if (!_IFA_contentView) {
        _IFA_contentView = [UIView new];
        _IFA_contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _IFA_contentView.backgroundColor = [UIColor clearColor];
        NSLog(@"[_IFA_contentView description] = %@", [_IFA_contentView description]);  //wip: clean up
    }
    return _IFA_contentView;
}

- (UITapGestureRecognizer *)IFA_tapGestureRecognizer {
    if (!_IFA_tapGestureRecognizer) {
        _IFA_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(IFA_onTapGestureRecognizerAction)];
    }
    return _IFA_tapGestureRecognizer;
}

- (void)IFA_onTapGestureRecognizerAction {
    if (self.tapActionBlock) {
        self.tapActionBlock();
    }
}

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

- (void)IFA_updateContentViewLayoutConstraints {

    UIView *contentView = self.IFA_contentView;
    UIView *frameView = self.IFA_frameView;
    UIActivityIndicatorView *activityIndicatorView = self.activityIndicatorView;
    UIProgressView *progressView = self.progressView;
    UILabel *textLabel = self.textLabel;
    UILabel *detailTextLabel = self.detailTextLabel;
    NSDictionary *views = NSDictionaryOfVariableBindings(activityIndicatorView, progressView, textLabel, detailTextLabel);

    // Update label sizes
    [textLabel sizeToFit];
    [detailTextLabel sizeToFit];

    // Remove existing constraints
    [contentView removeConstraints:self.IFA_contentHorizontalLayoutConstraints];
    [contentView removeConstraints:self.IFA_contentVerticalLayoutConstraints];
    [frameView removeConstraints:self.IFA_frameViewSizeConstraints];

    BOOL allContentItemsHidden = activityIndicatorView.hidden
            && progressView.hidden
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
    if (self.view.bounds.size.width < referenceScreenWidth) {
        referenceScreenWidth = self.view.bounds.size.width;
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
    [self.IFA_frameView addMotionEffect:group];
}

//- (UIVisualEffectView *)IFA_blurEffectView {
//    if (!_IFA_blurEffectView) {
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        _IFA_blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//        _IFA_blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
//    }
//    return _IFA_blurEffectView;
//}

//- (UIVisualEffectView *)IFA_vibrancyEffectView {
//    if (!_IFA_vibrancyEffectView) {
//        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:(UIBlurEffect *) self.IFA_blurEffectView.effect];
//        _IFA_vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
//        _IFA_vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = NO;
//    }
//    return _IFA_vibrancyEffectView;
//}

- (UIView *)IFA_frameView {
    if (!_IFA_frameView) {
        _IFA_frameView = [UIView new];
        _IFA_frameView.translatesAutoresizingMaskIntoConstraints = NO;
        _IFA_frameView.backgroundColor = [[self IFA_backgroundColour] colorWithAlphaComponent:0.95];    //wip: move to theme
        CALayer *layer = _IFA_frameView.layer;
        layer.cornerRadius = 9.0;
        layer.masksToBounds = YES;
        [_IFA_frameView addGestureRecognizer:self.IFA_tapGestureRecognizer];
        NSLog(@"[_IFA_frameView description] = %@", [_IFA_frameView description]);  //wip: clean up
    }
    return _IFA_frameView;
}

- (void)IFA_configureViewHierarchy {

    // Content views
    [self.IFA_contentView addSubview:self.activityIndicatorView];
    [self.IFA_contentView addSubview:self.progressView];
    [self.IFA_contentView addSubview:self.textLabel];
    [self.IFA_contentView addSubview:self.detailTextLabel];

    // Content container view
    [self.IFA_frameView addSubview:self.IFA_contentView];

//    // Content container view
//    [self.IFA_vibrancyEffectView.contentView addSubview:self.IFA_contentView];
//    [self.IFA_contentView ifa_addLayoutConstraintsToFillSuperview];

//    // Vibrancy effect view
//    [self.IFA_blurEffectView.contentView addSubview:self.IFA_vibrancyEffectView];
//    [self.IFA_vibrancyEffectView ifa_addLayoutConstraintsToFillSuperview];

//    // Blur effect view
//    [self.IFA_frameView addSubview:self.IFA_blurEffectView];
//    [self.IFA_blurEffectView ifa_addLayoutConstraintsToFillSuperview];

    // Frame view
    [self.view addSubview:self.IFA_frameView];

}

- (void)IFA_addImmutableLayoutConstraints{

    // Content container view
    [self.IFA_contentView ifa_addLayoutConstraintsToFillSuperview];

    // Frame view
    [self.IFA_frameView ifa_addLayoutConstraintsToCenterInSuperview];

}

- (UIColor *)IFA_foregroundColour{
    return [UIColor blackColor];
}

- (UIColor *)IFA_backgroundColour{
    return [UIColor whiteColor];
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