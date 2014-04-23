//
//  Gusty - NSIndexPathTests.m
//  Copyright 2014 InfoAccent Pty Limited. All rights reserved.
//
//  Created by: Marcelo Schroeder
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
