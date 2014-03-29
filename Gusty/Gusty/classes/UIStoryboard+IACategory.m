//
// Created by Marcelo Schroeder on 17/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "UIStoryboard+IACategory.h"


@implementation UIStoryboard (IACategory)

#pragma mark - Public

+ (UIStoryboard *)m_storyboardNamed:(NSString *)a_storyboardName {
    return [UIStoryboard storyboardWithName:a_storyboardName
                                     bundle:nil];
}

+ (id)m_instantiateInitialViewControllerFromStoryboardNamed:(NSString *)a_storyboardName{
    return [[self m_storyboardNamed:a_storyboardName] instantiateInitialViewController];
}

+ (id)m_instantiateViewControllerWithIdentifier:(NSString *)a_viewControllerIdentifier fromStoryboardNamed:(NSString *)a_storyboardName {
    return [[self m_storyboardNamed:a_storyboardName] instantiateViewControllerWithIdentifier:a_viewControllerIdentifier];
}

@end