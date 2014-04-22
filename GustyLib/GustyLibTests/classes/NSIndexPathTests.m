//
//  Gusty - NSIndexPathTests.m
//  Copyright 2014 InfoAccent Pty Limited. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IACommonTests.h"
#import "NSIndexPath+IACategory.h"

@interface NSIndexPathTests : XCTestCase
@end

@implementation NSIndexPathTests{
}

- (void)testIndexPathsForRowRangeAndSection {

    // given
    NSRange l_rowRange = NSMakeRange(2, 3);
    NSInteger l_section = 1;

    // when
    NSArray *l_indexPaths = [NSIndexPath m_indexPathsForRowRange:l_rowRange
                                                         section:l_section];
    // then
    assertThat(l_indexPaths,
    contains(
            [NSIndexPath indexPathForRow:2 inSection:1],
            [NSIndexPath indexPathForRow:3 inSection:1],
            [NSIndexPath indexPathForRow:4 inSection:1],
            nil
    ));

}

@end
