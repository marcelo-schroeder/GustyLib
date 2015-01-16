//
//  IFATableViewController.m
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

#import "GustyLibCoreUI.h"

#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
#import "GustyLibGoogleMobileAdsSupport.h"
#endif

@interface IFATableViewController ()

@property (nonatomic, strong) UITableView *IFA_tableView;
@property(nonatomic, strong) NSLayoutConstraint *IFA_tableViewBottomLayoutConstraint;
@property(nonatomic) BOOL IFA_initDone;
@property(nonatomic, strong) NSMutableDictionary *IFA_cellHeightCacheByIndexPath;

@end

@implementation IFATableViewController {
    
}

#pragma mark - Private

//-(void)IFA_onTableViewCellAccessoryButtonTap:(UIButton *)l_button withEvent:(UIEvent*)l_event{
//    NSIndexPath *l_indexPath = [self.tableView indexPathForRowAtPoint:[[[l_event touchesForView:l_button] anyObject] locationInView:self.tableView]];
//    if (l_indexPath){
//        [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath:l_indexPath];
//    }
//}

- (NSMutableDictionary *)IFA_cellHeightCacheByIndexPath {
    if (!_IFA_cellHeightCacheByIndexPath) {
        _IFA_cellHeightCacheByIndexPath = [@{} mutableCopy];
    }
    return _IFA_cellHeightCacheByIndexPath;
}

- (CGFloat)IFA_calculateHeightForView:(UIView *)view {
    return [view ifa_calculateHeightForWidth:self.tableView.bounds.size.width];
}

#pragma mark - Public

//-(UIView*)newTableViewCellAccessoryView {
//    UIButton *l_button = [[self ifa_appearanceTheme] newDetailDisclosureButton];
//    l_button.frame = CGRectMake(l_button.frame.origin.x, l_button.frame.origin.y, IFAMinimumTapAreaDimension, IFAMinimumTapAreaDimension);
//    [l_button addTarget:self action:@selector(IFA_onTableViewCellAccessoryButtonTap:withEvent:)
//       forControlEvents:UIControlEventTouchUpInside];
//    return l_button;
//}

-(void)replyToContextSwitchRequestWithGranted:(BOOL)a_granted{
    NSString *l_notificationName = a_granted ? IFANotificationContextSwitchRequestGranted : IFANotificationContextSwitchRequestDenied;
    NSNotification *l_notification = [NSNotification notificationWithName:l_notificationName
                                                                   object:self.contextSwitchRequestObject userInfo:nil];
    [[NSNotificationQueue defaultQueue] enqueueNotification:l_notification 
                                               postingStyle:NSPostNow  // The only posting style that works - others would cause the tabbar to stop responding after setting the selected tab programmatically
                                               coalesceMask:NSNotificationNoCoalescing
                                                   forModes:nil];
    self.contextSwitchRequestPending = NO;
    self.contextSwitchRequestObject = nil;
//    NSLog(@"IFANotificationContextSwitchRequest%@ sent by %@", a_granted?@"Granted":@"Denied", [self description]);
}

- (void)reloadData{
    [self.tableView reloadData];
}

- (void)onContextSwitchRequestNotification:(NSNotification*)aNotification{
//    NSLog(@"IFANotificationContextSwitchRequest received by %@", [self description]);
    self.contextSwitchRequestPending = YES;
    self.contextSwitchRequestObject = aNotification.object;
    [self quitEditing];
}

- (BOOL)automaticallyHandleContextSwitchingBasedOnEditingState {
    return YES;
}

// To be overriden by subclasses
- (void)quitEditing{
    self.editing = NO;
}

- (BOOL)selectedViewControllerInPagingContainer {
//    NSLog(@"self: %@, self.pagingContainerViewController: %@, self.pagingContainerViewController.p_mainChildViewController: %@", [self description], [self.pagingContainerViewController description], [self.pagingContainerViewController.p_mainChildViewController description]);
    return self.pagingContainerViewController.selectedViewController == self;
}

