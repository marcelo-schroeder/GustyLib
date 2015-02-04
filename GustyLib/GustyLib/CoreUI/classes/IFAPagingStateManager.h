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

#import <Foundation/Foundation.h>

@class IFAPagingCriteria;

typedef NS_ENUM(NSUInteger, IFAPagingStateManagerEvent) {
    IFAPagingStateManagerEventShowFirstPage,
    IFAPagingStateManagerEventShowNextPage,
    IFAPagingStateManagerEventShowAll,
};

static const NSUInteger IFAPagingPageIndexFirst = 0;
static const NSUInteger IFAPagingPageSizeAll = 0;

@interface IFAPagingStateManager : NSObject

@property(nonatomic, readonly) NSUInteger pageSize;
@property (nonatomic, readonly) NSUInteger currentPageIndex;
@property (nonatomic, readonly) NSUInteger resultsCountShowing;
@property (nonatomic, readonly) NSUInteger resultsCountTotal;

- (id)initWithPageSize:(NSUInteger)a_pageSize;

- (IFAPagingCriteria *)pagingCriteriaForEvent:(IFAPagingStateManagerEvent)a_event;

- (void)updatePagingStateWithResultsAtPageIndex:(NSUInteger)a_pageIndex
                               pageResultsCount:(NSUInteger)a_pageResultsCount
                              totalResultsCount:(NSUInteger)a_totalResultsCount;

@end

@interface IFAPagingCriteria : NSObject
@property (nonatomic, readonly) NSUInteger pageIndex;
@property (nonatomic, readonly) NSUInteger pageSize;

- (instancetype)initWithPageIndex:(NSUInteger)a_pageIndex pageSize:(NSUInteger)a_pageSize;

@end