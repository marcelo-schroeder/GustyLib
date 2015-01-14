//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCore.h"

//wip: handle rotation now?
@interface IFAHudViewController ()
@property(nonatomic, strong) id <UIViewControllerTransitioningDelegate> IFA_viewControllerTransitioningDelegate;
@property(nonatomic, strong) UIView *IFA_contentView;
@property (nonatomic, strong) UILabel *IFA_textLabel;
@property(nonatomic, strong) NSArray *IFA_contentHorizontalLayoutConstraints;
@property(nonatomic, strong) NSArray *IFA_contentVerticalLayoutConstraints;
@property(nonatomic, strong) NSArray *contentViewSizeConstraints;
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

#pragma mark - Overrides

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.IFA_viewControllerTransitioningDelegate;
        [self.IFA_contentView addSubview:self.IFA_textLabel];
        [self.view addSubview:self.IFA_contentView];
        [self.IFA_contentView ifa_addLayoutConstraintsToCenterInSuperview];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self IFA_updateContentViewLayoutConstraints];
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
        _IFA_contentView.backgroundColor = [UIColor whiteColor];
        CALayer *layer = _IFA_contentView.layer;
        layer.cornerRadius = 9.0;
        layer.masksToBounds = YES;
    }
    return _IFA_contentView;
}

- (UILabel *)IFA_textLabel {
    if (!_IFA_textLabel) {
        _IFA_textLabel = [UILabel new];
        _IFA_textLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _IFA_textLabel.textAlignment = NSTextAlignmentCenter;
        _IFA_textLabel.numberOfLines = 0;
    }
    return _IFA_textLabel;
}

- (void)IFA_updateContentViewLayoutConstraints {

    UIView *contentView = self.IFA_contentView;
    UILabel *textLabel = self.IFA_textLabel;
    NSDictionary *views = NSDictionaryOfVariableBindings(contentView, textLabel);

    // Content horizontal layout constraints
    [contentView removeConstraints:self.IFA_contentHorizontalLayoutConstraints];
    self.IFA_contentHorizontalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textLabel]-|"
                                                                        options:NSLayoutFormatAlignAllCenterY
                                                                        metrics:nil
                                                                          views:views];
    [contentView addConstraints:self.IFA_contentHorizontalLayoutConstraints];

    // Content vertical layout constraints
    [contentView removeConstraints:self.IFA_contentVerticalLayoutConstraints];
    self.IFA_contentVerticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[textLabel]-|"
                                                                        options:NSLayoutFormatAlignAllCenterX
                                                                        metrics:nil
                                                                          views:views];
    [contentView addConstraints:self.IFA_contentVerticalLayoutConstraints];

    // Content container view size constraints
    [contentView removeConstraints:self.contentViewSizeConstraints];
    CGFloat contentViewMaxWidth = self.view.bounds.size.width - 20 - 20;   //wip: hardcoded
    NSLayoutConstraint *contentViewMaxWidthConstraint = [NSLayoutConstraint constraintWithItem:contentView
                                                                                  attribute:NSLayoutAttributeWidth
                                                                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1
                                                                                   constant:contentViewMaxWidth];
    [contentView addConstraint:contentViewMaxWidthConstraint];
    CGSize newContentViewSize = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    [contentView removeConstraint:contentViewMaxWidthConstraint];
    self.contentViewSizeConstraints = [contentView ifa_addLayoutConstraintsForSize:newContentViewSize];

}

@end