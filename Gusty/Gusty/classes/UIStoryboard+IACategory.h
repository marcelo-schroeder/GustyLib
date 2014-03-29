//
// Created by Marcelo Schroeder on 17/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIStoryboard (IACategory)

// Default implementation assumes storyboard has the same name as the view controller class name
+ (UIStoryboard *)m_storyboardNamed:(NSString *)a_storyboardName;

// Uses m_storyboardNamed: to determine the storyboard to instantiate the view controller from
+ (id)m_instantiateInitialViewControllerFromStoryboardNamed:(NSString *)a_storyboardName;

// Uses m_storyboardNamed: to determine the storyboard to instantiate the view controller from
+ (id)m_instantiateViewControllerWithIdentifier:(NSString *)a_viewControllerIdentifier
                            fromStoryboardNamed:(NSString *)a_storyboardName;
@end