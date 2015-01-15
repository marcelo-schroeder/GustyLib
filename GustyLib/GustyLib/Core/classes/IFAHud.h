//
// Created by Marcelo Schroeder on 15/01/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// wip: add documentation
// wip: add license
@interface IFAHud : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) void (^tapActionBlock) ();

- (void)showWithAnimation:(BOOL)a_animated completion:(void(^)())a_completion;
- (void)hideWithAnimation:(BOOL)a_animated completion:(void(^)())a_completion;

@end