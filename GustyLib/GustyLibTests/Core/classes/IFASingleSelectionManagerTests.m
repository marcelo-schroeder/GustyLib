//
//  GustyLib - IFASingleSelectionManagerTests.m
//  Copyright 2015 InfoAccent Pty Ltd. All rights reserved.
//
//  Created by: Marcelo Schroeder
//

#import "IFACommonTests.h"
#import "IFACoreUITestCase.h"
#import "GustyLibCoreUI.h"
#import "TestCoreDataEntity1.h"

@interface IFASingleSelectionManagerTests : IFACoreUITestCase <IFASelectionManagerDataSource>
@property(nonatomic, strong) IFASingleSelectionManager *selectionManager;
@property(nonatomic, strong) NSArray *objects;
@end

@implementation IFASingleSelectionManagerTests{
}


- (void)testSelection {
    // given
    NSUInteger indexToSelect = 2;
    NSIndexPath *indexPathToSelect = [NSIndexPath indexPathForRow:indexToSelect
                                                        inSection:0];
    id objectToSelect = self.objects[indexToSelect];
    // when
    [self.selectionManager handleSelectionForIndexPath:indexPathToSelect];
    // then
    assertThat(self.selectionManager.selectedObject, is(equalTo(objectToSelect)));
    assertThat(self.selectionManager.selectedIndexPath, is(equalTo(indexPathToSelect)));
}

- (void)testSelectionViaConstructor {
    // given
    NSUInteger indexToSelect = 2;
    NSIndexPath *indexPathToSelect = [NSIndexPath indexPathForRow:indexToSelect
                                                        inSection:0];
    id objectToSelect = self.objects[indexToSelect];
    // when
    IFASingleSelectionManager *selectionManager = [[IFASingleSelectionManager alloc] initWithSelectionManagerDataSource:self
                                                                                                         selectedObject:objectToSelect];
    // then
    assertThat(selectionManager.selectedObject, is(equalTo(objectToSelect)));
    assertThat(selectionManager.selectedIndexPath, is(equalTo(indexPathToSelect)));
}

- (void)testDeselection {
    // given
    NSUInteger indexToDeselect = 2;
    NSIndexPath *indexPathToDeselect = [NSIndexPath indexPathForRow:indexToDeselect
                                                          inSection:0];
    [self.selectionManager handleSelectionForIndexPath:indexPathToDeselect];
    // when
    [self.selectionManager handleSelectionForIndexPath:indexPathToDeselect];
    // then
    assertThatUnsignedInteger(self.selectionManager.selectedObjects.count, is(equalToUnsignedInteger(0)));
    assertThatUnsignedInteger(self.selectionManager.selectedIndexPaths.count, is(equalToUnsignedInteger(0)));
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
    self.selectionManager = [[IFASingleSelectionManager alloc] initWithSelectionManagerDataSource:self];
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

@end
