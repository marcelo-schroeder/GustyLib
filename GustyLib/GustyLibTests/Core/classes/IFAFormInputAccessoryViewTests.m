//
//  GustyLib - IFAFormInputAccessoryViewTests.m
//  Copyright 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import "IFACommonTests.h"
#import "GustyLibCoreUI.h"
#import "IFACoreUITestCase.h"

@interface IFAFormInputAccessoryView (Tests)
@property (strong, nonatomic) NSIndexPath *IFA_currentInputFieldIndexPath;
@property (strong, nonatomic) NSIndexPath *IFA_previousInputFieldIndexPath;
@property (strong, nonatomic) NSIndexPath *IFA_nextInputFieldIndexPath;
- (NSIndexPath *)IFA_indexPathForDirection:(IFAFormInputAccessoryViewDirection)a_direction;
@end

@interface IFAFormInputAccessoryViewTests : IFACoreUITestCase
@property(nonatomic, strong) IFAFormInputAccessoryView *p_view;
@property(nonatomic, strong) id p_mockTableView;
@property(nonatomic, strong) id p_mockTableViewDataSource;
@property(nonatomic, strong) id p_mockDataSource;
@property(nonatomic, strong) id p_mockPreviousBarButtonItem;
@property(nonatomic, strong) id p_mockNextBarButtonItem;
@property(nonatomic, strong) id p_mockResponder;
@end

@implementation IFAFormInputAccessoryViewTests{
}

/*

    Mock data model:

    Section   Row   Has Input Field?
    -------   ---   ----------------
    0         0     No
    1         0     Yes
    1         1     Yes
    2         0     No
    2         1     Yes
    2         2     Yes
    3         0     No

 */
- (void)setUp {
    [super setUp];
    [self m_createMockObjects];
    [self m_createSystemUnderTestAndSetMockObjects];
    [self m_configureMockObjects];
}

- (void)testThatInterfaceBuilderOutletConnectionsAreInPlace{
    IFAFormInputAccessoryView *l_view = [self m_createSystemUnderTest];
    assertThat(l_view.contentView, is(notNilValue()));
    assertThat(l_view.toolbar, is(notNilValue()));
    assertThat(l_view.previousBarButtonItem, is(notNilValue()));
    assertThat(l_view.nextBarButtonItem, is(notNilValue()));
    assertThat(l_view.doneBarButtonItem, is(notNilValue()));
    assertThat(l_view, is(notNilValue()));
}

- (void)testThatInterfaceBuilderEventConnectionsAreInPlace{
    IFAFormInputAccessoryView *l_view = [self m_createSystemUnderTest];
    [self ifa_assertThatBarButtonItem:l_view.previousBarButtonItem
      hasTapEventConfiguredWithTarget:l_view action:@selector(onPreviousButtonTap)];
    [self ifa_assertThatBarButtonItem:l_view.nextBarButtonItem
      hasTapEventConfiguredWithTarget:l_view action:@selector(onNextButtonTap)];
    [self ifa_assertThatBarButtonItem:l_view.doneBarButtonItem
    hasTapEventConfiguredWithTarget:l_view action:@selector(onDoneButtonTap)];
}

- (void)testThatPreviousButtonIsEnabledWhenThereIsAnImmediatelyPrecedingCellContainingAnInputFieldToScrollTo{
    [self m_assertThatForSection:1 row:1 previousButtonIsEnabled:YES nextButtonIsEnabled:YES];
}

- (void)testThatPreviousButtonIsEnabledWhenThereIsAPrecedingCellOtherThanTheImmediatelyPrecedingCellContainingAnInputFieldToScrollTo{
    [self m_assertThatForSection:2 row:1 previousButtonIsEnabled:YES nextButtonIsEnabled:YES];
}

- (void)testThatPreviousButtonIsDisabledWhenThereIsNoPrecedingCellContainingAnInputFieldToScrollTo{
    [self m_assertThatForSection:1 row:0 previousButtonIsEnabled:NO nextButtonIsEnabled:YES];
}

- (void)testThatPreviousButtonIsDisabledWhenCurrentCellIsTheFirstOne{
    [self m_assertThatForSection:0 row:0 previousButtonIsEnabled:NO nextButtonIsEnabled:YES];
}

- (void)testThatNextButtonIsEnabledWhenThereIsAnImmediatelySubsequentCellContainingAnInputFieldToScrollTo{
    [self m_assertThatForSection:2 row:1 previousButtonIsEnabled:YES nextButtonIsEnabled:YES];
}

- (void)testThatNextButtonIsEnabledWhenThereIsASubsequentCellOtherThanTheImmediatelySubsequentCellContainingAnInputFieldToScrollTo{
    [self m_assertThatForSection:1 row:1 previousButtonIsEnabled:YES nextButtonIsEnabled:YES];
}

