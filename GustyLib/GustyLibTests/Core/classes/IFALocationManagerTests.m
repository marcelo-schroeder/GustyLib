//
//  GustyLib - IFALocationManagerTests.m
//  Copyright 2015 InfoAccent Pty Ltd. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IFACommonTests.h"
#import "GustyLibCoreUI.h"
#import "IFACoreUITestCase.h"

@interface IFALocationManagerTests : IFACoreUITestCase
@end

@implementation IFALocationManagerTests{
}

- (void)testDistanceBetweenCoordinates {
    // given
    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(-33.957449, 151.156043);
    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(-33.959969, 151.154327);
    // when
    CLLocationDistance distance = [IFALocationManager distanceBetweenCoordinate:coordinate1
                                                                  andCoordinate:coordinate2];
    // then
    assertThatDouble(distance, is(greaterThanOrEqualTo(@(320))));
    assertThatDouble(distance, is(lessThanOrEqualTo(@(325))));
}

@end
