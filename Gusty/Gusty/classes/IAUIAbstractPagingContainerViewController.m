//
//  IAUIPagingContainerViewController.m
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

#import "IACommon.h"

@interface IAUIAbstractPagingContainerViewController ()

@property (nonatomic) NSUInteger p_selectedPageIndex;
@property (nonatomic) NSUInteger p_newChildViewControllerCount;

@end

@implementation IAUIAbstractPagingContainerViewController


#pragma mark - Public

-(UIScrollView*)p_scrollView{
    return (UIScrollView*)self.view;
}

-(IAUITableViewController*)p_selectedViewController{
    return [self.childViewControllers objectAtIndex:self.p_selectedPageIndex];
}

-(void)m_updateContentLayout{
    NSUInteger l_contentWidth = 0;
    for (int i=0; i<[self.childViewControllers count]; i++) {
        UIViewController *l_viewController = [self.childViewControllers objectAtIndex:i];
        CGRect l_frame = self.view.frame;
//        NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
        l_frame.origin.x = l_frame.size.width * i;
        l_viewController.view.frame = l_frame;
//        NSLog(@"l_viewController.view.frame: %@", NSStringFromCGRect(l_viewController.view.frame));
        l_contentWidth += l_viewController.view.frame.size.width;
    }
    self.p_scrollView.contentSize = CGSizeMake(l_contentWidth, self.view.frame.size.height);
}

-(CGRect)m_visibleRectForPage:(NSUInteger)a_pageIndex{

    CGRect l_rect = self.view.frame;
    l_rect.origin.x = l_rect.size.width * a_pageIndex;
    l_rect.origin.y = 0;
//    NSLog(@"l_rect: %@", NSStringFromCGRect(l_rect));

    return l_rect;

}

-(void)m_scrollToPage:(NSUInteger)a_pageIndex animated:(BOOL)a_animated{
    
//    NSLog(@"m_scrollToPage: %u", a_pageIndex);
    
    [self.p_scrollView scrollRectToVisible:[self m_visibleRectForPage:a_pageIndex] animated:a_animated];
//    NSLog(@"m_scrollToPage - frame: %@", NSStringFromCGRect(self.p_scrollView.frame));
//    NSLog(@"m_scrollToPage - bounds: %@", NSStringFromCGRect(self.p_scrollView.bounds));
    
    self.p_previousVisibleViewController = nil;
    
    [self m_updateScreenDecorationState];
    
}

-(NSArray*)m_dataLoadPageIndexes{
    NSMutableArray *l_pageIndexes = [NSMutableArray new];
    for (int i=0; i<[self.childViewControllers count]; i++) {
        [l_pageIndexes addObject:@(i)];
    }
    return l_pageIndexes;
}

-(void)m_refreshAndReloadChildData{
    //    NSLog(@"m_refreshAndReloadChildData - START");
    BOOL l_firstChildViewController = YES;
    for (NSNumber *l_pageIndex in [self m_dataLoadPageIndexes]) {
        NSUInteger i = [l_pageIndex unsignedIntegerValue];
        UIViewController *l_viewController = [self.childViewControllers objectAtIndex:i];
        if ([l_viewController isKindOfClass:[IAUIListViewController class]]) {
            IAUIListViewController *l_childListViewController = (IAUIListViewController*)l_viewController;
            //            NSLog(@"  l_pageIndex: %u, child: %@, staleData: %u", i, [l_childViewController description], l_childViewController.p_staleData);
            if (l_childListViewController.p_staleData) {
                BOOL l_shouldShowProgressIndicator = l_firstChildViewController && l_childListViewController==self.p_selectedViewController;
                //                NSLog(@"    l_shouldShowProgressIndicator: %u", l_shouldShowProgressIndicator);
                //                NSLog(@"    l_childViewController.p_refreshAndReloadDataAsyncBlock: %@", [l_childViewController.p_refreshAndReloadDataAsyncBlock description]);
                [self.p_aom m_dispatchSerialBlock:l_childListViewController.p_refreshAndReloadDataAsyncBlock showProgressIndicator:l_shouldShowProgressIndicator cancelPreviousBlocks:l_firstChildViewController];
                l_firstChildViewController = NO;
            }
        }
    }    
    //    NSLog(@"m_refreshAndReloadChildData - END");
}

