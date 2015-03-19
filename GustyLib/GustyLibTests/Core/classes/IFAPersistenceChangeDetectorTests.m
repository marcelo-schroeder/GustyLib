//
//  GustyLib - IFAPersistenceChangeDetectorTests.m
//  Copyright 2015 InfoAccent Pty Ltd. All rights reserved.
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

#import "IFACoreUITestCase.h"
#import "GustyLibCoreUI.h"
#import "TestCoreDataEntity1.h"
#import "TestCoreDataEntity2.h"

@interface IFAPersistenceChangeDetectorTests : IFACoreUITestCase
@property(nonatomic) IFAPersistenceChangeDetector *persistenceChangeDetector;
@end

@implementation IFAPersistenceChangeDetectorTests{
}

- (void)testChangeIsNotDetectedWhenNothingHappens {
    // given
    self.persistenceChangeDetector.enabled = YES;
    // then
    assertThatBool(self.persistenceChangeDetector.changed, isFalse());
    assertThat(self.persistenceChangeDetector.persistentEntityChangeNotificationUserInfoDictionariesByEntityName, isEmpty());
}

- (void)testChangeIsNotDetectedWhenManagedObjectContextIsChangedAndNotSaved {
    // given
    self.persistenceChangeDetector.enabled = YES;
    // when
    [TestCoreDataEntity1 ifa_instantiate];
    // then
    assertThatBool(self.persistenceChangeDetector.changed, isFalse());
    assertThat(self.persistenceChangeDetector.persistentEntityChangeNotificationUserInfoDictionariesByEntityName, isEmpty());
}

- (void)testChangeIsDetectedCorrectlyWhenManagedObjectContextIsChangedAndSavedOnce {
    // given
    self.persistenceChangeDetector.enabled = YES;
    // when
    TestCoreDataEntity1 *entity1 = [TestCoreDataEntity1 ifa_instantiate];
    [[IFAPersistenceManager sharedInstance] save];
    // then
    assertThatBool(self.persistenceChangeDetector.changed, isTrue());
    NSMutableDictionary *userInfoDictionariesByEntityName = self.persistenceChangeDetector.persistentEntityChangeNotificationUserInfoDictionariesByEntityName;
    assertThat(userInfoDictionariesByEntityName.allKeys, containsInAnyOrder(@"TestCoreDataEntity1", nil));
    NSArray *entity1UserInfoDictionaries = userInfoDictionariesByEntityName[@"TestCoreDataEntity1"];
    assertThat(entity1UserInfoDictionaries, hasCountOf(1));
    NSDictionary *entity1UserInfo1 = entity1UserInfoDictionaries[0];
    assertThat(entity1UserInfo1[IFAKeyDeletedObjects], isEmpty());
    assertThat(entity1UserInfo1[IFAKeyUpdatedObjects], isEmpty());
    assertThat(entity1UserInfo1[IFAKeyInsertedObjects], containsInAnyOrder(entity1, nil));
    assertThat(entity1UserInfo1[IFAKeyOriginalProperties], isEmpty());
    assertThat(entity1UserInfo1[IFAKeyUpdatedProperties], isEmpty());
}

