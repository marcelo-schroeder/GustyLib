//
//  IFAPresenter.h
//  Gusty
//
//  Created by Marcelo Schroeder on 9/05/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

#import <Foundation/Foundation.h>

@protocol IFAPresenter <NSObject>

@required

// Called when presented view controller is done handling dismissal user action
- (void)sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                       data:(id)a_data shouldAnimateDismissal:(BOOL)a_shouldAnimateDismissal;

@optional

// Called after presentation transition animation
-(void)didPresentViewController:(UIViewController*)a_viewController;

// Called when changes are made by the presented view controller
-(void)changesMadeByViewController:(UIViewController*)a_viewController;

// Called after dismissal transition animation
- (void)didDismissViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                            data:(id)a_data;

@end
