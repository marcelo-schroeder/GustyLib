//
// Created by Marcelo Schroeder on 31/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAUIViewController.h"

//wip: add sliding panel functionality
@interface IAUIMasterDetailViewController : IAUIViewController
@property (strong, nonatomic) UIViewController *p_masterViewController;
@property (strong, nonatomic) UIViewController *p_detailViewController;
@property (strong, nonatomic, readonly) UIView *p_masterContainerView;
@property (strong, nonatomic, readonly) UIView *p_detailContainerView;
@property (strong, nonatomic, readonly) UIView *p_separatorView;
@end