- (void)testThatNextButtonIsDisabledWhenThereIsNoSubsequentCellContainingAnInputFieldToScrollTo{
    [self m_assertThatForSection:2 row:2 previousButtonIsEnabled:YES nextButtonIsEnabled:NO];
}

- (void)testThatNextButtonIsDisabledWhenCurrentCellIsTheLastOne{
    [self m_assertThatForSection:3 row:0 previousButtonIsEnabled:YES nextButtonIsEnabled:NO];
}

- (void)testIndexPathFullForwardTraverse {

    id l_mockDataSource = [OCMockObject niceMockForProtocol:@protocol(IFAFormInputAccessoryViewDataSource)];
    [[[l_mockDataSource stub] ifa_andReturnBool:YES] formInputAccessoryView:self.p_view canReceiveKeyboardInputAtIndexPath:[OCMArg any]];
    self.p_view.dataSource = l_mockDataSource;

    IFAFormInputAccessoryViewDirection l_direction = IFAFormInputAccessoryViewDirectionNext;
    NSIndexPath *l_currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    l_currentIndexPath = [self assertNewIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                             withCurrentIndexPath:l_currentIndexPath
                                        direction:l_direction];

    l_currentIndexPath = [self assertNewIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]
                             withCurrentIndexPath:l_currentIndexPath
                                        direction:l_direction];

    l_currentIndexPath = [self assertNewIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]
                             withCurrentIndexPath:l_currentIndexPath
                                        direction:l_direction];

    l_currentIndexPath = [self assertNewIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]
                             withCurrentIndexPath:l_currentIndexPath
                                        direction:l_direction];

    l_currentIndexPath = [self assertNewIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]
                             withCurrentIndexPath:l_currentIndexPath
                                        direction:l_direction];

    [self assertNewIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]
        withCurrentIndexPath:l_currentIndexPath
                   direction:l_direction];

}

- (void)testIndexPathBackwardTraverse {

    id l_mockDataSource = [OCMockObject niceMockForProtocol:@protocol(IFAFormInputAccessoryViewDataSource)];
    [[[l_mockDataSource stub] ifa_andReturnBool:YES] formInputAccessoryView:self.p_view canReceiveKeyboardInputAtIndexPath:[OCMArg any]];
    self.p_view.dataSource = l_mockDataSource;

    IFAFormInputAccessoryViewDirection l_direction = IFAFormInputAccessoryViewDirectionPrevious;
    NSIndexPath *l_currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:3];

    l_currentIndexPath = [self assertNewIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]
                             withCurrentIndexPath:l_currentIndexPath
                                        direction:l_direction];

    l_currentIndexPath = [self assertNewIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]
                             withCurrentIndexPath:l_currentIndexPath
                                        direction:l_direction];

    l_currentIndexPath = [self assertNewIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]
                             withCurrentIndexPath:l_currentIndexPath
                                        direction:l_direction];

    l_currentIndexPath = [self assertNewIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]
                             withCurrentIndexPath:l_currentIndexPath
                                        direction:l_direction];

    l_currentIndexPath = [self assertNewIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                             withCurrentIndexPath:l_currentIndexPath
                                        direction:l_direction];

    [self assertNewIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
        withCurrentIndexPath:l_currentIndexPath
                   direction:l_direction];

}

- (void)testThatTableViewIsScrolledToRowAtTheNextIndexPathWithAnInputFieldWhenUserTapsTheNextButtonAndTheDestinationCellIsNotFullyVisible {
    // given
    NSIndexPath *l_currentInputFieldIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.p_view notifyOfCurrentInputFieldIndexPath:l_currentInputFieldIndexPath];
    [[[self.p_mockDataSource expect] andReturn:self.p_mockResponder] formInputAccessoryView:self.p_view
                                                  responderForKeyboardInputFocusAtIndexPath:l_currentInputFieldIndexPath];
    [[self.p_mockTableView expect] scrollToRowAtIndexPath:self.p_view.IFA_nextInputFieldIndexPath
                                         atScrollPosition:UITableViewScrollPositionTop animated:YES];

    // when
    [self.p_view onNextButtonTap];

    // then
    [self.p_mockTableView verify];
}

