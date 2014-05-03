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

#import "UIStoryboard+IACategory.h"


@implementation UIStoryboard (IACategory)

#pragma mark - Public

+ (UIStoryboard *)IFA_storyboardNamed:(NSString *)a_storyboardName {
    return [UIStoryboard storyboardWithName:a_storyboardName
                                     bundle:nil];
}

+ (id)IFA_instantiateInitialViewControllerFromStoryboardNamed:(NSString *)a_storyboardName{
    return [[self IFA_storyboardNamed:a_storyboardName] instantiateInitialViewController];
}

+ (id)IFA_instantiateViewControllerWithIdentifier:(NSString *)a_viewControllerIdentifier fromStoryboardNamed:(NSString *)a_storyboardName {
    return [[self IFA_storyboardNamed:a_storyboardName] instantiateViewControllerWithIdentifier:a_viewControllerIdentifier];
}

@end