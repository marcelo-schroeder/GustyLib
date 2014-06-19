//
//  IFADynamicPagingContainerViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 12/11/11.
//  Copyright (c) 2011 InfoAccent Pty Limited. All rights reserved.
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

#ifdef IFA_AVAILABLE_Help
#import "UIViewController+IFAHelp.h"
#endif

static NSArray *c_pageDataLoadingOrder = nil;

@interface IFADynamicPagingContainerViewController ()

@property (nonatomic) NSUInteger newChildViewControllerCount;
@property (nonatomic, strong) NSDate *lastFullChildViewControllerUpdate;

@end

@implementation IFADynamicPagingContainerViewController {
    
    @private
    BOOL v_performingScroll;
    
}


#pragma mark - Private

-(void)IFA_enableNavigationButtonsAction:(BOOL)a_enable{
//    NSLog(@"IFA_enableNavigationButtonsAction: %u", a_enable);
    v_previousViewBarButtonItem.action = a_enable ? @selector(IFA_onToolbarNavigationButtonAction:) : NULL;
    v_nextViewBarButtonItem.action = a_enable ? @selector(IFA_onToolbarNavigationButtonAction:) : NULL;
}

-(void)IFA_scrollToDynamicPage:(IFAScrollPage)a_page animated:(BOOL)a_animated{

    // Switch flag that indicates scrolling is being performed on
    v_performingScroll = YES;

    [self scrollToPage:(a_page - v_firstPageWithContent) animated:a_animated];

}

-(id)IFA_requestChildViewControllerFromDataSourceForPage:(IFAScrollPage)a_page{
    UITableViewController *l_viewController = [self.dataSource childViewControlerForPage:a_page];
    l_viewController.tableView.scrollsToTop = NO;
    return l_viewController ? l_viewController : [NSNull null];
}

-(void)IFA_updateChildViewControllersForSelectedPageNumber:(NSNumber*)a_selectedPage{
    [self updateChildViewControllersForSelectedPage:[a_selectedPage unsignedIntegerValue]];
}

- (void)IFA_onToolbarNavigationButtonAction:(id)aSender{
    
    if (!v_performingScroll) {

        IFAScrollPage l_selectedPage = v_selectedPage + (aSender==v_previousViewBarButtonItem ? (-1) : (+1));
        //    NSLog(@"m_onToolbarNavigationButtonAction - l_selectedPage: %u", l_selectedPage);
        [self IFA_scrollToDynamicPage:l_selectedPage animated:YES];
        //    NSLog(@"scroll ended!");

//    }else{
//        NSLog(@"Ignoring nav button action...");
    }

}

#pragma mark - Overrides

-(void)viewDidLoad{

    [super viewDidLoad];
    
    // Sets some class level stuff
    static dispatch_once_t c_dispatchOncePredicate;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_pageDataLoadingOrder = @[@(IFAScrollPageCentre),
                                  @(IFAScrollPageLeftNear),
                                  @(IFAScrollPageRightNear),
                                  @(IFAScrollPageLeftFar),
                                  @(IFAScrollPageRightFar)];
    });

	// Toolbar nav buttons
    v_previousViewBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemPreviousPage target:self
                                                            action:NULL];
    [IFAUIUtils adjustImageInsetsForBarButtonItem:v_previousViewBarButtonItem insetValue:1];
#ifdef IFA_AVAILABLE_Help
    v_previousViewBarButtonItem.helpTargetId = [self ifa_helpTargetIdForName:@"previousPageButton"];
#endif
    v_nextViewBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemNextPage target:self action:NULL];
    [IFAUIUtils adjustImageInsetsForBarButtonItem:v_nextViewBarButtonItem insetValue:1];
#ifdef IFA_AVAILABLE_Help
    v_nextViewBarButtonItem.helpTargetId = [self ifa_helpTargetIdForName:@"nextPageButton"];
#endif
    [self IFA_enableNavigationButtonsAction:YES];

}

-(void)viewWillAppear:(BOOL)animated{

//    NSLog(@"*** viewWillAppear in container - start");
    
    //    NSLog(@" ");
    //    NSLog(@"self: %@", [self description]);
    //    NSLog(@"self.navigationController.topViewController: %@", [self.navigationController.topViewController description]);
    //    NSLog(@"self.navigationController.visibleViewController: %@", [self.navigationController.visibleViewController description]);
    //    NSLog(@"self.navigationController.viewControllers: %@", [self.navigationController.viewControllers description]);
    //    NSLog(@"presentingViewController: %@", [self.presentingViewController description]);
    //    NSLog(@"presentedViewController: %@", [self.presentedViewController description]);
    //    NSLog(@"isMovingToParentViewController: %u", self.isMovingToParentViewController);
    //    NSLog(@"isMovingFromParentViewController: %u", self.isMovingFromParentViewController);
    //    NSLog(@"isBeingPresented: %u", self.isBeingPresented);
    //    NSLog(@"isBeingDismissed: %u", self.isBeingDismissed);
    
    [super viewWillAppear:animated];
    
    if (![self ifa_isReturningVisibleViewController]) {
        
        // At first time, initialise child view controllers and scroll to centre page, otherwise just scroll to centre page (to avoid any previously unfinished animation)
        [self updateChildViewControllersForSelectedPage:self.pagingContainerChildViewControllers ? v_selectedPage : IFAScrollPageInit];

    }

//    NSLog(@"*** viewWillAppear in container - end");

}