-(IAUITableViewController*)p_mainChildViewController{
    return [self.childViewControllers objectAtIndex:0];
}

-(NSUInteger)m_calculateSelectedPageIndex{
    CGFloat l_contentWidth = self.view.frame.size.width;
    IAUIScrollPage l_selectedPageIndex = floor((self.p_scrollView.contentOffset.x - l_contentWidth / 2) / l_contentWidth) + 1;
    return l_selectedPageIndex;
}

-(void)m_addChildViewControllers:(NSArray*)a_childViewControllers{
    for (UIViewController *l_viewController in a_childViewControllers) {
        [self addChildViewController:l_viewController]; // conform to the container view controller pattern
        [self.view addSubview:l_viewController.view];
        [l_viewController didMoveToParentViewController:self]; // conform to the container view controller pattern
    }
    [self m_updateContentLayout];
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

-(void)viewWillAppear:(BOOL)animated{
    
    // When the interface orientation changes in some other tab, it will trigger a scrollViewDidScroll event when this view is shown.
    // We need to ignore that event and that is reason to re-layout below so we can do set a flag to indicate we have to ignore it.
    if (self.p_interfaceOrientation!=self.interfaceOrientation) {
        
        //        NSLog(@"Orientation CHANGED in viewWillAppear! - v_interfaceOrientation: %u, self.interfaceOrientation: %u", v_interfaceOrientation, self.interfaceOrientation);
        
        self.p_willRotate = YES;
        self.p_interfaceOrientation = self.interfaceOrientation;
        
        // If orientation changes while this controller's view is not visible, we need to adjust this controller's frame to reflect the new orientation.
        //  The frame must reflect the new orientation by the time the m_updateChildViewControllersForSelectedPage method call is made below because it will the basis for the children's frames.
        // One would think that this would be done automatically. It seems that it would be but the new frame would be available only in viewDidAppear and we need it now because m_updateChildViewControllersForSelectedPage must be called below in some cases.
        [self.splitViewController.view layoutIfNeeded]; // Forces the navigation controller view's frame to be adjusted so it can be used in the calculation below
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.navigationController.toolbar.frame.size.height);
        
    }
    self.p_willRotate = NO;
    
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    // Update scroll view content's height as it may need to change due to toolbar being hidden/shown
    self.p_scrollView.contentSize = CGSizeMake(self.p_scrollView.contentSize.width, self.view.frame.size.height);
    
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    NSLog(@"willRotateToInterfaceOrientation in %@", [self description]);
    self.p_willRotate = YES;
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    NSLog(@"willAnimateRotationToInterfaceOrientation in %@", [self description]);
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
//    [self m_updateContentLayout];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    NSLog(@"didRotateFromInterfaceOrientation in %@", [self description]);
    self.p_willRotate = NO;
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.p_interfaceOrientation = self.interfaceOrientation;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender{
    
    if (self.p_willRotate) {
        // v_willRotate: changes to interface orientation may generate callbacks to this method: we have to ignore those...
//        NSLog(@"Ignoring scrollViewDidScroll event in IAUIAbstractPagingContainerViewController");
        return;
    }
    
    IAUIScrollPage l_newSelectedPageIndex = [self m_calculateSelectedPageIndex];
    if (self.p_selectedPageIndex!=l_newSelectedPageIndex) {
        self.p_selectedPageIndex = l_newSelectedPageIndex;
        [self m_updateScreenDecorationState];
//        NSLog(@" self.p_selectedPageIndex CHANGED: %u, title: %@", self.p_selectedPageIndex, self.navigationItem.title);
    }
    
}

@end
