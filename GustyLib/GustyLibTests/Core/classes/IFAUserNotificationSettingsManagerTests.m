//
//  GustyLib - IFAUserNotificationSettingsManagerTests.m
//  Copyright 2015 InfoAccent Pty Ltd. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IFACommonTests.h"
#import "IFACoreUITestCase.h"
#import "GustyLibCoreUI.h"

@interface IFAUserNotificationSettingsManagerTests : IFACoreUITestCase
@end

@implementation IFAUserNotificationSettingsManagerTests{
}

- (void)testRegisterUserNotificationSettings {
    //given
    XCTestExpectation *expectation = [self expectationWithDescription:@"Completion block called"];
    UIUserNotificationSettings *notificationSettingsMock = OCMClassMock([UIUserNotificationSettings class]);
    id applicationMock = OCMClassMock([UIApplication class]);
    OCMExpect([applicationMock sharedApplication]).andReturn(applicationMock);
    __block BOOL checkBlockCalled = NO;
    BOOL (^checkBlock)(id) = ^BOOL(id obj) {
        if (!checkBlockCalled) {
            checkBlockCalled = YES;
            id <UIApplicationDelegate> applicationDelegate = [IFAApplicationDelegate new];
            [applicationDelegate application:applicationMock
         didRegisterUserNotificationSettings:notificationSettingsMock];
        }
        return obj == notificationSettingsMock;
    };
    OCMExpect([applicationMock registerUserNotificationSettings:[OCMArg checkWithBlock:checkBlock]]);
    void (^completionBlock)(UIUserNotificationSettings *) = ^(UIUserNotificationSettings *a_allowedNotificationSettings) {
        [expectation fulfill];
    };
    //when
    [IFAUserNotificationSettingsManager registerUserNotificationSettings:notificationSettingsMock
                                                         completionBlock:completionBlock];
    //then
    [self waitForExpectationsWithTimeout:1
                                 handler:nil];
    OCMVerifyAll(applicationMock);
}

@end