- (void)testChangeIsDetectedCorrectlyWhenManagedObjectContextIsChangedAndSavedMultipleTimes {

    // given
    self.persistenceChangeDetector.enabled = YES;

    // when
    TestCoreDataEntity1 *entity1 = [TestCoreDataEntity1 ifa_instantiate];
    [[IFAPersistenceManager sharedInstance] save];
    TestCoreDataEntity2 *entity2 = [TestCoreDataEntity2 ifa_instantiate];
    [[IFAPersistenceManager sharedInstance] save];
    entity2.attribute1 = @"changed";
    [[IFAPersistenceManager sharedInstance] save];

    // then
    assertThatBool(self.persistenceChangeDetector.changed, isTrue());
    NSMutableDictionary *userInfoDictionariesByEntityName = self.persistenceChangeDetector.persistentEntityChangeNotificationUserInfoDictionariesByEntityName;
    assertThat(userInfoDictionariesByEntityName.allKeys, containsInAnyOrder(@"TestCoreDataEntity1", @"TestCoreDataEntity2", nil));

    NSArray *entity1UserInfoDictionaries = userInfoDictionariesByEntityName[@"TestCoreDataEntity1"];
    assertThat(entity1UserInfoDictionaries, hasCountOf(1));

    NSDictionary *entity1UserInfo1 = entity1UserInfoDictionaries[0];
    assertThat(entity1UserInfo1[IFAKeyDeletedObjects], isEmpty());
    assertThat(entity1UserInfo1[IFAKeyUpdatedObjects], isEmpty());
    assertThat(entity1UserInfo1[IFAKeyInsertedObjects], containsInAnyOrder(entity1, nil));
    assertThat(entity1UserInfo1[IFAKeyOriginalProperties], isEmpty());
    assertThat(entity1UserInfo1[IFAKeyUpdatedProperties], isEmpty());

    NSArray *entity2UserInfoDictionaries = userInfoDictionariesByEntityName[@"TestCoreDataEntity2"];
    assertThat(entity2UserInfoDictionaries, hasCountOf(2));

    NSDictionary *entity2UserInfo1 = entity2UserInfoDictionaries[0];
    assertThat(entity2UserInfo1[IFAKeyDeletedObjects], isEmpty());
    assertThat(entity2UserInfo1[IFAKeyUpdatedObjects], isEmpty());
    assertThat(entity2UserInfo1[IFAKeyInsertedObjects], containsInAnyOrder(entity2, nil));
    assertThat(entity2UserInfo1[IFAKeyOriginalProperties], isEmpty());
    assertThat(entity2UserInfo1[IFAKeyUpdatedProperties], isEmpty());

    NSDictionary *entity2UserInfo2 = entity2UserInfoDictionaries[1];
    assertThat(entity2UserInfo2[IFAKeyDeletedObjects], isEmpty());
    assertThat(entity2UserInfo2[IFAKeyUpdatedObjects], containsInAnyOrder(entity2, nil));
    assertThat(entity2UserInfo2[IFAKeyInsertedObjects], isEmpty());

    NSDictionary *entity2UserInfo2OriginalPropertiesByEntityId = entity2UserInfo2[IFAKeyOriginalProperties];
    assertThat(entity2UserInfo2OriginalPropertiesByEntityId, containsInAnyOrder(entity2.ifa_stringId, nil));
    NSDictionary *entity2UserInfo2OriginalProperties = entity2UserInfo2OriginalPropertiesByEntityId[entity2.ifa_stringId];
    assertThat(entity2UserInfo2OriginalProperties, containsInAnyOrder(@"attribute1", @"attribute2", nil));
    assertThat(entity2UserInfo2OriginalProperties[@"attribute1"], is(equalTo([NSNull null])));
    assertThat(entity2UserInfo2OriginalProperties[@"attribute2"], is(equalTo([NSNull null])));

    NSDictionary *entity2UserInfo2UpdatedPropertiesByEntityId = entity2UserInfo2[IFAKeyUpdatedProperties];
    assertThat(entity2UserInfo2UpdatedPropertiesByEntityId, containsInAnyOrder(entity2.ifa_stringId, nil));
    NSDictionary *entity2UserInfo2UpdatedProperties = entity2UserInfo2UpdatedPropertiesByEntityId[entity2.ifa_stringId];
    assertThat(entity2UserInfo2UpdatedProperties, containsInAnyOrder(@"attribute1", nil));
    assertThat(entity2UserInfo2UpdatedProperties[@"attribute1"], is(equalTo(@"changed")));

}

- (void)testReset{
    // given
    self.persistenceChangeDetector.enabled = YES;
    [TestCoreDataEntity1 ifa_instantiate];
    [[IFAPersistenceManager sharedInstance] save];
    // when
    [self.persistenceChangeDetector reset];
    // then
    assertThatBool(self.persistenceChangeDetector.changed, isFalse());
    assertThat(self.persistenceChangeDetector.persistentEntityChangeNotificationUserInfoDictionariesByEntityName, hasCountOf(0));
}

- (void)testThatSettingEnabledToYesWillAddObserverIfObserverHasNotBeenAddedBefore{
    // given
    id notificationCenterMock = OCMClassMock([NSNotificationCenter class]);
    OCMExpect([notificationCenterMock addObserver:self.persistenceChangeDetector
                                         selector:[OCMArg anySelector]
                                             name:IFANotificationPersistentEntityChange
                                           object:nil]);
    OCMStub([notificationCenterMock defaultCenter]).andReturn(notificationCenterMock);
    // when
    self.persistenceChangeDetector.enabled = YES;
    // then
    OCMVerifyAll(notificationCenterMock);
}

- (void)testThatSettingEnabledToYesWillNotAddObserverIfObserverHasBeenAddedBefore{
    // given
    id notificationCenterMock = OCMClassMock([NSNotificationCenter class]);
    OCMExpect([notificationCenterMock addObserver:self.persistenceChangeDetector
                                         selector:[OCMArg anySelector]
                                             name:IFANotificationPersistentEntityChange
                                           object:nil]);
    [[notificationCenterMock reject] addObserver:self.persistenceChangeDetector
                                        selector:[OCMArg anySelector]
                                            name:IFANotificationPersistentEntityChange
                                          object:nil];
    OCMStub([notificationCenterMock defaultCenter]).andReturn(notificationCenterMock);
    self.persistenceChangeDetector.enabled = YES;
    // when
    self.persistenceChangeDetector.enabled = YES;
    // then
    OCMVerifyAll(notificationCenterMock);
}

- (void)testThatSettingEnabledToNoWillRemoveObserverIfObserverHasNotBeenRemovedBefore{
    // given
    self.persistenceChangeDetector.enabled = YES;
    id notificationCenterMock = OCMClassMock([NSNotificationCenter class]);
    OCMExpect([notificationCenterMock removeObserver:self.persistenceChangeDetector
                                                name:IFANotificationPersistentEntityChange
                                              object:nil]);
    OCMStub([notificationCenterMock defaultCenter]).andReturn(notificationCenterMock);
    // when
    self.persistenceChangeDetector.enabled = NO;
    // then
    OCMVerifyAll(notificationCenterMock);
}

