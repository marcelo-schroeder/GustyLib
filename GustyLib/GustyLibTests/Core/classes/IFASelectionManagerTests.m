//
//  GustyLib - IFASelectionManagerTests.m
//  Copyright 2015 InfoAccent Pty Ltd. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IFACommonTests.h"
#import "IFACoreUITestCase.h"
#import "GustyLibCoreUI.h"
#import "TestCoreDataEntity1.h"

@interface IFASelectionManagerTests : IFACoreUITestCase <IFASelectionManagerDataSource>
@property(nonatomic, strong) IFASelectionManager *selectionManager;
@property(nonatomic, strong) NSArray *objects;
@property(nonatomic, strong) id selectionManagerDelegateMock;
@property(nonatomic, strong) id tableViewMock;
@property(nonatomic, strong) id tableViewCellMock1;
@property(nonatomic, strong) id tableViewCellMock2;
@end

@implementation IFASelectionManagerTests{
}

- (void)testSingleSelectionSelection {
    // given
    NSUInteger indexToSelect = 2;
    NSIndexPath *indexPathToSelect = [NSIndexPath indexPathForRow:indexToSelect
                                                        inSection:0];
    id objectToSelect = self.objects[indexToSelect];
    NSDictionary *userInfo = @{@"key":@"value"};
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                                  didSelectObject:objectToSelect
                                                 deselectedObject:[OCMArg isNil]
                                                        indexPath:indexPathToSelect
                                                         userInfo:userInfo]);
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                      didRequestDecorationForCell:self.tableViewCellMock1
                                                         selected:YES
                                                           object:objectToSelect]);
    OCMExpect([self.tableViewMock deselectRowAtIndexPath:indexPathToSelect
                                                animated:YES]);
    OCMExpect([self.tableViewMock cellForRowAtIndexPath:indexPathToSelect]).andReturn(self.tableViewCellMock1);
    // when
    [self.selectionManager handleSelectionForIndexPath:indexPathToSelect
                                              userInfo:userInfo];
    // then
    OCMVerifyAll(self.selectionManagerDelegateMock);
    OCMVerifyAll(self.tableViewMock);
    assertThat(self.selectionManager.selectedObjects, containsInAnyOrder(objectToSelect, nil));
    assertThat(self.selectionManager.selectedIndexPaths, containsInAnyOrder(indexPathToSelect, nil));
}

- (void)testSingleSelectionSelectionViaConstructor {
    // given
    NSUInteger indexToSelect = 2;
    NSIndexPath *indexPathToSelect = [NSIndexPath indexPathForRow:indexToSelect
                                                        inSection:0];
    id objectToSelect = self.objects[indexToSelect];
    // when
    IFASelectionManager *selectionManager = [[IFASelectionManager alloc] initWithSelectionManagerDataSource:self
                                                                                            selectedObjects:@[objectToSelect]];
    // then
    assertThat(selectionManager.selectedObjects, containsInAnyOrder(objectToSelect, nil));
    assertThat(selectionManager.selectedIndexPaths, containsInAnyOrder(indexPathToSelect, nil));
}

- (void)testSingleSelectionDeselection {
    // given
    NSUInteger indexToDeselect = 2;
    NSIndexPath *indexPathToDeselect = [NSIndexPath indexPathForRow:indexToDeselect
                                                          inSection:0];
    [self.selectionManager handleSelectionForIndexPath:indexPathToDeselect];
    id objectToDeselect = self.objects[indexToDeselect];
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                                  didSelectObject:[OCMArg isNil]
                                                 deselectedObject:objectToDeselect
                                                        indexPath:indexPathToDeselect
                                                         userInfo:[OCMArg isNil]]);
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                      didRequestDecorationForCell:self.tableViewCellMock1
                                                         selected:NO
                                                           object:objectToDeselect]);
    OCMExpect([self.tableViewMock deselectRowAtIndexPath:indexPathToDeselect
                                                animated:YES]);
    OCMExpect([self.tableViewMock cellForRowAtIndexPath:indexPathToDeselect]).andReturn(self.tableViewCellMock1);
    // when
    [self.selectionManager handleSelectionForIndexPath:indexPathToDeselect];
    // then
    OCMVerifyAll(self.selectionManagerDelegateMock);
    OCMVerifyAll(self.tableViewMock);
    assertThatUnsignedInteger(self.selectionManager.selectedObjects.count, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(self.selectionManager.selectedIndexPaths.count, is(equalToUnsignedInteger(0)));
}