-(NSCalendar*)calendar {
    return [NSCalendar ifa_threadSafeCalendar];
}

- (NSUInteger)numberOfRows {
    NSInteger l_numberOfSections = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
    NSUInteger l_numberOfRows = 0;
    for (int l_section = 0; l_section < l_numberOfSections ; l_section++) {
        l_numberOfRows += [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:l_section];
    }
    return l_numberOfRows;
}

- (UITableViewCell*)visibleCellForIndexPath:(NSIndexPath*)a_indexPath{
    UITableViewCell *l_cell = nil;
    if ([[self.tableView indexPathsForVisibleRows] containsObject:a_indexPath]) {
        l_cell = [self.tableView cellForRowAtIndexPath:a_indexPath];
    }
    return l_cell;
}

- (UITableViewCellStyle)tableViewCellStyle {
	return UITableViewCellStyleDefault;
}

- (UITableViewCell *)dequeueAndCreateReusableCellWithIdentifier:(NSString *)a_reuseIdentifier atIndexPath:(NSIndexPath*)a_indexPath{
    
    UITableViewCell *l_cell = [self.tableView dequeueReusableCellWithIdentifier:a_reuseIdentifier];
    if (!l_cell) {
        
        l_cell = [self createReusableCellWithIdentifier:a_reuseIdentifier atIndexPath:a_indexPath];

        // Set appearance
        [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnInitReusableCellForViewController:self
                                                                                                                       cell:l_cell];
        
    }
    
    return l_cell;
    
}

- (UITableViewCell *)createReusableCellWithIdentifier:(NSString *)a_reuseIdentifier atIndexPath:(NSIndexPath*)a_indexPath{
    return [[IFATableViewCell alloc] initWithStyle:[self tableViewCellStyle] reuseIdentifier:a_reuseIdentifier];
}

-(CGFloat)sectionHeaderNonEditingXOffset {
    return IFATableViewEditingCellXOffset;
}

-(void)updateSectionHeaderBounds {
    BOOL l_swipedToDelete = NO;
    for (UITableViewCell *l_cell in self.tableView.visibleCells) {
        @autoreleasepool {
            if ([l_cell isKindOfClass:[IFATableViewCell class]]) {
                IFATableViewCell *l_customCell = (IFATableViewCell *)l_cell;
//                NSLog(@"swipedToDelete: %u", l_customCell.swipedToDelete);
                if (l_customCell.swipedToDelete) {
                    l_swipedToDelete = YES;
                    break;
                }
            }
        }
    }
}

// Commented the method below out as it was causing issues with self sizing cells (i.e. cells would have incorrect height after reordering)

//- (void)reloadInvolvedSectionsAfterImplicitAnimationForRowMovedFromIndexPath:(NSIndexPath *)a_fromIndexPath toIndexPath:(NSIndexPath *)a_toIndexPath {
//    [CATransaction setCompletionBlock:^{
//        [IFAUtils dispatchAsyncMainThreadBlock:^{
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger) a_toIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
//            if (a_fromIndexPath.section!=a_toIndexPath.section) {
//                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger) a_fromIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
//            }
//        }];
//    }];
//}

-(void)beginRefreshing {
    [self beginRefreshingWithControlShowing:YES];
}

-(void)beginRefreshingWithControlShowing:(BOOL)a_shouldShowControl{
    if (!self.refreshControl.refreshing) {
        [self.refreshControl beginRefreshing];
        if (a_shouldShowControl) {
            [self ifa_showRefreshControl:self.refreshControl inScrollView:self.tableView];
        }
    }
}

- (BOOL)shouldClearSelectionOnViewDidAppear {
    return YES;
}

- (CGFloat)calculateHeaderHeightForSection:(NSInteger)a_section {
    UIView *view = [self.tableView.delegate tableView:self.tableView viewForHeaderInSection:a_section];
    return [self IFA_calculateHeightForView:view];
}

