//
// Created by Marcelo Schroeder on 8/04/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "NSIndexPath+IACategory.h"


@implementation NSIndexPath (IACategory)

#pragma mark - Public

+ (NSArray *)m_indexPathsForRowRange:(NSRange)a_rowRange section:(NSInteger)a_section {
    NSMutableArray *l_indexPaths = [@[] mutableCopy];
    for (NSUInteger l_row = a_rowRange.location; l_row < a_rowRange.location + a_rowRange.length; l_row++) {
        [l_indexPaths addObject:[NSIndexPath indexPathForRow:l_row inSection:a_section]];
    }
    return l_indexPaths;
}

@end