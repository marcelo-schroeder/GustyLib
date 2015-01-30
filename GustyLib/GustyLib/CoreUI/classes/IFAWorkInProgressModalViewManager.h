//
//  IFAWorkInProgressModalViewManager.h
//  Gusty
//
//  Created by Marcelo Schroeder on 18/04/11.
//  Copyright 2010 InfoAccent Pty Limited. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

@class IFAHudViewController;

//wip: clean up commented code
//wip: add doc
@interface IFAWorkInProgressModalViewManager : NSObject

@property (nonatomic) BOOL determinateProgress;
@property (nonatomic) CGFloat determinateProgressPercentage;
@property (nonatomic, strong) NSString *progressMessage;
@property (nonatomic) BOOL hasBeenCancelled;

@property (nonatomic, strong, readonly) IFAHudViewController *hudViewController;

@property(nonatomic, strong) void (^cancelationCompletionBlock)();

- (void)showViewWithMessage:(NSString *)a_message;

- (void)showViewWithMessage:(NSString *)a_message
       parentViewController:(UIViewController *)a_parentViewController
                 parentView:(UIView *)a_parentView
                   animated:(BOOL)a_animated;

- (void)hideView;

- (void)hideViewAnimated:(BOOL)a_animated;

@end
