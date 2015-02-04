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

#import "GustyLibCoreUI.h"

#ifdef IFA_AVAILABLE_Help
#import "GustyLibHelp.h"
#endif

#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
#import "GustyLibGoogleMobileAdsSupport.h"
#endif

//static UIPopoverArrowDirection  const k_arrowDirectionWithoutKeyboard   = UIPopoverArrowDirectionAny;
static UIPopoverArrowDirection  const k_arrowDirectionWithoutKeyboard   = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
static UIPopoverArrowDirection  const k_arrowDirectionWithKeyboard      = UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
static BOOL                     const k_animated                        = YES;

static char c_presenterKey;
static char c_delegateKey;
static char c_activePopoverControllerKey;
static char c_activePopoverControllerBarButtonItemKey;
static char c_subTitleKey;
static char c_slidingMenuBarButtonItemKey;
static char c_titleViewDefaultKey;
static char c_titleViewLandscapePhoneKey;
static char c_changesMadeByPresentedViewControllerKey;
static char c_refreshControlKey;
static char c_keyboardPassthroughViewKey;
static char c_notificationObserversToRemoveOnDeallocKey;
static char c_shouldUseKeyboardPassthroughViewKey;
static char c_childManagedObjectContextCountOnViewDidLoadKey;
static char c_hasViewAppearedKey;
static char c_modalDismissalDoneBarButtonItemKey;
static char c_toolbarUpdatedBeforeViewAppearedKey;
static char c_previousVisibleViewControllerKey;

@interface UIViewController (IFACategory_Private)

@property (nonatomic, strong) UIPopoverController *ifa_activePopoverController;
@property (nonatomic, strong) UIBarButtonItem *ifa_activePopoverControllerBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *IFA_slidingMenuBarButtonItem;
@property (nonatomic) BOOL ifa_changesMadeByPresentedViewController;
@property (nonatomic, strong) IFAPassthroughView *IFA_keyboardPassthroughView;
@property (nonatomic, strong) NSMutableArray *IFA_notificationObserversToRemoveOnDealloc;
@property (nonatomic) NSUInteger IFA_childManagedObjectContextCountOnViewDidLoad;   // Used for assertion only
@property (nonatomic) BOOL ifa_hasViewAppeared;
@property (nonatomic) BOOL IFA_toolbarUpdatedBeforeViewAppeared;

@end

@implementation UIViewController (IFACoreUI)

typedef NS_ENUM(NSUInteger, IFANavigationBarButtonItemsSide) {
    IFANavigationBarButtonItemsSideLeft,
    IFANavigationBarButtonItemsSideRight,
    IFANavigationBarButtonItemsSideNotApplicable,
};

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

    if ([self conformsToProtocol:@protocol(IFAPresenter)]) {
        a_viewController.ifa_presenter = (id <IFAPresenter>) self;
    }

    // Handle special case first: make sure that full screen form selection views are "pushed" instead of being modal on the iPhone
    if (![IFAUIUtils isIPad] && ![a_viewController ifa_hasFixedSize] && [self isKindOfClass:[IFAFormViewController class]] && self.navigationController) {
        [self.navigationController pushViewController:a_viewController
                                             animated:YES];
        return;
    }

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
            if ([a_viewController conformsToProtocol:@protocol(IFASemiModalViewDelegate)]) {
                self.semiModalViewDelegate = (id <IFASemiModalViewDelegate>) a_viewController;
            }else{
                self.semiModalViewDelegate = nil;
            }
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

/*
-(void)IFA_releaseViewForController:(UIViewController*)a_viewController{
//    NSLog(@"IFA_releaseViewForController: %@", [a_viewController description]);
    a_viewController.view = nil;
    a_viewController.ifa_previousVisibleViewController = nil;
    for (UIViewController *l_childViewController in a_viewController.childViewControllers) {
//        NSLog(@"   going to release view for child view controller: %@", [l_childViewController description]);
        [self IFA_releaseViewForController:l_childViewController];
    }
}
*/

