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

#import "IFACommon.h"

#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
#import "UIViewController+IFAGoogleMobileAdsSupport.h"
#endif

@interface IFATableViewController (){
    @private
    BOOL v_initDone;
}

@property (nonatomic, strong) UITableView *IFA_tableView;
@property(nonatomic, strong) NSLayoutConstraint *IFA_tableViewBottomLayoutConstraint;

@end

@implementation IFATableViewController {
    
}

#pragma mark - Private

-(void)IFA_onTableViewCellAccessoryButtonTap:(UIButton *)l_button withEvent:(UIEvent*)l_event{
    NSIndexPath *l_indexPath = [self.tableView indexPathForRowAtPoint:[[[l_event touchesForView:l_button] anyObject] locationInView:self.tableView]];
    if (l_indexPath){
        [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath:l_indexPath];
    }
}

#pragma mark - Public

-(UIView*)newTableViewCellAccessoryView {
    UIButton *l_button = [[self ifa_appearanceTheme] newDetailDisclosureButton];
    l_button.frame = CGRectMake(l_button.frame.origin.x, l_button.frame.origin.y, IFAMinimumTapAreaDimension, IFAMinimumTapAreaDimension);
    [l_button addTarget:self action:@selector(IFA_onTableViewCellAccessoryButtonTap:withEvent:)
       forControlEvents:UIControlEventTouchUpInside];
    return l_button;
}

-(void)replyToContextSwitchRequestWithGranted:(BOOL)a_granted{
    NSString *l_notificationName = a_granted ? IFANotificationContextSwitchRequestGranted : IFANotificationContextSwitchRequestDenied;
    NSNotification *l_notification = [NSNotification notificationWithName:l_notificationName
                                                                   object:self.contextSwitchRequestObject userInfo:nil];
    [[NSNotificationQueue defaultQueue] enqueueNotification:l_notification 
                                               postingStyle:NSPostASAP
                                               coalesceMask:NSNotificationNoCoalescing 
                                                   forModes:nil];
    self.contextSwitchRequestPending = NO;
    self.contextSwitchRequestObject = nil;
//    NSLog(@"IFA_NOTIFICATION_CONTEXT_SWITCH_REQUEST_%@ sent by %@", a_granted?@"GRANTED":@"DENIED", [self description]);
}

-(BOOL)contextSwitchRequestRequired {
    if ([self.navigationController isKindOfClass:[IFANavigationController class]]) {
        return ((IFANavigationController *)self.navigationController).contextSwitchRequestRequired;
    }else{
        return NO;
    }
}

-(void)setContextSwitchRequestRequired:(BOOL)a_contextSwitchRequestRequired{
//    NSLog(@"setting contextSwitchRequestRequired 2...");
    if ([self.navigationController isKindOfClass:[IFANavigationController class]]) {
        ((IFANavigationController *)self.navigationController).contextSwitchRequestRequired = a_contextSwitchRequestRequired;
//        NSLog(@"   *** contextSwitchRequestRequired set to %u", self.contextSwitchRequestRequired);
    }
}

- (void)reloadData{
    [self.tableView reloadData];
}

- (void)oncontextSwitchRequestNotification:(NSNotification*)aNotification{
//    NSLog(@"IFANotificationContextSwitchRequest received by %@", [self description]);
    self.contextSwitchRequestPending = YES;
    self.contextSwitchRequestObject = aNotification.object;
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
    if ([self.tableView.visibleCells count]>0) {
        NSUInteger l_index = [[self.tableView indexPathsForVisibleRows] indexOfObject:a_indexPath];
        if (l_index!=NSNotFound) {
            l_cell = [self.tableView.visibleCells objectAtIndex:l_index];
        }
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

        // Set help target ID
        l_cell.ifa_helpTargetId = [self ifa_helpTargetIdForName:@"tableCell"];
       
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
    self.sectionHeaderView.bounds = CGRectMake( (self.editing && !l_swipedToDelete ) ? 0 : [self sectionHeaderNonEditingXOffset], 0, self.tableView.frame.size.width, self.sectionHeaderView.frame.size.height);
}

-(void)reloadMovedCellAtIndexPath:(NSIndexPath*)a_indexPath{
    [IFAUtils dispatchAsyncMainThreadBlock:^{
        [self.tableView reloadRowsAtIndexPaths:@[a_indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }                           afterDelay:IFAAnimationDuration];
}

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
    
    v_initDone = YES;

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
                                                 selector:@selector(oncontextSwitchRequestNotification:)
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
//        [super m_updateEditButtonItemAccessibilityLabel];
        
        // Set edit button's appearance
        [[self ifa_appearanceTheme] setAppearanceForBarButtonItem:self.editButtonItem viewController:nil
                                                      important:editing];
        
        if (self.sectionHeaderView) {
            [UIView animateWithDuration:IFAAnimationDuration animations:^{
                [self updateSectionHeaderBounds];
            }];
        }
    }

    if (v_initDone && !self.skipEditingUiStateChange) {
        if (self.ifa_manageToolbar) {
            [self ifa_updateToolbarForMode:editing animated:animated];
        }else{
            [((IFAViewController *) self.parentViewController) ifa_updateToolbarForMode:editing animated:animated];
        }
    }

    if (self.contextSwitchRequestPending) {
        // Notify that any pending context switch can occur
        [self replyToContextSwitchRequestWithGranted:YES];
    }

    if ([self contextSwitchRequestRequiredInEditMode]) {
//        NSLog(@"setting contextSwitchRequestRequired 1...");
        self.contextSwitchRequestRequired =  editing;
    }

    if (self.pagingContainerViewController) {
        self.pagingContainerViewController.scrollView.scrollEnabled = !editing;
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return ![IFAHelpManager sharedInstance].helpMode;
}

#pragma mark - UITableViewDelegate protocol

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return [IFAHelpManager sharedInstance].helpMode ? nil : indexPath;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnWillDisplayCell:cell
                                                                                    forRowAtIndexPath:indexPath
                                                                                       viewController:self];
}

#pragma mark - UIScrollViewDelegate protocol

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([IFAHelpManager sharedInstance].helpMode) {
        [[IFAHelpManager sharedInstance] refreshHelpTargets];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        if ([IFAHelpManager sharedInstance].helpMode) {
            [[IFAHelpManager sharedInstance] refreshHelpTargets];
        }
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([IFAHelpManager sharedInstance].helpMode) {
        [[IFAHelpManager sharedInstance] resetUi];
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