- (void)testSingleSelectionDeselectionDisallowingDeselection {
    // given
    self.selectionManager.disallowDeselection = YES;
    NSUInteger indexToDeselect = 2;
    NSIndexPath *indexPathToDeselect = [NSIndexPath indexPathForRow:indexToDeselect
                                                          inSection:0];
    [self.selectionManager handleSelectionForIndexPath:indexPathToDeselect];
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                                  didSelectObject:[OCMArg isNil]
                                                 deselectedObject:[OCMArg isNil]
                                                        indexPath:indexPathToDeselect
                                                         userInfo:[OCMArg isNil]]);
    [[[self.selectionManagerDelegateMock reject] ignoringNonObjectArgs] selectionManager:[OCMArg any]
                                                             didRequestDecorationForCell:[OCMArg any]
                                                                                selected:NO
                                                                                  object:[OCMArg any]];
    OCMExpect([self.tableViewMock deselectRowAtIndexPath:indexPathToDeselect
                                                animated:YES]);
    // when
    [self.selectionManager handleSelectionForIndexPath:indexPathToDeselect];
    // then
    OCMVerifyAll(self.selectionManagerDelegateMock);
    OCMVerifyAll(self.tableViewMock);
    assertThat(self.selectionManager.selectedObjects, containsInAnyOrder(self.objects[indexToDeselect], nil));
    assertThat(self.selectionManager.selectedIndexPaths, containsInAnyOrder(indexPathToDeselect, nil));
}

- (void)testSingleSelectionSelectionWithPreviousSelection {
    // given
    NSUInteger previouslySelectedIndex = 4;
    NSIndexPath *previouslySelectedIndexPath = [NSIndexPath indexPathForRow:previouslySelectedIndex
                                                                          inSection:0];
    id previouslySelectedObject = self.objects[previouslySelectedIndex];
    [self.selectionManager handleSelectionForIndexPath:previouslySelectedIndexPath];
    NSUInteger indexToSelect = 2;
    NSIndexPath *indexPathToSelect = [NSIndexPath indexPathForRow:indexToSelect
                                                        inSection:0];
    id objectToSelect = self.objects[indexToSelect];
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                                  didSelectObject:objectToSelect
                                                 deselectedObject:previouslySelectedObject
                                                        indexPath:indexPathToSelect
                                                         userInfo:[OCMArg isNil]]);
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                      didRequestDecorationForCell:self.tableViewCellMock1
                                                         selected:NO
                                                           object:previouslySelectedObject]);
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                      didRequestDecorationForCell:self.tableViewCellMock2
                                                         selected:YES
                                                           object:objectToSelect]);
    OCMExpect([self.tableViewMock deselectRowAtIndexPath:indexPathToSelect
                                                animated:YES]);
    OCMExpect([self.tableViewMock cellForRowAtIndexPath:previouslySelectedIndexPath]).andReturn(self.tableViewCellMock1);
    OCMExpect([self.tableViewMock cellForRowAtIndexPath:indexPathToSelect]).andReturn(self.tableViewCellMock2);
    // when
    [self.selectionManager handleSelectionForIndexPath:indexPathToSelect];
    // then
    OCMVerifyAll(self.selectionManagerDelegateMock);
    OCMVerifyAll(self.tableViewMock);
    assertThat(self.selectionManager.selectedObjects, containsInAnyOrder(objectToSelect, nil));
    assertThat(self.selectionManager.selectedIndexPaths, containsInAnyOrder(indexPathToSelect, nil));
}

