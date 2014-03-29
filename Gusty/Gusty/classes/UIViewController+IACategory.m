//
//  UIViewController+IACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 16/11/11.
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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "IACommon.h"
#import "UIStoryboard+IACategory.h"
#import "IAExternalUrlManager.h"
#import "IAUISubjectActivityItem.h"
#import "IAUIExternalWebBrowserActivity.h"

//static UIPopoverArrowDirection  const k_arrowDirectionWithoutKeyboard   = UIPopoverArrowDirectionAny;
static UIPopoverArrowDirection  const k_arrowDirectionWithoutKeyboard   = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
static UIPopoverArrowDirection  const k_arrowDirectionWithKeyboard      = UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
static BOOL                     const k_animated                        = YES;

static const int k_iPhoneLandscapeAdHeight = 32;
static char c_presenterKey;
static char c_activePopoverControllerKey;
static char c_activePopoverControllerBarButtonItemKey;
static char c_subTitleKey;
static char c_slidingMenuBarButtonItemKey;
static char c_titleViewDefaultKey;
static char c_helpTargetIdKey;
static char c_titleViewLandscapePhoneKey;
static char c_changesMadeByPresentedViewControllerKey;
static char c_helpBarButtonItemKey;
static char c_adContainerViewKey;
static char c_refreshControlKey;
static char c_fetchedResultsControllerKey;

@interface UIViewController (IACategory_Private)

@property (nonatomic, strong) UIPopoverController *p_activePopoverController;
@property (nonatomic, strong) UIBarButtonItem *p_activePopoverControllerBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *p_slidingMenuBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *p_helpBarButtonItem;
@property (nonatomic) BOOL p_changesMadeByPresentedViewController;
@property (nonatomic, strong) NSFetchedResultsController *p_fetchedResultsController;

@end

@implementation UIViewController (IACategory)

#pragma mark - Private

-(void)m_presentModalSelectionViewController:(UIViewController*)a_viewController fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem fromRect:(CGRect)a_fromRect inView:(UIView *)a_view{

//    NSLog(@"m_presentModalSelectionViewController: %@", [a_viewController description]);

    UIViewController *l_viewController = [a_viewController isKindOfClass:[UIActivityViewController class]] ? a_viewController : [[[[self m_appearanceTheme] m_navigationControllerClass] alloc] initWithRootViewController:a_viewController];
//    NSLog(@"  l_viewController: %@", [l_viewController description]);

    if ([a_viewController m_hasFixedSize]) {
        CGFloat l_width = a_viewController.view.frame.size.width;
        CGFloat l_height = a_viewController.view.frame.size.height + a_viewController.navigationController.navigationBar.frame.size.height + (a_viewController.p_needsToolbar ? a_viewController.navigationController.toolbar.frame.size.height : 0);
        l_viewController.view.frame = CGRectMake(0, 0, l_width, l_height);
//        NSLog(@"  l_viewController.view.frame: %@", NSStringFromCGRect(l_viewController.view.frame));
//        NSLog(@"  a_viewController.view.frame: %@", NSStringFromCGRect(a_viewController.view.frame));
    }
    
    if ([self conformsToProtocol:@protocol(IAUIPresenter)]) {
        a_viewController.p_presenter = (id<IAUIPresenter>)self;
    }

    if ([IAUIUtils m_isIPad]) { // If iPad present controller in a popover
        
        // Instantiate and configure popover controller
        UIPopoverController *l_popoverController = [self m_newPopoverControllerWithContentViewController:l_viewController];
        
        // Set the delegate
        if ([a_viewController conformsToProtocol:@protocol(UIPopoverControllerDelegate)]) {
            l_popoverController.delegate = (id<UIPopoverControllerDelegate>)a_viewController;
        }
        
        // Set the content size
        if ([a_viewController isKindOfClass:[IAUIAbstractFieldEditorViewController class]]) {
            // Popover controllers "merge" the navigation bar from the navigation controller with its border at the top.
            // Therefore we need to reduce the content height by that amount otherwise a small gap is shown at the bottom of the popover view.
            // The same goes for the toolbar when it exists.
            CGFloat l_newHeight = l_viewController.view.frame.size.height - (l_popoverController.p_borderThickness * (a_viewController.p_needsToolbar ? 2 : 1));
            l_popoverController.popoverContentSize = CGSizeMake(l_viewController.view.frame.size.width, l_newHeight);
        }
        
        // Present popover controller
        if (a_fromBarButtonItem) {
            [self m_presentPopoverController:l_popoverController fromBarButtonItem:a_fromBarButtonItem];
        }else{
            [self m_presentPopoverController:l_popoverController fromRect:a_fromRect inView:a_view];
        }
        
    }else { // If not iPad present as modal
        
        if ([a_viewController m_hasFixedSize]) {
            [self presentSemiModalViewController:l_viewController];
        }else {
            if ([a_viewController isKindOfClass:[UIActivityViewController class]]) {
                [self presentViewController:a_viewController animated:YES completion:NULL];
            }else{
                [self m_presentModalViewController:a_viewController presentationStyle:UIModalPresentationFullScreen transitionStyle:UIModalTransitionStyleCoverVertical];
            }
        }
        
    }
    
}

-(UIViewController *)p_presentedViewController{
    if ([self isKindOfClass:[IAUIAbstractPagingContainerViewController class]]) {
        IAUIAbstractPagingContainerViewController *l_pagingContainerViewController = (IAUIAbstractPagingContainerViewController*)self;
        return l_pagingContainerViewController.p_selectedViewController.presentedViewController ? l_pagingContainerViewController.p_selectedViewController.presentedViewController : self.presentedViewController;
    }else{
        return self.presentedViewController;
    }
}

