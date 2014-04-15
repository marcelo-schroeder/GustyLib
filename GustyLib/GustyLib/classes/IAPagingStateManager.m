//
// Created by Marcelo Schroeder on 1/04/2014.
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

#import "IAPagingStateManager.h"


@interface IAPagingStateManager ()
@property(nonatomic) NSUInteger p_pageSize;
@property (nonatomic, readwrite) NSUInteger p_currentPageIndex;
@property (nonatomic, readwrite) NSUInteger p_resultsCountShowing;
@property (nonatomic, readwrite) NSUInteger p_resultsCountTotal;
@end

@implementation IAPagingStateManager {

}

#pragma mark - Public

- (id)initWithPageSize:(NSUInteger)a_pageSize {
    self = [super init];
    if (self) {
        self.p_pageSize = a_pageSize;
    }
    return self;
}

- (IAPagingCriteria *)m_pagingCriteriaForEvent:(IAPagingStateManagerEvent)a_event {
    NSUInteger l_pageIndex = 0, l_pageSize = 0;
    switch (a_event) {
        case IAPagingStateManagerEventShowFirstPage:
            l_pageIndex = k_IAPagingPageIndexFirst;
            l_pageSize = self.p_pageSize;
            break;
        case IAPagingStateManagerEventShowNextPage:
            l_pageIndex = self.p_currentPageIndex;
            l_pageIndex++;
            l_pageSize = self.p_pageSize;
            break;
        case IAPagingStateManagerEventShowAll:
            l_pageIndex = k_IAPagingPageIndexFirst;
            l_pageSize = k_IAPagingPageSizeAll;
            break;
        default:
            NSAssert(NO, @"Unexpected event: %u", a_event);
    }
    IAPagingCriteria *l_pagingCriteria = [[IAPagingCriteria alloc] initWithPageIndex:l_pageIndex
                                                                            pageSize:l_pageSize];
    return l_pagingCriteria;
}

- (void)m_updatePagingStateWithResultsAtPageIndex:(NSUInteger)a_pageIndex
                                 pageResultsCount:(NSUInteger)a_pageResultsCount
                                totalResultsCount:(NSUInteger)a_totalResultsCount {
    self.p_currentPageIndex = a_pageIndex;
    self.p_resultsCountShowing = (a_pageIndex * self.p_pageSize) + a_pageResultsCount;
    self.p_resultsCountTotal = a_totalResultsCount;
}

@end

@interface IAPagingCriteria()
@property (nonatomic) NSUInteger p_pageIndex;
@property (nonatomic) NSUInteger p_pageSize;
@end

@implementation IAPagingCriteria

- (instancetype)initWithPageIndex:(NSUInteger)a_pageIndex pageSize:(NSUInteger)a_pageSize {
    self = [super init];
    if (self) {
        self.p_pageIndex = a_pageIndex;
        self.p_pageSize = a_pageSize;
    }
    return self;
}

@end