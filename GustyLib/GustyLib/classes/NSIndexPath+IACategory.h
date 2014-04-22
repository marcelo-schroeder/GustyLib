//
// Created by Marcelo Schroeder on 8/04/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (IACategory)

/**
* Creates an array of index paths given a row range and a section.
*
* @param a_rowRange Range of rows to generate.
* @param a_section Section the index paths to be generated will belong to.
*
* @returns Array of NSIndexPath instances created based on the parameters provided.
*/
+ (NSArray *)m_indexPathsForRowRange:(NSRange)a_rowRange section:(NSInteger)a_section;

@end