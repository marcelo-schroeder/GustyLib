//
//  UIViewController+IFACategory.m
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

#import "IFACommon.h"
#import "UIStoryboard+IFACategory.h"
#import "IFASubjectActivityItem.h"
#import "IFAPassthroughView.h"

#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
#import "UIViewController+IFAGoogleMobileAdsSupport.h"
#endif

//static UIPopoverArrowDirection  const k_arrowDirectionWithoutKeyboard   = UIPopoverArrowDirectionAny;
static UIPopoverArrowDirection  const k_arrowDirectionWithoutKeyboard   = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
static UIPopoverArrowDirection  const k_arrowDirectionWithKeyboard      = UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
static BOOL                     const k_animated                        = YES;

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
static char c_refreshControlKey;
static char c_activeFetchedResultsControllerKey;
static char c_keyboardPassthroughViewKey;
static char c_notificationObserversToRemoveOnDeallocKey;
static char c_shouldUseKeyboardPassthroughViewKey;
//static char c_delegateKey;

@interface UIViewController (IFACategory_Private)

@property (nonatomic, strong) UIPopoverController *ifa_activePopoverController;
@property (nonatomic, strong) UIBarButtonItem *ifa_activePopoverControllerBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *IFA_slidingMenuBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *IFA_helpBarButtonItem;
@property (nonatomic) BOOL ifa_changesMadeByPresentedViewController;
@property (nonatomic, strong) NSFetchedResultsController *ifa_activeFetchedResultsController;
@property (nonatomic, strong) IFAPassthroughView *IFA_keyboardPassthroughView;
@property (nonatomic, strong) NSMutableArray *IFA_notificationObserversToRemoveOnDealloc;

@end

@implementation UIViewController (IFACategory)

#pragma mark - Private

- (void)IFA_presentModalSelectionViewController:(UIViewController *)a_viewController
                              fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem fromRect:(CGRect)a_fromRect
                                         inView:(UIView *)a_view {
    [self IFA_presentModalSelectionViewController:a_viewController
                                fromBarButtonItem:a_fromBarButtonItem
                                         fromRect:a_fromRect inView:a_view
               shouldWrapWithNavigationController:[self IFA_shouldWrapWithNavigationControllerForViewController:a_viewController]];
}

- (void)IFA_presentModalSelectionViewController:(UIViewController *)a_viewController
                              fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem fromRect:(CGRect)a_fromRect
                                         inView:(UIView *)a_view
             shouldWrapWithNavigationController:(BOOL)a_shouldWrapWithNavigationController {

//    NSLog(@"m_presentModalSelectionViewController: %@", [a_viewController description]);

    UIViewController *l_viewController;
    if (a_shouldWrapWithNavigationController) {
        l_viewController = [[[[self ifa_appearanceTheme] navigationControllerClass] alloc] initWithRootViewController:a_viewController];
    }else{
        l_viewController = a_viewController;
    }
//    NSLog(@"  l_viewController: %@", [l_viewController description]);

    if ([a_viewController ifa_hasFixedSize]) {
        CGFloat l_width = a_viewController.view.frame.size.width;
        CGFloat l_height = a_viewController.view.frame.size.height + a_viewController.navigationController.navigationBar.frame.size.height + (a_viewController.ifa_needsToolbar ? a_viewController.navigationController.toolbar.frame.size.height : 0);
        l_viewController.view.frame = CGRectMake(0, 0, l_width, l_height);
//        NSLog(@"  l_viewController.view.frame: %@", NSStringFromCGRect(l_viewController.view.frame));
//        NSLog(@"  a_viewController.view.frame: %@", NSStringFromCGRect(a_viewController.view.frame));
    }

    if ([self conformsToProtocol:@protocol(IFAPresenter)]) {
        a_viewController.ifa_presenter = (id <IFAPresenter>) self;
    }

    if ([IFAUIUtils isIPad]) { // If iPad present controller in a popover

        // Instantiate and configure popover controller
        UIPopoverController *l_popoverController = [self ifa_newPopoverControllerWithContentViewController:l_viewController];

        // Set the delegate
        if ([a_viewController conformsToProtocol:@protocol(UIPopoverControllerDelegate)]) {
            l_popoverController.delegate = (id <UIPopoverControllerDelegate>) a_viewController;
        }

        // Set the content size
        if ([a_viewController isKindOfClass:[IFAAbstractFieldEditorViewController class]]) {
            // Popover controllers "merge" the navigation bar from the navigation controller with its border at the top.
            // Therefore we need to reduce the content height by that amount otherwise a small gap is shown at the bottom of the popover view.
            // The same goes for the toolbar when it exists.
            CGFloat l_newHeight = l_viewController.view.frame.size.height - (l_popoverController.ifa_borderThickness * (a_viewController.ifa_needsToolbar ? 2 : 1));
            l_popoverController.popoverContentSize = CGSizeMake(l_viewController.view.frame.size.width, l_newHeight);
        }

        // Present popover controller
        if (a_fromBarButtonItem) {
            [self ifa_presentPopoverController:l_popoverController fromBarButtonItem:a_fromBarButtonItem];
        } else {
            [self ifa_presentPopoverController:l_popoverController fromRect:a_fromRect inView:a_view];
        }

    } else { // If not iPad present as modal

        if ([a_viewController ifa_hasFixedSize]) {
            [self presentSemiModalViewController:l_viewController];
        } else {
            if ([a_viewController isKindOfClass:[UIActivityViewController class]]) {
                [self presentViewController:a_viewController animated:YES completion:NULL];
            } else {
                [self ifa_presentModalViewController:a_viewController presentationStyle:UIModalPresentationFullScreen
                                     transitionStyle:UIModalTransitionStyleCoverVertical];
            }
        }

    }

}

- (BOOL)IFA_shouldWrapWithNavigationControllerForViewController:(UIViewController *)a_viewController {
    return ![a_viewController isKindOfClass:[UIActivityViewController class]];
}

//-(UIViewController *)p_presentedViewController{
//    if ([self isKindOfClass:[IFAAbstractPagingContainerViewController class]]) {
//        IFAAbstractPagingContainerViewController *l_pagingContainerViewController = (IFAAbstractPagingContainerViewController*)self;
//        return l_pagingContainerViewController.selectedViewController.presentedViewController ? l_pagingContainerViewController.selectedViewController.presentedViewController : self.presentedViewController;
//    }else{
//        return self.presentedViewController;
//    }
//}