- (CGFloat)calculateFooterHeightForSection:(NSInteger)a_section {
    UIView *view = [self.tableView.delegate tableView:self.tableView viewForFooterInSection:a_section];
    return [self IFA_calculateHeightForView:view];
}

#pragma mark - Overrides

-(void)IFA_init {
#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
    if ([self ifa_shouldEnableAds]) {
        self.shouldCreateContainerViewOnLoadView = YES;
    }
#endif
}

-(id)init{
    if (self=[super init]) {
        [self IFA_init];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self=[super initWithCoder:aDecoder]) {
        [self IFA_init];
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self IFA_init];
    }
    return self;
}

-(id)initWithStyle:(UITableViewStyle)style{
    if (self=[super initWithStyle:style]) {
        [self IFA_init];
    }
    return self;
}

-(void)dealloc{
    [self ifa_dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.IFA_initDone = YES;

    [super viewWillAppear:animated];
    [self ifa_viewWillAppear];
    
//    // Scroll back to top
//    if (![self ifa_isReturningVisibleViewController] && [self.tableView.visibleCells count]) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    }

}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    [self ifa_viewDidAppear];
        
    if ( (!self.pagingContainerViewController || self.selectedViewControllerInPagingContainer) && (![IFAUIUtils isIPad] || self.ifa_isDetailViewController) ) {
        
        // Add observers
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onContextSwitchRequestNotification:)
                                                     name:IFANotificationContextSwitchRequest
                                                   object:nil];
        
    }

    if ([self shouldClearSelectionOnViewDidAppear]) {
        for (NSIndexPath *l_indexPath in [self.tableView indexPathsForSelectedRows]){
            [self.tableView deselectRowAtIndexPath:l_indexPath animated:YES];
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
	[super viewWillDisappear:animated];
    [self ifa_viewWillDisappear];
        
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationContextSwitchRequest object:nil];

}

-(void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    [self ifa_viewDidDisappear];
    
}

-(UITableView *)tableView{
    if (self.shouldCreateContainerViewOnLoadView) {
        if (!self.view) {
            [self loadView];
        }
        return self.IFA_tableView;
    }else{
        return [super tableView];
    }
}

-(void)loadView{
    if (self.shouldCreateContainerViewOnLoadView) {
        CGRect l_frame;
        if (self.parentViewController) {
            l_frame = CGRectZero;
            l_frame.size = self.parentViewController.view.frame.size;
        }else{
            l_frame = [UIScreen mainScreen].applicationFrame;
        }
        UIView *l_view = [[UIView alloc] initWithFrame:l_frame];
        l_view.autoresizingMask = [IFAUIUtils fullAutoresizingMask];
        self.IFA_tableView = [[UITableView alloc] initWithFrame:l_frame style:UITableViewStylePlain];
        self.IFA_tableView.autoresizingMask = [IFAUIUtils fullAutoresizingMask];
        [l_view addSubview:self.IFA_tableView];
        NSArray *l_constraints = [self.IFA_tableView ifa_addLayoutConstraintsToFillSuperview];
        for (NSLayoutConstraint *l_constraint in l_constraints) {
            if (l_constraint.firstAttribute == NSLayoutAttributeBottom) {
                self.IFA_tableViewBottomLayoutConstraint = l_constraint;
            }
        }
        self.view = l_view;
    }else{
        [super loadView];
    }
}

