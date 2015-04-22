//
// Created by Marcelo Schroeder on 18/03/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
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
#import "IFACoreUITestCase.h"
#import "GustyLibCoreUI.h"


@implementation IFACoreUITestCase {

}

#pragma mark - Public

- (void)createInMemoryTestDatabase {
    [[IFAPersistenceManager sharedInstance] configureWithDatabaseResourceName:nil
                                               managedObjectModelResourceName:@"GustyLibCoreUITestsModel"
                                             managedObjectModelResourceBundle:[NSBundle bundleForClass:[self class]]];
}

- (IFAAsynchronousWorkManager *)asynchronousWorkManagerMock {
    if (!_asynchronousWorkManagerMock) {
        _asynchronousWorkManagerMock = OCMStrictClassMock([IFAAsynchronousWorkManager class]);
        OCMStub([_asynchronousWorkManagerMock cancelAllOperations]);
        OCMStub([_asynchronousWorkManagerMock dispatchOperation:[OCMArg any]
                                          showProgressIndicator:NO
                                                completionBlock:[OCMArg any]]).andCall(self, @selector(dispatchOperation:showProgressIndicator:completionBlock:));
    }
    return _asynchronousWorkManagerMock;
}

#pragma mark - Overrides

- (void)setUp{
    [super setUp];

    // Force a US calendar for week number calculation - this is the easiest week number system (i.e. it doesn't matter how many days the first week has)
    [NSCalendar ifa_setThreadSafeCalendarFirstWeekday:1];
    [NSCalendar ifa_setThreadSafeCalendarMinimumDaysInFirstWeek:1];

    self.dispatchQueueManagerPartialMock = OCMPartialMock([IFADispatchQueueManager sharedInstance]);
    OCMStub([self.dispatchQueueManagerPartialMock dispatchAsyncMainThreadBlock:[OCMArg any]]).andCall(self, @selector(dispatchAsyncMainThreadBlock:));
    [[[[self.dispatchQueueManagerPartialMock stub] andCall:@selector(dispatchAsyncMainThreadBlock:afterDelay:)
                                                  onObject:self] ignoringNonObjectArgs] dispatchAsyncMainThreadBlock:[OCMArg any]
                                                                                                          afterDelay:0];
    [[[[self.dispatchQueueManagerPartialMock stub] andCall:@selector(dispatchAsyncGlobalQueueBlock:priority:)
                                                  onObject:self] ignoringNonObjectArgs] dispatchAsyncGlobalQueueBlock:[OCMArg any]
                                                                                                             priority:0];
    self.dispatchQueueManagerClassMock = OCMClassMock([IFADispatchQueueManager class]);
    OCMStub([self.dispatchQueueManagerClassMock sharedInstance]).andReturn(self.dispatchQueueManagerPartialMock);

}

- (void)tearDown {
    [super tearDown];
    self.asynchronousWorkManagerMock = nil; // Deallocate it, in case it has been initialised on demand
    [self.dispatchQueueManagerClassMock stopMocking];
    [self.dispatchQueueManagerPartialMock stopMocking];
}

#pragma mark - Private

- (void)dispatchOperation:(NSOperation *)a_operation
    showProgressIndicator:(BOOL)a_showProgressIndicator
          completionBlock:(IFAAsynchronousWorkManagerOperationCompletionBlock)a_completionBlock{
    [a_operation main];
    if (a_completionBlock) {
        a_completionBlock(a_operation);
    }
}

- (void)dispatchAsyncMainThreadBlock:(dispatch_block_t)a_block{
    if (a_block) {
        a_block();
    }
}

- (void)dispatchAsyncMainThreadBlock:(dispatch_block_t)a_block afterDelay:(NSTimeInterval)a_delay{
    [self dispatchAsyncMainThreadBlock:a_block];
}

- (void)dispatchAsyncGlobalQueueBlock:(dispatch_block_t)a_block priority:(dispatch_queue_priority_t)a_priority{
    [self dispatchAsyncMainThreadBlock:a_block];
}

@end