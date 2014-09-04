//
// Created by Marcelo Schroeder on 4/09/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

@protocol IFAContextSwitchingManagerDelegate;

/**
* This class helps managing top level context switching such as those performed by top level view controllers such as tab bar controllers and menu view controllers in a master/detail layout.
* This allows forms being edited a chance to ask the user whether they want to lose or keep any changes.
*/
@interface IFAContextSwitchingManager : NSObject

@property (nonatomic, weak) id<IFAContextSwitchingManagerDelegate> delegate;

/**
* Call this method to request a context switch.
* This is normally called from a top level controller such as a tab bar controller.
* This method will then orchestrate the request to the currently selected view controller which will have the opportunity to grant or deny the request.
* @param a_object Optional object that will be returned in the contextSwitchingManager:didReceiveContextSwitchRequestReplyForObject:granted: delegate callback.
* @returns YES if the request can be granted immediately. NO if a reply is required via the contextSwitchingManager:didReceiveContextSwitchRequestReplyForObject:granted: delegate callback (e.g. decision requires user intervention).
*/
- (BOOL)requestContextSwitchForObject:(id)a_object;

/**
* Call this method to keep the receiver informed of the currently selected view controller.
* This is important to that any clean up can be performed when the focus moves away from the currently selected view controller.
* @param a_viewController Currently selected top level view controller.
*/
- (void)didCommitContextSwitchForViewController:(UIViewController *)a_viewController;

@end

@protocol IFAContextSwitchingManagerDelegate <NSObject>

@required

/**
* Delegate callback to indicate that a reply for context switch request has been received.
* This method is only called after the requestContextSwitchForObject: has been called and only when that method returned NO (i.e. it could not grant the request immediately).
* @param a_contextSwitchingManager The caller.
* @param a_object Same object passed in the requestContextSwitchForObject: call.
* @param a_granted YES if the request to switch context has been granted. NO if the request has not been granted.
*/
- (void)             contextSwitchingManager:(IFAContextSwitchingManager *)a_contextSwitchingManager
didReceiveContextSwitchRequestReplyForObject:(id)a_object granted:(BOOL)a_granted;

@end