- (void)testThatTableViewIsNotScrolledToRowAtTheNextIndexPathWithAnInputFieldAndThatResponderIsRequestedWhenUserTapsTheNextButtonAndTheDestinationCellIsAlreadyFullyVisible {
    // given
    NSIndexPath *l_currentInputFieldIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.p_view notifyOfCurrentInputFieldIndexPath:l_currentInputFieldIndexPath];
    NSIndexPath *l_nextInputFieldIndexPath = self.p_view.IFA_nextInputFieldIndexPath;
    [[[self.p_mockTableView expect] ifa_andReturnBool:YES] ifa_isCellFullyVisibleForRowAtIndexPath:l_nextInputFieldIndexPath];
    [[[self.p_mockDataSource expect] andReturn:self.p_mockResponder] formInputAccessoryView:self.p_view
                                             responderForKeyboardInputFocusAtIndexPath:l_currentInputFieldIndexPath];
    [[self.p_mockDataSource expect] formInputAccessoryView:self.p_view
                 responderForKeyboardInputFocusAtIndexPath:l_nextInputFieldIndexPath];
    [[self.p_mockTableView reject] scrollToRowAtIndexPath:l_nextInputFieldIndexPath
                                         atScrollPosition:UITableViewScrollPositionTop animated:YES];

    // when
    [self.p_view onNextButtonTap];

    // then
    [self.p_mockTableView verify];
}

- (void)testThatTableViewIsScrolledToRowAtThePreviousIndexPathWithAnInputFieldWhenUserTapsThePreviousButtonAndTheDestinationCellIsNotFullyVisible {
    // given
    NSIndexPath *l_currentInputFieldIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.p_view notifyOfCurrentInputFieldIndexPath:l_currentInputFieldIndexPath];
    [[[self.p_mockDataSource expect] andReturn:self.p_mockResponder] formInputAccessoryView:self.p_view
                                                  responderForKeyboardInputFocusAtIndexPath:l_currentInputFieldIndexPath];
    [[self.p_mockTableView expect] scrollToRowAtIndexPath:self.p_view.IFA_previousInputFieldIndexPath
                                         atScrollPosition:UITableViewScrollPositionTop animated:YES];

    // when
    [self.p_view onPreviousButtonTap];

    // then
    [self.p_mockTableView verify];
}

- (void)testThatTableViewIsNotScrolledToRowAtThePreviousIndexPathWithAnInputFieldAndThatResponderIsRequestedWhenUserTapsThePreviousButtonAndTheDestinationCellIsAlreadyFullyVisible {
    // given
    NSIndexPath *l_currentInputFieldIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.p_view notifyOfCurrentInputFieldIndexPath:l_currentInputFieldIndexPath];
    NSIndexPath *l_previousInputFieldIndexPath = self.p_view.IFA_previousInputFieldIndexPath;
    [[[self.p_mockTableView expect] ifa_andReturnBool:YES] ifa_isCellFullyVisibleForRowAtIndexPath:l_previousInputFieldIndexPath];
    [[[self.p_mockDataSource expect] andReturn:self.p_mockResponder] formInputAccessoryView:self.p_view
                                                  responderForKeyboardInputFocusAtIndexPath:l_currentInputFieldIndexPath];
    [[self.p_mockDataSource expect] formInputAccessoryView:self.p_view
                 responderForKeyboardInputFocusAtIndexPath:l_previousInputFieldIndexPath];
    [[self.p_mockTableView reject] scrollToRowAtIndexPath:l_previousInputFieldIndexPath
                                         atScrollPosition:UITableViewScrollPositionTop animated:YES];

    // when
    [self.p_view onPreviousButtonTap];

    // then
    [self.p_mockTableView verify];
}

- (void)testThatDataSourceIsRequestedTheResponderAfterTableViewScrollingAnimationEnded{

    NSIndexPath *l_currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *l_nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];

    // Notify of current input field index path
    [self.p_view notifyOfCurrentInputFieldIndexPath:l_currentIndexPath];

    // "Tap" the Next button
    [[[self.p_mockDataSource expect] andReturn:self.p_mockResponder] formInputAccessoryView:self.p_view
                 responderForKeyboardInputFocusAtIndexPath:l_currentIndexPath];
    [self.p_view onNextButtonTap];

    // Simulate scrolling animation ended
    [[self.p_mockDataSource expect] formInputAccessoryView:self.p_view
                 responderForKeyboardInputFocusAtIndexPath:l_nextIndexPath];
    [self.p_view notifyTableViewDidEndScrollingAnimation];
    [self.p_mockDataSource verify];

}

#pragma mark - Private

- (void)m_configureMockObjects {
    [self m_configureMockTableView];
    [self m_configureMockDataSource];
    [self m_configureMockTableViewDataSource];
    [self m_configureMockResponder];
}

- (void)m_configureMockTableView {
    [[[self.p_mockTableView stub] andReturn:self.p_mockTableViewDataSource] dataSource];
}

