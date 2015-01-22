//
// Created by Marcelo Schroeder on 14/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFAViewController.h"
#import "IFAHudView.h"

@class IFAHudView;

//wip: add documentation
@interface IFAHudViewController : IFAViewController

@property (nonatomic, strong, readonly) IFAHudView *hudView;

@property(nonatomic, strong, readonly) IFAViewControllerTransitioningDelegate *viewControllerTransitioningDelegate;

- (instancetype)initWithStyle:(IFAHudViewStyle)a_style NS_DESIGNATED_INITIALIZER;

@end