//
// Created by Marcelo Schroeder on 1/04/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAPagingCriteria;

typedef enum {
    IAPagingStateManagerEventShowFirstPage,
    IAPagingStateManagerEventShowNextPage,
    IAPagingStateManagerEventShowAll,
} IAPagingStateManagerEvent;

static const NSUInteger k_IAPagingPageIndexFirst = 0;
static const NSUInteger k_IAPagingPageSizeAll = 0;

@interface IAPagingStateManager : NSObject

@property(nonatomic, readonly) NSUInteger p_pageSize;
@property (nonatomic, readonly) NSUInteger p_currentPageIndex;
@property (nonatomic, readonly) NSUInteger p_resultsCountShowing;
@property (nonatomic, readonly) NSUInteger p_resultsCountTotal;

- (id)initWithPageSize:(NSUInteger)a_pageSize;

- (IAPagingCriteria *)m_pagingCriteriaForEvent:(IAPagingStateManagerEvent)a_event;

- (void)m_updatePagingStateWithResultsAtPageIndex:(NSUInteger)a_pageIndex
                                 pageResultsCount:(NSUInteger)a_pageResultsCount
                                totalResultsCount:(NSUInteger)a_totalResultsCount;

@end

@interface IAPagingCriteria : NSObject
@property (nonatomic, readonly) NSUInteger p_pageIndex;
@property (nonatomic, readonly) NSUInteger p_pageSize;

- (instancetype)initWithPageIndex:(NSUInteger)a_pageIndex pageSize:(NSUInteger)a_pageSize;

@end