//
// Created by Marcelo Schroeder on 17/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

@interface UIStoryboard (IFACoreUI)

// Default implementation assumes storyboard has the same name as the view controller class name
+ (UIStoryboard *)ifa_storyboardNamed:(NSString *)a_storyboardName;

// Uses ifa_storyboardNamed: to determine the storyboard to instantiate the view controller from
+ (id)ifa_instantiateInitialViewControllerFromStoryboardNamed:(NSString *)a_storyboardName;

// Uses ifa_storyboardNamed: to determine the storyboard to instantiate the view controller from
+ (id)ifa_instantiateViewControllerWithIdentifier:(NSString *)a_viewControllerIdentifier
                              fromStoryboardNamed:(NSString *)a_storyboardName;
@end