- (NSArray*)ifa_nonEditModeToolbarItems {
    
	// Separator
	UIBarButtonItem *spaceBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemFlexibleSpace
                                                                    target:nil action:nil];
	
	return @[v_previousViewBarButtonItem, 
			spaceBarButtonItem, 
			v_nextViewBarButtonItem];
    
}

-(NSArray *)ifa_editModeToolbarItems {
    return [v_childViewControllerCentre ifa_editModeToolbarItems];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateChildViewControllersForSelectedPage:v_selectedPage];
}

-(void)ifa_updateNavigationItemState {
    [super ifa_updateNavigationItemState];
//    NSLog(@"ifa_updateNavigationItemState v_selectedPage: %u", v_selectedPage);
    self.navigationItem.title = [self.dataSource titleForPage:v_selectedPage];
}

- (void)ifa_updateToolbarNavigationButtonState {
    [super ifa_updateToolbarNavigationButtonState];
    //    NSLog(@"m_updateToolbarNavigationButtonStateForPage: %@", [v_childViewControllers description]);
	v_previousViewBarButtonItem.enabled = [self.pagingContainerChildViewControllers objectAtIndex:v_selectedPage - 1]!=[NSNull null];
	v_nextViewBarButtonItem.enabled = [self.pagingContainerChildViewControllers objectAtIndex:v_selectedPage + 1]!=[NSNull null];
    //    NSLog(@"v_previousViewBarButtonItem.enabled: %u", v_previousViewBarButtonItem.enabled);
    //    NSLog(@"v_nextViewBarButtonItem.enabled: %u", v_nextViewBarButtonItem.enabled);
}

-(void)ifa_updateScreenDecorationState {
    [super ifa_updateScreenDecorationState];
    [self ifa_updateNavigationItemState];
    [self ifa_updateToolbarNavigationButtonState];
}

-(BOOL)isEditing{
    return v_childViewControllerCentre.editing ? v_childViewControllerCentre.editing : [super isEditing];
}

-(IFATableViewController *)selectedViewController {
    return v_childViewControllerCentre;
}

