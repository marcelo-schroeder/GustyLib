//
//  IAUITableViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 21/09/10.
//  Copyright 2010 InfoAccent Pty Limited. All rights reserved.
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

#import "IACommon.h"

@interface IAUITableViewController(){
    @private
    BOOL v_initDone;
}

@property (nonatomic, strong) UITableView *p_tableView;
@property(nonatomic, strong) NSLayoutConstraint *p_tableViewBottomLayoutConstraint;

@end

@implementation IAUITableViewController{
    
}

#pragma mark - Private

-(void)m_onTableViewCellAccessoryButtonTap:(UIButton*)l_button withEvent:(UIEvent*)l_event{
    NSIndexPath *l_indexPath = [self.tableView indexPathForRowAtPoint:[[[l_event touchesForView:l_button] anyObject] locationInView:self.tableView]];
    if (l_indexPath){
        [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath:l_indexPath];
    }
}

#pragma mark - Public

-(UIView*)m_newTableViewCellAccessoryView{
    UIButton *l_button = [[self m_appearanceTheme] newDetailDisclosureButton];
    l_button.frame = CGRectMake(l_button.frame.origin.x, l_button.frame.origin.y, IA_MINIMUM_TAP_AREA_DIMENSION, IA_MINIMUM_TAP_AREA_DIMENSION);
    [l_button addTarget:self action:@selector(m_onTableViewCellAccessoryButtonTap:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    return l_button;
}

-(void)m_replyToContextSwitchRequestWithGranted:(BOOL)a_granted{
    NSString *l_notificationName = a_granted ? IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST_GRANTED : IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST_DENIED;
    NSNotification *l_notification = [NSNotification notificationWithName:l_notificationName object:self.p_contextSwitchRequestObject userInfo:nil];
    [[NSNotificationQueue defaultQueue] enqueueNotification:l_notification 
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing 
                                                   forModes:nil];
    self.p_contextSwitchRequestPending = NO;
    self.p_contextSwitchRequestObject = nil;
//    NSLog(@"IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST_%@ sent by %@", a_granted?@"GRANTED":@"DENIED", [self description]);
}

-(BOOL)p_contextSwitchRequestRequired{
    if ([self.navigationController isKindOfClass:[IAUINavigationController class]]) {
        return ((IAUINavigationController*)self.navigationController).p_contextSwitchRequestRequired;
    }else{
        return NO;
    }
}

-(void)setP_contextSwitchRequestRequired:(BOOL)a_contextSwitchRequestRequired{
//    NSLog(@"setting p_contextSwitchRequestRequired 2...");
    if ([self.navigationController isKindOfClass:[IAUINavigationController class]]) {
        ((IAUINavigationController*)self.navigationController).p_contextSwitchRequestRequired = a_contextSwitchRequestRequired;
//        NSLog(@"   *** p_contextSwitchRequestRequired set to %u", self.p_contextSwitchRequestRequired);
    }
}

- (void)reloadData{
    [self.tableView reloadData];
}

- (void)m_oncontextSwitchRequestNotification:(NSNotification*)aNotification{
//    NSLog(@"IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST received by %@", [self description]);
    self.p_contextSwitchRequestPending = YES;
    self.p_contextSwitchRequestObject = aNotification.object;
    [self quitEditing];
}

// To be overriden by subclasses
- (BOOL)contextSwitchRequestRequiredInEditMode{
    return YES;
}

// To be overriden by subclasses
- (void)quitEditing{
    self.editing = NO;
}

- (BOOL)p_selectedViewControllerInPagingContainer{
//    NSLog(@"self: %@, self.p_pagingContainerViewController: %@, self.p_pagingContainerViewController.p_mainChildViewController: %@", [self description], [self.p_pagingContainerViewController description], [self.p_pagingContainerViewController.p_mainChildViewController description]);
    return self.p_pagingContainerViewController.p_selectedViewController == self;
}

-(NSCalendar*)m_calendar{
    return [NSCalendar m_threadSafeCalendar];
}

- (NSUInteger)m_numberOfRows {
    NSInteger l_numberOfSections = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
    NSUInteger l_numberOfRows = 0;
    for (int l_section = 0; l_section < l_numberOfSections ; l_section++) {
        l_numberOfRows += [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:l_section];
    }
    return l_numberOfRows;
}

- (UITableViewCell*)m_visibleCellForIndexPath:(NSIndexPath*)a_indexPath{
    UITableViewCell *l_cell = nil;
    if ([self.tableView.visibleCells count]>0) {
        NSUInteger l_index = [[self.tableView indexPathsForVisibleRows] indexOfObject:a_indexPath];
        if (l_index!=NSNotFound) {
            l_cell = [self.tableView.visibleCells objectAtIndex:l_index];
        }
    }
    return l_cell;
}

- (UITableViewCellStyle) m_tableViewCellStyle{
	return UITableViewCellStyleDefault;
}

- (UITableViewCell *)m_dequeueAndInitReusableCellWithIdentifier:(NSString*)a_reuseIdentifier atIndexPath:(NSIndexPath*)a_indexPath{
    
    UITableViewCell *l_cell = [self.tableView dequeueReusableCellWithIdentifier:a_reuseIdentifier];
    if (!l_cell) {
        
        l_cell = [self m_initReusableCellWithIdentifier:a_reuseIdentifier atIndexPath:a_indexPath];

        // Set help target ID
        l_cell.p_helpTargetId = [self m_helpTargetIdForName:@"tableCell"];
       
        // Set appearance
        [[[IAUIAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                       cell:l_cell];
        
    }
    
    return l_cell;
    
}

- (UITableViewCell *)m_initReusableCellWithIdentifier:(NSString*)a_reuseIdentifier atIndexPath:(NSIndexPath*)a_indexPath{
    return [[IAUITableViewCell alloc] initWithStyle:[self m_tableViewCellStyle] reuseIdentifier:a_reuseIdentifier];
}

-(CGFloat)m_sectionHeaderNonEditingXOffset{
    return IA_TABLE_VIEW_EDITING_CELL_X_OFFSET;
}

-(void)m_updateSectionHeaderBounds{
    BOOL l_swipedToDelete = NO;
    for (UITableViewCell *l_cell in self.tableView.visibleCells) {
        @autoreleasepool {
            if ([l_cell isKindOfClass:[IAUITableViewCell class]]) {
                IAUITableViewCell *l_customCell = (IAUITableViewCell*)l_cell;
//                NSLog(@"p_swipedToDelete: %u", l_customCell.p_swipedToDelete);
                if (l_customCell.p_swipedToDelete) {
                    l_swipedToDelete = YES;
                    break;
                }
            }
        }
    }
    self.p_sectionHeaderView.bounds = CGRectMake( (self.editing && !l_swipedToDelete ) ? 0 : [self m_sectionHeaderNonEditingXOffset], 0, self.tableView.frame.size.width, self.p_sectionHeaderView.frame.size.height);
}

-(void)m_reloadMovedCellAtIndexPath:(NSIndexPath*)a_indexPath{
    [IAUtils m_dispatchAsyncMainThreadBlock:^{
        [self.tableView reloadRowsAtIndexPaths:@[a_indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }                            afterDelay:IA_UI_ANIMATION_DURATION];
}

-(void)m_beginRefreshing{
    [self m_beginRefreshingWithControlShowing:YES];
}

-(void)m_beginRefreshingWithControlShowing:(BOOL)a_shouldShowControl{
    if (!self.refreshControl.refreshing) {
        [self.refreshControl beginRefreshing];
        if (a_shouldShowControl) {
            [self m_showRefreshControl:self.refreshControl inScrollView:self.tableView];
        }
    }
}

- (BOOL)m_shouldClearSelectionOnViewDidAppear{
    return YES;
}

#pragma mark - Overrides

-(void)m_init{
    if ([self m_shouldEnableAds]) {
        self.p_shouldCreateContainerViewOnLoadView = YES;
    }
}

-(id)init{
    if (self=[super init]) {
        [self m_init];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self=[super initWithCoder:aDecoder]) {
        [self m_init];
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self m_init];
    }
    return self;
}

-(id)initWithStyle:(UITableViewStyle)style{
    if (self=[super initWithStyle:style]) {
        [self m_init];
    }
    return self;
}

-(void)dealloc{
    [self m_dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    
    v_initDone = YES;

    [super viewWillAppear:animated];
    [self m_viewWillAppear];
    
//    // Scroll back to top
//    if (![self m_isReturningVisibleViewController] && [self.tableView.visibleCells count]) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    }

}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    [self m_viewDidAppear];
        
    if ( (!self.p_pagingContainerViewController || self.p_selectedViewControllerInPagingContainer) && (![IAUIUtils m_isIPad] || self.p_isDetailViewController) ) {
        
        // Add observers
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(m_oncontextSwitchRequestNotification:)
                                                     name:IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST
                                                   object:nil];
        
    }

    if ([self m_shouldClearSelectionOnViewDidAppear]) {
        for (NSIndexPath *l_indexPath in [self.tableView indexPathsForSelectedRows]){
            [self.tableView deselectRowAtIndexPath:l_indexPath animated:YES];
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
	[super viewWillDisappear:animated];
	[self m_viewWillDisappear];
        
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IA_NOTIFICATION_CONTEXT_SWITCH_REQUEST object:nil];

}

-(void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    [self m_viewDidDisappear];
    
}

-(UITableView *)tableView{
    if (self.p_shouldCreateContainerViewOnLoadView) {
        if (!self.view) {
            [self loadView];
        }
        return self.p_tableView;
    }else{
        return [super tableView];
    }
}

-(void)loadView{
    if (self.p_shouldCreateContainerViewOnLoadView) {
        CGRect l_frame;
        if (self.parentViewController) {
            l_frame = CGRectZero;
            l_frame.size = self.parentViewController.view.frame.size;
        }else{
            l_frame = [UIScreen mainScreen].applicationFrame;
        }
        UIView *l_view = [[UIView alloc] initWithFrame:l_frame];
        l_view.autoresizingMask = [IAUIUtils m_fullAutoresizingMask];
        self.p_tableView = [[UITableView alloc] initWithFrame:l_frame style:UITableViewStylePlain];
        self.p_tableView.autoresizingMask = [IAUIUtils m_fullAutoresizingMask];
        [l_view addSubview:self.p_tableView];
        NSArray *l_constraints = [self.p_tableView m_addLayoutConstraintsToFillSuperview];
        for (NSLayoutConstraint *l_constraint in l_constraints) {
            if (l_constraint.firstAttribute == NSLayoutAttributeBottom) {
                self.p_tableViewBottomLayoutConstraint = l_constraint;
            }
        }
        self.view = l_view;
    }else{
        [super loadView];
    }
}

-(void)viewDidLoad{

    self.p_tableCellTextColor = [[self m_appearanceTheme] tableCellTextColor];
    [super viewDidLoad];
    [self m_viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    if ([self m_shouldClearSelectionOnViewDidAppear]) {
        self.clearsSelectionOnViewWillAppear = NO;
    }

}

-(void)viewDidUnload{
    [super viewDidUnload];
    [self m_viewDidUnload];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    if (!self.p_skipEditingUiStateChange) { // Avoids unnecessary UI state change in Create mode
        [super setEditing:editing animated:animated];
//        [super m_updateEditButtonItemAccessibilityLabel];
        
        // Set edit button's appearance
        [[self m_appearanceTheme] setAppearanceForBarButtonItem:self.editButtonItem viewController:nil
                                                      important:editing];
        
        if (self.p_sectionHeaderView) {
            [UIView animateWithDuration:IA_UI_ANIMATION_DURATION animations:^{
                [self m_updateSectionHeaderBounds];
            }];
        }
    }

    if (v_initDone && !self.p_skipEditingUiStateChange) {
        if (self.p_manageToolbar) {
            [self m_updateToolbarForMode:editing animated:animated];
        }else{
            [((IAUIViewController*)self.parentViewController) m_updateToolbarForMode:editing animated:animated];
        }
    }

    if (self.p_contextSwitchRequestPending) {
        // Notify that any pending context switch can occur
        [self m_replyToContextSwitchRequestWithGranted:YES];
    }

    if ([self contextSwitchRequestRequiredInEditMode]) {
//        NSLog(@"setting p_contextSwitchRequestRequired 1...");
        self.p_contextSwitchRequestRequired =  editing;
    }

    if (self.p_pagingContainerViewController) {
        self.p_pagingContainerViewController.p_scrollView.scrollEnabled = !editing;
    }

}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return [self m_shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return [self m_supportedInterfaceOrientations];
}

-(BOOL)p_manageToolbar{
    return !self.p_pagingContainerViewController;
}

-(IAUIAbstractPagingContainerViewController*)p_pagingContainerViewController{
    return [self.parentViewController isKindOfClass:[IAUIAbstractPagingContainerViewController class]] ? (IAUIAbstractPagingContainerViewController*)self.parentViewController : nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    [self m_prepareForSegue:segue sender:sender];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self m_willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self m_willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self m_didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(UIView*)m_nonAdContainerView{
    return self.tableView;
}

- (void)m_updateNonAdContainerViewFrameWithAdBannerViewHeight:(CGFloat)a_adBannerViewHeight {
    if (self.p_tableViewBottomLayoutConstraint) {
        self.p_tableViewBottomLayoutConstraint.constant = a_adBannerViewHeight;
        [[self m_nonAdContainerView] layoutIfNeeded];   // Done so that this change can be animated
    }else{
        [super m_updateNonAdContainerViewFrameWithAdBannerViewHeight:a_adBannerViewHeight];
    }
}

#pragma mark - UITableViewDataSource protocol

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return ![IAHelpManager sharedInstance].p_helpMode;
}

#pragma mark - UITableViewDelegate protocol

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return [IAHelpManager sharedInstance].p_helpMode ? nil : indexPath;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[[IAUIAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnWillDisplayCell:cell
                                                                                    forRowAtIndexPath:indexPath
                                                                                       viewController:self];
}

#pragma mark - UIScrollViewDelegate protocol

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([IAHelpManager sharedInstance].p_helpMode) {
        [[IAHelpManager sharedInstance] refreshHelpTargets];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        if ([IAHelpManager sharedInstance].p_helpMode) {
            [[IAHelpManager sharedInstance] refreshHelpTargets];
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([IAHelpManager sharedInstance].p_helpMode) {
        [[IAHelpManager sharedInstance] resetUi];
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSIndexPath *l_selectedIndexPath = self.tableView.indexPathForSelectedRow;
    if (l_selectedIndexPath) {
        [self.tableView deselectRowAtIndexPath:l_selectedIndexPath animated:YES];
    }
}

@end
