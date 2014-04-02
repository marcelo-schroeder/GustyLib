//
//  Gusty - IAPagingStateManagerTests.m
//  Copyright 2014 InfoAccent Pty Limited. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IACommonTests.h"
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
    IAPagingCriteria *l_pagingCriteria = [l_pagingStateManager m_pagingCriteriaForEvent:IAPagingStateManagerEventShowFirstPage];
    assertThatUnsignedInteger(l_pagingCriteria.p_pageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingCriteria.p_pageSize, is(equalToUnsignedInteger(10)));

    // First page results - full page
    [l_pagingStateManager m_updatePagingStateWithResultsAtPageIndex:0
                                                   pageResultsCount:10
                                                  totalResultsCount:k_totalResultsCount];
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(25)));

    // Second page criteria
    l_pagingCriteria = [l_pagingStateManager m_pagingCriteriaForEvent:IAPagingStateManagerEventShowNextPage];
    assertThatUnsignedInteger(l_pagingCriteria.p_pageIndex, is(equalToUnsignedInteger(1)));
    assertThatUnsignedInteger(l_pagingCriteria.p_pageSize, is(equalToUnsignedInteger(10)));

    // Second page results - full page
    [l_pagingStateManager m_updatePagingStateWithResultsAtPageIndex:1
                                                   pageResultsCount:10
                                                  totalResultsCount:k_totalResultsCount];
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(1)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(20)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(25)));

    // Third page criteria
    l_pagingCriteria = [l_pagingStateManager m_pagingCriteriaForEvent:IAPagingStateManagerEventShowNextPage];
    assertThatUnsignedInteger(l_pagingCriteria.p_pageIndex, is(equalToUnsignedInteger(2)));
    assertThatUnsignedInteger(l_pagingCriteria.p_pageSize, is(equalToUnsignedInteger(10)));

    // Third page results - partial page
    [l_pagingStateManager m_updatePagingStateWithResultsAtPageIndex:2
                                                   pageResultsCount:5
                                                  totalResultsCount:k_totalResultsCount];
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(2)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(25)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(25)));

    // First page criteria - again
    l_pagingCriteria = [l_pagingStateManager m_pagingCriteriaForEvent:IAPagingStateManagerEventShowFirstPage];
    assertThatUnsignedInteger(l_pagingCriteria.p_pageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingCriteria.p_pageSize, is(equalToUnsignedInteger(10)));

    // First page results - again - full page
    [l_pagingStateManager m_updatePagingStateWithResultsAtPageIndex:0
                                                   pageResultsCount:10
                                                  totalResultsCount:k_totalResultsCount];
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(25)));

    // Show all criteria
    l_pagingCriteria = [l_pagingStateManager m_pagingCriteriaForEvent:IAPagingStateManagerEventShowAll];
    assertThatUnsignedInteger(l_pagingCriteria.p_pageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingCriteria.p_pageSize, is(equalToUnsignedInteger(0)));

    // First page results - again - full page
    [l_pagingStateManager m_updatePagingStateWithResultsAtPageIndex:0
                                                   pageResultsCount:k_totalResultsCount
                                                  totalResultsCount:k_totalResultsCount];
    assertThatUnsignedInteger(l_pagingStateManager.p_pageSize, is(equalToUnsignedInteger(10)));
    assertThatUnsignedInteger(l_pagingStateManager.p_currentPageIndex, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountShowing, is(equalToUnsignedInteger(25)));
    assertThatUnsignedInteger(l_pagingStateManager.p_resultsCountTotal, is(equalToUnsignedInteger(25)));

}

@end