- (void)testMultipleSelectionSelection {
    // given
    self.selectionManager.allowMultipleSelection = YES;
    NSUInteger indexToSelect1 = 2;
    NSIndexPath *indexPathToSelect1 = [NSIndexPath indexPathForRow:indexToSelect1
                                                         inSection:0];
    id objectToSelect1 = self.objects[indexToSelect1];
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                                  didSelectObject:objectToSelect1
                                                 deselectedObject:[OCMArg isNil]
                                                        indexPath:indexPathToSelect1
                                                         userInfo:[OCMArg isNil]]);
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                      didRequestDecorationForCell:self.tableViewCellMock1
                                                         selected:YES
                                                           object:objectToSelect1]);
    OCMExpect([self.tableViewMock deselectRowAtIndexPath:indexPathToSelect1
                                                animated:YES]);
    OCMExpect([self.tableViewMock cellForRowAtIndexPath:indexPathToSelect1]).andReturn(self.tableViewCellMock1);
    NSUInteger indexToSelect2 = 4;
    NSIndexPath *indexPathToSelect2 = [NSIndexPath indexPathForRow:indexToSelect2
                                                         inSection:0];
    id objectToSelect2 = self.objects[indexToSelect2];
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                                  didSelectObject:objectToSelect2
                                                 deselectedObject:[OCMArg isNil]
                                                        indexPath:indexPathToSelect2
                                                         userInfo:[OCMArg isNil]]);
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                      didRequestDecorationForCell:self.tableViewCellMock2
                                                         selected:YES
                                                           object:objectToSelect2]);
    OCMExpect([self.tableViewMock deselectRowAtIndexPath:indexPathToSelect2
                                                animated:YES]);
    OCMExpect([self.tableViewMock cellForRowAtIndexPath:indexPathToSelect2]).andReturn(self.tableViewCellMock2);
    // when
    [self.selectionManager handleSelectionForIndexPath:indexPathToSelect1];
    [self.selectionManager handleSelectionForIndexPath:indexPathToSelect2];
    // then
    OCMVerifyAll(self.selectionManagerDelegateMock);
    OCMVerifyAll(self.tableViewMock);
    assertThat(self.selectionManager.selectedObjects, containsInAnyOrder(objectToSelect1, objectToSelect2, nil));
    assertThat(self.selectionManager.selectedIndexPaths, containsInAnyOrder(indexPathToSelect1, indexPathToSelect2, nil));
}

- (void)testMultipleSelectionSelectionViaConstructor {
    // given
    self.selectionManager.allowMultipleSelection = YES;
    NSUInteger indexToSelect1 = 2;
    NSIndexPath *indexPathToSelect1 = [NSIndexPath indexPathForRow:indexToSelect1
                                                         inSection:0];
    id objectToSelect1 = self.objects[indexToSelect1];
    NSUInteger indexToSelect2 = 4;
    NSIndexPath *indexPathToSelect2 = [NSIndexPath indexPathForRow:indexToSelect2
                                                         inSection:0];
    id objectToSelect2 = self.objects[indexToSelect2];
    // when
    IFASelectionManager *selectionManager = [[IFASelectionManager alloc] initWithSelectionManagerDataSource:self
                                                                                            selectedObjects:@[objectToSelect1, objectToSelect2]];
    // then
    assertThat(selectionManager.selectedObjects, containsInAnyOrder(objectToSelect1, objectToSelect2, nil));
    assertThat(selectionManager.selectedIndexPaths, containsInAnyOrder(indexPathToSelect1, indexPathToSelect2, nil));
}

- (void)testMultipleSelectionDeselection {
    // given
    self.selectionManager.allowMultipleSelection = YES;
    NSUInteger previouslySelectedIndex = 2;
    NSIndexPath *previouslySelectedIndexPath = [NSIndexPath indexPathForRow:previouslySelectedIndex
                                                                  inSection:0];
    [self.selectionManager handleSelectionForIndexPath:previouslySelectedIndexPath];
    NSUInteger indexToDeselect = 4;
    NSIndexPath *indexPathToDeselect = [NSIndexPath indexPathForRow:indexToDeselect
                                                          inSection:0];
    [self.selectionManager handleSelectionForIndexPath:indexPathToDeselect];
    id objectToDeselect = self.objects[indexToDeselect];
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                                  didSelectObject:[OCMArg isNil]
                                                 deselectedObject:objectToDeselect
                                                        indexPath:indexPathToDeselect
                                                         userInfo:[OCMArg isNil]]);
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                      didRequestDecorationForCell:self.tableViewCellMock1
                                                         selected:NO
                                                           object:objectToDeselect]);
    OCMExpect([self.tableViewMock deselectRowAtIndexPath:indexPathToDeselect
                                                animated:YES]);
    OCMExpect([self.tableViewMock cellForRowAtIndexPath:indexPathToDeselect]).andReturn(self.tableViewCellMock1);
    // when
    [self.selectionManager handleSelectionForIndexPath:indexPathToDeselect];
    // then
    OCMVerifyAll(self.selectionManagerDelegateMock);
    OCMVerifyAll(self.tableViewMock);
    assertThat(self.selectionManager.selectedObjects, containsInAnyOrder(self.objects[previouslySelectedIndex],nil));
    assertThat(self.selectionManager.selectedIndexPaths, containsInAnyOrder(previouslySelectedIndexPath, nil));
}

