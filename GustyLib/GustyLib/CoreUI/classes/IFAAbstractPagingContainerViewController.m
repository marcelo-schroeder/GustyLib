//
//  IFAAbstractPagingContainerViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 31/05/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

@interface IFAAbstractPagingContainerViewController ()

@property (nonatomic) NSUInteger selectedPageIndex;

@end

@implementation IFAAbstractPagingContainerViewController


#pragma mark - Public

-(UIScrollView*)scrollView {
    return (UIScrollView*)self.view;
}

-(IFATableViewController *)selectedViewController {
    return (self.childViewControllers)[self.selectedPageIndex];
}

-(void)updateContentLayout {
    [self updateContentLayoutWithAnimation:NO];
}

-(void)updateContentLayoutWithAnimation:(BOOL)a_animated {
//    NSLog(@"updateContentLayout");
    CGFloat l_statusBarHeight = [IFAUIUtils statusBarSize].height;
    if (l_statusBarHeight==IFAIPhoneStatusBarDoubleHeight) {
        l_statusBarHeight = IFAIPhoneStatusBarDoubleHeight / 2; // The extra height added by the double height status should not be added, for some strange reason...
    }
    CGFloat l_contentTopInset = l_statusBarHeight + self.navigationController.navigationBar.bounds.size.height;
    UIToolbar *l_toolbar = self.navigationController.toolbar;
    UIViewController *l_visibleViewController = self.navigationController.visibleViewController;
    BOOL l_shouldShowToolbar = (l_visibleViewController.editing && l_visibleViewController.ifa_editModeToolbarItems.count) || (!l_visibleViewController.editing && l_visibleViewController.ifa_nonEditModeToolbarItems.count);
    CGFloat l_toolbarHeight = l_shouldShowToolbar ? l_toolbar.bounds.size.height : 0;
    CGFloat l_contentBottomInset = l_toolbarHeight + self.tabBarController.tabBar.bounds.size.height;
//    NSLog(@"  l_contentTopInset = %f", l_contentTopInset);
//    NSLog(@"  l_contentBottomInset = %f", l_contentBottomInset);
    __block NSUInteger l_contentWidth = 0;
    void (^l_uiChangesBlock)() = ^{
        for (NSUInteger i=0; i<[self.childViewControllers count]; i++) {
//        NSLog(@"    i = %u", i);
            UIViewController *l_viewController = (self.childViewControllers)[i];
            CGRect l_frame = self.view.frame;
//        NSLog(@"      self.view.frame: %@", NSStringFromCGRect(self.view.frame));
            l_frame.origin.x = l_frame.size.width * i;
            l_frame.origin.y = 0;
            l_viewController.view.frame = l_frame;
//        NSLog(@"      l_viewController.view.frame: %@", NSStringFromCGRect(l_viewController.view.frame));
            l_contentWidth += l_viewController.view.frame.size.width;
            if ([l_viewController isKindOfClass:[UITableViewController class]]) {
                UITableViewController *l_tableViewController = (UITableViewController *) l_viewController;
                l_tableViewController.tableView.contentInset = UIEdgeInsetsMake(l_contentTopInset, 0, l_contentBottomInset, 0);
                l_tableViewController.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(l_contentTopInset, 0, l_contentBottomInset, 0);
            }
        }
    };
    if (a_animated) {
        [UIView animateWithDuration:IFAAnimationDuration animations:l_uiChangesBlock];
    }else{
        l_uiChangesBlock();
    }
    self.scrollView.contentSize = CGSizeMake(l_contentWidth, self.view.frame.size.height);
}

-(CGRect)visibleRectForPage:(NSUInteger)a_pageIndex{

    CGRect l_rect = self.view.frame;
    l_rect.origin.x = l_rect.size.width * a_pageIndex;
    l_rect.origin.y = 0;
//    NSLog(@"l_rect: %@", NSStringFromCGRect(l_rect));

    return l_rect;

}