-(NSArray *)dataLoadPageIndexes {
    NSMutableArray *l_pageIndexes = [NSMutableArray new];
    for (NSNumber *l_pageIndex in c_pageDataLoadingOrder) {
        NSUInteger i = [l_pageIndex unsignedIntegerValue];
        if ( [self.pagingContainerChildViewControllers objectAtIndex:i] != [NSNull null] ) {
            [l_pageIndexes addObject:l_pageIndex];
        }
    }    
    return l_pageIndexes;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender{

//    NSLog(@" ");
//    NSLog(@"scrollViewDidScroll - interfaceOrientation: %u", self.interfaceOrientation);
    
    if (self.willRotate) {
        // v_willRotate: changes to interface orientation may generate callbacks to this method: we have to ignore those...
//        NSLog(@"Ignoring scrollViewDidScroll event in IFADynamicPagingContainerViewController");
        return;
    }
    
//    NSLog(@"   v_selectedPage BEFORE: %u", v_selectedPage);
    v_selectedPage = [self calculateSelectedPageIndex] + v_firstPageWithContent;
//    NSLog(@"   v_selectedPage AFTER: %u", v_selectedPage);
    
    [super scrollViewDidScroll:sender];
    
    // Disables user interaction when it is mid scrolling... for now - ideally it would handle continuous scrolling gestures
    self.scrollView.userInteractionEnabled = NO;

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

//    NSLog(@"scrollViewDidEndDecelerating - v_selectedPage: %u", v_selectedPage);

    // Update child view controllers after a horizontal swipe by user
    [self updateChildViewControllersForSelectedPage:v_selectedPage];

}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{

    //    NSLog(@"   ***   scrollViewDidEndScrollingAnimation");
    
    // Update child view controllers after a navigation button has been tapped
    [self performSelectorOnMainThread:@selector(IFA_updateChildViewControllersForSelectedPageNumber:)
                           withObject:@(v_selectedPage) waitUntilDone:NO];

}

#pragma mark - Public

-(void)updateChildViewControllersForSelectedPage:(IFAScrollPage)a_selectedPage{
    
//    NSLog(@"m_updateChildViewControllersForSelectedPage - a_selectedPage: %u", a_selectedPage);
    
    //    [self.ifa_asynchronousWorkManager m_cancelAllBlocks];
    
    //    [v_childViewControllerCentre m_willResignMainChildViewController];
    
    // Some clean up
    self.childViewDidAppearCount = 0;
    self.newChildViewControllerCount = 0;
    for (id l_object in self.pagingContainerChildViewControllers) {
        if (l_object!=[NSNull null]) {
            UITableViewController *l_viewController = (UITableViewController*)l_object;
            l_viewController.tableView.scrollsToTop = NO;
            [l_viewController willMoveToParentViewController:nil]; // conform to the container view controller pattern
            [l_viewController.view removeFromSuperview];
            [l_viewController removeFromParentViewController]; // conform to the container view controller pattern
        }
    }
    
    //    [v_childViewControllerCentre m_didResignMainChildViewController];
    
    IFATableViewController *l_previousChildViewControllerCentre = v_childViewControllerCentre;
    
    switch (a_selectedPage) {
            
        case IFAScrollPageLeftNear:
            //            NSLog(@"Handling previous page selection...");
            v_childViewControllerRightFar = v_childViewControllerRightNear;
            v_childViewControllerRightNear = v_childViewControllerCentre;
            v_childViewControllerCentre = v_childViewControllerLeftNear;
            v_childViewControllerLeftNear = v_childViewControllerLeftFar;
            v_childViewControllerLeftFar = [self IFA_requestChildViewControllerFromDataSourceForPage:IFAScrollPageLeftFar];
            break;
            
        case IFAScrollPageRightNear:
            //            NSLog(@"Handling next page selection...");
            v_childViewControllerLeftFar = v_childViewControllerLeftNear;
            v_childViewControllerLeftNear = v_childViewControllerCentre;
            v_childViewControllerCentre = v_childViewControllerRightNear;
            v_childViewControllerRightNear = v_childViewControllerRightFar;
            v_childViewControllerRightFar = [self IFA_requestChildViewControllerFromDataSourceForPage:IFAScrollPageRightFar];
            break;
            
        case IFAScrollPageInit:
            self.lastFullChildViewControllerUpdate = [NSDate date];
            self.pagingContainerChildViewControllers = [NSMutableArray new];
            v_childViewControllerCentre = nil;
            v_childViewControllerCentre = [self IFA_requestChildViewControllerFromDataSourceForPage:IFAScrollPageCentre];
            v_childViewControllerLeftNear = [self IFA_requestChildViewControllerFromDataSourceForPage:IFAScrollPageLeftNear];
            v_childViewControllerLeftFar = [self IFA_requestChildViewControllerFromDataSourceForPage:IFAScrollPageLeftFar];
            v_childViewControllerRightNear = [self IFA_requestChildViewControllerFromDataSourceForPage:IFAScrollPageRightNear];
            v_childViewControllerRightFar = [self IFA_requestChildViewControllerFromDataSourceForPage:IFAScrollPageRightFar];
            break;
            
        case IFAScrollPageCentre:
            // does not initialise any child view controllers in this case
            break;
            
        default:
            NSAssert(NO, @"Unexpected selected page: %u", a_selectedPage);
            break;
            
    }
    
    //    [v_childViewControllerCentre m_willBecomeMainChildViewController];
    
    [self.pagingContainerChildViewControllers removeAllObjects];
    [self.pagingContainerChildViewControllers addObjectsFromArray:@[v_childViewControllerLeftFar, v_childViewControllerLeftNear, v_childViewControllerCentre, v_childViewControllerRightNear, v_childViewControllerRightFar]];
    v_selectedPage = IFAScrollPageCentre;
    
    // Update scroll view content and child view controllers
    //    NSLog(@"self.view.frame.size: %@", NSStringFromCGSize(self.view.frame.size));
    v_firstPageWithContent = NSNotFound;
    for (NSUInteger i=0, j=0; i<[self.pagingContainerChildViewControllers count]; i++) {
        
        id l_object = [self.pagingContainerChildViewControllers objectAtIndex:i];
        if (l_object!=[NSNull null]) {
            
            if (v_firstPageWithContent==NSNotFound) {
                v_firstPageWithContent = i;
            }
            IFAListViewController *l_viewController = (IFAListViewController *)l_object;
            
            [self addChildViewController:l_viewController]; // conform to the container view controller pattern
            [self.view addSubview:l_viewController.view];
            [l_viewController didMoveToParentViewController:self]; // conform to the container view controller pattern
            //            NSLog(@"added view for %@", [l_viewController description]);
            if (l_previousChildViewControllerCentre!=v_childViewControllerCentre && [l_viewController tableView:l_viewController.tableView numberOfRowsInSection:0]) {
                [l_viewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            
            if (l_viewController.staleData) {
                self.newChildViewControllerCount++;
            }
            
            j++;
            
        }
        
    }

    [self updateContentLayout];

    [self IFA_scrollToDynamicPage:v_selectedPage animated:NO];
    
    // Centre child view controller the only one to respond to "scroll to top" taps on status bar
    v_childViewControllerCentre.tableView.scrollsToTop = YES;
    
    self.scrollView.userInteractionEnabled = YES;
    
    v_performingScroll = NO;

    [self ifa_updateToolbarNavigationButtonState];
    
    //    [v_childViewControllerCentre m_didBecomeMainChildViewController];
    
    //    NSLog(@"*** finished updating container children");
    
}

-(UIViewController*)visibleChildViewController {
    return v_childViewControllerCentre;
}

@end
