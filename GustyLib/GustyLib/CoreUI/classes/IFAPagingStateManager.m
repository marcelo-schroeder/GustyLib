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

#import "IFAPagingStateManager.h"


@interface IFAPagingStateManager ()
@property(nonatomic) NSUInteger pageSize;
@property (nonatomic, readwrite) NSUInteger currentPageIndex;
@property (nonatomic, readwrite) NSUInteger resultsCountShowing;
@property (nonatomic, readwrite) NSUInteger resultsCountTotal;
@end

@implementation IFAPagingStateManager {

}

#pragma mark - Public

- (id)initWithPageSize:(NSUInteger)a_pageSize {
    self = [super init];
    if (self) {
        self.pageSize = a_pageSize;
    }
    return self;
}

- (IFAPagingCriteria *)pagingCriteriaForEvent:(IFAPagingStateManagerEvent)a_event {
    NSUInteger l_pageIndex = 0, l_pageSize = 0;
    switch (a_event) {
        case IFAPagingStateManagerEventShowFirstPage:
            l_pageIndex = IFAPagingPageIndexFirst;
            l_pageSize = self.pageSize;
            break;
        case IFAPagingStateManagerEventShowNextPage:
            l_pageIndex = self.currentPageIndex;
            l_pageIndex++;
            l_pageSize = self.pageSize;
            break;
        case IFAPagingStateManagerEventShowAll:
            l_pageIndex = IFAPagingPageIndexFirst;
            l_pageSize = IFAPagingPageSizeAll;
            break;
        default:
            NSAssert(NO, @"Unexpected event: %lu", (unsigned long)a_event);
    }
    IFAPagingCriteria *l_pagingCriteria = [[IFAPagingCriteria alloc] initWithPageIndex:l_pageIndex
                                                                            pageSize:l_pageSize];
    return l_pagingCriteria;
}

- (void)updatePagingStateWithResultsAtPageIndex:(NSUInteger)a_pageIndex
                               pageResultsCount:(NSUInteger)a_pageResultsCount
                              totalResultsCount:(NSUInteger)a_totalResultsCount {
    self.currentPageIndex = a_pageIndex;
    self.resultsCountShowing = (a_pageIndex * self.pageSize) + a_pageResultsCount;
    self.resultsCountTotal = a_totalResultsCount;
}

@end

@interface IFAPagingCriteria ()
@property (nonatomic) NSUInteger pageIndex;
@property (nonatomic) NSUInteger pageSize;
@end

@implementation IFAPagingCriteria

- (instancetype)initWithPageIndex:(NSUInteger)a_pageIndex pageSize:(NSUInteger)a_pageSize {
    self = [super init];
    if (self) {
        self.pageIndex = a_pageIndex;
        self.pageSize = a_pageSize;
    }
    return self;
}

@end