- (void)m_configureMockDataSource {
    [[[self.p_mockDataSource stub] ifa_andReturnBool:NO] formInputAccessoryView:self.p_view canReceiveKeyboardInputAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                inSection:0]];
    [[[self.p_mockDataSource stub] ifa_andReturnBool:YES] formInputAccessoryView:self.p_view canReceiveKeyboardInputAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                 inSection:1]];
    [[[self.p_mockDataSource stub] ifa_andReturnBool:YES] formInputAccessoryView:self.p_view canReceiveKeyboardInputAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                                                 inSection:1]];
    [[[self.p_mockDataSource stub] ifa_andReturnBool:NO] formInputAccessoryView:self.p_view canReceiveKeyboardInputAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                inSection:2]];
    [[[self.p_mockDataSource stub] ifa_andReturnBool:YES] formInputAccessoryView:self.p_view canReceiveKeyboardInputAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                                                 inSection:2]];
    [[[self.p_mockDataSource stub] ifa_andReturnBool:YES] formInputAccessoryView:self.p_view canReceiveKeyboardInputAtIndexPath:[NSIndexPath indexPathForRow:2
                                                                                                 inSection:2]];
    [[[self.p_mockDataSource stub] ifa_andReturnBool:NO] formInputAccessoryView:self.p_view canReceiveKeyboardInputAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                inSection:3]];
}

- (void)m_configureMockTableViewDataSource {
    [[[self.p_mockTableViewDataSource stub] ifa_andReturnInteger:4] numberOfSectionsInTableView:self.p_mockTableView];
    [[[self.p_mockTableViewDataSource stub] ifa_andReturnInteger:1] tableView:self.p_mockTableView
                                                    numberOfRowsInSection:0];
    [[[self.p_mockTableViewDataSource stub] ifa_andReturnInteger:2] tableView:self.p_mockTableView
                                                    numberOfRowsInSection:1];
    [[[self.p_mockTableViewDataSource stub] ifa_andReturnInteger:3] tableView:self.p_mockTableView
                                                    numberOfRowsInSection:2];
    [[[self.p_mockTableViewDataSource stub] ifa_andReturnInteger:1] tableView:self.p_mockTableView
                                                    numberOfRowsInSection:3];
}

- (void)m_createMockObjects {
    self.p_mockTableViewDataSource = [OCMockObject niceMockForProtocol:@protocol(UITableViewDataSource)];
    self.p_mockTableView = [OCMockObject niceMockForClass:[UITableView class]];
    self.p_mockDataSource = [OCMockObject mockForProtocol:@protocol(IFAFormInputAccessoryViewDataSource)];
    self.p_mockPreviousBarButtonItem = [OCMockObject niceMockForClass:[UIBarButtonItem class]];
    self.p_mockNextBarButtonItem = [OCMockObject niceMockForClass:[UIBarButtonItem class]];
    self.p_mockResponder = [OCMockObject mockForClass:[UIResponder class]];
}

- (void)m_configureMockResponder {
    [[[self.p_mockResponder expect] ifa_andReturnBool:YES] canResignFirstResponder];
}

- (void)m_createSystemUnderTestAndSetMockObjects {
    self.p_view = [self m_createSystemUnderTest];
    self.p_view.dataSource = self.p_mockDataSource;
    self.p_view.previousBarButtonItem = self.p_mockPreviousBarButtonItem;
    self.p_view.nextBarButtonItem = self.p_mockNextBarButtonItem;
}

- (IFAFormInputAccessoryView *)m_createSystemUnderTest {
    return [[IFAFormInputAccessoryView alloc] initWithTableView:self.p_mockTableView];
}

- (void)m_assertThatForSection:(NSInteger)a_section row:(NSInteger)a_row
       previousButtonIsEnabled:(BOOL)a_previousButtonEnabled nextButtonIsEnabled:(BOOL)a_nextButtonEnabled {
    [[self.p_mockPreviousBarButtonItem expect] setEnabled:a_previousButtonEnabled];
    [[self.p_mockNextBarButtonItem expect] setEnabled:a_nextButtonEnabled];
    [self.p_view notifyOfCurrentInputFieldIndexPath:[NSIndexPath indexPathForRow:a_row inSection:a_section]];
    [self.p_mockPreviousBarButtonItem verify];
    [self.p_mockNextBarButtonItem verify];
}

- (NSIndexPath *)assertNewIndexPath:(NSIndexPath *)a_newIndexPath withCurrentIndexPath:(NSIndexPath *)a_currentIndexPath
                          direction:(IFAFormInputAccessoryViewDirection)a_direction {
    [self.p_view notifyOfCurrentInputFieldIndexPath:a_currentIndexPath];
    NSIndexPath *l_actualNewIndexPath = [self.p_view IFA_indexPathForDirection:a_direction];
    assertThat(l_actualNewIndexPath, is(equalTo(a_newIndexPath)));
    return l_actualNewIndexPath;
}

@end