-(void)setIfa_activePopoverController:(UIPopoverController*)a_activePopoverController{
    objc_setAssociatedObject(self, &c_activePopoverControllerKey, a_activePopoverController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setIfa_activePopoverControllerBarButtonItem:(UIBarButtonItem*)a_activePopoverControllerBarButtonItem{
    objc_setAssociatedObject(self, &c_activePopoverControllerBarButtonItemKey, a_activePopoverControllerBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)IFA_setActivePopoverController:(UIPopoverController *)a_popoverController
                            presenter:(UIViewController *)a_presenter barButtonItem:(UIBarButtonItem*)a_barButtonItem{
//    NSLog(@"a_popoverController.popoverContentSize: %@", NSStringFromCGSize(a_popoverController.popoverContentSize));
//    NSLog(@"a_popoverController.contentViewController.view.frame.size: %@", NSStringFromCGSize(a_popoverController.contentViewController.view.frame.size));
    self.ifa_activePopoverController = a_popoverController;
    [IFAApplicationDelegate sharedInstance].popoverControllerPresenter = a_presenter;
    self.ifa_activePopoverControllerBarButtonItem = a_barButtonItem;
}

-(void)IFA_resizePopoverContent {
    UIPopoverController *l_popoverController = self.ifa_activePopoverController;
    UIViewController *l_contentViewController = l_popoverController.contentViewController;
    BOOL l_hasFixedSize =  [l_contentViewController isKindOfClass:[UINavigationController class]] ? [((UINavigationController *) l_contentViewController).topViewController ifa_hasFixedSize] : [l_contentViewController ifa_hasFixedSize];
    CGSize l_contentViewControllerSize = l_contentViewController.view.frame.size;
    if (l_hasFixedSize) {
        l_popoverController.popoverContentSize = l_contentViewControllerSize;
//        NSLog(@"l_popoverController.popoverContentSize: %@", NSStringFromCGSize(l_popoverController.popoverContentSize));
    }
}

-(void)IFA_onMenuBarButtonItemInvalidated:(NSNotification*)a_notification{
//    NSLog(@"menu button invalidated - removing it...");
    [self ifa_removeLeftBarButtonItem:a_notification.object];
}

-(void)IFA_onSlidingMenuButtonAction:(UIBarButtonItem*)a_button{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(void)IFA_releaseViewForController:(UIViewController*)a_viewController{
//    NSLog(@"IFA_releaseViewForController: %@", [a_viewController description]);
    a_viewController.view = nil;
    a_viewController.ifa_previousVisibleViewController = nil;
    for (UIViewController *l_childViewController in a_viewController.childViewControllers) {
//        NSLog(@"   going to release view for child view controller: %@", [l_childViewController description]);
        [self IFA_releaseViewForController:l_childViewController];
    }
}

-(void)IFA_popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)IFA_spaceBarButtonItems:(NSMutableArray *)a_items firstItemSpacingType:(IFASpacingBarButtonItemType)a_firstItemSpacingType{
    
    if (![[self ifa_appearanceTheme] shouldAutomateBarButtonItemSpacingForViewController:self]) {
        return;
    }
    
    NSArray *l_items = [NSArray arrayWithArray:a_items];
    [a_items removeAllObjects];
    for (int i=0; i<l_items.count; i++) {
        UIBarButtonItem *l_spacingBarButtonItem;
        if (i==0) {
            l_spacingBarButtonItem = [[self ifa_appearanceTheme] spacingBarButtonItemForType:a_firstItemSpacingType
                                                                            viewController:self];
        }else{
            l_spacingBarButtonItem = [[self ifa_appearanceTheme] spacingBarButtonItemForType:IFASpacingBarButtonItemTypeMiddle
                                                                            viewController:self];
        }
        if (l_spacingBarButtonItem) {
            [a_items addObject:l_spacingBarButtonItem];
        }
        [a_items addObject:l_items[i]];
    }
    
}

-(void)IFA_removeAutomatedSpacingFromBarButtonItemArray:(NSMutableArray*)a_items{
    
    if (![[self ifa_appearanceTheme] shouldAutomateBarButtonItemSpacingForViewController:self]) {
        return;
    }
    
    NSMutableArray *l_objectsToRemove = [NSMutableArray new];
    for (UIBarButtonItem *l_barButtonItem in a_items) {
        if (l_barButtonItem.tag== IFABarItemTagFixedSpaceButton) {
            [l_objectsToRemove addObject:l_barButtonItem];
        }
    }
    [a_items removeObjectsInArray:l_objectsToRemove];
    
}

- (void)IFA_showLeftSlidingPaneButtonIfRequired {
    if ([self ifa_shouldShowLeftSlidingPaneButton]) {
        if (self.slidingViewController) {
            self.navigationController.view.layer.shadowOpacity = 0.75f;
            self.navigationController.view.layer.shadowRadius = 10.0f;
            self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;
            [self.navigationController.view addGestureRecognizer:self.slidingViewController.panGesture];

            BOOL l_shouldShowMenuButton = self.navigationController.topViewController==[self.navigationController.viewControllers objectAtIndex:0];
            if (l_shouldShowMenuButton) {
                if (!self.IFA_slidingMenuBarButtonItem) {
                    self.IFA_slidingMenuBarButtonItem = [[self ifa_appearanceTheme] slidingMenuBarButtonItemForViewController:self];
                    self.IFA_slidingMenuBarButtonItem.target = self;
                    self.IFA_slidingMenuBarButtonItem.action = @selector(IFA_onSlidingMenuButtonAction:);
                    self.IFA_slidingMenuBarButtonItem.tag = IFABarItemTagLeftSlidingPaneButton;
                }
                [self ifa_addToNavigationBarForSlidingMenuBarButtonItem:self.IFA_slidingMenuBarButtonItem];
            }
        }else if (self.splitViewController) {
            [self ifa_addLeftBarButtonItem:((IFASplitViewController *) self.splitViewController).splitViewControllerPopoverControllerBarButtonItem];
        }
    }
}

// Determines the best presenting view controller for the situation.
//  For instance, a view controller set as the master view controller in a split view controller is not
//      the most appropriate view controller when presenting another view controller in portrait orientation.
//  If the device is rotated to landscape, the master view controller presented as a popover will be dismissed and so will
//      the presented view controller. In those case, it is better to present the view controller from the detail
//      view controller in the split view controller (which does not get dismissed if the device is rotated)
-(UIViewController*)IFA_appropriatePresentingViewController {
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

- (void)IFA_removeKeyboardPassthroughView {
    [self.IFA_keyboardPassthroughView removeFromSuperview];
}

#pragma mark - Public

-(void)setIfa_presenter:(id<IFAPresenter>)a_presenter{
    objc_setAssociatedObject(self, &c_presenterKey, a_presenter, OBJC_ASSOCIATION_ASSIGN);
}

-(id<IFAPresenter>)ifa_presenter {
    return objc_getAssociatedObject(self, &c_presenterKey);
}

//-(void)setIFA_delegate:(id<IFAViewControllerDelegate>)a_delegate{
//    objc_setAssociatedObject(self, &c_delegateKey, a_delegate, OBJC_ASSOCIATION_ASSIGN);
//}
//
//-(id<IFAViewControllerDelegate>)IFA_delegate {
//    return objc_getAssociatedObject(self, &c_delegateKey);
//}

-(UIPopoverController*)ifa_activePopoverController {
    return objc_getAssociatedObject(self, &c_activePopoverControllerKey);
}

-(UIBarButtonItem*)ifa_activePopoverControllerBarButtonItem {
    return objc_getAssociatedObject(self, &c_activePopoverControllerBarButtonItemKey);
}

-(NSString*)ifa_subTitle {
    return objc_getAssociatedObject(self, &c_subTitleKey);
}

-(void)setIfa_subTitle:(NSString*)a_subTitle{
    objc_setAssociatedObject(self, &c_subTitleKey, a_subTitle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(IFANavigationItemTitleView *)ifa_titleViewDefault {
    return objc_getAssociatedObject(self, &c_titleViewDefaultKey);
}

-(void)setIfa_titleViewDefault:(IFANavigationItemTitleView *)a_titleViewDefault{
    objc_setAssociatedObject(self, &c_titleViewDefaultKey, a_titleViewDefault, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)ifa_helpTargetId {
    return objc_getAssociatedObject(self, &c_helpTargetIdKey);
}

-(void)setIfa_helpTargetId:(NSString*)a_helpTargetId{
    objc_setAssociatedObject(self, &c_helpTargetIdKey, a_helpTargetId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(ODRefreshControl*)ifa_refreshControl {
    return objc_getAssociatedObject(self, &c_refreshControlKey);
}

-(void)setIfa_refreshControl:(ODRefreshControl*)a_refreshControl{
    objc_setAssociatedObject(self, &c_refreshControlKey, a_refreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)ifa_shouldUseKeyboardPassthroughView {
    return ((NSNumber*)objc_getAssociatedObject(self, &c_shouldUseKeyboardPassthroughViewKey)).boolValue;
}

-(void)setIfa_shouldUseKeyboardPassthroughView:(BOOL)a_shouldUseKeyboardPassthroughView{
    objc_setAssociatedObject(self, &c_shouldUseKeyboardPassthroughViewKey, @(a_shouldUseKeyboardPassthroughView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(IFAPassthroughView *)IFA_keyboardPassthroughView {
    IFAPassthroughView *l_obj = objc_getAssociatedObject(self, &c_keyboardPassthroughViewKey);
    if (!l_obj) {
        l_obj = [IFAPassthroughView new];
        l_obj.shouldDismissKeyboardOnNonTextInputInteractions = YES;
        self.IFA_keyboardPassthroughView = l_obj;
    }
    return l_obj;
}

-(void)setIFA_keyboardPassthroughView:(IFAPassthroughView *)a_keyboardPassthroughView{
    objc_setAssociatedObject(self, &c_keyboardPassthroughViewKey, a_keyboardPassthroughView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray *)IFA_notificationObserversToRemoveOnDealloc {
    NSMutableArray *l_obj = objc_getAssociatedObject(self, &c_notificationObserversToRemoveOnDeallocKey);
    if (!l_obj) {
        l_obj = [NSMutableArray new];
        self.IFA_notificationObserversToRemoveOnDealloc = l_obj;
    }
    return l_obj;
}

-(void)setIFA_notificationObserversToRemoveOnDealloc:(NSMutableArray *)a_notificationObserversToRemoveOnDealloc{
    objc_setAssociatedObject(self, &c_notificationObserversToRemoveOnDeallocKey, a_notificationObserversToRemoveOnDealloc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIBarButtonItem*)IFA_helpBarButtonItem {
    return objc_getAssociatedObject(self, &c_helpBarButtonItemKey);
}

-(void)setIFA_helpBarButtonItem:(UIBarButtonItem*)a_helpBarButtonItem{
    objc_setAssociatedObject(self, &c_helpBarButtonItemKey, a_helpBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSFetchedResultsController*)ifa_activeFetchedResultsController {
    return objc_getAssociatedObject(self, &c_activeFetchedResultsControllerKey);
}

-(void)setIfa_activeFetchedResultsController:(NSFetchedResultsController*)a_activeFetchedResultsController {
    objc_setAssociatedObject(self, &c_activeFetchedResultsControllerKey, a_activeFetchedResultsController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)ifa_changesMadeByPresentedViewController {
    return ((NSNumber*)objc_getAssociatedObject(self, &c_changesMadeByPresentedViewControllerKey)).boolValue;
}

-(void)setIfa_changesMadeByPresentedViewController:(BOOL)a_changesMadeByPresentedViewController{
    objc_setAssociatedObject(self, &c_changesMadeByPresentedViewControllerKey, @(a_changesMadeByPresentedViewController), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(IFANavigationItemTitleView *)ifa_titleViewLandscapePhone {
    return objc_getAssociatedObject(self, &c_titleViewLandscapePhoneKey);
}

-(void)setIfa_titleViewLandscapePhone:(IFANavigationItemTitleView *)a_titleViewLandscapePhone{
    objc_setAssociatedObject(self, &c_titleViewLandscapePhoneKey, a_titleViewLandscapePhone, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)IFA_slidingMenuBarButtonItem {
    return objc_getAssociatedObject(self, &c_slidingMenuBarButtonItemKey);
}

-(void)setIFA_slidingMenuBarButtonItem:(NSString*)a_slidingMenuBarButtonItem{
    objc_setAssociatedObject(self, &c_slidingMenuBarButtonItemKey, a_slidingMenuBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)ifa_addLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem{
    [self ifa_insertLeftBarButtonItem:a_barButtonItem atIndex:NSNotFound];
}

-(void)ifa_insertLeftBarButtonItem:(UIBarButtonItem *)a_barButtonItem atIndex:(NSUInteger)a_index{

    if (!a_barButtonItem) {
        return;
    }
    UINavigationItem *l_navigationItem = [self ifa_navigationItem];
    NSMutableArray *l_leftBarButtonItems = [l_navigationItem.leftBarButtonItems mutableCopy];

    BOOL l_fixedPositionItem = a_barButtonItem.tag== IFABarItemTagBackButton || a_barButtonItem.tag== IFABarItemTagLeftSlidingPaneButton;
    if (![l_navigationItem.leftBarButtonItems containsObject:a_barButtonItem] || l_fixedPositionItem) {
        
        if (l_leftBarButtonItems) {
            [self IFA_removeAutomatedSpacingFromBarButtonItemArray:l_leftBarButtonItems];
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
                    case IFABarItemTagBackButton:
                        l_backBarButtonItem = l_barButtonItem;
                        break;
                    case IFABarItemTagLeftSlidingPaneButton:
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
        [self IFA_spaceBarButtonItems:l_leftBarButtonItems firstItemSpacingType:IFASpacingBarButtonItemTypeLeft];

        [l_navigationItem setLeftBarButtonItems:l_leftBarButtonItems animated:NO];
//        NSLog(@"m_insertLeftBarButtonItem - button inserted for %@, tag: %u, navigationItem.title: %@: %@", [self description], a_barButtonItem.tag, l_navigationItem.title, [l_navigationItem.leftBarButtonItems description]);

    }

}

-(void)ifa_removeLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem{

    if (!a_barButtonItem) {
        return;
    }

    UINavigationItem *l_navigationItem = [self ifa_navigationItem];
    NSMutableArray *l_leftBarButtonItems = [l_navigationItem.leftBarButtonItems mutableCopy];
    if (l_leftBarButtonItems) {
        [self IFA_removeAutomatedSpacingFromBarButtonItemArray:l_leftBarButtonItems];
        [l_leftBarButtonItems removeObject:a_barButtonItem];
        [self IFA_spaceBarButtonItems:l_leftBarButtonItems firstItemSpacingType:IFASpacingBarButtonItemTypeLeft];
        [l_navigationItem setLeftBarButtonItems:l_leftBarButtonItems animated:NO];
//        NSLog(@"m_removeLeftBarButtonItem - button removed for %@: %@", l_navigationItem.title, [l_navigationItem.leftBarButtonItems description]);
    }

}

-(void)ifa_addRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem{
    [self ifa_insertRightBarButtonItem:a_barButtonItem atIndex:NSNotFound];
}

-(void)ifa_insertRightBarButtonItem:(UIBarButtonItem *)a_barButtonItem atIndex:(NSUInteger)a_index{

    if (!a_barButtonItem) {
        return;
    }

    UINavigationItem *l_navigationItem = [self ifa_navigationItem];
    NSMutableArray *l_rightBarButtonItems = [l_navigationItem.rightBarButtonItems mutableCopy];
    if (![l_navigationItem.rightBarButtonItems containsObject:a_barButtonItem]) {

        if (l_rightBarButtonItems) {
            [self IFA_removeAutomatedSpacingFromBarButtonItemArray:l_rightBarButtonItems];
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
        [self IFA_spaceBarButtonItems:l_rightBarButtonItems firstItemSpacingType:IFASpacingBarButtonItemTypeRight];

        [l_navigationItem setRightBarButtonItems:l_rightBarButtonItems animated:NO];
        //        NSLog(@"m_insertRightBarButtonItem - button inserted for %@, navigationItem.title: %@: %@", [self description], l_navigationItem.title, [l_navigationItem.rightBarButtonItems description]);

    }

}

-(void)ifa_removeRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem{

    if (!a_barButtonItem) {
        return;
    }

    UINavigationItem *l_navigationItem = [self ifa_navigationItem];
    NSMutableArray *l_rightBarButtonItems = [l_navigationItem.rightBarButtonItems mutableCopy];
    if (l_rightBarButtonItems) {
        [self IFA_removeAutomatedSpacingFromBarButtonItemArray:l_rightBarButtonItems];
        [l_rightBarButtonItems removeObject:a_barButtonItem];
        [self IFA_spaceBarButtonItems:l_rightBarButtonItems firstItemSpacingType:IFASpacingBarButtonItemTypeRight];
        [l_navigationItem setRightBarButtonItems:l_rightBarButtonItems animated:NO];
        //        NSLog(@"m_removeRightBarButtonItem - button removed for %@: %@", l_navigationItem.title, [l_navigationItem.rightBarButtonItems description]);
    }

}

-(BOOL)ifa_isMasterViewController {
    return [self.splitViewController.viewControllers objectAtIndex:0]==self.navigationController && self.navigationController.viewControllers[0]==self;
}

-(BOOL)ifa_isDetailViewController {
    return [self.splitViewController.viewControllers objectAtIndex:1]==self.navigationController && self.navigationController.viewControllers[0]==self;
}

-(NSString*)ifa_helpTargetIdForName:(NSString*)a_name{
    return [NSString stringWithFormat:@"controllers.%@.%@", [[self class] description], a_name];
}

-(BOOL)ifa_presentedAsModal {
    //    NSLog(@"presentingViewController: %@, presentedViewController: %@, self: %@, topViewController: %@, visibleViewController: %@, viewController[0]: %@, navigationController.parentViewController: %@, parentViewController: %@, presentedAsSemiModal: %u", [self.presentingViewController description], [self.presentedViewController description], [self description], self.navigationController.topViewController, self.navigationController.visibleViewController, [self.navigationController.viewControllers objectAtIndex:0], self.navigationController.parentViewController, self.parentViewController, self.presentedAsSemiModal);
    return [IFAApplicationDelegate sharedInstance].popoverControllerPresenter.ifa_activePopoverController.contentViewController==self.navigationController
            || [IFAApplicationDelegate sharedInstance].popoverControllerPresenter.ifa_activePopoverController.contentViewController==self
            || ( self.navigationController.presentingViewController!=nil && [self.navigationController.viewControllers objectAtIndex:0]==self)
            || self.parentViewController.presentedAsSemiModal
            || [[IFAApplicationDelegate sharedInstance].popoverControllerPresenter.ifa_activePopoverController.contentViewController isKindOfClass:[UIActivityViewController class]];
}

- (void)ifa_updateToolbarForMode:(BOOL)anEditModeFlag animated:(BOOL)anAnimatedFlag{
//    NSLog(@" ");
//    NSLog(@"toolbar items before: %@", [self.toolbarItems description]);
    if(self.ifa_manageToolbar || anEditModeFlag){
        NSArray *toolbarItems = anEditModeFlag ? [self ifa_editModeToolbarItems] : [self ifa_nonEditModeToolbarItems];
//        NSLog(@"self.navigationController.toolbar: %@", [self.navigationController.toolbar description]);
//        NSLog(@" self.navigationController.toolbarHidden: %u, animated: %u", self.navigationController.toolbarHidden, anAnimatedFlag);
        [self.navigationController setToolbarHidden:(![toolbarItems count]) animated:anAnimatedFlag];
//        NSLog(@" self.navigationController.toolbarHidden: %u", self.navigationController.toolbarHidden);
        if ([toolbarItems count]) {
            if (self.ifa_manageToolbar) {
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

-(BOOL)ifa_hasFixedSize {
    return NO;
}

-(void)ifa_presentPopoverController:(UIPopoverController *)a_popoverController fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem{
    [self IFA_setActivePopoverController:a_popoverController presenter:self barButtonItem:a_fromBarButtonItem];
    [self IFA_resizePopoverContent];
    [a_popoverController presentPopoverFromBarButtonItem:a_fromBarButtonItem
                                permittedArrowDirections:[self ifa_permittedPopoverArrowDirectionForViewController:nil ]
                                                animated:k_animated];
    __weak UIViewController *l_weakSelf = self;
    [IFAUtils dispatchAsyncMainThreadBlock:^{
        [l_weakSelf ifa_didPresentPopoverController:a_popoverController];
    }];
}

-(void)ifa_presentPopoverController:(UIPopoverController *)a_popoverController fromRect:(CGRect)a_fromRect inView:(UIView *)a_view{
    [self IFA_setActivePopoverController:a_popoverController presenter:self barButtonItem:nil];
    [self IFA_resizePopoverContent];
    [a_popoverController presentPopoverFromRect:a_fromRect inView:a_view
                       permittedArrowDirections:[self ifa_permittedPopoverArrowDirectionForViewController:nil ] animated:k_animated];
    __weak UIViewController *l_weakSelf = self;
    [IFAUtils dispatchAsyncMainThreadBlock:^{
        [l_weakSelf ifa_didPresentPopoverController:a_popoverController];
    }];
}

-(void)ifa_didPresentPopoverController:(UIPopoverController*)a_popoverController{
    // Remove the navigation bar or toolbar that owns the button from the passthrough view list
    a_popoverController.passthroughViews = nil;
}

-(void)ifa_presentModalFormViewController:(UIViewController*)a_viewController{
    [self ifa_presentModalViewController:a_viewController presentationStyle:UIModalPresentationPageSheet
                         transitionStyle:UIModalTransitionStyleCoverVertical];
}

- (void)ifa_presentModalSelectionViewController:(UIViewController *)a_viewController
                              fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem
             shouldWrapWithNavigationController:(BOOL)a_shouldWrapWithNavigationController {
    [self IFA_presentModalSelectionViewController:a_viewController fromBarButtonItem:a_fromBarButtonItem
                                         fromRect:CGRectZero inView:nil shouldWrapWithNavigationController:a_shouldWrapWithNavigationController];
}

-(void)ifa_presentModalSelectionViewController:(UIViewController *)a_viewController fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem{
    [self IFA_presentModalSelectionViewController:a_viewController fromBarButtonItem:a_fromBarButtonItem
                                         fromRect:CGRectZero inView:nil];
}

- (void)ifa_presentModalSelectionViewController:(UIViewController *)a_viewController fromRect:(CGRect)a_fromRect
                                         inView:(UIView *)a_view
             shouldWrapWithNavigationController:(BOOL)a_shouldWrapWithNavigationController {
    [self IFA_presentModalSelectionViewController:a_viewController fromBarButtonItem:nil fromRect:a_fromRect
                                           inView:a_view shouldWrapWithNavigationController:a_shouldWrapWithNavigationController];
}

-(void)ifa_presentModalSelectionViewController:(UIViewController *)a_viewController fromRect:(CGRect)a_fromRect inView:(UIView *)a_view{
    [self IFA_presentModalSelectionViewController:a_viewController fromBarButtonItem:nil fromRect:a_fromRect
                                           inView:a_view];
}

-(void)ifa_presentModalViewController:(UIViewController *)a_viewController
                    presentationStyle:(UIModalPresentationStyle)a_presentationStyle transitionStyle:(UIModalTransitionStyle)a_transitionStyle{
    [self ifa_presentModalViewController:a_viewController presentationStyle:a_presentationStyle
                         transitionStyle:a_transitionStyle shouldAddDoneButton:NO];
}

- (void)ifa_presentModalViewController:(UIViewController *)a_viewController
                     presentationStyle:(UIModalPresentationStyle)a_presentationStyle
                       transitionStyle:(UIModalTransitionStyle)a_transitionStyle
                   shouldAddDoneButton:(BOOL)a_shouldAddDoneButton {
    [self ifa_presentModalViewController:a_viewController
                       presentationStyle:a_presentationStyle
                         transitionStyle:a_transitionStyle
                     shouldAddDoneButton:a_shouldAddDoneButton
                              customSize:CGSizeZero];
}

- (void)ifa_presentModalViewController:(UIViewController *)a_viewController
                     presentationStyle:(UIModalPresentationStyle)a_presentationStyle
                       transitionStyle:(UIModalTransitionStyle)a_transitionStyle
                   shouldAddDoneButton:(BOOL)a_shouldAddDoneButton
                            customSize:(CGSize)a_customSize{
    UIViewController *l_presentingViewController = [self IFA_appropriatePresentingViewController];
    if ([l_presentingViewController conformsToProtocol:@protocol(IFAPresenter)]) {
        a_viewController.ifa_presenter = (id <IFAPresenter>) l_presentingViewController;
        if (a_shouldAddDoneButton) {
            UIBarButtonItem *l_barButtonItem = [[l_presentingViewController ifa_appearanceTheme] doneBarButtonItemWithTarget:a_viewController
                                                                                                                    action:@selector(ifa_onDoneButtonTap:)
                                                                                                            viewController:a_viewController];
            [a_viewController ifa_addLeftBarButtonItem:l_barButtonItem];
        }
    }
    id <IFAAppearanceTheme> l_appearanceTheme = [self ifa_appearanceTheme];
    Class l_navigationControllerClass = [l_appearanceTheme navigationControllerClass];
    IFANavigationController *l_navigationController = [[l_navigationControllerClass alloc] initWithRootViewController:a_viewController];
    l_navigationController.modalPresentationStyle = a_presentationStyle;
    l_navigationController.modalTransitionStyle = a_transitionStyle;
    [l_presentingViewController presentViewController:l_navigationController animated:YES completion:^{
        [a_viewController.ifa_presenter didPresentViewController:l_navigationController];
    }];
    if (a_customSize.width && a_customSize.height) {
        l_navigationController.view.superview.backgroundColor = [UIColor clearColor];
        l_navigationController.view.bounds = CGRectMake(0, 0, a_customSize.width, a_customSize.height + l_navigationController.navigationBar.frame.size.height);
    }
}

- (void)ifa_notifySessionCompletionWithChangesMade:(BOOL)a_changesMade data:(id)a_data {
    [self.ifa_presenter sessionDidCompleteForViewController:self changesMade:a_changesMade data:a_data];
}

- (void)ifa_notifySessionCompletionWithChangesMade:(BOOL)a_changesMade data:(id)a_data animated:(BOOL)a_animated{
    [self.ifa_presenter sessionDidCompleteForViewController:self changesMade:a_changesMade data:a_data animated:a_animated];
}

-(void)ifa_notifySessionCompletion {
    [self ifa_notifySessionCompletionWithChangesMade:NO data:nil ];
}

-(void)ifa_notifySessionCompletionAnimated:(BOOL)a_animate {
    [self ifa_notifySessionCompletionWithChangesMade:NO data:nil animated:a_animate];
}

- (void)ifa_dismissModalViewControllerWithChangesMade:(BOOL)a_changesMade data:(id)a_data {
    [self ifa_dismissModalViewControllerWithChangesMade:a_changesMade data:a_data
                                               animated:YES];
}

- (void)ifa_dismissModalViewControllerWithChangesMade:(BOOL)a_changesMade data:(id)a_data animated:(BOOL)a_animate{
    if (self.presentedViewController) {
        __weak UIViewController *l_weakSelf = self;
        UIViewController *l_presentedViewController = self.presentedViewController; // Add retain cycle
        [self dismissViewControllerAnimated:a_animate completion:^{
            if ([l_weakSelf conformsToProtocol:@protocol(IFAPresenter)]) {
                [l_weakSelf didDismissViewController:l_presentedViewController changesMade:a_changesMade data:a_data];
            }
        }];
    }else if(self.ifa_activePopoverController){
        [self.ifa_activePopoverController dismissPopoverAnimated:a_animate];
        [self ifa_resetActivePopoverController];
    }else if(self.presentingSemiModal){
        [self dismissSemiModalViewWithChangesMade:a_changesMade data:a_data];
    }
}

-(IFAAsynchronousWorkManager *)ifa_asynchronousWorkManager {
    return [IFAAsynchronousWorkManager instance];
}

-(void)ifa_dismissMenuPopoverController {
    [self ifa_dismissMenuPopoverControllerWithAnimation:YES];
}

-(void)ifa_dismissMenuPopoverControllerWithAnimation:(BOOL)a_animated{
    // Dismiss the popover controller if a split view controller is used and this controller is not presented as modal
    if (!self.ifa_presentedAsModal) {
        [((IFASplitViewController *)self.splitViewController).splitViewControllerPopoverController dismissPopoverAnimated:a_animated];
    }
}

-(void)ifa_resetActivePopoverController {
    [self IFA_setActivePopoverController:nil presenter:nil barButtonItem:nil];
}

-(void)ifa_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self ifa_dismissMenuPopoverController];
}

-(id<IFAAppearanceTheme>)ifa_appearanceTheme {
    return [[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme];
}

// To be overriden by subclasses
-(BOOL)ifa_manageToolbar {
    return YES;
}

// To be overriden by subclasses
-(UIViewController*)ifa_previousVisibleViewController {
    return nil;
}

// To be overriden by subclasses
-(BOOL)ifa_doneButtonSaves {
    return NO;
}

// To be overriden by subclasses
-(void)setIfa_previousVisibleViewController:(UIViewController *)ifa_previousVisibleViewController {
}

// To be overriden by subclasses
- (NSArray*)ifa_editModeToolbarItems {
	return nil;
}

// To be overriden by subclasses
- (NSArray*)ifa_nonEditModeToolbarItems {
	return nil;
}

// To be overriden by subclasses
-(void)ifa_updateScreenDecorationState {
}

// To be overriden by subclasses
-(void)ifa_updateNavigationItemState {
}

// To be overriden by subclasses
-(void)ifa_updateToolbarNavigationButtonState {
}

// To be overriden by subclasses
- (void)ifa_onApplicationWillEnterForegroundNotification:(NSNotification*)aNotification{
}

// To be overriden by subclasses
- (void)ifa_onApplicationDidBecomeActiveNotification:(NSNotification*)aNotification{
}

// To be overriden by subclasses
- (void)ifa_onApplicationWillResignActiveNotification:(NSNotification*)aNotification{
}

// To be overriden by subclasses
- (void)ifa_onApplicationDidEnterBackgroundNotification:(NSNotification*)aNotification{
}

-(void)ifa_dealloc {
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationMenuBarButtonItemInvalidated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];

    for (id l_observer in self.IFA_notificationObserversToRemoveOnDealloc) {
        [[NSNotificationCenter defaultCenter] removeObserver:l_observer];
    }

}

-(UIBarButtonItem*)IFA_editBarButtonItem {
    if ([self isKindOfClass:[IFADynamicPagingContainerViewController class]]) {
        IFADynamicPagingContainerViewController *l_containerViewController = (IFADynamicPagingContainerViewController *)self;
        return [l_containerViewController visibleChildViewController].editButtonItem;
    }else{
        return self.editButtonItem;
    }
}

//-(void)m_updateEditButtonItemAccessibilityLabel{
//    [self IFA_editBarButtonItem].accessibilityLabel = self.editing ? @"Done Button" : @"Edit Button";
//}

- (void)ifa_viewDidLoad {
    
//    NSLog(@"ifa_viewDidLoad: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
    
//    [self m_updateEditButtonItemAccessibilityLabel];

    UINavigationItem *l_navigationItem = [self ifa_navigationItem];
    l_navigationItem.leftItemsSupplementBackButton = YES;
    UIBarButtonItem *l_backBarButtonItem = [[self ifa_appearanceTheme] backBarButtonItemForViewController:self];
    l_navigationItem.backBarButtonItem = l_backBarButtonItem;
    if (l_backBarButtonItem.customView && self.navigationController.topViewController==self && self.navigationController.viewControllers.count>1) {
        l_navigationItem.hidesBackButton = YES;
        l_backBarButtonItem.tag = IFABarItemTagBackButton;
        l_backBarButtonItem.target = self;
        l_backBarButtonItem.action = @selector(IFA_popViewController);
        [self ifa_addLeftBarButtonItem:l_backBarButtonItem];
    }

    // Configure help button
    if ([[IFAHelpManager sharedInstance] isHelpEnabledForViewController:self]) {
        self.IFA_helpBarButtonItem = [[IFAHelpManager sharedInstance] newHelpBarButtonItem];
    }else{
        self.IFA_helpBarButtonItem = nil;
    }
    
    // Set appearance
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnViewDidLoadForViewController:self];
    
    // Add observers
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(IFA_onMenuBarButtonItemInvalidated:)
                                                 name:IFANotificationMenuBarButtonItemInvalidated
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ifa_onApplicationWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ifa_onApplicationDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ifa_onApplicationWillResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ifa_onApplicationDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    // Configure fetched results controller and perform fetch
    [self ifa_configureFetchedResultsControllerAndPerformFetch];

    // Configure keyboard passthrough view
    if (self.ifa_shouldUseKeyboardPassthroughView) {
        self.IFA_keyboardPassthroughView.shouldDismissKeyboardOnNonTextInputInteractions = YES;
    }

}

-(void)ifa_viewDidUnload {

    //    NSLog(@"ifa_viewDidUnload: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
    
    // Remove observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationMenuBarButtonItemInvalidated
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];

    self.ifa_activeFetchedResultsController = nil;

}

- (void)ifa_viewWillAppear {
    
//    NSLog(@"ifa_viewWillAppear: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
    
    // Add the help button if help is enabled for this view controller
    if (self.IFA_helpBarButtonItem) {
        if ([self isKindOfClass:[IFAAbstractFieldEditorViewController class]] || [self isKindOfClass:[IFAMultiSelectionListViewController class]]) {
            if ([self isKindOfClass:[IFAAbstractFieldEditorViewController class]] ) {
                CGRect l_customViewFrame = self.IFA_helpBarButtonItem.customView.frame;
                self.IFA_helpBarButtonItem.customView.frame = CGRectMake(l_customViewFrame.origin.x, l_customViewFrame.origin.y, 34, self.navigationController.navigationBar.frame.size.height);
            }
            [self ifa_addLeftBarButtonItem:self.IFA_helpBarButtonItem];
        }else{
            [self ifa_insertRightBarButtonItem:self.IFA_helpBarButtonItem atIndex:0];
        }
    }
    
    // Add observers
#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
    [self ifa_startObservingGoogleMobileAdsSupportNotifications];
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ifa_onKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ifa_onKeyboardNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ifa_onKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ifa_onKeyboardNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    if (self.ifa_manageToolbar && [self.navigationController.viewControllers count]==1 && ![self ifa_isReturningVisibleViewController]) {
        //            NSLog(@"About to call m_updateToolbarForMode in ifa_viewWillAppear...");
        [self ifa_updateToolbarForMode:self.editing animated:NO];
    }

    // Manage left sliding menu button visibility
    [self IFA_showLeftSlidingPaneButtonIfRequired];

    // Set appearance
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnViewWillAppearForViewController:self];

    // Configure help target
    [self ifa_registerForHelp];

}

- (BOOL)ifa_shouldShowLeftSlidingPaneButton {
    BOOL l_shouldShowIt = NO;
    if (self.slidingViewController) {
        l_shouldShowIt = self.slidingViewController.topViewController==self.navigationController && self.navigationController.viewControllers[0]==self;
    }else if (self.splitViewController) {
        l_shouldShowIt = [self ifa_isDetailViewController];
    }
//    NSLog(@"  [self ifa_shouldShowLeftSlidingPaneButton] for %@: %u", [self description], l_shouldShowIt);
    return l_shouldShowIt;
}

- (void)ifa_addToNavigationBarForSlidingMenuBarButtonItem:(UIBarButtonItem *)a_slidingMenuBarButtonItem {
    [self ifa_insertLeftBarButtonItem:a_slidingMenuBarButtonItem atIndex:0];
}

- (void)ifa_viewDidAppear {
    
//    NSLog(@"ifa_viewDidAppear: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);

#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
    [self ifa_startGoogleMobileAdsRequests];
#endif

    if (self.ifa_manageToolbar && !([self.navigationController.viewControllers count]==1 && ![self ifa_isReturningVisibleViewController]) ) {
        //            NSLog(@"About to call m_updateToolbarForMode in ifa_viewDidAppear...");
        [self ifa_updateToolbarForMode:self.editing animated:YES];
    }
    
}

- (void)ifa_viewWillDisappear {
    
//    NSLog(@"ifa_viewWillDisappear: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
        
    self.ifa_previousVisibleViewController = self.navigationController.visibleViewController;
    
}

- (void)ifa_viewDidDisappear {
    
//    NSLog(@"ifa_viewDidDisappear: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);
        
    // Remove observers
#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
    [self ifa_stopObservingGoogleMobileAdsSupportNotifications];
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    if (self.ifa_manageToolbar && [self.toolbarItems count]>0) {
        self.toolbarItems = @[];
    }

#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
    [self ifa_stopGoogleMobileAdsRequests];
#endif

    // Remove keyboard passthrough view if required
    if (self.ifa_shouldUseKeyboardPassthroughView) {
        [self IFA_removeKeyboardPassthroughView]; // Keyboard dismissal is doing this already - this is just a safety net in case of any unforeseen scenarios out there.
    }

//    [self m_simulateMemoryWarning];
    
}

-(BOOL)ifa_isReturningVisibleViewController {
//    NSLog(@"m_isReturningTopViewController: %@, previousVisibleViewController: %@", self, self.previousVisibleViewController);
    if ([self.parentViewController isKindOfClass:[IFAAbstractPagingContainerViewController class]]) {
        return [((IFAAbstractPagingContainerViewController *) self.parentViewController) ifa_isReturningVisibleViewController];
    }else {
        return self.ifa_previousVisibleViewController && self!=self.ifa_previousVisibleViewController && ![self.ifa_previousVisibleViewController isKindOfClass:[IFAMenuViewController class]];
    }
}

//-(BOOL)m_isLeavingVisibleViewController{
////    NSLog(@"m_isLeavingTopViewController: %@, previousVisibleViewController: %@", self, self.previousVisibleViewController);
//    return self.previousVisibleViewController && self!=self.previousVisibleViewController;
//}

-(UIView*)ifa_viewForActionSheet {
    return [IFAUIUtils actionSheetShowInViewForViewController:self];
}

-(UIViewController*)ifa_mainViewController {
    if (((UIViewController*)[self.navigationController.viewControllers objectAtIndex:0]).ifa_presentedAsModal) {
        return self.navigationController;
    }else{
        return [UIApplication sharedApplication].delegate.window.rootViewController;
    }
}

// iOS 5 (the next method is for iOS 6 or greater)
-(BOOL)ifa_shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    BOOL l_shouldAutorotate;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        l_shouldAutorotate = YES;
    }else{
        l_shouldAutorotate = toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    if (l_shouldAutorotate) {
        if ([IFAApplicationDelegate sharedInstance].semiModalViewController) {
            l_shouldAutorotate = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) == UIInterfaceOrientationIsLandscape([IFAApplicationDelegate sharedInstance].semiModalInterfaceOrientation);
        }
    }
    return l_shouldAutorotate;
}

// iOS 6 or greater (the previous method is for iOS 5)
-(NSUInteger)ifa_supportedInterfaceOrientations {
    if ([IFAApplicationDelegate sharedInstance].semiModalViewController) {
        if (UIInterfaceOrientationIsLandscape([IFAApplicationDelegate sharedInstance].semiModalInterfaceOrientation)) {
            return UIInterfaceOrientationMaskLandscape;
        }else{
            return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown : UIInterfaceOrientationMaskPortrait;
        }
    }else{
        return UIInterfaceOrientationMaskAll;
    }
}

-(void)ifa_willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    // Tell help manager about the interface orientation change
    if (self.ifa_helpMode && [IFAHelpManager sharedInstance].observedHelpTargetContainer ==self) {
        [[IFAHelpManager sharedInstance] observedViewControllerWillRotateToInterfaceOrientation:toInterfaceOrientation
                                                                                  duration:duration];
    }

    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnWillRotateForViewController:self
                                                                                           toInterfaceOrientation:toInterfaceOrientation];

}

- (void)ifa_willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{

    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnWillAnimateRotationForViewController:self
                                                                                                      interfaceOrientation:interfaceOrientation];

#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
    [self ifa_stopGoogleMobileAdsRequests];
#endif

}

-(void)ifa_didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    // Tell help manager about the interface orientation change
    if (self.ifa_helpMode && [IFAHelpManager sharedInstance].observedHelpTargetContainer ==self) {
        [[IFAHelpManager sharedInstance] observedViewControllerDidRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
    
    if (self.ifa_activePopoverController && self.ifa_activePopoverControllerBarButtonItem) {
        
        // Present popover controller in the new interface orientation
        // Also need to reset content size as iOS will attempt to resize it automatically due to the fact the popover was triggered by a bar button item
        [self ifa_presentPopoverController:self.ifa_activePopoverController
                         fromBarButtonItem:self.ifa_activePopoverControllerBarButtonItem];
        
    }

#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
    [self ifa_startGoogleMobileAdsRequests];
#endif

}

-(BOOL)ifa_needsToolbar {
    return [(self.editing ? [self ifa_editModeToolbarItems] : [self ifa_nonEditModeToolbarItems]) count] > 0;
}

-(BOOL)ifa_helpMode {
    return [IFAHelpManager sharedInstance].helpMode;
}

-(UIStoryboard*)ifa_commonStoryboard {
    static NSString * const k_storyboardName = @"CommonStoryboard";
    return [UIStoryboard storyboardWithName:k_storyboardName bundle:[[self ifa_appearanceTheme] bundle]];
}

-(void)ifa_reset {
    self.ifa_previousVisibleViewController = nil;
}

-(UINavigationItem*)ifa_navigationItem {
    if ([self.parentViewController isKindOfClass:[IFAAbstractPagingContainerViewController class]] || [self.parentViewController isKindOfClass:[UITabBarController class]]) {
        return self.parentViewController.navigationItem;
    }else{
        return self.navigationItem;
    }
}

-(void)ifa_registerForHelp {
    if (![self.parentViewController isKindOfClass:[IFAAbstractPagingContainerViewController class]]) {
        UIViewController *l_helpTargetViewController = [[IFAHelpManager sharedInstance] isHelpEnabledForViewController:self] ? self : nil;
        [[IFAHelpManager sharedInstance] observeHelpTargetContainer:l_helpTargetViewController];
    }
}

-(NSString*)ifa_editBarButtonItemHelpTargetId {
    NSString *l_helpTargetId = nil;
    if (self.editing) {
        BOOL l_doneButtonSaves = self.ifa_doneButtonSaves;
        if ([self isKindOfClass:[IFADynamicPagingContainerViewController class]]) {
            IFADynamicPagingContainerViewController *l_pagingContainerViewController = (IFADynamicPagingContainerViewController *)self;
            l_doneButtonSaves = [l_pagingContainerViewController visibleChildViewController].ifa_doneButtonSaves;
        }
        if (l_doneButtonSaves) {
            l_helpTargetId = [IFAUIUtils helpTargetIdForName:@"saveButton"];
        }else{
            l_helpTargetId = [IFAUIUtils helpTargetIdForName:@"doneButton"];
        }
    }else{
        l_helpTargetId = [IFAUIUtils helpTargetIdForName:@"editButton"];
    }
    return l_helpTargetId;
}

-(void)ifa_openUrl:(NSURL*)a_url{
    [[IFAExternalUrlManager sharedInstance] openUrl:a_url];
}

-(void)ifa_releaseView {
    [self IFA_releaseViewForController:self];
}

-(NSString*)ifa_accessibilityLabelForKeyPath:(NSString*)a_keyPath{
    return [[IFAHelpManager sharedInstance] accessibilityLabelForKeyPath:a_keyPath];
}

-(NSString*)ifa_accessibilityLabelForName:(NSString*)a_name{
    return [self ifa_accessibilityLabelForKeyPath:[self ifa_helpTargetIdForName:a_name]];
}

-(void)ifa_showRefreshControl:(UIControl *)a_control inScrollView:(UIScrollView*)a_scrollView{
//    NSLog(@"m_showRefreshControl - a_control: %@", [a_control description]);
    CGFloat l_controlHeight = [a_control isKindOfClass:[ODRefreshControl class]] ? 44 : a_control.frame.size.height;
    [a_scrollView setContentOffset:CGPointMake(0, -(l_controlHeight)) animated:YES];
}

-(void)ifa_beginRefreshingWithScrollView:(UIScrollView*)a_scrollView{
    [self ifa_beginRefreshingWithScrollView:a_scrollView showControl:YES];
}

-(void)ifa_beginRefreshingWithScrollView:(UIScrollView *)a_scrollView showControl:(BOOL)a_shouldShowControl{
    if (!self.ifa_refreshControl.refreshing) {
        [self.ifa_refreshControl beginRefreshing];
        if (a_shouldShowControl) {
            [self ifa_showRefreshControl:self.ifa_refreshControl inScrollView:a_scrollView];
        }
    }
}

-(UIPopoverController*)ifa_newPopoverControllerWithContentViewController:(UIViewController*)a_contentViewController{
    UIPopoverController *l_popoverController = [[UIPopoverController alloc] initWithContentViewController:a_contentViewController];
    [[self ifa_appearanceTheme] setAppearanceForPopoverController:l_popoverController];
    return l_popoverController;
}

-(void)ifa_onDoneButtonTap:(UIBarButtonItem*)a_barButtonItem{
    [self ifa_notifySessionCompletion];
}

// To be overriden by subclasses
-(NSFetchedResultsController*)ifa_fetchedResultsController {
    return nil;
}

// Can be overriden by subclasses
-(id<NSFetchedResultsControllerDelegate>)ifa_fetchedResultsControllerDelegate {
    return self;
}

// Can be overriden by subclasses
-(void)ifa_configureFetchedResultsControllerAndPerformFetch {
    
    self.ifa_activeFetchedResultsController = [self ifa_fetchedResultsController];
    
    if (self.ifa_activeFetchedResultsController) {
        
        // Configure delegate
        self.ifa_activeFetchedResultsController.delegate = [self ifa_fetchedResultsControllerDelegate];
        
        // Perform fetch
        NSError *l_error;
        if (![self.ifa_activeFetchedResultsController performFetch:&l_error]) {
            [IFAUtils handleUnrecoverableError:l_error];
        };
        
    }
    
}

- (void)ifa_addNotificationObserverForName:(NSString *)a_name object:(id)a_obj queue:(NSOperationQueue *)a_queue
                                usingBlock:(void (^)(NSNotification *a_note))a_block
                               removalTime:(IFAViewControllerNotificationObserverRemovalTime)a_removalTime {
    BOOL l_isObserverRemovalAutomationSupported =
            [self isKindOfClass:[IFACollectionViewController class]]
                    || [self isKindOfClass:[IFAPageViewController class]]
                    || [self isKindOfClass:[IFATableViewController class]]
                    || [self isKindOfClass:[IFAViewController class]];
    NSAssert(l_isObserverRemovalAutomationSupported, @"Notification observer removal automation not supported by this class: %@", [self.class description]);
    id l_observer = [[NSNotificationCenter defaultCenter] addObserverForName:a_name object:a_obj
                                                       queue:a_queue
                                                  usingBlock:a_block];
    if (a_removalTime==IFAViewControllerNotificationObserverRemovalTimeDealloc) {
        [self.IFA_notificationObserversToRemoveOnDealloc addObject:l_observer];
    }
}

- (BOOL)ifa_isVisibleTopViewController {
    return self.navigationController.topViewController==self && self.navigationController.viewControllers[0]==self;
}

- (UIPopoverArrowDirection)ifa_permittedPopoverArrowDirectionForViewController:(UIViewController *)a_viewController {
    return [IFAApplicationDelegate sharedInstance].keyboardVisible ? k_arrowDirectionWithKeyboard : k_arrowDirectionWithoutKeyboard;
}

- (void)ifa_presentActivityViewControllerFromBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                                                   webView:(UIWebView *)a_webView {
    NSString *l_subjectString = [a_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSURL *l_url = a_webView.request.URL;
    [self ifa_presentActivityViewControllerFromBarButtonItem:a_barButtonItem subject:l_subjectString url:l_url];
}

- (void)ifa_presentActivityViewControllerFromBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                                                   subject:(NSString *)a_subject url:(NSURL *)a_url {
    IFASubjectActivityItem *l_subject = [[IFASubjectActivityItem alloc] initWithSubject:a_subject];
    NSArray *l_activityItems = @[l_subject, a_url];
    id l_externalWebBrowserActivity = [IFAExternalWebBrowserActivity new];
    NSArray *l_applicationActivities = @[l_externalWebBrowserActivity];
    UIActivityViewController *l_activityVC = [[UIActivityViewController alloc] initWithActivityItems:l_activityItems applicationActivities:l_applicationActivities];
    l_activityVC.ifa_presenter = self;
    [self ifa_presentModalSelectionViewController:l_activityVC fromBarButtonItem:a_barButtonItem];
}

- (void)ifa_addChildViewController:(UIViewController *)a_childViewController parentView:(UIView *)a_parentView {
    [self ifa_addChildViewController:a_childViewController parentView:a_parentView
                 shouldFillSuperview:YES];
}

- (void)ifa_addChildViewController:(UIViewController *)a_childViewController parentView:(UIView *)a_parentView
               shouldFillSuperview:(BOOL)a_shouldFillParentView {
    [self addChildViewController:a_childViewController];
    [a_parentView addSubview:a_childViewController.view];
    if (a_shouldFillParentView) {
        [a_childViewController.view ifa_addLayoutConstraintsToFillSuperview];
    }
    [a_childViewController didMoveToParentViewController:self];
}

- (void)ifa_removeFromParentViewController {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)ifa_onKeyboardNotification:(NSNotification*)a_notification {
    if (self.ifa_shouldUseKeyboardPassthroughView) {
        if ([a_notification.name isEqualToString:UIKeyboardDidShowNotification]) {
            [self.navigationController.view addSubview:self.IFA_keyboardPassthroughView];
            [self.IFA_keyboardPassthroughView ifa_addLayoutConstraintsToFillSuperview];
        } else if ([a_notification.name isEqualToString:UIKeyboardDidHideNotification]) {
            [self IFA_removeKeyboardPassthroughView];
        }
    }
}

+ (instancetype)ifa_instantiateFromStoryboard {
    NSString *l_storyboardName = [self ifa_storyboardName];
    id l_viewController = [UIStoryboard ifa_instantiateInitialViewControllerFromStoryboardNamed:l_storyboardName];
    NSAssert(l_viewController, @"It was not possible to instantiate view controller from storyboard named %@", l_storyboardName);
    return l_viewController;
}

+ (id)ifa_instantiateFromStoryboardWithViewControllerIdentifier:(NSString *)a_viewControllerIdentifier {
    NSString *l_storyboardName = [self ifa_storyboardName];
    id l_viewController = [UIStoryboard ifa_instantiateViewControllerWithIdentifier:a_viewControllerIdentifier
                                                                fromStoryboardNamed:l_storyboardName];
    NSAssert(l_viewController, @"It was not possible to instantiate view controller with identifier %@ from storyboard named %@", a_viewControllerIdentifier, l_storyboardName);
    return l_viewController;
}

+ (NSString *)ifa_storyboardName {
    NSMutableString *l_storyboardName = [NSMutableString stringWithString:[self description]];
    if ([self ifa_isStoryboardDeviceSpecific]) {
        if ([IFAUIUtils isIPad]) {
            [l_storyboardName appendString:[self ifa_storyboardNameIPadSuffix]];
        }else{
            [l_storyboardName appendString:[self ifa_storyboardNameIPhoneSuffix]];
        }
    }
    return l_storyboardName;
}

+ (NSString *)ifa_storyboardNameIPhoneSuffix {
    return @"_iPhone";
}

+ (NSString *)ifa_storyboardNameIPadSuffix {
    return @"_iPad";
}

+ (BOOL)ifa_isStoryboardDeviceSpecific {
    return NO;
}

//-(void)m_simulateMemoryWarning{
//
//#ifdef DEBUG
//    NSLog(@"About to simulate memory warning situation...");
//    [IFAUtils dispatchAsyncMainThreadBlock:^{
//        [[UIApplication sharedApplication] performSelector:@selector(_performMemoryWarning)];
//    }];
//#endif
//    
//}

#pragma mark - IFAHelpTargetContainer

-(NSArray*)helpTargets {

    NSMutableArray *l_helpTargets = [NSMutableArray new];

    // Navigation bar
    id<IFAHelpTarget> l_helpTarget = nil;
    if ((l_helpTarget=self.navigationController.navigationBar)) {
//        NSLog(@"navigationBar: %@", [l_helpTarget description]);
        [l_helpTargets addObject:l_helpTarget];
    }
//    NSLog(@"Processing left bar button items in %@...", [self description]);
    for (UIBarButtonItem *l_barButtonItem in self.navigationItem.leftBarButtonItems) {
//        NSLog(@"l_barButtonItem: %@, helpTargetId: %@, title: %@", [l_barButtonItem description], l_barButtonItem.helpTargetId, l_barButtonItem.title);
        [l_helpTargets addObject:l_barButtonItem];
    }
//    NSLog(@"Processing right bar button items in %@...", [self description]);
    for (UIBarButtonItem *l_barButtonItem in self.navigationItem.rightBarButtonItems) {
//        NSLog(@" l_barButtonItem: %@", [l_barButtonItem description]);
        if (l_barButtonItem.tag== IFABarItemTagHelpButton) {
//            NSLog(@" help button ignored");
            continue;
        }
//        NSLog(@" IFA_editBarButtonItem: %@", [[self m_editBarButtonItem] description]);
        if (l_barButtonItem== [self IFA_editBarButtonItem]) {
            l_barButtonItem.helpTargetId = [self ifa_editBarButtonItemHelpTargetId];
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

-(UIView*)helpModeToggleView {
    return self.navigationController.navigationBar;
}

-(UIView*)targetView {
    return [self ifa_mainViewController].view;
}

-(void)willEnterHelpMode {
    // does nothing
}

-(void)didEnterHelpMode {
    // does nothing
}

-(void)willExitHelpMode {
    // does nothing
}

-(void)didExitHelpMode {
    // does nothing
}

#pragma mark - IFAPresenter protocol

-(void)changesMadeByViewController:(UIViewController *)a_viewController{
    // Subclasses to override
}

- (void)sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                       data:(id)a_data {
    [self sessionDidCompleteForViewController:a_viewController
                                  changesMade:a_changesMade data:a_data animated:YES];
}

- (void)sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                       data:(id)a_data animated:(BOOL)a_animate{
    self.ifa_changesMadeByPresentedViewController = a_changesMade;
    [self ifa_registerForHelp];
    if (a_viewController.ifa_presentedAsModal) {
        [self ifa_dismissModalViewControllerWithChangesMade:a_changesMade data:a_data animated:a_animate];
    }else{
        [a_viewController.navigationController popViewControllerAnimated:a_animate];
    }
}

-(void)didPresentViewController:(UIViewController *)a_viewController{
    // Subclasses to override
}

- (void)didDismissViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                            data:(id)a_data {
    // Subclasses to override
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.ifa_presenter sessionDidCompleteForViewController:self changesMade:NO data:nil ];
}

@end