-(void)IFA_popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)IFA_addSpacingToBarButtonItems:(NSMutableArray *)a_items side:(IFANavigationBarButtonItemsSide)a_side
                               barType:(IFABarButtonItemSpacingBarType)a_barType {

    if (a_items.count==0) {
        return;
    }

    id <IFAAppearanceTheme> l_appearanceTheme = [self ifa_appearanceTheme];
    NSArray *l_items = [NSArray arrayWithArray:a_items];
    id l_previousItem;
    [a_items removeAllObjects];
    for (NSUInteger i = 0; i < l_items.count; i++) {
        NSNumber *l_spaceWidth;
        if (i == 0) {
            BOOL l_isNavigationBarRightItemsCase = a_barType == IFABarButtonItemSpacingBarTypeNavigationBar && a_side == IFANavigationBarButtonItemsSideRight;
            IFABarButtonItemSpacingPosition l_position = l_isNavigationBarRightItemsCase ? IFABarButtonItemSpacingPositionRight : IFABarButtonItemSpacingPositionLeft;
            l_spaceWidth = [l_appearanceTheme spaceBarButtonItemWidthForPosition:l_position
                                                                         barType:a_barType viewController:self items:@[l_items[i]]];
        } else {
            l_spaceWidth = [l_appearanceTheme spaceBarButtonItemWidthForPosition:IFABarButtonItemSpacingPositionMiddle
                                                                         barType:a_barType viewController:self items:@[l_previousItem, l_items[i]]];
        }
        if (l_spaceWidth) {
            UIBarButtonItem *l_fixedSpace = [self IFA_newCustomFixedSpaceBarButtonItemWithWidth:l_spaceWidth.floatValue];
            [a_items addObject:l_fixedSpace];
        }
        [a_items addObject:l_items[i]];
        l_previousItem = l_items[i];
    }

    if (a_barType == IFABarButtonItemSpacingBarTypeToolbar) {
        NSNumber *l_spaceWidth = [l_appearanceTheme spaceBarButtonItemWidthForPosition:IFABarButtonItemSpacingPositionRight
                                                                               barType:a_barType viewController:self
                                                                                 items:@[l_previousItem]];
        if (l_spaceWidth) {
            UIBarButtonItem *l_fixedSpace = [self IFA_newCustomFixedSpaceBarButtonItemWithWidth:l_spaceWidth.floatValue];
            [a_items addObject:l_fixedSpace];
        }
    }

}

- (UIBarButtonItem *)IFA_newCustomFixedSpaceBarButtonItemWithWidth:(CGFloat)a_width {
    UIBarButtonItem *l_fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                          target:nil action:nil];
    l_fixedSpace.tag = IFABarItemTagAutomatedSpacingButton;
    l_fixedSpace.width = a_width;
    return l_fixedSpace;
}

