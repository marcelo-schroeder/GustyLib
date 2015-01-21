//
// Created by Marcelo Schroeder on 21/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFAView.h"

//wip: add doc
//wip: add lincense
@interface IFAHudView : IFAView

@property(nonatomic, strong, readonly) UIView *frameView;
@property(nonatomic, strong, readonly) UIView *contentView;
@property(nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong, readonly) UIProgressView *progressView;
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UILabel *detailTextLabel;
@property (nonatomic, strong) UIView *customView;

@property (nonatomic, strong) UIColor *frameForegroundColour;
@property (nonatomic, strong) UIColor *frameBackgroundColour;

@property(nonatomic) CGSize frameViewLayoutFittingSize;

@end