-(void)scrollToPage:(NSUInteger)a_pageIndex animated:(BOOL)a_animated{
    
//    NSLog(@"m_scrollToPage: %u", a_pageIndex);
    
    [self.scrollView scrollRectToVisible:[self visibleRectForPage:a_pageIndex] animated:a_animated];
//    NSLog(@"m_scrollToPage - frame: %@", NSStringFromCGRect(self.scrollView.frame));
//    NSLog(@"m_scrollToPage - bounds: %@", NSStringFromCGRect(self.scrollView.bounds));
    
    self.previousVisibleViewController = nil;

    [self ifa_updateScreenDecorationState];
    
}

-(NSArray*)dataLoadPageIndexes {
    NSMutableArray *l_pageIndexes = [NSMutableArray new];
    for (int i=0; i<[self.childViewControllers count]; i++) {
        [l_pageIndexes addObject:@(i)];
    }
    return l_pageIndexes;
}

-(void)refreshAndReloadChildData {
    //    NSLog(@"refreshAndReloadChildData - START");
    BOOL l_firstChildViewController = YES;
    for (NSNumber *l_pageIndex in [self dataLoadPageIndexes]) {
        NSUInteger i = [l_pageIndex unsignedIntegerValue];
        UIViewController *l_viewController = (self.childViewControllers)[i];
        if ([l_viewController isKindOfClass:[IFAListViewController class]]) {
            IFAListViewController *l_childListViewController = (IFAListViewController *)l_viewController;
            //            NSLog(@"  l_pageIndex: %u, child: %@, staleData: %u", i, [l_childViewController description], l_childViewController.staleData);
            if (l_childListViewController.staleData) {
                BOOL l_shouldShowProgressIndicator = l_firstChildViewController && l_childListViewController==self.selectedViewController;
                //                NSLog(@"    l_shouldShowProgressIndicator: %u", l_shouldShowProgressIndicator);
                //                NSLog(@"    l_childViewController.pagingContainerChildRefreshAndReloadDataAsynchronousBlock: %@", [l_childViewController.pagingContainerChildRefreshAndReloadDataAsynchronousBlock description]);
                [self.ifa_asynchronousWorkManager dispatchSerialBlock:l_childListViewController.pagingContainerChildRefreshAndReloadDataAsynchronousBlock
                                                showProgressIndicator:l_shouldShowProgressIndicator
                                                 cancelPreviousBlocks:l_firstChildViewController];
                l_firstChildViewController = NO;
            }
        }
    }    
    //    NSLog(@"refreshAndReloadChildData - END");
}

//-(IFATableViewController*)p_mainChildViewController{
//    return [self.childViewControllers objectAtIndex:0];
//}

-(NSUInteger)calculateSelectedPageIndex {
    CGFloat l_contentWidth = self.view.frame.size.width;
    IFAScrollPage l_selectedPageIndex = (IFAScrollPage)(NSUInteger)(floor((self.scrollView.contentOffset.x - l_contentWidth / 2) / l_contentWidth) + 1);
    return l_selectedPageIndex;
}

-(void)addChildViewControllers:(NSArray*)a_childViewControllers{
    for (UIViewController *l_viewController in a_childViewControllers) {
        [self addChildViewController:l_viewController]; // conform to the container view controller pattern
        [self.view addSubview:l_viewController.view];
        [l_viewController didMoveToParentViewController:self]; // conform to the container view controller pattern
    }
    [self updateContentLayout];
}

#pragma mark - Overrides

-(void)loadView{
    
    [super loadView];

    UIScrollView *l_scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    l_scrollView.pagingEnabled = YES;
    l_scrollView.showsHorizontalScrollIndicator = NO;
    l_scrollView.showsVerticalScrollIndicator = NO;
    l_scrollView.delegate = self;
    l_scrollView.directionalLockEnabled = YES;
    l_scrollView.scrollsToTop = NO;
    self.view = l_scrollView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self m_configureStatusBarFrameChangeNotificationObservers];
}