- (void)IFA_removeAutomatedSpacingFromBarButtonItems:(NSMutableArray *)a_items {
    NSMutableArray *l_objectsToRemove = [NSMutableArray new];
    for (UIBarButtonItem *l_barButtonItem in a_items) {
        if (l_barButtonItem.tag== IFABarItemTagAutomatedSpacingButton) {
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

            BOOL l_shouldShowMenuButton = self.navigationController.topViewController== (self.navigationController.viewControllers)[0];
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

//todo: remove the need for this assertion one day
- (void)IFA_assertManagedObjectContextCountForViewController:(UIViewController *)a_viewController {
    UIViewController *l_topLevelContentViewController = nil;
    UIViewController *l_rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    if ([l_rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *l_tabBarController = (UITabBarController *) l_rootViewController;
        UIViewController *l_tabBarSelectedViewController = l_tabBarController.selectedViewController;
        if ([l_tabBarSelectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *l_navigationController = (UINavigationController *) l_tabBarSelectedViewController;
            if (l_navigationController.childViewControllers) {
                l_topLevelContentViewController = l_navigationController.childViewControllers[0];
            }
        }
    }
#ifndef NS_BLOCK_ASSERTIONS
    if (l_topLevelContentViewController == a_viewController) {
        NSUInteger l_childManagedObjectContextCountExpected = a_viewController.IFA_childManagedObjectContextCountOnViewDidLoad;
        NSUInteger l_childManagedObjectContextCountActual = [IFAPersistenceManager sharedInstance].childManagedObjectContexts.count;
        NSAssert(l_childManagedObjectContextCountActual == l_childManagedObjectContextCountExpected, @"Number of child managed object context count mismatch! Expected: %lu | Actual: %lu", (unsigned long)l_childManagedObjectContextCountExpected, (unsigned long)l_childManagedObjectContextCountActual);
    }
#endif
}

#pragma mark - Public

-(void)setIfa_presenter:(id<IFAPresenter>)a_presenter{
    IFAZeroingWeakReferenceContainer *l_weakReferenceContainer = objc_getAssociatedObject(self, &c_presenterKey);
    if (!l_weakReferenceContainer) {
        l_weakReferenceContainer = [IFAZeroingWeakReferenceContainer new];
        objc_setAssociatedObject(self, &c_presenterKey, l_weakReferenceContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    l_weakReferenceContainer.weakReference = a_presenter;
}

-(id<IFAPresenter>)ifa_presenter {
    IFAZeroingWeakReferenceContainer *l_weakReferenceContainer = objc_getAssociatedObject(self, &c_presenterKey);
    return l_weakReferenceContainer.weakReference;
}

-(void)setIfa_delegate:(id<IFAViewControllerDelegate>)a_delegate{
    IFAZeroingWeakReferenceContainer *l_weakReferenceContainer = objc_getAssociatedObject(self, &c_delegateKey);
    if (!l_weakReferenceContainer) {
        l_weakReferenceContainer = [IFAZeroingWeakReferenceContainer new];
        objc_setAssociatedObject(self, &c_delegateKey, l_weakReferenceContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    l_weakReferenceContainer.weakReference = a_delegate;
}

-(id<IFAViewControllerDelegate>)ifa_delegate {
    IFAZeroingWeakReferenceContainer *l_weakReferenceContainer = objc_getAssociatedObject(self, &c_delegateKey);
    return l_weakReferenceContainer.weakReference;
}

-(void)setIfa_previousVisibleViewController:(UIViewController *)a_previousVisibleViewController{
    IFAZeroingWeakReferenceContainer *l_weakReferenceContainer = objc_getAssociatedObject(self, &c_previousVisibleViewControllerKey);
    if (!l_weakReferenceContainer) {
        l_weakReferenceContainer = [IFAZeroingWeakReferenceContainer new];
        objc_setAssociatedObject(self, &c_previousVisibleViewControllerKey, l_weakReferenceContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    l_weakReferenceContainer.weakReference = a_previousVisibleViewController;
}

-(UIViewController *)ifa_previousVisibleViewController {
    IFAZeroingWeakReferenceContainer *l_weakReferenceContainer = objc_getAssociatedObject(self, &c_previousVisibleViewControllerKey);
    return l_weakReferenceContainer.weakReference;
}

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

-(BOOL)ifa_changesMadeByPresentedViewController {
    return ((NSNumber*)objc_getAssociatedObject(self, &c_changesMadeByPresentedViewControllerKey)).boolValue;
}

-(void)setIfa_changesMadeByPresentedViewController:(BOOL)a_changesMadeByPresentedViewController{
    objc_setAssociatedObject(self, &c_changesMadeByPresentedViewControllerKey, @(a_changesMadeByPresentedViewController), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)ifa_hasViewAppeared {
    return ((NSNumber*)objc_getAssociatedObject(self, &c_hasViewAppearedKey)).boolValue;
}

-(void)setIfa_hasViewAppeared:(BOOL)a_hasViewAppeared{
    objc_setAssociatedObject(self, &c_hasViewAppearedKey, @(a_hasViewAppeared), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)IFA_toolbarUpdatedBeforeViewAppeared {
    return ((NSNumber*)objc_getAssociatedObject(self, &c_toolbarUpdatedBeforeViewAppearedKey)).boolValue;
}

-(void)setIFA_toolbarUpdatedBeforeViewAppeared:(BOOL)a_toolbarUpdatedBeforeViewAppeared{
    objc_setAssociatedObject(self, &c_toolbarUpdatedBeforeViewAppearedKey, @(a_toolbarUpdatedBeforeViewAppeared), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSUInteger)IFA_childManagedObjectContextCountOnViewDidLoad {
    return ((NSNumber*)objc_getAssociatedObject(self, &c_childManagedObjectContextCountOnViewDidLoadKey)).unsignedIntegerValue;
}

-(void)setIFA_childManagedObjectContextCountOnViewDidLoad:(NSUInteger)a_childManagedObjectContextCountOnViewWillAppear{
    objc_setAssociatedObject(self, &c_childManagedObjectContextCountOnViewDidLoadKey, @(a_childManagedObjectContextCountOnViewWillAppear), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(IFANavigationItemTitleView *)ifa_titleViewLandscapePhone {
    return objc_getAssociatedObject(self, &c_titleViewLandscapePhoneKey);
}

-(void)setIfa_titleViewLandscapePhone:(IFANavigationItemTitleView *)a_titleViewLandscapePhone{
    objc_setAssociatedObject(self, &c_titleViewLandscapePhoneKey, a_titleViewLandscapePhone, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIBarButtonItem*)IFA_slidingMenuBarButtonItem {
    return objc_getAssociatedObject(self, &c_slidingMenuBarButtonItemKey);
}

-(void)setIFA_slidingMenuBarButtonItem:(UIBarButtonItem*)a_slidingMenuBarButtonItem{
    objc_setAssociatedObject(self, &c_slidingMenuBarButtonItemKey, a_slidingMenuBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIBarButtonItem*)IFA_modalDismissalDoneBarButtonItem {
    return objc_getAssociatedObject(self, &c_modalDismissalDoneBarButtonItemKey);
}

-(void)setIFA_modalDismissalDoneBarButtonItem:(UIBarButtonItem*)a_doneBarButtonItem{
    objc_setAssociatedObject(self, &c_modalDismissalDoneBarButtonItemKey, a_doneBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
            [self IFA_removeAutomatedSpacingFromBarButtonItems:l_leftBarButtonItems];
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
        [self IFA_addSpacingToBarButtonItems:l_leftBarButtonItems side:IFANavigationBarButtonItemsSideLeft
                                     barType:IFABarButtonItemSpacingBarTypeNavigationBar];

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
        [self IFA_removeAutomatedSpacingFromBarButtonItems:l_leftBarButtonItems];
        [l_leftBarButtonItems removeObject:a_barButtonItem];
        [self IFA_addSpacingToBarButtonItems:l_leftBarButtonItems side:IFANavigationBarButtonItemsSideLeft
                                     barType:IFABarButtonItemSpacingBarTypeNavigationBar];
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
            [self IFA_removeAutomatedSpacingFromBarButtonItems:l_rightBarButtonItems];
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
        [self IFA_addSpacingToBarButtonItems:l_rightBarButtonItems side:IFANavigationBarButtonItemsSideRight
                                     barType:IFABarButtonItemSpacingBarTypeNavigationBar];

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
        [self IFA_removeAutomatedSpacingFromBarButtonItems:l_rightBarButtonItems];
        [l_rightBarButtonItems removeObject:a_barButtonItem];
        [self IFA_addSpacingToBarButtonItems:l_rightBarButtonItems side:IFANavigationBarButtonItemsSideRight
                                     barType:IFABarButtonItemSpacingBarTypeNavigationBar];
        [l_navigationItem setRightBarButtonItems:l_rightBarButtonItems animated:NO];
        //        NSLog(@"m_removeRightBarButtonItem - button removed for %@: %@", l_navigationItem.title, [l_navigationItem.rightBarButtonItems description]);
    }

}

-(BOOL)ifa_isMasterViewController {
    return (self.splitViewController.viewControllers)[0] ==self.navigationController && self.navigationController.viewControllers[0]==self;
}

-(BOOL)ifa_isDetailViewController {
    return (self.splitViewController.viewControllers)[1] ==self.navigationController && self.navigationController.viewControllers[0]==self;
}

-(BOOL)ifa_presentedAsModal {
    //    NSLog(@"presentingViewController: %@, presentedViewController: %@, self: %@, topViewController: %@, visibleViewController: %@, viewController[0]: %@, navigationController.parentViewController: %@, parentViewController: %@, presentedAsSemiModal: %u", [self.presentingViewController description], [self.presentedViewController description], [self description], self.navigationController.topViewController, self.navigationController.visibleViewController, [self.navigationController.viewControllers objectAtIndex:0], self.navigationController.parentViewController, self.parentViewController, self.presentedAsSemiModal);
    return [IFAApplicationDelegate sharedInstance].popoverControllerPresenter.ifa_activePopoverController.contentViewController==self.navigationController
            || [IFAApplicationDelegate sharedInstance].popoverControllerPresenter.ifa_activePopoverController.contentViewController==self
            || ( self.navigationController.presentingViewController!=nil && (self.navigationController.viewControllers)[0] ==self)
            || self.parentViewController.presentedAsSemiModal
            || [[IFAApplicationDelegate sharedInstance].popoverControllerPresenter.ifa_activePopoverController.contentViewController isKindOfClass:[UIActivityViewController class]];
}

- (void)ifa_updateToolbarForEditing:(BOOL)a_editing animated:(BOOL)a_animated {
//    NSLog(@" ");
//    NSLog(@"toolbar items before: %@", [self.toolbarItems description]);
    if(self.ifa_manageToolbar || a_editing){
        NSMutableArray *toolbarItems = [a_editing ? [self ifa_editModeToolbarItems] : [self ifa_nonEditModeToolbarItems] mutableCopy];
        [self IFA_addSpacingToBarButtonItems:toolbarItems side:IFANavigationBarButtonItemsSideNotApplicable
                                     barType:IFABarButtonItemSpacingBarTypeToolbar];
//        NSLog(@"self.navigationController.toolbar: %@", [self.navigationController.toolbar description]);
//        NSLog(@" self.navigationController.toolbarHidden: %u, animated: %u", self.navigationController.toolbarHidden, anAnimatedFlag);
        BOOL l_shouldHideToolbar = ![toolbarItems count];
        [self.navigationController setToolbarHidden:l_shouldHideToolbar animated:a_animated];
//        NSLog(@" self.navigationController.toolbarHidden: %u", self.navigationController.toolbarHidden);
        if ([toolbarItems count]) {
            if (self.ifa_manageToolbar) {
                if (![self.toolbarItems isEqualToArray:toolbarItems]) {
                    [self setToolbarItems:toolbarItems animated:a_animated];
                }
            }else{
                if (![self.parentViewController.toolbarItems isEqualToArray:toolbarItems]) {
                    [self.parentViewController setToolbarItems:toolbarItems animated:a_animated];
                }
            }
        }
    }else{
        BOOL l_shouldHideToolbar = ![self.toolbarItems count];
        [self.navigationController setToolbarHidden:l_shouldHideToolbar animated:a_animated];
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
            a_viewController.IFA_modalDismissalDoneBarButtonItem = [[l_presentingViewController ifa_appearanceTheme] doneBarButtonItemWithTarget:a_viewController
                                                                                                                                          action:@selector(ifa_onDoneButtonTap:)
                                                                                                                                  viewController:a_viewController];
            [a_viewController ifa_addLeftBarButtonItem:a_viewController.IFA_modalDismissalDoneBarButtonItem];
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

- (void)ifa_notifySessionCompletionWithChangesMade:(BOOL)a_changesMade data:(id)a_data animated:(BOOL)a_animated{
    [self.ifa_presenter sessionDidCompleteForViewController:self changesMade:a_changesMade data:a_data
                                     shouldAnimateDismissal:a_animated];
    if([self.ifa_presenter isKindOfClass:[UIViewController class]]){
        [self IFA_assertManagedObjectContextCountForViewController:(UIViewController *)self.ifa_presenter];
    }
}

- (void)ifa_notifySessionCompletionWithChangesMade:(BOOL)a_changesMade data:(id)a_data {
    [self ifa_notifySessionCompletionWithChangesMade:a_changesMade data:a_data animated:YES];
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
    __weak UIViewController *l_weakSelf = self;
    if (self.presentedViewController) {
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
        UIViewController *l_presentedViewController = [IFAApplicationDelegate sharedInstance].semiModalViewController; // Add retain cycle
        [self dismissSemiModalViewWithCompletionBlock:^{
            if ([l_weakSelf conformsToProtocol:@protocol(IFAPresenter)]) {
                [l_weakSelf didDismissViewController:l_presentedViewController changesMade:a_changesMade data:a_data];
            }
        }];
    }
}

-(IFAAsynchronousWorkManager *)ifa_asynchronousWorkManager {
    return [IFAAsynchronousWorkManager sharedInstance];
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
-(BOOL)ifa_doneButtonSaves {
    return NO;
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

- (void)ifa_setEditing:(BOOL)a_editing animated:(BOOL)a_animated {
    if (self.IFA_modalDismissalDoneBarButtonItem) {
        if (a_editing) {
            [self ifa_removeLeftBarButtonItem:self.IFA_modalDismissalDoneBarButtonItem];
        }else{
            [self ifa_addLeftBarButtonItem:self.IFA_modalDismissalDoneBarButtonItem];
        }
    }
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

- (void)ifa_viewDidLoad {
    
//    NSLog(@"ifa_viewDidLoad: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);

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
    if ([self.ifa_delegate respondsToSelector:@selector(viewController:didChangeContentSizeCategory:)]) {
        __weak __typeof(self) l_weakSelf = self;
        [self ifa_addNotificationObserverForName:UIContentSizeCategoryDidChangeNotification object:nil
                                           queue:nil
                                      usingBlock:^(NSNotification *a_note) {
                                          NSString *contentSizeCategory = a_note.userInfo[UIContentSizeCategoryNewValueKey];
//                                          NSLog(@"UIContentSizeCategoryDidChangeNotification: %@", contentSizeCategory);
                                          [l_weakSelf.ifa_delegate viewController:l_weakSelf
                                                     didChangeContentSizeCategory:contentSizeCategory];
                                      }
                                     removalTime:IFAViewControllerNotificationObserverRemovalTimeDealloc];
    }

    // Configure keyboard passthrough view
    if (self.ifa_shouldUseKeyboardPassthroughView) {
        self.IFA_keyboardPassthroughView.shouldDismissKeyboardOnNonTextInputInteractions = YES;
    }

    // Save for later assertion
    self.IFA_childManagedObjectContextCountOnViewDidLoad = [IFAPersistenceManager sharedInstance].childManagedObjectContexts.count;

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

}

- (void)ifa_viewWillAppear {
    
//    NSLog(@"ifa_viewWillAppear: %@, topViewController: %@, visibleViewController: %@, presentingViewController: %@, presentedViewController: %@", [self description], [self.navigationController.topViewController description], [self.navigationController.visibleViewController description], [self.presentingViewController description], [self.presentedViewController description]);

#ifdef IFA_AVAILABLE_Help
    // Add the help button if help is enabled for this view controller
    if (self.ifa_helpBarButtonItem) {
        [self ifa_insertRightBarButtonItem:self.ifa_helpBarButtonItem atIndex:0];
    }
#endif

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

    // Manage left sliding menu button visibility
    [self IFA_showLeftSlidingPaneButtonIfRequired];

    // Set appearance
    [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceOnViewWillAppearForViewController:self];

    // Make sure toolbar is already visible when the view appears for the first time (only for top level view controllers)
    self.IFA_toolbarUpdatedBeforeViewAppeared = NO;
    BOOL isTopLevelViewControllerBeingPresentedForTheFirstTime = self.navigationController.visibleViewController==self
            && self.navigationController.viewControllers[0]==self
            && !self.ifa_isReturningVisibleViewController;
    BOOL isReturningModalPresenter = self.presentedViewController == self.navigationController.visibleViewController.navigationController;
    if (self.ifa_manageToolbar && (isTopLevelViewControllerBeingPresentedForTheFirstTime || isReturningModalPresenter)) {
        [self ifa_updateToolbarForEditing:self.editing animated:NO];
        self.IFA_toolbarUpdatedBeforeViewAppeared = YES;
    }

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

    self.ifa_hasViewAppeared = YES;

    // Set appearance
    id <IFAAppearanceTheme> l_appearanceTheme = [[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme];
    if ([l_appearanceTheme respondsToSelector:@selector(setAppearanceOnViewDidAppearForViewController:)]) {
        [l_appearanceTheme setAppearanceOnViewDidAppearForViewController:self];
    }

    if (self.ifa_manageToolbar && !self.IFA_toolbarUpdatedBeforeViewAppeared) {
        [self ifa_updateToolbarForEditing:self.editing animated:YES];
    }

#ifdef IFA_AVAILABLE_GoogleMobileAdsSupport
    [self ifa_startGoogleMobileAdsRequests];
#endif

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
    if (((UIViewController*) (self.navigationController.viewControllers)[0]).ifa_presentedAsModal) {
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

/*
-(void)ifa_releaseView {
    [self IFA_releaseViewForController:self];
}
*/

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

- (void)ifa_addNotificationObserverForName:(NSString *)a_name object:(id)a_obj queue:(NSOperationQueue *)a_queue
                                usingBlock:(void (^)(NSNotification *a_note))a_block
                               removalTime:(IFAViewControllerNotificationObserverRemovalTime)a_removalTime {
#ifndef NS_BLOCK_ASSERTIONS
    BOOL l_isObserverRemovalAutomationSupported =
    [self isKindOfClass:[IFACollectionViewController class]]
    || [self isKindOfClass:[IFAPageViewController class]]
    || [self isKindOfClass:[IFATableViewController class]]
    || [self isKindOfClass:[IFAViewController class]];
    NSAssert(l_isObserverRemovalAutomationSupported, @"Notification observer removal automation not supported by this class: %@", [self.class description]);
#endif
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
    [self ifa_addChildViewController:a_childViewController
                          parentView:a_parentView
                 shouldFillSuperview:a_shouldFillParentView
                   animationDuration:0
                          completion:nil];
}

- (void)ifa_addChildViewController:(UIViewController *)a_childViewController parentView:(UIView *)a_parentView
               shouldFillSuperview:(BOOL)a_shouldFillParentView animationDuration:(NSTimeInterval)a_animationDuration
                        completion:(void (^)(BOOL a_finished))a_completion {

    BOOL animated = a_animationDuration > 0;
    [a_childViewController beginAppearanceTransition:YES animated:animated];
    [self addChildViewController:a_childViewController];
    [a_parentView addSubview:a_childViewController.view];
    if (a_shouldFillParentView) {
        [a_childViewController.view ifa_addLayoutConstraintsToFillSuperview];
    }
    [a_childViewController didMoveToParentViewController:self];
    [a_childViewController endAppearanceTransition];

    if (animated) {

        a_childViewController.view.alpha = 0;
        void (^animations)() = ^{
            a_childViewController.view.alpha = 1;
        };
        [UIView animateWithDuration:a_animationDuration
                         animations:animations
                         completion:a_completion];

    } else {

        if (a_completion) {
            a_completion(YES);
        }

    }

}

- (void)ifa_removeFromParentViewController {
    [self ifa_removeFromParentViewControllerWithAnimationDuration:0 completion:nil];
}

- (void)ifa_removeFromParentViewControllerWithAnimationDuration:(NSTimeInterval)a_animationDuration completion:(void (^)(BOOL a_finished))a_completion {

    BOOL animated = a_animationDuration > 0;
    [self beginAppearanceTransition:NO animated:animated];

    __weak __typeof(self) weakSelf = self;

    void (^completion)(BOOL) = ^(BOOL finished) {
        [weakSelf willMoveToParentViewController:nil];
        [weakSelf.view removeFromSuperview];
        [weakSelf removeFromParentViewController];
        [weakSelf endAppearanceTransition];
        if (a_completion) {
            a_completion(finished);
        }
    };

    if (animated) {

        void (^animations)() = ^{
            weakSelf.view.alpha = 0;
        };
        [UIView animateWithDuration:a_animationDuration
                         animations:animations
                         completion:completion];

    } else {

        completion(YES);

    }

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

-(NSCalendar*)ifa_calendar {
    return [NSCalendar ifa_threadSafeCalendar];
}

- (void)ifa_presentAlertControllerWithTitle:(NSString *)a_title
                                    message:(NSString *)a_message
                                      style:(UIAlertControllerStyle)a_style
                                    actions:(NSArray *)a_actions
                                 completion:(void (^)(void))a_completion {
    NSString *title = a_title || a_style==UIAlertControllerStyleActionSheet ? a_title : @"";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:a_message
                                                                      preferredStyle:a_style];
    for (UIAlertAction *action in a_actions) {
        [alertController addAction:action];
    }
    [self presentViewController:alertController
                       animated:YES completion:a_completion];
}

- (void)ifa_presentAlertControllerWithTitle:(NSString *)a_title message:(NSString *)a_message {
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Continue"
                                                             style:UIAlertActionStyleDefault
                                                           handler:nil];
    [self ifa_presentAlertControllerWithTitle:a_title message:a_message
                                        style:UIAlertControllerStyleAlert actions:@[continueAction]
                                   completion:nil];
}

- (void)ifa_presentAlertControllerWithTitle:(NSString *)a_title message:(NSString *)a_message
                                      style:(UIAlertControllerStyle)a_style
                          actionButtonTitle:(NSString *)a_actionButtonTitle actionBlock:(void (^)())a_actionBlock {
    UIAlertAction *mainAction = [UIAlertAction actionWithTitle:a_actionButtonTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           if (a_actionBlock) {
                                                               a_actionBlock();
                                                           }
                                                       }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [self ifa_presentAlertControllerWithTitle:a_title message:a_message
                                        style:a_style actions:@[cancelAction, mainAction]
                                   completion:nil];
}

- (void)ifa_presentAlertControllerWithTitle:(NSString *)a_title message:(NSString *)a_message
               destructiveActionButtonTitle:(NSString *)a_destructiveActionButtonTitle
                     destructiveActionBlock:(void (^)())a_destructiveActionBlock
                                cancelBlock:(void (^)())a_cancelBlock {
    void (^destructiveActionHandler)(UIAlertAction *) = ^(UIAlertAction *action) {
        if (a_destructiveActionBlock) {
            a_destructiveActionBlock();
        }
    };
    UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:a_destructiveActionButtonTitle
                                                                style:UIAlertActionStyleDestructive
                                                              handler:destructiveActionHandler];
    void (^cancelActionHandler)(UIAlertAction *) = ^(UIAlertAction *action) {
        if (a_cancelBlock) {
            a_cancelBlock();
        }
    };
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:cancelActionHandler];
    [self ifa_presentAlertControllerWithTitle:a_title message:a_message
                                        style:UIAlertControllerStyleActionSheet
                                      actions:@[cancelAction, destructiveAction]
                                   completion:nil];
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

#pragma mark - IFAPresenter protocol

-(void)changesMadeByViewController:(UIViewController *)a_viewController{
    // Subclasses to override
}

- (void)sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                       data:(id)a_data shouldAnimateDismissal:(BOOL)a_shouldAnimateDismissal {
    self.ifa_changesMadeByPresentedViewController = a_changesMade;
    if (a_viewController.ifa_presentedAsModal) {
        [self ifa_dismissModalViewControllerWithChangesMade:a_changesMade data:a_data animated:a_shouldAnimateDismissal];
    }else{
        [a_viewController.navigationController popViewControllerAnimated:a_shouldAnimateDismissal];
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
    [self.ifa_presenter sessionDidCompleteForViewController:self changesMade:NO data:nil shouldAnimateDismissal:NO];
}

@end
