//
// Created by Marcelo Schroeder on 30/04/2014.
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

@interface NSURL (IFACoreUI)

- (BOOL)ifa_isAppleUrlScheme;

/**
* Convenience method for opening the receiver by an external app.
*/
- (void)ifa_open;

/**
* Convenience method for opening the receiver by an external app with the option to ask for user confirmation before leaving the host app.
* @param a_alertPresenterViewController If provided, this view controller will present an alert asking the user whether it is ok to navigate to another app which will open the URL.
*/
- (void)ifa_openWithAlertPresenterViewController:(UIViewController *)a_alertPresenterViewController;

@end