-(void)viewWillAppear:(BOOL)animated{
    
/*

    UPDATE: 05/09/2014 - Commented out code below as I modernise the framework to be more iOS 7 friendly - at the moment I don't have use cases that require the below.

    // When the interface orientation changes in some other tab, it will trigger a scrollViewDidScroll event when this view is shown.
    // We need to ignore that event and that is reason to re-layout below so we can do set a flag to indicate we have to ignore it.
    if (self.lastActiveInterfaceOrientation !=self.interfaceOrientation) {
        
        //        NSLog(@"Orientation CHANGED in viewWillAppear! - v_interfaceOrientation: %u, self.interfaceOrientation: %u", v_interfaceOrientation, self.interfaceOrientation);
        
        self.willRotate = YES;
        self.lastActiveInterfaceOrientation = self.interfaceOrientation;
        
        // If orientation changes while this controller's view is not visible, we need to adjust this controller's frame to reflect the new orientation.
        //  The frame must reflect the new orientation by the time the m_updateChildViewControllersForSelectedPage method call is made below because it will the basis for the children's frames.
        // One would think that this would be done automatically. It seems that it would be but the new frame would be available only in viewDidAppear and we need it now because m_updateChildViewControllersForSelectedPage must be called below in some cases.
        [self.splitViewController.view layoutIfNeeded]; // Forces the navigation controller view's frame to be adjusted so it can be used in the calculation below
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.navigationController.toolbar.frame.size.height);
        
    }
    self.willRotate = NO;
*/

    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    // Update content layout with animation (in case toolbar were hidden and are now animated into view)
    [self updateContentLayoutWithAnimation:YES];

}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];

    // Update content layout without animation before view appears again (in case toolbars were hidden, for instance)
    [self updateContentLayout];

}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    NSLog(@"willRotateToInterfaceOrientation in %@", [self description]);
    self.willRotate = YES;
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    NSLog(@"willAnimateRotationToInterfaceOrientation in %@", [self description]);
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    [self updateContentLayout];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    NSLog(@"didRotateFromInterfaceOrientation in %@", [self description]);
    self.willRotate = NO;
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.lastActiveInterfaceOrientation = self.interfaceOrientation;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender{
    
    if (self.willRotate) {
        // v_willRotate: changes to interface orientation may generate callbacks to this method: we have to ignore those...
//        NSLog(@"Ignoring scrollViewDidScroll event in IFAAbstractPagingContainerViewController");
        return;
    }
    
    IFAScrollPage l_newSelectedPageIndex = (IFAScrollPage) [self calculateSelectedPageIndex];
    if (self.selectedPageIndex !=l_newSelectedPageIndex) {
        self.selectedPageIndex = l_newSelectedPageIndex;
        [self ifa_updateScreenDecorationState];
//        NSLog(@" self.selectedPageIndex CHANGED: %u, title: %@", self.selectedPageIndex, self.navigationItem.title);
    }
    
}

#pragma mark - IFAContextSwitchTarget

- (BOOL)contextSwitchRequestRequired {
    if ([self.selectedViewController conformsToProtocol:@protocol(IFAContextSwitchTarget)]) {
        return ((id <IFAContextSwitchTarget>) self.selectedViewController).contextSwitchRequestRequired;
    }else{
        return NO;
    }
}

#pragma mark - Private

- (void)m_configureStatusBarFrameChangeNotificationObservers {
    __weak __typeof(self) l_weakSelf = self;
    void (^l_afterFrameChangeBlock)(NSNotification *) = ^(NSNotification *a_note) {
        [l_weakSelf updateContentLayout];
    };
    [self ifa_addNotificationObserverForName:UIApplicationDidChangeStatusBarFrameNotification object:nil
                                       queue:nil
                                  usingBlock:l_afterFrameChangeBlock
                                 removalTime:IFAViewControllerNotificationObserverRemovalTimeDealloc];
}

@end
