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

/**
* This class manages the presentation of the <IFAHudViewController> in the context of
* a modal HUD indicating the progress of an asynchronous task.
*/
@interface IFAWorkInProgressModalViewManager : NSObject

/**
* Indicates whether a determinate progress indicator should be used instead of an indeterminate progress indicator.
* If YES, then use <determinateProgressPercentage> to indicate how much progress the progress indicator should show.
*/
@property (nonatomic) BOOL determinateProgress;

/**
* Determines how much progress the determinate progress indicator should show.
* This property is only relevant when <determinateProgress> is set to YES.
*/
@property (nonatomic) CGFloat determinateProgressPercentage;

/**
* Message to be displayed along with the progress indicator.
*/
@property (nonatomic, strong) NSString *progressMessage;

/**
* Indicates whether the user has cancelled the operation.
*/
@property (nonatomic) BOOL hasBeenCancelled;

/**
* The underlying <IFAHudViewController> instance used.
*/
@property (nonatomic, strong, readonly) IFAHudViewController *hudViewController;

/**
* Block to execute when the user cancels the operation.
* When not nil, this will enable user interaction for cancellation of the current operation.
*/
@property(nonatomic, strong) void (^cancellationCompletionBlock)();

/**
* Presents the HUD view in its dedicated UIWindow instance.
*
* @param a_message Initial message to be displayed.
*/
- (void)showViewWithMessage:(NSString *)a_message;

/**
* Presents the HUD view.
*
* @param a_message Initial message to be displayed.
*
* @param a_parentViewController Parent view controller to which the HUD view controller will be added as a child view controller.
* If nil, a dedicated UIWindow instance with a UIViewController instance as its root view controller will be created.
* The HUD view controller will then be added as a child view controller of the dedicated UIWindow's root view controller.
*
* @param a_parentView Parent view controller's view to which the HUD view controller's view will be added as a subview.
* If nil, a_parentViewController's view is used as the parent view.
*
* @param a_animated Indicates whether the presentation transition will be animated or not.
*/
- (void)showViewWithMessage:(NSString *)a_message
       parentViewController:(UIViewController *)a_parentViewController
                 parentView:(UIView *)a_parentView
                   animated:(BOOL)a_animated;

/**
* Dismisses the HUD view.
*/
- (void)hideView;

/**
* Dismisses the HUD view.
*
* @param a_animated Indicates whether the dismissal transition will be animated or not.
*/
- (void)hideViewAnimated:(BOOL)a_animated;

@end
