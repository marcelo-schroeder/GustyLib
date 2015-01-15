//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCore.h"

//wip: does the dynamic font stuff work?
//wip: test rotation again when some serious blurring is available (e.g. map view)
//wip: I'm relying on the dimming plumming - I am going to use a dimmed bg? Clean up.
@interface IFAHudViewController ()
@property(nonatomic, strong) id <UIViewControllerTransitioningDelegate> IFA_viewControllerTransitioningDelegate;
@property(nonatomic, strong) UIView *IFA_frameView;
@property(nonatomic, strong) UIVisualEffectView *IFA_blurEffectView;
@property(nonatomic, strong) UIVisualEffectView *IFA_vibrancyEffectView;
@property(nonatomic, strong) UIView *IFA_contentView;
@property (nonatomic, strong) UILabel *IFA_textLabel;
@property (nonatomic, strong) UILabel *IFA_detailTextLabel;
@property(nonatomic, strong) NSMutableArray *IFA_contentHorizontalLayoutConstraints;
@property(nonatomic, strong) NSArray *IFA_contentVerticalLayoutConstraints;
@property(nonatomic, strong) NSArray *IFA_frameViewSizeConstraints;
@property(nonatomic, strong) UIActivityIndicatorView *IFA_activityIndicatorView;
@property(nonatomic, strong) UIProgressView *IFA_progressView;
@property (nonatomic, strong) UITapGestureRecognizer *IFA_tapGestureRecognizer;
@end

@implementation IFAHudViewController {

}

#pragma mark - Public

- (void)setText:(NSString *)text {
    _text = text;
    self.IFA_textLabel.text = _text;
    [self.IFA_textLabel sizeToFit];
    [self IFA_updateContentViewLayoutConstraints];
}

- (void)setDetailText:(NSString *)detailText {
    _detailText = detailText;
    self.IFA_detailTextLabel.text = _detailText;
    [self.IFA_detailTextLabel sizeToFit];
    [self IFA_updateContentViewLayoutConstraints];
}

- (void)setTapActionBlock:(void (^)())tapActionBlock {
    _tapActionBlock = tapActionBlock;
}

#pragma mark - Overrides

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.IFA_viewControllerTransitioningDelegate;
        [self IFA_configureViewHierarchy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self IFA_updateContentViewLayoutConstraints];
    [self IFA_addMotionEffects];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.IFA_activityIndicatorView startAnimating];
}

#pragma mark - Private

- (IFAViewControllerTransitioningDelegate *)IFA_viewControllerTransitioningDelegate {
    if (!_IFA_viewControllerTransitioningDelegate) {
        _IFA_viewControllerTransitioningDelegate = [IFADimmedFadingOverlayViewControllerTransitioningDelegate new];
    }
    return _IFA_viewControllerTransitioningDelegate;
}

- (UIView *)IFA_contentView {
    if (!_IFA_contentView) {
        _IFA_contentView = [UIView new];
        _IFA_contentView.translatesAutoresizingMaskIntoConstraints = NO;
        _IFA_contentView.backgroundColor = [UIColor clearColor];
    }
    return _IFA_contentView;
}

- (UILabel *)IFA_textLabel {
    if (!_IFA_textLabel) {
        _IFA_textLabel = [UILabel new];
        _IFA_textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _IFA_textLabel.textAlignment = NSTextAlignmentCenter;
        _IFA_textLabel.numberOfLines = 0;
        _IFA_textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];   //wip: move to theme?
    }
    return _IFA_textLabel;
}

- (UILabel *)IFA_detailTextLabel {
    if (!_IFA_detailTextLabel) {
        _IFA_detailTextLabel = [UILabel new];
        _IFA_detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _IFA_detailTextLabel.textAlignment = NSTextAlignmentCenter;
        _IFA_detailTextLabel.numberOfLines = 0;
        _IFA_detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];   //wip: move to theme?
    }
    return _IFA_detailTextLabel;
}

- (UIActivityIndicatorView *)IFA_activityIndicatorView {
    if (!_IFA_activityIndicatorView) {
        _IFA_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _IFA_activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
//        _IFA_activityIndicatorView.color = [UIColor blackColor];  //wip: move to theme?
    }
    return _IFA_activityIndicatorView;
}

- (UIProgressView *)IFA_progressView {
    if (!_IFA_progressView) {
        _IFA_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _IFA_progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _IFA_progressView.progress = 0.25;  //wip: hardcoded
//        _IFA_progressView.progressTintColor = [UIColor blackColor];   //wip: move to theme?
        _IFA_progressView.trackTintColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];    //wip: move to theme?
    }
    return _IFA_progressView;
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