-(void)viewDidLoad{

    self.tableCellTextColor = [[self ifa_appearanceTheme] tableCellTextColor];
    [super viewDidLoad];
    [self ifa_viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    if ([self shouldClearSelectionOnViewDidAppear]) {
        self.clearsSelectionOnViewWillAppear = NO;
    }

}

-(void)viewDidUnload{
    [super viewDidUnload];
    [self ifa_viewDidUnload];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    if (!self.skipEditingUiStateChange) { // Avoids unnecessary UI state change in Create mode
        [super setEditing:editing animated:animated];
        [self ifa_setEditing:editing animated:animated];
//        [super m_updateEditButtonItemAccessibilityLabel];
        
        // Set edit button's appearance
        [[self ifa_appearanceTheme] setAppearanceForBarButtonItem:self.editButtonItem viewController:nil
                                                      important:editing];
        
    }

    if (self.IFA_initDone && !self.skipEditingUiStateChange) {

        UIViewController *l_viewControllerToHaveToolbarUpdated = nil;
        if (self.ifa_manageToolbar) {
            l_viewControllerToHaveToolbarUpdated = self;
        }else{
            l_viewControllerToHaveToolbarUpdated = self.parentViewController;
        }

        // Had to dispatch the below async to avoid the toolbar update kinda mid flight here...
        // It was triggering updates to parts of the table view affected by the toolbar updates and this was causing other issues.
        // So, this is now done after this run loop ends for consistency.
        [IFAUtils dispatchAsyncMainThreadBlock:^{
            [l_viewControllerToHaveToolbarUpdated ifa_updateToolbarForEditing:editing animated:animated];
        }];

    }

    if (self.contextSwitchRequestPending) {
        // Notify that any pending context switch can occur
        [self replyToContextSwitchRequestWithGranted:YES];
    }

    if (self.pagingContainerViewController) {
        self.pagingContainerViewController.scrollView.scrollEnabled = !editing;
    }

    if (self.shouldReloadTableViewDataAfterQuittingEditing && !editing) {
        [IFAUtils dispatchAsyncMainThreadBlock:^{
            [UIView transitionWithView:self.view duration:IFAAnimationDuration
                               options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                        [self.tableView reloadData];
                    }       completion:NULL];
        }                           afterDelay:IFAAnimationDuration];
    }

}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return [self ifa_shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return [self ifa_supportedInterfaceOrientations];
}

-(BOOL)ifa_manageToolbar {
    return !self.pagingContainerViewController;
}

-(IFAAbstractPagingContainerViewController *)pagingContainerViewController {
    return [self.parentViewController isKindOfClass:[IFAAbstractPagingContainerViewController class]] ? (IFAAbstractPagingContainerViewController *)self.parentViewController : nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    [self ifa_prepareForSegue:segue sender:sender];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self ifa_willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self ifa_willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self ifa_didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
- (void)ifa_updateNonAdContainerViewFrameWithGoogleMobileAdBannerViewHeight:(CGFloat)a_adBannerViewHeight {
    if (self.IFA_tableViewBottomLayoutConstraint) {
        self.IFA_tableViewBottomLayoutConstraint.constant = a_adBannerViewHeight;
        [[self.ifa_googleMobileAdsSupportDataSource nonAdContainerViewForGoogleMobileAdsEnabledViewController:self] layoutIfNeeded];   // Done so that this change can be animated
    }else{
        [super ifa_updateNonAdContainerViewFrameWithGoogleMobileAdBannerViewHeight:a_adBannerViewHeight];
    }
}
#endif

#pragma mark - UITableViewDataSource protocol

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDelegate protocol

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    // Cache cell height
    self.IFA_cellHeightCacheByIndexPath[indexPath.ifa_tableViewKey] = @(cell.bounds.size.height);

    // Set appearance
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnWillDisplayCell:cell
                                                                                    forRowAtIndexPath:indexPath
                                                                                       viewController:self];

}

// Not having this may produce incorrect cell heights (added with support for dynamic type)
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *heightNumber = self.IFA_cellHeightCacheByIndexPath[indexPath.ifa_tableViewKey];
    if (heightNumber) { // Cell height cache hit
        return heightNumber.floatValue;
    }else{  // Cell height cache miss
        return IFAMinimumTapAreaDimension;
    }
}

#pragma mark - IFAContextSwitchTarget

-(BOOL)contextSwitchRequestRequired {
    if ([self automaticallyHandleContextSwitchingBasedOnEditingState]) {
        return self.editing;
    }else{
        return NO;
    }
}

@end