-(void)setP_activePopoverController:(UIPopoverController*)a_activePopoverController{
    objc_setAssociatedObject(self, &c_activePopoverControllerKey, a_activePopoverController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setP_activePopoverControllerBarButtonItem:(UIBarButtonItem*)a_activePopoverControllerBarButtonItem{
    objc_setAssociatedObject(self, &c_activePopoverControllerBarButtonItemKey, a_activePopoverControllerBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)m_setActivePopoverController:(UIPopoverController*)a_popoverController presenter:(UIViewController*)a_presenter barButtonItem:(UIBarButtonItem*)a_barButtonItem{
//    NSLog(@"a_popoverController.popoverContentSize: %@", NSStringFromCGSize(a_popoverController.popoverContentSize));
//    NSLog(@"a_popoverController.contentViewController.view.frame.size: %@", NSStringFromCGSize(a_popoverController.contentViewController.view.frame.size));
    self.p_activePopoverController = a_popoverController;
    [IAUIApplicationDelegate m_instance].p_popoverControllerPresenter = a_presenter;
    self.p_activePopoverControllerBarButtonItem = a_barButtonItem;
}

-(void)m_resizePopoverContent{
    UIPopoverController *l_popoverController = self.p_activePopoverController;
    UIViewController *l_contentViewController = l_popoverController.contentViewController;
    BOOL l_hasFixedSize =  [l_contentViewController isKindOfClass:[UINavigationController class]] ? [((UINavigationController*) l_contentViewController).topViewController m_hasFixedSize] : [l_contentViewController m_hasFixedSize];
    CGSize l_contentViewControllerSize = l_contentViewController.view.frame.size;
    if (l_hasFixedSize) {
        l_popoverController.popoverContentSize = l_contentViewControllerSize;
        NSLog(@"l_popoverController.popoverContentSize: %@", NSStringFromCGSize(l_popoverController.popoverContentSize));
    }
}

-(void)m_onMenuBarButtonItemInvalidated:(NSNotification*)a_notification{
//    NSLog(@"menu button invalidated - removing it...");
    [self m_removeLeftBarButtonItem:a_notification.object];
}

-(void)m_onSlidingMenuButtonAction:(UIBarButtonItem*)a_button{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)m_releaseViewForController:(UIViewController*)a_viewController{
//    NSLog(@"m_releaseViewForController: %@", [a_viewController description]);
    a_viewController.view = nil;
    a_viewController.p_previousVisibleViewController = nil;
    for (UIViewController *l_childViewController in a_viewController.childViewControllers) {
//        NSLog(@"   going to release view for child view controller: %@", [l_childViewController description]);
        [self m_releaseViewForController:l_childViewController];
    }
}

-(CGSize)m_gadAdFrameSize{
    CGFloat l_width, l_height;
    if ([IAUIUtils m_isIPad]) {
        l_width = self.view.frame.size.width;
        l_height = kGADAdSizeLeaderboard.size.height;
    }else{
        l_width = self.view.frame.size.width;
        l_height = [IAUIUtils isDeviceInLandscapeOrientation] ? k_iPhoneLandscapeAdHeight : kGADAdSizeBanner.size.height;
    }
    CGSize l_size = CGSizeMake(l_width, l_height);
//    NSLog(@"m_gadAdSize: %@", NSStringFromCGSize(l_size));
    return l_size;
}

-(GADAdSize)m_gadAdSize {
    return GADAdSizeFromCGSize([self m_gadAdFrameSize]);
}

-(GADBannerView *)m_gadBannerView{
    return [[IAUIApplicationDelegate m_instance] m_gadBannerView];
}

-(void)m_popViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)m_spaceBarButtonItems:(NSMutableArray*)a_items firstItemSpacingType:(IAUISpacingBarButtonItemType)a_firstItemSpacingType{
    
    if (![[self m_appearanceTheme] m_shouldAutomateBarButtonItemSpacingForViewController:self]) {
        return;
    }
    
    NSArray *l_items = [NSArray arrayWithArray:a_items];
    [a_items removeAllObjects];
    for (int i=0; i<l_items.count; i++) {
        UIBarButtonItem *l_spacingBarButtonItem;
        if (i==0) {
            l_spacingBarButtonItem = [[self m_appearanceTheme] m_spacingBarButtonItemForType:a_firstItemSpacingType viewController:self];
        }else{
            l_spacingBarButtonItem = [[self m_appearanceTheme] m_spacingBarButtonItemForType:IAUISpacingBarButtonItemTypeMiddle viewController:self];
        }
        if (l_spacingBarButtonItem) {
            [a_items addObject:l_spacingBarButtonItem];
        }
        [a_items addObject:l_items[i]];
    }
    
}

-(void)m_removeAutomatedSpacingFromBarButtonItemArray:(NSMutableArray*)a_items{
    
    if (![[self m_appearanceTheme] m_shouldAutomateBarButtonItemSpacingForViewController:self]) {
        return;
    }
    
    NSMutableArray *l_objectsToRemove = [NSMutableArray new];
    for (UIBarButtonItem *l_barButtonItem in a_items) {
        if (l_barButtonItem.tag==IA_UIBAR_ITEM_TAG_FIXED_SPACE_BUTTON) {
            [l_objectsToRemove addObject:l_barButtonItem];
        }
    }
    [a_items removeObjectsInArray:l_objectsToRemove];
    
}

- (void)m_showLeftSlidingPaneButtonIfRequired {
    if ([self m_shouldShowLeftSlidingPaneButton]) {
        if (self.slidingViewController) {
            self.navigationController.view.layer.shadowOpacity = 0.75f;
            self.navigationController.view.layer.shadowRadius = 10.0f;
            self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
            [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];

            BOOL l_shouldShowMenuButton = self.navigationController.topViewController==[self.navigationController.viewControllers objectAtIndex:0];
            if (l_shouldShowMenuButton) {
                if (!self.p_slidingMenuBarButtonItem) {
                    self.p_slidingMenuBarButtonItem = [[self m_appearanceTheme] m_slidingMenuBarButtonItemForViewController:self];
                    self.p_slidingMenuBarButtonItem.target = self;
                    self.p_slidingMenuBarButtonItem.action = @selector(m_onSlidingMenuButtonAction:);
                    self.p_slidingMenuBarButtonItem.tag = IA_UIBAR_ITEM_TAG_LEFT_SLIDING_PANE_BUTTON;
                }
                [self m_addToNavigationBarForSlidingMenuBarButtonItem:self.p_slidingMenuBarButtonItem];
            }
        }else if (self.splitViewController) {
            [self m_addLeftBarButtonItem:((IAUISplitViewController *) self.splitViewController).p_popoverControllerBarButtonItem];
        }
    }
}

- (void)m_updateAdContainerViewFrameWithAdBannerViewHeight:(CGFloat)a_adBannerViewHeight {
    UIView *l_adContainerView = self.p_adContainerView;
    CGRect l_newAdContainerViewFrame = l_adContainerView.frame;
    l_newAdContainerViewFrame.origin.y = self.view.frame.size.height - a_adBannerViewHeight;
    l_newAdContainerViewFrame.size.height = a_adBannerViewHeight;
    l_adContainerView.frame = l_newAdContainerViewFrame;
//    NSLog(@"adContainerView.frame 2: %@", NSStringFromCGRect(l_adContainerView.frame));
}

- (void)m_updateAdBannerSize {
//    NSLog(@"m_updateAdBannerSize");
    GADBannerView *l_bannerView = [self m_gadBannerView];
    CGRect l_newAdBannerViewFrame = CGRectZero;
    l_newAdBannerViewFrame.size = [self m_gadAdFrameSize];
    l_bannerView.frame = l_newAdBannerViewFrame;
//    NSLog(@"          l_bannerView.frame: %@", NSStringFromCGRect(l_bannerView.frame));
//    NSLog(@"self.p_adContainerView.frame: %@", NSStringFromCGRect(self.p_adContainerView.frame));
    l_bannerView.adSize = [self m_gadAdSize];
//    NSLog(@"    l_bannerView.adSize.size: %@", NSStringFromCGSize(l_bannerView.adSize.size));
//    NSLog(@"   l_bannerView.adSize.flags: %u", l_bannerView.adSize.flags);
}

// Determines the best presenting view controller for the situation.
//  For instance, a view controller set as the master view controller in a split view controller is not
//      the most appropriate view controller when presenting another view controller in portrait orientation.
//  If the device is rotated to landscape, the master view controller presented as a popover will be dismissed and so will
//      the presented view controller. In those case, it is better to present the view controller from the detail
//      view controller in the split view controller (which does not get dismissed if the device is rotated)
-(UIViewController*)m_appropriatePresentingViewController{
    BOOL l_shouldPresentingViewControllerBeSplitViewControllerDetail = NO;
    if (self.splitViewController) {
        UIViewController *l_masterViewController = self.splitViewController.viewControllers[0];
        if (l_masterViewController==self) {
            l_shouldPresentingViewControllerBeSplitViewControllerDetail = YES;
        }else if([l_masterViewController isKindOfClass:[UINavigationController class]]){
            UINavigationController *l_navigationController = (UINavigationController*)l_masterViewController;
            if (l_navigationController.topViewController==self) {
                l_shouldPresentingViewControllerBeSplitViewControllerDetail = YES;
            }
        }
    }
    return l_shouldPresentingViewControllerBeSplitViewControllerDetail ? self.splitViewController.viewControllers[1] : self;
}

#pragma mark - Public

-(void)setP_presenter:(id<IAUIPresenter>)a_presenter{
    objc_setAssociatedObject(self, &c_presenterKey, a_presenter, OBJC_ASSOCIATION_ASSIGN);
}

-(id<IAUIPresenter>)p_presenter{
    return objc_getAssociatedObject(self, &c_presenterKey);
}

-(UIPopoverController*)p_activePopoverController{
    return objc_getAssociatedObject(self, &c_activePopoverControllerKey);
}

-(UIBarButtonItem*)p_activePopoverControllerBarButtonItem{
    return objc_getAssociatedObject(self, &c_activePopoverControllerBarButtonItemKey);
}

-(NSString*)p_subTitle{
    return objc_getAssociatedObject(self, &c_subTitleKey);
}

-(void)setP_subTitle:(NSString*)a_subTitle{
    objc_setAssociatedObject(self, &c_subTitleKey, a_subTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(IAUINavigationItemTitleView*)p_titleViewDefault{
    return objc_getAssociatedObject(self, &c_titleViewDefaultKey);
}

-(void)setP_titleViewDefault:(IAUINavigationItemTitleView*)a_titleViewDefault{
    objc_setAssociatedObject(self, &c_titleViewDefaultKey, a_titleViewDefault, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)p_helpTargetId{
    return objc_getAssociatedObject(self, &c_helpTargetIdKey);
}

-(void)setP_helpTargetId:(NSString*)a_helpTargetId{
    objc_setAssociatedObject(self, &c_helpTargetIdKey, a_helpTargetId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(ODRefreshControl*)p_refreshControl{
    return objc_getAssociatedObject(self, &c_refreshControlKey);
}

-(void)setP_refreshControl:(ODRefreshControl*)a_refreshControl{
    objc_setAssociatedObject(self, &c_refreshControlKey, a_refreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIBarButtonItem*)p_helpBarButtonItem{
    return objc_getAssociatedObject(self, &c_helpBarButtonItemKey);
}

-(void)setP_helpBarButtonItem:(UIBarButtonItem*)a_helpBarButtonItem{
    objc_setAssociatedObject(self, &c_helpBarButtonItemKey, a_helpBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSFetchedResultsController*)p_fetchedResultsController{
    return objc_getAssociatedObject(self, &c_fetchedResultsControllerKey);
}

-(void)setP_fetchedResultsController:(NSFetchedResultsController*)a_fetchedResultsController{
    objc_setAssociatedObject(self, &c_fetchedResultsControllerKey, a_fetchedResultsController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView*)p_adContainerView{

    UIView *l_adContainerView = objc_getAssociatedObject(self, &c_adContainerViewKey);

    if (!l_adContainerView && [self m_shouldEnableAds]) {
        
        // Create ad container
        CGSize l_gadAdFrameSize = [self m_gadAdFrameSize];
        CGFloat l_adContainerViewX = 0;
        CGFloat l_adContainerViewY = self.view.frame.size.height-l_gadAdFrameSize.height;
        CGFloat l_adContainerViewWidth = self.view.frame.size.width;
        CGFloat l_adContainerViewHeight = l_gadAdFrameSize.height;
        CGRect l_adContainerViewFrame = CGRectMake(l_adContainerViewX, l_adContainerViewY, l_adContainerViewWidth, l_adContainerViewHeight);
        l_adContainerView = [[UIView alloc] initWithFrame:l_adContainerViewFrame];
//        NSLog(@"adContainerView.frame 1: %@", NSStringFromCGRect(l_adContainerView.frame));
        l_adContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        
        // Add shadow
        l_adContainerView.layer.masksToBounds = NO;
        l_adContainerView.layer.shadowOffset = CGSizeMake(0, 2);
        l_adContainerView.layer.shadowOpacity = 1;

        self.p_adContainerView = l_adContainerView;
    
    }

    return l_adContainerView;

}

-(void)setP_adContainerView:(UIView*)a_adContainerView{
    objc_setAssociatedObject(self, &c_adContainerViewKey, a_adContainerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)p_changesMadeByPresentedViewController{
    return ((NSNumber*)objc_getAssociatedObject(self, &c_changesMadeByPresentedViewControllerKey)).boolValue;
}

-(void)setP_changesMadeByPresentedViewController:(BOOL)a_changesMadeByPresentedViewController{
    objc_setAssociatedObject(self, &c_changesMadeByPresentedViewControllerKey, @(a_changesMadeByPresentedViewController), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(IAUINavigationItemTitleView*)p_titleViewLandscapePhone{
    return objc_getAssociatedObject(self, &c_titleViewLandscapePhoneKey);
}

-(void)setP_titleViewLandscapePhone:(IAUINavigationItemTitleView*)a_titleViewLandscapePhone{
    objc_setAssociatedObject(self, &c_titleViewLandscapePhoneKey, a_titleViewLandscapePhone, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)p_slidingMenuBarButtonItem{
    return objc_getAssociatedObject(self, &c_slidingMenuBarButtonItemKey);
}

-(void)setP_slidingMenuBarButtonItem:(NSString*)a_slidingMenuBarButtonItem{
    objc_setAssociatedObject(self, &c_slidingMenuBarButtonItemKey, a_slidingMenuBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)m_addLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem{
    [self m_insertLeftBarButtonItem:a_barButtonItem atIndex:NSNotFound];
}

-(void)m_insertLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem atIndex:(NSUInteger)a_index{

    if (!a_barButtonItem) {
        return;
    }
    UINavigationItem *l_navigationItem = [self m_navigationItem];
    NSMutableArray *l_leftBarButtonItems = [l_navigationItem.leftBarButtonItems mutableCopy];

    BOOL l_fixedPositionItem = a_barButtonItem.tag==IA_UIBAR_ITEM_TAG_BACK_BUTTON || a_barButtonItem.tag== IA_UIBAR_ITEM_TAG_LEFT_SLIDING_PANE_BUTTON;
    if (![l_navigationItem.leftBarButtonItems containsObject:a_barButtonItem] || l_fixedPositionItem) {
        
        if (l_leftBarButtonItems) {
            [self m_removeAutomatedSpacingFromBarButtonItemArray:l_leftBarButtonItems];
        }else{
            l_leftBarButtonItems = [NSMutableArray new];
        }

        if (a_barButtonItem.tag) {
            // Remove any existing instance with a matching tag
            for (UIBarButtonItem *l_barButtonItem in l_navigationItem.leftBarButtonItems) {
                if (l_barButtonItem.tag==a_barButtonItem.tag) {
                    [l_leftBarButtonItems removeObject:l_barButtonItem];
                }
            }
        }
        if (a_index==NSNotFound) {
            [l_leftBarButtonItems addObject:a_barButtonItem];
            // Prioritise certain bar button items
            UIBarButtonItem *l_backBarButtonItem, *l_leftSlidingPane;
            for (UIBarButtonItem *l_barButtonItem in l_leftBarButtonItems) {
                switch (l_barButtonItem.tag) {
                    case IA_UIBAR_ITEM_TAG_BACK_BUTTON:
                        l_backBarButtonItem = l_barButtonItem;
                        break;
                    case IA_UIBAR_ITEM_TAG_LEFT_SLIDING_PANE_BUTTON:
                        l_leftSlidingPane = l_barButtonItem;
                        break;
                    default:
                        // does nothing
                        break;
                }
            }
            [l_leftBarButtonItems removeObject:l_backBarButtonItem];
            [l_leftBarButtonItems removeObject:l_leftSlidingPane];
            if (l_leftSlidingPane) {
                [l_leftBarButtonItems insertObject:l_leftSlidingPane atIndex:0];
            }
            if (l_backBarButtonItem) {
                [l_leftBarButtonItems insertObject:l_backBarButtonItem atIndex:0];
            }
        }else{
            [l_leftBarButtonItems insertObject:a_barButtonItem atIndex:a_index];
        }

        // Bar button item spacing automation
        [self m_spaceBarButtonItems:l_leftBarButtonItems firstItemSpacingType:IAUISpacingBarButtonItemTypeLeft];

        [l_navigationItem setLeftBarButtonItems:l_leftBarButtonItems animated:NO];
//        NSLog(@"m_insertLeftBarButtonItem - button inserted for %@, tag: %u, navigationItem.title: %@: %@", [self description], a_barButtonItem.tag, l_navigationItem.title, [l_navigationItem.leftBarButtonItems description]);

    }

}

-(void)m_removeLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem{

    if (!a_barButtonItem) {
        return;
    }

    UINavigationItem *l_navigationItem = [self m_navigationItem];
    NSMutableArray *l_leftBarButtonItems = [l_navigationItem.leftBarButtonItems mutableCopy];
    if (l_leftBarButtonItems) {
        [self m_removeAutomatedSpacingFromBarButtonItemArray:l_leftBarButtonItems];
        [l_leftBarButtonItems removeObject:a_barButtonItem];
        [self m_spaceBarButtonItems:l_leftBarButtonItems firstItemSpacingType:IAUISpacingBarButtonItemTypeLeft];
        [l_navigationItem setLeftBarButtonItems:l_leftBarButtonItems animated:NO];
//        NSLog(@"m_removeLeftBarButtonItem - button removed for %@: %@", l_navigationItem.title, [l_navigationItem.leftBarButtonItems description]);
    }

}

-(void)m_addRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem{
    [self m_insertRightBarButtonItem:a_barButtonItem atIndex:NSNotFound];
}

-(void)m_insertRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem atIndex:(NSUInteger)a_index{

    if (!a_barButtonItem) {
        return;
    }

    UINavigationItem *l_navigationItem = [self m_navigationItem];
    NSMutableArray *l_rightBarButtonItems = [l_navigationItem.rightBarButtonItems mutableCopy];
    if (![l_navigationItem.rightBarButtonItems containsObject:a_barButtonItem]) {

        if (l_rightBarButtonItems) {
            [self m_removeAutomatedSpacingFromBarButtonItemArray:l_rightBarButtonItems];
        }else{
            l_rightBarButtonItems = [NSMutableArray new];
        }

        if (a_barButtonItem.tag) {
            // Remove any existing instance with a matching tag
            for (UIBarButtonItem *l_barButtonItem in l_navigationItem.rightBarButtonItems) {
                if (l_barButtonItem.tag==a_barButtonItem.tag) {
                    [l_rightBarButtonItems removeObject:l_barButtonItem];
                }
            }
        }
        if (a_index==NSNotFound) {
            [l_rightBarButtonItems addObject:a_barButtonItem];
        }else{
            [l_rightBarButtonItems insertObject:a_barButtonItem atIndex:a_index];
        }
        
        // Bar button item spacing automation
        [self m_spaceBarButtonItems:l_rightBarButtonItems firstItemSpacingType:IAUISpacingBarButtonItemTypeRight];

        [l_navigationItem setRightBarButtonItems:l_rightBarButtonItems animated:NO];
        //        NSLog(@"m_insertRightBarButtonItem - button inserted for %@, navigationItem.title: %@: %@", [self description], l_navigationItem.title, [l_navigationItem.rightBarButtonItems description]);

    }

}

-(void)m_removeRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem{

    if (!a_barButtonItem) {
        return;
    }

    UINavigationItem *l_navigationItem = [self m_navigationItem];
    NSMutableArray *l_rightBarButtonItems = [l_navigationItem.rightBarButtonItems mutableCopy];
    if (l_rightBarButtonItems) {
        [self m_removeAutomatedSpacingFromBarButtonItemArray:l_rightBarButtonItems];
        [l_rightBarButtonItems removeObject:a_barButtonItem];
        [self m_spaceBarButtonItems:l_rightBarButtonItems firstItemSpacingType:IAUISpacingBarButtonItemTypeRight];
        [l_navigationItem setRightBarButtonItems:l_rightBarButtonItems animated:NO];
        //        NSLog(@"m_removeRightBarButtonItem - button removed for %@: %@", l_navigationItem.title, [l_navigationItem.rightBarButtonItems description]);
    }

}

-(BOOL)p_isMasterViewController{
    return [self.splitViewController.viewControllers objectAtIndex:0]==self.navigationController && self.navigationController.viewControllers[0]==self;
}

-(BOOL)p_isDetailViewController{
    return [self.splitViewController.viewControllers objectAtIndex:1]==self.navigationController && self.navigationController.viewControllers[0]==self;
}

-(NSString*)m_helpTargetIdForName:(NSString*)a_name{
    return [NSString stringWithFormat:@"controllers.%@.%@", [[self class] description], a_name];
}

-(BOOL)p_presentedAsModal{
    //    NSLog(@"presentingViewController: %@, presentedViewController: %@, self: %@, topViewController: %@, visibleViewController: %@, viewController[0]: %@, navigationController.parentViewController: %@, parentViewController: %@, presentedAsSemiModal: %u", [self.presentingViewController description], [self.presentedViewController description], [self description], self.navigationController.topViewController, self.navigationController.visibleViewController, [self.navigationController.viewControllers objectAtIndex:0], self.navigationController.parentViewController, self.parentViewController, self.p_presentedAsSemiModal);
    return [IAUIApplicationDelegate m_instance].p_popoverControllerPresenter.p_activePopoverController.contentViewController==self.navigationController || ( self.navigationController.presentingViewController!=nil && [self.navigationController.viewControllers objectAtIndex:0]==self) || self.parentViewController.p_presentedAsSemiModal || [[IAUIApplicationDelegate m_instance].p_popoverControllerPresenter.p_activePopoverController.contentViewController isKindOfClass:[UIActivityViewController class]];
}

- (void)m_updateToolbarForMode:(BOOL)anEditModeFlag animated:(BOOL)anAnimatedFlag{
//    NSLog(@" ");
//    NSLog(@"toolbar items before: %@", [self.toolbarItems description]);
    if(self.p_manageToolbar || anEditModeFlag){
        NSArray *toolbarItems = anEditModeFlag ? [self m_editModeToolbarItems] : [self m_nonEditModeToolbarItems];
//        NSLog(@"self.navigationController.toolbar: %@", [self.navigationController.toolbar description]);
//        NSLog(@" self.navigationController.toolbarHidden: %u, animated: %u", self.navigationController.toolbarHidden, anAnimatedFlag);
        [self.navigationController setToolbarHidden:(![toolbarItems count]) animated:anAnimatedFlag];
//        NSLog(@" self.navigationController.toolbarHidden: %u", self.navigationController.toolbarHidden);
        if ([toolbarItems count]) {
            if (self.p_manageToolbar) {
                if (![self.toolbarItems isEqualToArray:toolbarItems]) {
                    [self setToolbarItems:toolbarItems animated:anAnimatedFlag];
                }
            }else{
                if (![self.parentViewController.toolbarItems isEqualToArray:toolbarItems]) {
                    [self.parentViewController setToolbarItems:toolbarItems animated:anAnimatedFlag];
                }
            }
        }
    }else{
        [self.navigationController setToolbarHidden:(![self.toolbarItems count]) animated:anAnimatedFlag];
    }
//    NSLog(@"toolbar items after: %@", [self.toolbarItems description]);
}

-(BOOL)m_hasFixedSize{
    return NO;
}

-(void)m_presentPopoverController:(UIPopoverController*)a_popoverController fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem{
    [self m_setActivePopoverController:a_popoverController presenter:self barButtonItem:a_fromBarButtonItem];
    [self m_resizePopoverContent];
    [a_popoverController presentPopoverFromBarButtonItem:a_fromBarButtonItem
                                permittedArrowDirections:[self m_permittedPopoverArrowDirectionForViewController:nil ]
                                                animated:k_animated];
    __weak UIViewController *l_weakSelf = self;
    [IAUtils m_dispatchAsyncMainThreadBlock:^{
        [l_weakSelf m_didPresentPopoverController:a_popoverController];
    }];
}

-(void)m_presentPopoverController:(UIPopoverController*)a_popoverController fromRect:(CGRect)a_fromRect inView:(UIView *)a_view{
    [self m_setActivePopoverController:a_popoverController presenter:self barButtonItem:nil];
    [self m_resizePopoverContent];
    [a_popoverController presentPopoverFromRect:a_fromRect inView:a_view
                       permittedArrowDirections:[self m_permittedPopoverArrowDirectionForViewController:nil ] animated:k_animated];
    __weak UIViewController *l_weakSelf = self;
    [IAUtils m_dispatchAsyncMainThreadBlock:^{
        [l_weakSelf m_didPresentPopoverController:a_popoverController];
    }];
}

-(void)m_didPresentPopoverController:(UIPopoverController*)a_popoverController{
    // Remove the navigation bar or toolbar that owns the button from the passthrough view list
    a_popoverController.passthroughViews = nil;
}

-(void)m_presentModalFormViewController:(UIViewController*)a_viewController{
    [self m_presentModalViewController:a_viewController presentationStyle:UIModalPresentationPageSheet transitionStyle:UIModalTransitionStyleCoverVertical];
}

-(void)m_presentModalSelectionViewController:(UIViewController*)a_viewController fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem{
    [self m_presentModalSelectionViewController:a_viewController fromBarButtonItem:a_fromBarButtonItem fromRect:CGRectZero inView:nil];
}

-(void)m_presentModalSelectionViewController:(UIViewController*)a_viewController fromRect:(CGRect)a_fromRect inView:(UIView *)a_view{
    [self m_presentModalSelectionViewController:a_viewController fromBarButtonItem:nil fromRect:a_fromRect inView:a_view];
}

-(void)m_presentModalViewController:(UIViewController*)a_viewController presentationStyle:(UIModalPresentationStyle)a_presentationStyle transitionStyle:(UIModalTransitionStyle)a_transitionStyle{
    [self m_presentModalViewController:a_viewController presentationStyle:a_presentationStyle transitionStyle:a_transitionStyle shouldAddDoneButton:NO];
}

- (void)m_presentModalViewController:(UIViewController *)a_viewController
                   presentationStyle:(UIModalPresentationStyle)a_presentationStyle
                     transitionStyle:(UIModalTransitionStyle)a_transitionStyle
                 shouldAddDoneButton:(BOOL)a_shouldAddDoneButton {
    [self m_presentModalViewController:a_viewController
                     presentationStyle:a_presentationStyle
                       transitionStyle:a_transitionStyle
                   shouldAddDoneButton:a_shouldAddDoneButton
                            customSize:CGSizeZero];
}

- (void)m_presentModalViewController:(UIViewController *)a_viewController
                   presentationStyle:(UIModalPresentationStyle)a_presentationStyle
                     transitionStyle:(UIModalTransitionStyle)a_transitionStyle
                 shouldAddDoneButton:(BOOL)a_shouldAddDoneButton
                          customSize:(CGSize)a_customSize{
    UIViewController *l_presentingViewController = [self m_appropriatePresentingViewController];
    if ([l_presentingViewController conformsToProtocol:@protocol(IAUIPresenter)]) {
        a_viewController.p_presenter = (id <IAUIPresenter>) l_presentingViewController;
        if (a_shouldAddDoneButton) {
            UIBarButtonItem *l_barButtonItem = [[l_presentingViewController m_appearanceTheme] m_doneBarButtonItemWithTarget:a_viewController
                                                                                                                      action:@selector(m_onDoneButtonTap:)
                                                                                                              viewController:a_viewController];
            [a_viewController m_addLeftBarButtonItem:l_barButtonItem];
        }
    }
    id <IAUIAppearanceTheme> l_appearanceTheme = [self m_appearanceTheme];
    Class l_navigationControllerClass = [l_appearanceTheme m_navigationControllerClass];
    IAUINavigationController *l_navigationController = [[l_navigationControllerClass alloc] initWithRootViewController:a_viewController];
    l_navigationController.modalPresentationStyle = a_presentationStyle;
    l_navigationController.modalTransitionStyle = a_transitionStyle;
    [l_presentingViewController presentViewController:l_navigationController animated:YES completion:^{
        [a_viewController.p_presenter m_didPresentViewController:l_navigationController];
    }];
    if (a_customSize.width && a_customSize.height) {
        l_navigationController.view.superview.backgroundColor = [UIColor clearColor];
        l_navigationController.view.bounds = CGRectMake(0, 0, a_customSize.width, a_customSize.height + l_navigationController.navigationBar.frame.size.height);
    }
}

- (void)m_notifySessionCompletionWithChangesMade:(BOOL)a_changesMade data:(id)a_data {
    [self.p_presenter m_sessionDidCompleteForViewController:self changesMade:a_changesMade data:a_data ];
}

-(void)m_notifySessionCompletion{
    [self m_notifySessionCompletionWithChangesMade:NO data:nil ];
}

- (void)m_dismissModalViewControllerWithChangesMade:(BOOL)a_changesMade data:(id)a_data {
    if (self.presentedViewController) {
        __weak UIViewController *l_weakSelf = self;
        UIViewController *l_presentedViewController = self.presentedViewController; // Add retain cycle
        [self dismissViewControllerAnimated:YES completion:^{
            if ([l_weakSelf conformsToProtocol:@protocol(IAUIPresenter)]) {
                [l_weakSelf m_didDismissViewController:l_presentedViewController changesMade:a_changesMade data:a_data];
            }
        }];
    }else if(self.p_activePopoverController){
        [self.p_activePopoverController dismissPopoverAnimated:YES];
        [self m_resetActivePopoverController];
    }else if(self.p_presentingSemiModal){
        [self dismissSemiModalViewWithChangesMade:a_changesMade data:a_data];
    }else{
        NSAssert(NO, @"No modal view controller to dismiss");
    }
}

-(IAAsynchronousWorkManager*)p_aom{
    return [IAAsynchronousWorkManager instance];
}

-(void)m_dismissMenuPopoverController{
    [self m_dismissMenuPopoverControllerWithAnimation:YES];
}

-(void)m_dismissMenuPopoverControllerWithAnimation:(BOOL)a_animated{
    // Dismiss the popover controller if a split view controller is used and this controller is not presented as modal
    if (!self.p_presentedAsModal) {
        [((IAUISplitViewController*)self.splitViewController).p_popoverController dismissPopoverAnimated:a_animated];
    }
}

-(void)m_resetActivePopoverController{
    [self m_setActivePopoverController:nil presenter:nil barButtonItem:nil];
}

-(void)m_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self m_dismissMenuPopoverController];
}

-(id<IAUIAppearanceTheme>)m_appearanceTheme{
    return [[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme];
}

// To be overriden by subclasses
-(BOOL)p_manageToolbar{
    return YES;
}

// To be overriden by subclasses
-(UIViewController*)p_previousVisibleViewController{
    return nil;
}

// To be overriden by subclasses
-(BOOL)p_doneButtonSaves{
    return NO;
}

// To be overriden by subclasses
-(void)setP_previousVisibleViewController:(UIViewController *)p_previousVisibleViewController{
}

// To be overriden by subclasses
- (NSArray*)m_editModeToolbarItems{
	return nil;
}

// To be overriden by subclasses
- (NSArray*)m_nonEditModeToolbarItems{
	return nil;
}

// To be overriden by subclasses
-(void)m_updateScreenDecorationState{
}

// To be overriden by subclasses
-(void)m_updateNavigationItemState{
}

// To be overriden by subclasses
-(void)m_updateToolbarNavigationButtonState{
}

// To be overriden by subclasses
- (void)m_onApplicationWillEnterForegroundNotification:(NSNotification*)aNotification{
}

// To be overriden by subclasses
- (void)m_onApplicationDidBecomeActiveNotification:(NSNotification*)aNotification{
}

// To be overriden by subclasses
- (void)m_onApplicationWillResignActiveNotification:(NSNotification*)aNotification{
}

- (void)m_onAdsSuspendRequest:(NSNotification*)aNotification{
    [self m_stopAdRequests];
}

- (void)m_onAdsResumeRequest:(NSNotification*)aNotification{
    if ([self m_shouldEnableAds]) {
        [self m_startAdRequests];
    }
}

-(void)m_dealloc{
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IA_NOTIFICATION_MENU_BAR_BUTTON_ITEM_INVALIDATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

// To be overriden by subclasses
-(UIView*)m_nonAdContainerView{
    return nil;
}

// To be overriden by subclasses
-(BOOL)m_shouldEnableAds{
    return NO;
}

-(UIBarButtonItem*)m_editBarButtonItem{
    if ([self isKindOfClass:[IAUIDynamicPagingContainerViewController class]]) {
        IAUIDynamicPagingContainerViewController *l_containerViewController = (IAUIDynamicPagingContainerViewController*)self;
        return [l_containerViewController m_visibleChildViewController].editButtonItem;
    }else{
        return self.editButtonItem;
    }
}

//-(void)m_updateEditButtonItemAccessibilityLabel{
//    [self m_editBarButtonItem].accessibilityLabel = self.editing ? @"Done Button" : @"Edit Button";
//}

- (void)m_viewDidLoad{
    
//    NSLog(@"m_viewDidLoad: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
    
//    [self m_updateEditButtonItemAccessibilityLabel];

    UINavigationItem *l_navigationItem = [self m_navigationItem];
    l_navigationItem.leftItemsSupplementBackButton = YES;
    UIBarButtonItem *l_backBarButtonItem = [[self m_appearanceTheme] m_backBarButtonItemForViewController:self];
    l_navigationItem.backBarButtonItem = l_backBarButtonItem;
    if (l_backBarButtonItem.customView && self.navigationController.topViewController==self && self.navigationController.viewControllers.count>1) {
        l_navigationItem.hidesBackButton = YES;
        l_backBarButtonItem.tag = IA_UIBAR_ITEM_TAG_BACK_BUTTON;
        l_backBarButtonItem.target = self;
        l_backBarButtonItem.action = @selector(m_popViewController);
        [self m_addLeftBarButtonItem:l_backBarButtonItem];
    }

    // Configure help button
    if ([[IAHelpManager m_instance] m_isHelpEnabledForViewController:self]) {
        self.p_helpBarButtonItem = [[IAHelpManager m_instance] m_newHelpBarButtonItem];
    }else{
        self.p_helpBarButtonItem = nil;
    }
    
    // Set appearance
    [[[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme] m_setAppearanceOnViewDidLoadForViewController:self];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(m_onMenuBarButtonItemInvalidated:) 
                                                 name:IA_NOTIFICATION_MENU_BAR_BUTTON_ITEM_INVALIDATED 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onApplicationWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    // Configure fetched results controller and perform fetch
    [self m_configureFetchedResultsControllerAndPerformFetch];

}

-(void)m_viewDidUnload{

    //    NSLog(@"m_viewDidUnload: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IA_NOTIFICATION_MENU_BAR_BUTTON_ITEM_INVALIDATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

    self.p_fetchedResultsController = nil;

}

- (void)m_viewWillAppear{
    
//    NSLog(@"m_viewWillAppear: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
    
    // Add the help button if help is enabled for this view controller
    if (self.p_helpBarButtonItem) {
        if ([self isKindOfClass:[IAUIAbstractFieldEditorViewController class]] || [self isKindOfClass:[IAUIMultiSelectionListViewController class]]) {
            if ([self isKindOfClass:[IAUIAbstractFieldEditorViewController class]] ) {
                CGRect l_customViewFrame = self.p_helpBarButtonItem.customView.frame;
                self.p_helpBarButtonItem.customView.frame = CGRectMake(l_customViewFrame.origin.x, l_customViewFrame.origin.y, 34, self.navigationController.navigationBar.frame.size.height);
            }
            [self m_addLeftBarButtonItem:self.p_helpBarButtonItem];
        }else{
            [self m_insertRightBarButtonItem:self.p_helpBarButtonItem atIndex:0];
        }
    }
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onApplicationDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onApplicationWillResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onAdsSuspendRequest:)
                                                 name:IA_NOTIFICATION_ADS_SUSPEND_REQUEST
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onAdsResumeRequest:)
                                                 name:IA_NOTIFICATION_ADS_RESUME_REQUEST
                                               object:nil];
    
    if (self.p_manageToolbar && [self.navigationController.viewControllers count]==1 && ![self m_isReturningVisibleViewController]) {
        //            NSLog(@"About to call m_updateToolbarForMode in m_viewWillAppear...");
        [self m_updateToolbarForMode:self.editing animated:NO];
    }

    // Manage left sliding menu button visibility
    [self m_showLeftSlidingPaneButtonIfRequired];

    // Set appearance
    [[[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme] m_setAppearanceOnViewWillAppearForViewController:self];

    // Configure help target
    [self m_registerForHelp];

}

- (BOOL)m_shouldShowLeftSlidingPaneButton {
    BOOL l_shouldShowIt = NO;
    if (self.slidingViewController) {
        l_shouldShowIt = self.slidingViewController.topViewController==self.navigationController && self.navigationController.viewControllers[0]==self;
    }else if (self.splitViewController) {
        l_shouldShowIt = [self p_isDetailViewController];
    }
//    NSLog(@"  [self m_shouldShowLeftSlidingPaneButton] for %@: %u", [self description], l_shouldShowIt);
    return l_shouldShowIt;
}

- (void)m_addToNavigationBarForSlidingMenuBarButtonItem:(UIBarButtonItem *)a_slidingMenuBarButtonItem {
    [self m_insertLeftBarButtonItem:a_slidingMenuBarButtonItem atIndex:0];
}

- (void)m_viewDidAppear{
    
//    NSLog(@"m_viewDidAppear: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
    
    if ([self m_shouldEnableAds]) {
        [self m_startAdRequests];
    }
    
    if (self.p_manageToolbar && !([self.navigationController.viewControllers count]==1 && ![self m_isReturningVisibleViewController]) ) {
        //            NSLog(@"About to call m_updateToolbarForMode in m_viewDidAppear...");
        [self m_updateToolbarForMode:self.editing animated:YES];
    }
    
}

- (void)m_viewWillDisappear{
    
//    NSLog(@"m_viewWillDisappear: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
        
    self.p_previousVisibleViewController = self.navigationController.visibleViewController;
    
}

- (void)m_viewDidDisappear{
    
//    NSLog(@"m_viewDidDisappear: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
        
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IA_NOTIFICATION_ADS_SUSPEND_REQUEST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IA_NOTIFICATION_ADS_RESUME_REQUEST object:nil];
    
    if (self.p_manageToolbar && [self.toolbarItems count]>0) {
        self.toolbarItems = @[];
    }
    
    // Remove ad container
    if ([self m_shouldEnableAds]) {
        [self m_stopAdRequests];
    }
    
//    [self m_simulateMemoryWarning];
    
}

-(BOOL)m_isReturningVisibleViewController{
//    NSLog(@"m_isReturningTopViewController: %@, p_previousVisibleViewController: %@", self, self.p_previousVisibleViewController);
    if ([self.parentViewController isKindOfClass:[IAUIAbstractPagingContainerViewController class]]) {
        return [((IAUIAbstractPagingContainerViewController*)self.parentViewController) m_isReturningVisibleViewController];
    }else {
        return self.p_previousVisibleViewController && self!=self.p_previousVisibleViewController && ![self.p_previousVisibleViewController isKindOfClass:[IAUIMenuViewController class]];
    }
}

//-(BOOL)m_isLeavingVisibleViewController{
////    NSLog(@"m_isLeavingTopViewController: %@, p_previousVisibleViewController: %@", self, self.p_previousVisibleViewController);
//    return self.p_previousVisibleViewController && self!=self.p_previousVisibleViewController;
//}

-(UIView*)m_viewForActionSheet{
    return [IAUIUtils actionSheetShowInViewForViewController:self];
}

-(UIViewController*)m_mainViewController{
    if (((UIViewController*)[self.navigationController.viewControllers objectAtIndex:0]).p_presentedAsModal) {
        return self.navigationController;
    }else{
        return [UIApplication sharedApplication].delegate.window.rootViewController;
    }
}

// iOS 5 (the next method is for iOS 6 or greater)
-(BOOL)m_shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    BOOL l_shouldAutorotate = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        l_shouldAutorotate = YES;
    }else{
        l_shouldAutorotate = toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    if (l_shouldAutorotate) {
        if ([IAUIApplicationDelegate m_instance].p_semiModalViewController) {
            l_shouldAutorotate = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) == UIInterfaceOrientationIsLandscape([IAUIApplicationDelegate m_instance].p_semiModalInterfaceOrientation);
        }
    }
    return l_shouldAutorotate;
}

// iOS 6 or greater (the previous method is for iOS 5)
-(NSUInteger)m_supportedInterfaceOrientations{
    if ([IAUIApplicationDelegate m_instance].p_semiModalViewController) {
        if (UIInterfaceOrientationIsLandscape([IAUIApplicationDelegate m_instance].p_semiModalInterfaceOrientation)) {
            return UIInterfaceOrientationMaskLandscape;
        }else{
            return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown : UIInterfaceOrientationMaskPortrait;
        }
    }else{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            return UIInterfaceOrientationMaskAll;
        }else{
            return UIInterfaceOrientationMaskAllButUpsideDown;
        }
    }
}

-(void)m_willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    // Tell help manager about the interface orientation change
    if (self.p_helpMode && [IAHelpManager m_instance].p_observedHelpTargetContainer==self) {
        [[IAHelpManager m_instance] m_observedViewControllerWillRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }

    [[[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme] m_setAppearanceOnWillRotateForViewController:self toInterfaceOrientation:toInterfaceOrientation];

}

- (void)m_willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{

    [[[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme] m_setAppearanceOnWillAnimateRotationForViewController:self interfaceOrientation:interfaceOrientation];

    if ([self m_shouldEnableAds]) {
        [self m_stopAdRequests];
    }

}

-(void)m_didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    // Tell help manager about the interface orientation change
    if (self.p_helpMode && [IAHelpManager m_instance].p_observedHelpTargetContainer==self) {
        [[IAHelpManager m_instance] m_observedViewControllerDidRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
    
    if (self.p_activePopoverController && self.p_activePopoverControllerBarButtonItem) {
        
        // Present popover controller in the new interface orientation
        // Also need to reset content size as iOS will attempt to resize it automatically due to the fact the popover was triggered by a bar button item
        [self m_presentPopoverController:self.p_activePopoverController fromBarButtonItem:self.p_activePopoverControllerBarButtonItem];
        
    }
    
    // Hide ad container (but it should be offscreen at this point)
    self.p_adContainerView.hidden = YES;

    if ([self m_shouldEnableAds]) {
        [self m_startAdRequests];
    }

}

-(BOOL)p_needsToolbar{
    return [(self.editing ? [self m_editModeToolbarItems] : [self m_nonEditModeToolbarItems]) count] > 0;
}

-(BOOL)p_helpMode{
    return [IAHelpManager m_instance].p_helpMode;
}

-(UIStoryboard*)m_commonStoryboard{
    static NSString * const k_storyboardName = @"CommonStoryboard";
    return [UIStoryboard storyboardWithName:k_storyboardName bundle:[[self m_appearanceTheme] m_bundle]];
}

-(void)m_reset{
    self.p_previousVisibleViewController = nil;
}

-(UINavigationItem*)m_navigationItem{
    if ([self.parentViewController isKindOfClass:[IAUIAbstractPagingContainerViewController class]] || [self.parentViewController isKindOfClass:[UITabBarController class]]) {
        return self.parentViewController.navigationItem;
    }else{
        return self.navigationItem;
    }
}

-(void)m_registerForHelp{
    if (![self.parentViewController isKindOfClass:[IAUIAbstractPagingContainerViewController class]]) {
        UIViewController *l_helpTargetViewController = [[IAHelpManager m_instance] m_isHelpEnabledForViewController:self] ? self : nil;
        [[IAHelpManager m_instance] m_observeHelpTargetContainer:l_helpTargetViewController];
    }
}

-(NSString*)m_editBarButtonItemHelpTargetId{
    NSString *l_helpTargetId = nil;
    if (self.editing) {
        BOOL l_doneButtonSaves = self.p_doneButtonSaves;
        if ([self isKindOfClass:[IAUIDynamicPagingContainerViewController class]]) {
            IAUIDynamicPagingContainerViewController *l_pagingContainerViewController = (IAUIDynamicPagingContainerViewController*)self;
            l_doneButtonSaves = [l_pagingContainerViewController m_visibleChildViewController].p_doneButtonSaves;
        }
        if (l_doneButtonSaves) {
            l_helpTargetId = [IAUIUtils m_helpTargetIdForName:@"saveButton"];
        }else{
            l_helpTargetId = [IAUIUtils m_helpTargetIdForName:@"doneButton"];
        }
    }else{
        l_helpTargetId = [IAUIUtils m_helpTargetIdForName:@"editButton"];
    }
    return l_helpTargetId;
}

-(void)m_openUrl:(NSURL*)a_url{
    [[IAExternalUrlManager m_instance] m_openUrl:a_url];
}

-(void)m_releaseView{
    [self m_releaseViewForController:self];
}

-(NSString*)m_accessibilityLabelForKeyPath:(NSString*)a_keyPath{
    return [[IAHelpManager m_instance] m_accessibilityLabelForKeyPath:a_keyPath];
}

-(NSString*)m_accessibilityLabelForName:(NSString*)a_name{
    return [self m_accessibilityLabelForKeyPath:[self m_helpTargetIdForName:a_name]];
}

-(void)m_showRefreshControl:(UIControl*)a_control inScrollView:(UIScrollView*)a_scrollView{
//    NSLog(@"m_showRefreshControl - a_control: %@", [a_control description]);
    CGFloat l_controlHeight = [a_control isKindOfClass:[ODRefreshControl class]] ? 44 : a_control.frame.size.height;
    [a_scrollView setContentOffset:CGPointMake(0, -(l_controlHeight)) animated:YES];
}

-(void)m_beginRefreshingWithScrollView:(UIScrollView*)a_scrollView{
    [self m_beginRefreshingWithScrollView:a_scrollView showControl:YES];
}

-(void)m_beginRefreshingWithScrollView:(UIScrollView*)a_scrollView showControl:(BOOL)a_shouldShowControl{
    if (!self.p_refreshControl.refreshing) {
        [self.p_refreshControl beginRefreshing];
        if (a_shouldShowControl) {
            [self m_showRefreshControl:self.p_refreshControl inScrollView:a_scrollView];
        }
    }
}

-(UIPopoverController*)m_newPopoverControllerWithContentViewController:(UIViewController*)a_contentViewController{
    UIPopoverController *l_popoverController = [[UIPopoverController alloc] initWithContentViewController:a_contentViewController];
    [[self m_appearanceTheme] m_setAppearanceForPopoverController:l_popoverController];
    return l_popoverController;
}

-(void)m_onDoneButtonTap:(UIBarButtonItem*)a_barButtonItem{
    [self m_notifySessionCompletion];
}

-(void)m_startAdRequests{
    
    if (![self m_shouldEnableAds] || [self m_gadBannerView].superview) {
        return;
    }
    
    // Add ad container subview
    UIView *l_adContainerView = self.p_adContainerView;
    if (l_adContainerView) {
        l_adContainerView.hidden = YES;
        l_adContainerView.frame = CGRectMake(0, self.view.frame.size.height, l_adContainerView.frame.size.width, l_adContainerView.frame.size.height);
//        NSLog(@"adContainerView.frame 3: %@", NSStringFromCGRect(l_adContainerView.frame));
        [self.view addSubview:l_adContainerView];
    }

    [self m_updateAdBannerSize];

    // Add the ad view to the container view
    [self.p_adContainerView addSubview:[self m_gadBannerView]];
    
    // Make a note of the owner view controller
    [IAUIApplicationDelegate m_instance].p_adsOwnerViewController = self;

    // Configure request Google ad request
    GADRequest *l_gadRequest = [GADRequest request];
    GADAdMobExtras *l_gadExtras = [[IAUIApplicationDelegate m_instance] m_gadExtras];
    if (l_gadExtras) {
        [l_gadRequest registerAdNetworkExtras:l_gadExtras];
    }
    
//    // Register simulator as a test device
//#if TARGET_IPHONE_SIMULATOR
//    l_gadRequest.testDevices = @[[[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)]];
//    //    NSLog(@"Configured test devices for Google Ads: %@", [l_gadRequest.testDevices description]);
//#endif
    
    // Initiate a generic Google ad request
    [self m_gadBannerView].delegate = self;
    [self m_gadBannerView].rootViewController = self;
    [[self m_gadBannerView] loadRequest:l_gadRequest];
    
}

-(void)m_stopAdRequests{
    
    if (![self m_shouldEnableAds] || ![self m_gadBannerView].superview) {
        return;
    }
    
    UIView *l_adContainerView = self.p_adContainerView;
    if (l_adContainerView) {
        [l_adContainerView removeFromSuperview];
        [self m_updateNonAdContainerViewFrameWithAdBannerViewHeight:0];
    }
    
    [[self m_gadBannerView] removeFromSuperview]; // This seems to stop ad loading
    [self m_gadBannerView].delegate = nil;
    [self m_gadBannerView].rootViewController = nil;

    [IAUIApplicationDelegate m_instance].p_adsOwnerViewController = self;
    
}

// To be overriden by subclasses
-(NSFetchedResultsController*)m_fetchedResultsController{
    return nil;
}

// Can be overriden by subclasses
-(id<NSFetchedResultsControllerDelegate>)m_fetchedResultsControllerDelegate{
    return self;
}

// Can be overriden by subclasses
-(void)m_configureFetchedResultsControllerAndPerformFetch{
    
    self.p_fetchedResultsController = [self m_fetchedResultsController];
    
    if (self.p_fetchedResultsController) {
        
        // Configure delegate
        self.p_fetchedResultsController.delegate = [self m_fetchedResultsControllerDelegate];
        
        // Perform fetch
        NSError *l_error;
        if (![self.p_fetchedResultsController performFetch:&l_error]) {
            [IAUtils handleUnrecoverableError:l_error];
        };
        
    }
    
}

- (BOOL)m_isVisibleTopViewController {
    return self.navigationController.topViewController==self && self.navigationController.viewControllers[0]==self;
}

- (void)m_updateNonAdContainerViewFrameWithAdBannerViewHeight:(CGFloat)a_adBannerViewHeight {
//    NSLog(@"m_updateNonAdContainerViewFrameWithAdBannerViewHeight BEFORE: self m_nonAdContainerView.frame: %@", NSStringFromCGRect([self m_nonAdContainerView].frame));
    CGRect l_newNonAdContainerViewFrame = [self m_nonAdContainerView].frame;
    l_newNonAdContainerViewFrame.size.height = self.view.frame.size.height - a_adBannerViewHeight;
    [self m_nonAdContainerView].frame = l_newNonAdContainerViewFrame;
//    NSLog(@"m_updateNonAdContainerViewFrameWithAdBannerViewHeight AFTER: self m_nonAdContainerView.frame: %@", NSStringFromCGRect([self m_nonAdContainerView].frame));
}

- (UIPopoverArrowDirection)m_permittedPopoverArrowDirectionForViewController:(UIViewController *)a_viewController {
    return [IAUIApplicationDelegate m_instance].p_isKeyboardVisible ? k_arrowDirectionWithKeyboard : k_arrowDirectionWithoutKeyboard;
}

- (void)m_presentActivityViewControllerFromBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                                                 webView:(UIWebView *)a_webView {
    NSString *l_subjectString = [a_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSURL *l_url = a_webView.request.URL;
    [self m_presentActivityViewControllerFromBarButtonItem:a_barButtonItem subject:l_subjectString url:l_url];
}

- (void)m_presentActivityViewControllerFromBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                                                 subject:(NSString *)a_subject url:(NSURL *)a_url {
    IAUISubjectActivityItem *l_subject = [[IAUISubjectActivityItem alloc] initWithSubject:a_subject];
    NSArray *l_activityItems = @[l_subject, a_url];
    id l_externalWebBrowserActivity = [IAUIExternalWebBrowserActivity new];
    NSArray *l_applicationActivities = @[l_externalWebBrowserActivity];
    UIActivityViewController *l_activityVC = [[UIActivityViewController alloc] initWithActivityItems:l_activityItems applicationActivities:l_applicationActivities];
    l_activityVC.p_presenter = self;
    [self m_presentModalSelectionViewController:l_activityVC fromBarButtonItem:a_barButtonItem];
}

+ (instancetype)m_instantiateFromStoryboard {
    NSString *l_storyboardName = [self m_storyboardName];
    id l_viewController = [UIStoryboard m_instantiateInitialViewControllerFromStoryboardNamed:l_storyboardName];
    NSAssert(l_viewController, @"It was not possible to instantiate view controller from storyboard named %@", l_storyboardName);
    return l_viewController;
}

+ (instancetype)m_instantiateFromStoryboardWithViewControllerIdentifier:(NSString *)a_viewControllerIdentifier {
    NSString *l_storyboardName = [self m_storyboardName];
    id l_viewController = [UIStoryboard m_instantiateViewControllerWithIdentifier:a_viewControllerIdentifier
                                                              fromStoryboardNamed:l_storyboardName];
    NSAssert(l_viewController, @"It was not possible to instantiate view controller with identifier %@ from storyboard named %@", a_viewControllerIdentifier, l_storyboardName);
    return l_viewController;
}

+ (NSString *)m_storyboardName {
    NSMutableString *l_storyboardName = [NSMutableString stringWithString:[self description]];
    if ([self m_isStoryboardDeviceSpecific]) {
        if ([IAUIUtils m_isIPad]) {
            [l_storyboardName appendString:[self m_storyboardNameIPadSuffix]];
        }else{
            [l_storyboardName appendString:[self m_storyboardNameIPhoneSuffix]];
        }
    }
    return l_storyboardName;
}

+ (NSString *)m_storyboardNameIPhoneSuffix{
    return @"_iPhone";
}

+ (NSString *)m_storyboardNameIPadSuffix{
    return @"_iPad";
}

+ (BOOL)m_isStoryboardDeviceSpecific{
    return NO;
}

//-(void)m_simulateMemoryWarning{
//
//#ifdef DEBUG
//    NSLog(@"About to simulate memory warning situation...");
//    [IAUtils m_dispatchAsyncMainThreadBlock:^{
//        [[UIApplication sharedApplication] performSelector:@selector(_performMemoryWarning)];
//    }];
//#endif
//    
//}

#pragma mark - IAHelpTargetContainer

-(NSArray*)m_helpTargets{

    NSMutableArray *l_helpTargets = [NSMutableArray new];

    // Navigation bar
    id<IAHelpTarget> l_helpTarget = nil;
    if ((l_helpTarget=self.navigationController.navigationBar)) {
//        NSLog(@"navigationBar: %@", [l_helpTarget description]);
        [l_helpTargets addObject:l_helpTarget];
    }
//    NSLog(@"Processing left bar button items in %@...", [self description]);
    for (UIBarButtonItem *l_barButtonItem in self.navigationItem.leftBarButtonItems) {
//        NSLog(@"l_barButtonItem: %@, helpTargetId: %@, title: %@", [l_barButtonItem description], l_barButtonItem.p_helpTargetId, l_barButtonItem.title);
        [l_helpTargets addObject:l_barButtonItem];
    }
//    NSLog(@"Processing right bar button items in %@...", [self description]);
    for (UIBarButtonItem *l_barButtonItem in self.navigationItem.rightBarButtonItems) {
//        NSLog(@" l_barButtonItem: %@", [l_barButtonItem description]);
        if (l_barButtonItem.tag==IA_UIBAR_ITEM_TAG_HELP_BUTTON) {
//            NSLog(@" help button ignored");
            continue;
        }
//        NSLog(@" m_editBarButtonItem: %@", [[self m_editBarButtonItem] description]);
        if (l_barButtonItem==[self m_editBarButtonItem]) {
            l_barButtonItem.p_helpTargetId = [self m_editBarButtonItemHelpTargetId];
        }
        [l_helpTargets addObject:l_barButtonItem];
    }

    // Tool bar
    for (UIBarButtonItem *l_barButtonItem in self.navigationController.toolbar.items) {
        [l_helpTargets addObject:l_barButtonItem];
    }

    // Tab bar
    if (self.tabBarController.tabBar) {
        [l_helpTargets addObject:self.tabBarController.tabBar];
    }

    return l_helpTargets;

}

-(UIView*)m_helpModeToggleView{
    return self.navigationController.navigationBar;
}

-(UIView*)m_view{
    return [self m_mainViewController].view;
}

-(void)m_willEnterHelpMode{
    // does nothing
}

-(void)m_didEnterHelpMode{
    // does nothing
}

-(void)m_willExitHelpMode{
    // does nothing
}

-(void)m_didExitHelpMode{
    // does nothing
}

-(void)m_logAnalyticsScreenEntry{
    if (![self m_isReturningVisibleViewController]) {
        [IAAnalyticsUtils m_logEntryForScreenName:self.navigationItem.title];
    }
}

#pragma mark - IAUIPresenter protocol

-(void)m_changesMadeByViewController:(UIViewController *)a_viewController{
    // Subclasses to override
}

- (void)m_sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                         data:(id)a_data {
    self.p_changesMadeByPresentedViewController = a_changesMade;
    [self m_registerForHelp];
    if (a_viewController.p_presentedAsModal) {
        [self m_dismissModalViewControllerWithChangesMade:a_changesMade data:a_data];
    }else{
        [a_viewController.navigationController popViewControllerAnimated:YES];
    }
}

-(void)m_didPresentViewController:(UIViewController *)a_viewController{
    // Subclasses to override
}

- (void)m_didDismissViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                              data:(id)a_data {
    // Subclasses to override
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    
//    NSLog(@"adViewDidReceiveAd in %@ - bannerView.frame: %@", [self description], NSStringFromCGRect(bannerView.frame));
    
    if ([self m_shouldEnableAds]) {
        
        if (![IAUIApplicationDelegate m_instance].p_adsSuspended) {
            UIView *l_adContainerView = self.p_adContainerView;
            if (l_adContainerView.hidden) {
                [UIView animateWithDuration:0.2 animations:^{
                    l_adContainerView.hidden = NO;
                    CGFloat l_bannerViewHeight = bannerView.frame.size.height;
                    [self m_updateNonAdContainerViewFrameWithAdBannerViewHeight:l_bannerViewHeight];
                    [self m_updateAdContainerViewFrameWithAdBannerViewHeight:l_bannerViewHeight];
                }];
            }
        }

    }else{

        // This can occur if ads were previously enabled but have now been disabled and the UI has not been reloaded yet
        [self m_stopAdRequests];

    }
    
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{

    NSLog(@"didFailToReceiveAdWithError: %@", [error description]);

    if ([self m_shouldEnableAds]) {
        // This can occur if ads were previously enabled but have now been disabled and the UI has not been reloaded yet
        [self m_stopAdRequests];
    }

}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{

    //    NSLog(@"adViewWillPresentScreen");

    // Hides the status overlay in case it is being used
    [[MTStatusBarOverlay sharedInstance] hide];

}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.p_presenter m_sessionDidCompleteForViewController:self changesMade:NO data:nil ];
}

@end