- (void)IFA_updateContentViewLayoutConstraints {

    UIView *contentView = self.IFA_contentView;
    UIActivityIndicatorView *activityIndicatorView = self.IFA_activityIndicatorView;
    UIProgressView *progressView = self.IFA_progressView;
    UILabel *textLabel = self.IFA_textLabel;
    UILabel *detailTextLabel = self.IFA_detailTextLabel;
    NSDictionary *views = NSDictionaryOfVariableBindings(activityIndicatorView, progressView, textLabel, detailTextLabel);

    // Content horizontal layout constraints
    [contentView removeConstraints:self.IFA_contentHorizontalLayoutConstraints];
    [self.IFA_contentHorizontalLayoutConstraints removeAllObjects];
    [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8)-[activityIndicatorView]-(>=8)-|"
                                                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                                                             metrics:nil
                                                                                                               views:views]];
    [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[progressView]-|"
                                                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                                                             metrics:nil
                                                                                                               views:views]];
    [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8)-[textLabel]-(>=8)-|"
                                                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                                                             metrics:nil
                                                                                                               views:views]];
    [self.IFA_contentHorizontalLayoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=8)-[detailTextLabel]-(>=8)-|"
                                                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                                                             metrics:nil
                                                                                                               views:views]];
    [contentView addConstraints:self.IFA_contentHorizontalLayoutConstraints];

    // Content vertical layout constraints
    [contentView removeConstraints:self.IFA_contentVerticalLayoutConstraints];
    NSMutableString *contentVerticalLayoutConstraintsVisualFormat = [@"V:|" mutableCopy];
    [contentVerticalLayoutConstraintsVisualFormat appendString:@"-[activityIndicatorView]"];
    [contentVerticalLayoutConstraintsVisualFormat appendString:@"-[progressView]"];
    [contentVerticalLayoutConstraintsVisualFormat appendString:@"-[textLabel]"];
    [contentVerticalLayoutConstraintsVisualFormat appendString:@"-[detailTextLabel]"];
    [contentVerticalLayoutConstraintsVisualFormat appendString:@"-|"];
    self.IFA_contentVerticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:contentVerticalLayoutConstraintsVisualFormat
                                                                        options:NSLayoutFormatAlignAllCenterX
                                                                        metrics:nil
                                                                          views:views];
    [contentView addConstraints:self.IFA_contentVerticalLayoutConstraints];

    // Frame view size constraints
    UIView *frameView = self.IFA_frameView;
    [frameView removeConstraints:self.IFA_frameViewSizeConstraints];
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
    CGSize newFrameViewSize = [frameView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
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
    [self.IFA_contentView addMotionEffect:group];
}

- (UIVisualEffectView *)IFA_blurEffectView {
    if (!_IFA_blurEffectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
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

- (UIView *)IFA_frameView {
    if (!_IFA_frameView) {
        _IFA_frameView = [UIView new];
        _IFA_frameView.translatesAutoresizingMaskIntoConstraints = NO;
        CALayer *layer = _IFA_blurEffectView.layer;
        layer.cornerRadius = 9.0;
        layer.masksToBounds = YES;
        [_IFA_frameView addGestureRecognizer:self.IFA_tapGestureRecognizer];
    }
    return _IFA_frameView;
}

- (void)IFA_configureViewHierarchy {

    // Content views
    [self.IFA_contentView addSubview:self.IFA_activityIndicatorView];
    [self.IFA_contentView addSubview:self.IFA_progressView];
    [self.IFA_contentView addSubview:self.IFA_textLabel];
    [self.IFA_contentView addSubview:self.IFA_detailTextLabel];

    // Content container view
    [self.IFA_vibrancyEffectView.contentView addSubview:self.IFA_contentView];
    [self.IFA_contentView ifa_addLayoutConstraintsToFillSuperview];

    // Vibrancy effect view
    [self.IFA_blurEffectView.contentView addSubview:self.IFA_vibrancyEffectView];
    [self.IFA_vibrancyEffectView ifa_addLayoutConstraintsToFillSuperview];

    // Blur effect view
    [self.IFA_frameView addSubview:self.IFA_blurEffectView];
    [self.IFA_blurEffectView ifa_addLayoutConstraintsToFillSuperview];

    // Frame view
    [self.view addSubview:self.IFA_frameView];
    [self.IFA_frameView ifa_addLayoutConstraintsToCenterInSuperview];

}

@end