- (void)testThatSettingEnabledToNoWillNotRemoveObserverIfObserverHasBeenRemovedBefore {
    // given
    self.persistenceChangeDetector.enabled = YES;
    id notificationCenterMock = OCMClassMock([NSNotificationCenter class]);
    OCMExpect([notificationCenterMock removeObserver:self.persistenceChangeDetector
                                                name:IFANotificationPersistentEntityChange
                                              object:nil]);
    [[notificationCenterMock reject] removeObserver:self.persistenceChangeDetector
                                               name:IFANotificationPersistentEntityChange
                                             object:nil];
    OCMStub([notificationCenterMock defaultCenter]).andReturn(notificationCenterMock);
    self.persistenceChangeDetector.enabled = NO;
    // when
    self.persistenceChangeDetector.enabled = NO;
    // then
    OCMVerifyAll(notificationCenterMock);
}

- (void)testThatDeallocWillRemoveObserver{
    // given
    self.persistenceChangeDetector.enabled = YES;
    id notificationCenterMock = OCMClassMock([NSNotificationCenter class]);
    OCMExpect([notificationCenterMock removeObserver:[OCMArg any]
                                                name:IFANotificationPersistentEntityChange
                                              object:nil]);
    OCMStub([notificationCenterMock defaultCenter]).andReturn(notificationCenterMock);
    // when
    self.persistenceChangeDetector = nil;
    // then
    OCMVerifyAll(notificationCenterMock);
}

- (void)testChangedForManagedObjectWhenObjectIsNil{
    // when
    BOOL result = [self.persistenceChangeDetector changedForManagedObject:nil];
    // then
    assertThatBool(result, isFalse());
}

- (void)testChangedForManagedObjectWhenThereIsNoChange{
    // given
    TestCoreDataEntity1 *managedObject1 = [TestCoreDataEntity1 ifa_instantiate];
    [[IFAPersistenceManager sharedInstance] save];
    self.persistenceChangeDetector.enabled = YES;
    // when
    BOOL result = [self.persistenceChangeDetector changedForManagedObject:managedObject1];
    // then
    assertThatBool(result, isFalse());
}

- (void)testChangedForManagedObjectWhenObjectIsUpdated{
    // given
    TestCoreDataEntity1 *managedObject1 = [TestCoreDataEntity1 ifa_instantiate];
    [[IFAPersistenceManager sharedInstance] save];
    self.persistenceChangeDetector.enabled = YES;
    managedObject1.attribute1 = @"changed";
    [[IFAPersistenceManager sharedInstance] save];
    // when
    BOOL result = [self.persistenceChangeDetector changedForManagedObject:managedObject1];
    // then
    assertThatBool(result, isTrue());
}

- (void)testChangedForManagedObjectWhenAnotherObjectIsUpdated{
    // given
    TestCoreDataEntity1 *managedObject1 = [TestCoreDataEntity1 ifa_instantiate];
    TestCoreDataEntity1 *managedObject2 = [TestCoreDataEntity1 ifa_instantiate];
    [[IFAPersistenceManager sharedInstance] save];
    self.persistenceChangeDetector.enabled = YES;
    managedObject2.attribute1 = @"changed";
    [[IFAPersistenceManager sharedInstance] save];
    // when
    BOOL result = [self.persistenceChangeDetector changedForManagedObject:managedObject1];
    // then
    assertThatBool(result, isFalse());
}

- (void)testChangedForManagedObjectWhenObjectIsDeleted{
    // given
    TestCoreDataEntity1 *managedObject1 = [TestCoreDataEntity1 ifa_instantiate];
    [[IFAPersistenceManager sharedInstance] save];
    self.persistenceChangeDetector.enabled = YES;
    [managedObject1 ifa_deleteAndSaveWithValidationAlertPresenter:nil];
    // when
    BOOL result = [self.persistenceChangeDetector changedForManagedObject:managedObject1];
    // then
    assertThatBool(result, isTrue());
}

- (void)testChangedForManagedObjectWhenAnotherObjectIsDeleted{
    // given
    TestCoreDataEntity1 *managedObject1 = [TestCoreDataEntity1 ifa_instantiate];
    TestCoreDataEntity1 *managedObject2 = [TestCoreDataEntity1 ifa_instantiate];
    [[IFAPersistenceManager sharedInstance] save];
    self.persistenceChangeDetector.enabled = YES;
    [managedObject2 ifa_deleteAndSaveWithValidationAlertPresenter:nil];
    // when
    BOOL result = [self.persistenceChangeDetector changedForManagedObject:managedObject1];
    // then
    assertThatBool(result, isFalse());
}

#pragma mark - Overrides

- (void)setUp {
    [super setUp];
    [self createInMemoryTestDatabase];
    self.persistenceChangeDetector = [IFAPersistenceChangeDetector new];
}

@end
