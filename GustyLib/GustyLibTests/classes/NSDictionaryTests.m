//
//  GustyLib - NSDictionaryTests.m
//  Copyright 2014 InfoAccent Pty Ltd. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IFACommonTests.h"
#import "NSDictionary+IACategory.h"

@interface NSDictionaryTests : XCTestCase 
@end

@interface NSDictionaryTestsTestObjectClass : NSObject
@property (nonatomic, strong) NSString *p_property1;
@property (nonatomic, strong) NSString *p_property2;
- (instancetype)initWithProperty1:(NSString *)a_property1 property2:(NSString *)a_property2;
+ (instancetype)testObjectWithProperty1:(NSString *)a_property1 property2:(NSString *)a_property2;
@end

@implementation NSDictionaryTests{
}

- (void)testDictionaryFromObjectsGroupedByPath {
    // given
    NSArray *l_objects = @[
            [NSDictionaryTestsTestObjectClass testObjectWithProperty1:@"one"
                                                            property2:@"1a"],
            [NSDictionaryTestsTestObjectClass testObjectWithProperty1:@"two"
                                                            property2:@"2a"],
            [NSDictionaryTestsTestObjectClass testObjectWithProperty1:@"two"
                                                            property2:@"2b"],
            [NSDictionaryTestsTestObjectClass testObjectWithProperty1:@"three"
                                                            property2:@"3a"],
            [NSDictionaryTestsTestObjectClass testObjectWithProperty1:@"three"
                                                            property2:@"3b"],
            [NSDictionaryTestsTestObjectClass testObjectWithProperty1:@"three"
                                                            property2:@"3c"],
    ];
    // when
    NSDictionary *l_groupedObjects = [NSDictionary IFA_dictionaryFromObjects:l_objects groupedByPath:@"p_property1"
                                                            sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"p_property2"
                                                                                                         ascending:NO]];
    // then
    assertThat(l_groupedObjects.allKeys, containsInAnyOrder(@"one", @"two", @"three", nil));
    NSArray *l_group1 = (NSArray *)l_groupedObjects[@"one"];
    NSArray *l_group2 = (NSArray *)l_groupedObjects[@"two"];
    NSArray *l_group3 = (NSArray *)l_groupedObjects[@"three"];
    assertThatUnsignedInteger(l_group1.count, is(equalToUnsignedInteger(1)));
    assertThatUnsignedInteger(l_group2.count, is(equalToUnsignedInteger(2)));
    assertThatUnsignedInteger(l_group3.count, is(equalToUnsignedInteger(3)));
    assertThat([l_group1 valueForKeyPath:@"p_property2"], contains(@"1a", nil));
    assertThat([l_group2 valueForKeyPath:@"p_property2"], contains(@"2b", @"2a", nil));
    assertThat([l_group3 valueForKeyPath:@"p_property2"], contains(@"3c", @"3b", @"3a", nil));
}

@end

@implementation NSDictionaryTestsTestObjectClass
- (instancetype)initWithProperty1:(NSString *)a_property1 property2:(NSString *)a_property2 {
    self = [super init];
    if (self) {
        self.p_property1 = a_property1;
        self.p_property2 = a_property2;
    }

    return self;
}

+ (instancetype)testObjectWithProperty1:(NSString *)a_property1 property2:(NSString *)a_property2 {
    return [[self alloc] initWithProperty1:a_property1 property2:a_property2];
}

@end