- (void)testDeselectAll {
    // given
    self.selectionManager.allowMultipleSelection = YES;
    NSDictionary *userInfo = @{@"key":@"value"};
    NSUInteger index1 = 2;
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:index1
                                                         inSection:0];
    id object1 = self.objects[index1];
    [self.selectionManager handleSelectionForIndexPath:indexPath1];
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                                  didSelectObject:[OCMArg isNil]
                                                 deselectedObject:object1
                                                        indexPath:indexPath1
                                                         userInfo:userInfo]);
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                      didRequestDecorationForCell:self.tableViewCellMock1
                                                         selected:NO
                                                           object:object1]);
    OCMExpect([self.tableViewMock deselectRowAtIndexPath:indexPath1
                                                animated:YES]);
    OCMExpect([self.tableViewMock cellForRowAtIndexPath:indexPath1]).andReturn(self.tableViewCellMock1);
    NSUInteger index2 = 4;
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:index2
                                                         inSection:0];
    id object2 = self.objects[index2];
    [self.selectionManager handleSelectionForIndexPath:indexPath2];
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                                  didSelectObject:[OCMArg isNil]
                                                 deselectedObject:object2
                                                        indexPath:indexPath2
                                                         userInfo:userInfo]);
    OCMExpect([self.selectionManagerDelegateMock selectionManager:self.selectionManager
                                      didRequestDecorationForCell:self.tableViewCellMock2
                                                         selected:NO
                                                           object:object2]);
    OCMExpect([self.tableViewMock deselectRowAtIndexPath:indexPath2
                                                animated:YES]);
    OCMExpect([self.tableViewMock cellForRowAtIndexPath:indexPath2]).andReturn(self.tableViewCellMock2);
    // when
    [self.selectionManager deselectAllWithUserInfo:userInfo];
    // then
    OCMVerifyAll(self.selectionManagerDelegateMock);
    OCMVerifyAll(self.tableViewMock);
    assertThatUnsignedInteger(self.selectionManager.selectedObjects.count, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(self.selectionManager.selectedIndexPaths.count, is(equalToUnsignedInteger(0)));
}

- (void)testNotifyDeletionForObject {
    // given
    self.selectionManager.allowMultipleSelection = YES;
    NSUInteger previouslySelectedIndex = 2;
    NSIndexPath *previouslySelectedIndexPath = [NSIndexPath indexPathForRow:previouslySelectedIndex
                                                                  inSection:0];
    [self.selectionManager handleSelectionForIndexPath:previouslySelectedIndexPath];
    NSUInteger indexToDelete = 4;
    NSIndexPath *indexPathToDelete = [NSIndexPath indexPathForRow:indexToDelete
                                                          inSection:0];
    [self.selectionManager handleSelectionForIndexPath:indexPathToDelete];
    id objectToDelete = self.objects[indexToDelete];
    // when
    [self.selectionManager notifyDeletionForObject:objectToDelete];
    // then
    assertThat(self.selectionManager.selectedObjects, containsInAnyOrder(self.objects[previouslySelectedIndex],nil));
    assertThat(self.selectionManager.selectedIndexPaths, containsInAnyOrder(previouslySelectedIndexPath, nil));
}

#pragma mark - Overrides

- (void)setUp {
    [super setUp];
    [self createInMemoryTestDatabase];
    self.objects = @[
            [TestCoreDataEntity1 ifa_instantiate],
            [TestCoreDataEntity1 ifa_instantiate],
            [TestCoreDataEntity1 ifa_instantiate],
            [TestCoreDataEntity1 ifa_instantiate],
            [TestCoreDataEntity1 ifa_instantiate],
    ];
    [[IFAPersistenceManager sharedInstance] save];
    self.selectionManager = [[IFASelectionManager alloc] initWithSelectionManagerDataSource:self];
    self.selectionManagerDelegateMock = OCMProtocolMock(@protocol(IFASelectionManagerDelegate));
    self.selectionManager.delegate = self.selectionManagerDelegateMock;
    self.tableViewMock = OCMClassMock([UITableView class]);
    self.tableViewCellMock1 = OCMClassMock([UITableViewCell class]);
    self.tableViewCellMock2 = OCMClassMock([UITableViewCell class]);
}

#pragma mark - IFASelectionManagerDataSource

- (NSObject *)selectionManager:(IFASelectionManager *)a_selectionManager
             objectAtIndexPath:(NSIndexPath *)a_indexPath {
    return self.objects[(NSUInteger) a_indexPath.row];
}

- (NSIndexPath *)selectionManager:(IFASelectionManager *)a_selectionManager
               indexPathForObject:(NSObject *)a_object {
    return [NSIndexPath indexPathForRow:[self.objects indexOfObject:a_object]
                              inSection:0];
}

- (UITableView *)tableViewForSelectionManager:(IFASelectionManager *)a_selectionManager {
    return self.tableViewMock;
}

@end
