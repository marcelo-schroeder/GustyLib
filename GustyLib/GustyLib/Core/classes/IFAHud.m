//
// Created by Marcelo Schroeder on 15/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCore.h"


//wip: memory profile this window thing
@interface IFAHud ()
@property(nonatomic, strong) UIWindow *IFA_window;
@property(nonatomic, strong) IFAHudViewController *IFA_hudViewController;
@end

@implementation IFAHud {

}

#pragma mark - Public

- (void)showWithAnimation:(BOOL)a_animated completion:(void (^)())a_completion {    //wip: is animation going to work with the blur thing?
    if (self.IFA_window.hidden) {
        [self.IFA_window makeKeyAndVisible];
        [self.IFA_window.rootViewController presentViewController:self.IFA_hudViewController
                                                         animated:a_animated
                                                       completion:a_completion];
    }

}

- (void)hideWithAnimation:(BOOL)a_animated completion:(void (^)())a_completion {
    if (!self.IFA_window.hidden) {
        __weak __typeof(self) l_weakSelf = self;
        void(^completion)() = ^{
            if (a_completion) {
                a_completion();
            }
            [l_weakSelf.IFA_window resignKeyWindow];
            l_weakSelf.IFA_window.hidden = YES;
        };
        [l_weakSelf.IFA_window.rootViewController dismissViewControllerAnimated:a_animated
                                                                     completion:completion];
    }
}

- (void)setText:(NSString *)text {
    self.IFA_hudViewController.text = text;
}

- (NSString *)text {
    return self.IFA_hudViewController.text;
}


- (void)setDetailText:(NSString *)detailText {
    self.IFA_hudViewController.detailText = detailText;
}

- (NSString *)detailText {
    return self.IFA_hudViewController.detailText;
}

- (void)setTapActionBlock:(void (^)())tapActionBlock {
    _tapActionBlock = tapActionBlock;
    __weak __typeof(self) l_weakSelf = self;
    self.IFA_hudViewController.tapActionBlock = ^{
        if (l_weakSelf.tapActionBlock) {
            l_weakSelf.tapActionBlock();
        }
        if (l_weakSelf.shouldHideOnTap) {
            [l_weakSelf hideWithAnimation:YES completion:nil];
        }
    };
}

- (void)setShouldHideOnTap:(BOOL)shouldHideOnTap {
    _shouldHideOnTap = shouldHideOnTap;
}

#pragma mark - Private

- (UIWindow *)IFA_window {
    if (!_IFA_window) {
        _IFA_window = [[UIWindow alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
        _IFA_window.backgroundColor = [UIColor clearColor];
        UIViewController *rootViewController = [UIViewController new];
        _IFA_window.rootViewController = rootViewController;
    }
    return _IFA_window;
}

- (IFAHudViewController *)IFA_hudViewController {
    if (!_IFA_hudViewController) {
        _IFA_hudViewController = [IFAHudViewController new];
    }
    return _IFA_hudViewController;
}

@end