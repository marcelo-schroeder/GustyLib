//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFAViewController.h"

//wip: add documentation
@interface IFAHudViewController : IFAViewController

@property(nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong, readonly) UIProgressView *progressView;
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UILabel *detailTextLabel;
@property(nonatomic, strong, readonly) IFAViewControllerTransitioningDelegate *viewControllerTransitioningDelegate;

@property (nonatomic, strong) void (^tapActionBlock) ();
@property(nonatomic) CGSize frameViewLayoutFittingSize;

@end