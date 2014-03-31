//
// Created by Marcelo Schroeder on 31/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IACommon.h"
#import "IAUIMasterDetailViewController.h"

@interface IAUIMasterDetailViewController ()
@property (strong, nonatomic, readwrite) UIView *p_masterContainerView;
@property (strong, nonatomic, readwrite) UIView *p_detailContainerView;
@property (strong, nonatomic, readwrite) UIView *p_separatorView;
//@property(nonatomic, strong) UISwipeGestureRecognizer *p_swipeGestureRecogniser;
@end

@implementation IAUIMasterDetailViewController {

}

#pragma mark - Private

- (void)m_configureSubViews {
    UIView *l_masterView = self.p_masterContainerView;
    UIView *l_detailView = self.p_detailContainerView;
    UIView *l_separatorView = self.p_separatorView;
    [self.view addSubview:l_masterView];
    [self.view addSubview:l_detailView];
    [self.view addSubview:l_separatorView];
    NSDictionary *l_views = NSDictionaryOfVariableBindings(l_masterView, l_detailView, l_separatorView);
    NSArray *l_horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[l_masterView(320)][l_separatorView(1)][l_detailView]|"
                                                                               options:(NSLayoutFormatOptions) 0
                                                                               metrics:nil
                                                                                 views:l_views];
    [self.view addConstraints:l_horizontalConstraints];
    [l_masterView m_addLayoutConstraintsToFillSuperviewVertically];
    [l_detailView m_addLayoutConstraintsToFillSuperviewVertically];
    [l_separatorView m_addLayoutConstraintsToFillSuperviewVertically];
}

//- (UISwipeGestureRecognizer *)p_swipeGestureRecogniser {
//    if (!_p_swipeGestureRecogniser) {
//        _p_swipeGestureRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self
//                                                                              action:@selector(m_onSwipeGesture:)];
//        _p_swipeGestureRecogniser.direction = UISwipeGestureRecognizerDirectionLeft;
//    }
//    return _p_swipeGestureRecogniser;
//}
//
//- (void)m_onSwipeGesture:(UISwipeGestureRecognizer *)a_gestureRecogniser {
//    NSLog(@"gesture");
//}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    [self m_configureSubViews];
//    [self.view addGestureRecognizer:self.p_swipeGestureRecogniser];
}

#pragma mark - Public

- (UIView *)p_masterContainerView {
    if (!_p_masterContainerView) {
        _p_masterContainerView = [UIView new];
    }
    return _p_masterContainerView;
}

- (UIView *)p_detailContainerView {
    if (!_p_detailContainerView) {
        _p_detailContainerView = [UIView new];
    }
    return _p_detailContainerView;
}

- (UIView *)p_separatorView {
    if (!_p_separatorView) {
        _p_separatorView = [UIView new];
    }
    return _p_separatorView;
}

- (void)setP_masterViewController:(UIViewController *)p_masterViewController {
    _p_masterViewController = p_masterViewController;
    [self m_addChildViewController:_p_masterViewController parentView:self.p_masterContainerView];
}

- (void)setP_detailViewController:(UIViewController *)p_detailViewController {
    _p_detailViewController = p_detailViewController;
    [self m_addChildViewController:_p_detailViewController parentView:self.p_detailContainerView];
}

@end