//
//  Gusty - IAPagingStateManagerTests.m
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

#import "IFACommonTests.h"
#import "IAPagingStateManager.h"

@interface IAPagingStateManagerTests : XCTestCase
@property(nonatomic, strong) IAPagingStateManager *p_pagingStateManager;
@end

@implementation IAPagingStateManagerTests{
}

- (void)setUp {
    [super setUp];
    self.p_pagingStateManager = [[IAPagingStateManager alloc] initWithPageSize:10];
}

- (void)testUsualPagingLifeCycle {

    IAPagingStateManager *l_pagingStateManager = self.p_pagingStateManager;
    static NSUInteger const k_totalResultsCount = 25;

    // Initial state
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(0)));

    // First page criteria
    IAPagingCriteria *l_pagingCriteria = [l_pagingStateManager pagingCriteriaForEvent:IAPagingStateManagerEventShowFirstPage];
    assertThatUnsignedInteger(l_pagingCriteria.p_pageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingCriteria.p_pageSize, is(equalToUnsignedInteger(10)));

    // First page results - full page
    [l_pagingStateManager updatePagingStateWithResultsAtPageIndex:0
                                                   pageResultsCount:10
                                                  totalResultsCount:k_totalResultsCount];
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(25)));

    // Second page criteria
    l_pagingCriteria = [l_pagingStateManager pagingCriteriaForEvent:IAPagingStateManagerEventShowNextPage];
    assertThatUnsignedInteger(l_pagingCriteria.p_pageIndex, is(equalToUnsignedInteger(1)));
    assertThatUnsignedInteger(l_pagingCriteria.p_pageSize, is(equalToUnsignedInteger(10)));

    // Second page results - full page
    [l_pagingStateManager updatePagingStateWithResultsAtPageIndex:1
                                                   pageResultsCount:10
                                                  totalResultsCount:k_totalResultsCount];
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(1)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(20)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(25)));

    // Third page criteria
    l_pagingCriteria = [l_pagingStateManager pagingCriteriaForEvent:IAPagingStateManagerEventShowNextPage];
    assertThatUnsignedInteger(l_pagingCriteria.p_pageIndex, is(equalToUnsignedInteger(2)));
    assertThatUnsignedInteger(l_pagingCriteria.p_pageSize, is(equalToUnsignedInteger(10)));

    // Third page results - partial page
    [l_pagingStateManager updatePagingStateWithResultsAtPageIndex:2
                                                   pageResultsCount:5
                                                  totalResultsCount:k_totalResultsCount];
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(2)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(25)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(25)));

    // First page criteria - again
    l_pagingCriteria = [l_pagingStateManager pagingCriteriaForEvent:IAPagingStateManagerEventShowFirstPage];
    assertThatUnsignedInteger(l_pagingCriteria.p_pageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingCriteria.p_pageSize, is(equalToUnsignedInteger(10)));

    // First page results - again - full page
    [l_pagingStateManager updatePagingStateWithResultsAtPageIndex:0
                                                   pageResultsCount:10
                                                  totalResultsCount:k_totalResultsCount];
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(25)));

    // Show all criteria
    l_pagingCriteria = [l_pagingStateManager pagingCriteriaForEvent:IAPagingStateManagerEventShowAll];
    assertThatUnsignedInteger(l_pagingCriteria.p_pageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingCriteria.p_pageSize, is(equalToUnsignedInteger(0)));

    // First page results - again - full page
    [l_pagingStateManager updatePagingStateWithResultsAtPageIndex:0
                                                   pageResultsCount:k_totalResultsCount
                                                  totalResultsCount:k_totalResultsCount];
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(25)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(25)));

}

@end
