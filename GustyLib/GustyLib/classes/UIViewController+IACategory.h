//
//  UIViewController+IACategory.h
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

#import "IAUIPresenter.h"
#import "GADBannerViewDelegate.h"
#import "IAHelpManager.h"
#import "CoreData/CoreData.h"

@class IAAsynchronousWorkManager;
@class IAUINavigationItemTitleView;
@class ODRefreshControl;

@protocol IAUIAppearanceTheme;
@class IAUIPassthroughView;

@interface UIViewController (IACategory) <IAHelpTargetContainer, IAUIPresenter, GADBannerViewDelegate, NSFetchedResultsControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, readonly) BOOL p_presentedAsModal;
@property (nonatomic, readonly) BOOL p_isMasterViewController;
@property (nonatomic, readonly) BOOL p_isDetailViewController;
@property (nonatomic, readonly) BOOL p_needsToolbar;
@property (nonatomic, readonly) BOOL p_helpMode;
@property (nonatomic, readonly) BOOL p_changesMadeByPresentedViewController;
@property (nonatomic, readonly) IAAsynchronousWorkManager *p_aom;
@property (nonatomic) id<IAUIPresenter> p_presenter;
@property (nonatomic, strong, readonly) UIPopoverController *p_activePopoverController;
@property (nonatomic, strong, readonly) UIBarButtonItem *p_activePopoverControllerBarButtonItem;
@property (nonatomic, strong) NSString *p_subTitle;
@property (nonatomic, strong) NSString *p_helpTargetId;
@property (nonatomic, strong) IAUINavigationItemTitleView *p_titleViewDefault;
@property (nonatomic, strong) IAUINavigationItemTitleView *p_titleViewLandscapePhone;
@property (nonatomic, strong) UIView *p_adContainerView;
@property (nonatomic, strong) ODRefreshControl *p_refreshControl;
@property (nonatomic, strong, readonly) NSFetchedResultsController *p_fetchedResultsController;
@property (nonatomic) BOOL p_shouldUseKeyboardPassthroughView;

// to be overriden by subclasses
@property (nonatomic, readonly) BOOL p_manageToolbar;
@property (nonatomic, readonly) BOOL p_doneButtonSaves;
@property (nonatomic, weak) UIViewController *p_previousVisibleViewController;

/**
* Adds a child view controller to self.
* It also adds auto layout constraints so that the child view controller's view has the same size as the parent view.
*
* @param a_childViewController Child view controller to add to self.
* @param a_parentView Parent view to add the child view controller's view as a subview of.
*/
- (void)m_addChildViewController:(UIViewController *)a_childViewController parentView:(UIView *)a_parentView;

- (void)m_addChildViewController:(UIViewController *)a_childViewController parentView:(UIView *)a_parentView
                                                                  shouldFillSuperview:(BOOL)a_shouldFillParentView;

/**
* Removes this view controller from its parent.
*/
- (void)m_removeFromParentViewController;

+ (instancetype)m_instantiateFromStoryboard;

+ (id)m_instantiateFromStoryboardWithViewControllerIdentifier:(NSString *)a_viewControllerIdentifier;

+ (NSString *)m_storyboardName;

+ (NSString *)m_storyboardNameIPhoneSuffix;

+ (NSString *)m_storyboardNameIPadSuffix;

+ (BOOL)m_isStoryboardDeviceSpecific;

- (void)m_onKeyboardNotification:(NSNotification *)a_notification;

-(NSString*)m_helpTargetIdForName:(NSString*)a_name;

- (void)m_updateToolbarForMode:(BOOL)anEditModeFlag animated:(BOOL)anAnimatedFlag;

-(BOOL)m_isReturningVisibleViewController;
//-(BOOL)m_isLeavingVisibleViewController;
-(UIView*)m_viewForActionSheet;

-(BOOL)m_hasFixedSize;

// This callback can be used to customise, for instance, the popover controller's passthroughViews array
- (void)m_didPresentPopoverController:(UIPopoverController *)a_popoverController;

-(void)m_presentModalFormViewController:(UIViewController*)a_viewController;
-(void)m_presentModalSelectionViewController:(UIViewController*)a_viewController fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem;
-(void)m_presentModalSelectionViewController:(UIViewController*)a_viewController fromRect:(CGRect)a_fromRect inView:(UIView *)a_view;
-(void)m_presentModalViewController:(UIViewController*)a_viewController presentationStyle:(UIModalPresentationStyle)a_presentationStyle transitionStyle:(UIModalTransitionStyle)a_transitionStyle;
-(void)m_presentModalViewController:(UIViewController*)a_viewController presentationStyle:(UIModalPresentationStyle)a_presentationStyle transitionStyle:(UIModalTransitionStyle)a_transitionStyle shouldAddDoneButton:(BOOL)a_shouldAddDoneButton;

- (void)m_presentModalViewController:(UIViewController *)a_viewController
                   presentationStyle:(UIModalPresentationStyle)a_presentationStyle
                     transitionStyle:(UIModalTransitionStyle)a_transitionStyle
                 shouldAddDoneButton:(BOOL)a_shouldAddDoneButton customSize:(CGSize)a_customSize;

-(void)m_presentPopoverController:(UIPopoverController*)a_popoverController fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem;
-(void)m_presentPopoverController:(UIPopoverController*)a_popoverController fromRect:(CGRect)a_fromRect inView:(UIView *)a_view;

/* Presenting view controller methods */
- (void)m_dismissModalViewControllerWithChangesMade:(BOOL)a_changesMade data:(id)a_data;

/* Presented view controller methods */
- (void)m_notifySessionCompletionWithChangesMade:(BOOL)a_changesMade data:(id)a_data;
-(void)m_notifySessionCompletion;

-(UIViewController*)m_mainViewController;
-(BOOL)m_shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
-(NSUInteger)m_supportedInterfaceOrientations;
-(void)m_willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
-(void)m_willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation duration:(NSTimeInterval)duration;
-(void)m_didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
-(void)m_dismissMenuPopoverController;
-(void)m_dismissMenuPopoverControllerWithAnimation:(BOOL)a_animated;
-(void)m_resetActivePopoverController;

-(void)m_addLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem;
-(void)m_insertLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem atIndex:(NSUInteger)a_index;
-(void)m_removeLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem;

-(void)m_addRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem;
-(void)m_insertRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem atIndex:(NSUInteger)a_index;
-(void)m_removeRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem;

-(void)m_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
-(id<IAUIAppearanceTheme>)m_appearanceTheme;
-(UIStoryboard*)m_commonStoryboard;
//-(void)m_updateEditButtonItemAccessibilityLabel;

-(void)m_reset;

-(UINavigationItem*)m_navigationItem;
-(void)m_registerForHelp;
-(NSString*)m_editBarButtonItemHelpTargetId;

-(void)m_openUrl:(NSURL*)a_url;
-(void)m_openSavedUrl;

-(void)m_releaseView;

-(NSString*)m_accessibilityLabelForKeyPath:(NSString*)a_keyPath;
-(NSString*)m_accessibilityLabelForName:(NSString*)a_name;

- (UIPopoverArrowDirection)m_permittedPopoverArrowDirectionForViewController:(UIViewController *)a_viewController;

- (void)m_presentActivityViewControllerFromBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                                                 webView:(UIWebView *)a_webView;

- (void)m_presentActivityViewControllerFromBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                                                 subject:(NSString *)a_subject url:(NSURL *)a_url;

- (CGSize)m_gadAdFrameSize;

- (GADBannerView*)m_gadBannerView;

// Message "beginRefreshing" to self.p_refreshControl but does not show control
-(void)m_beginRefreshingWithScrollView:(UIScrollView*)a_scrollView;
// Message "beginRefreshing" to self.p_refreshControl with option to show control or not
-(void)m_beginRefreshingWithScrollView:(UIScrollView*)a_scrollView showControl:(BOOL)a_shouldShowControl;
-(void)m_showRefreshControl:(UIControl*)a_control inScrollView:(UIScrollView*)a_scrollView;

-(UIPopoverController*)m_newPopoverControllerWithContentViewController:(UIViewController*)a_contentViewController;

/* to be overriden by subclasses */

- (NSArray*)m_editModeToolbarItems;
- (NSArray*)m_nonEditModeToolbarItems;
- (void)m_viewWillAppear;

- (BOOL)m_shouldShowLeftSlidingPaneButton;

- (void)m_addToNavigationBarForSlidingMenuBarButtonItem:(UIBarButtonItem *)a_slidingMenuBarButtonItem;

- (void)m_viewDidAppear;
- (void)m_viewWillDisappear;
- (void)m_viewDidDisappear;
- (void)m_viewDidLoad;
- (void)m_viewDidUnload;
- (void)m_onApplicationWillEnterForegroundNotification:(NSNotification*)aNotification;
- (void)m_onApplicationDidBecomeActiveNotification:(NSNotification*)aNotification;
- (void)m_onApplicationWillResignActiveNotification:(NSNotification*)aNotification;
- (void)m_onApplicationDidEnterBackgroundNotification:(NSNotification *)aNotification;

- (void)m_dealloc;
-(UIView*)m_nonAdContainerView;
-(BOOL)m_shouldEnableAds;

// UI state update callbacks
-(void)m_updateScreenDecorationState;
-(void)m_updateNavigationItemState;
-(void)m_updateToolbarNavigationButtonState;

-(void)m_onDoneButtonTap:(UIBarButtonItem*)a_barButtonItem;

-(void)m_startAdRequests;
-(void)m_stopAdRequests;

//-(void)m_simulateMemoryWarning;

#pragma mark - IAHelpTargetContainer

- (BOOL)m_isVisibleTopViewController;

- (void)m_updateNonAdContainerViewFrameWithAdBannerViewHeight:(CGFloat)a_adBannerViewHeight;

-(NSArray*)helpTargets;
-(UIView*)helpModeToggleView;
-(UIView*)targetView;
-(void)didEnterHelpMode;
-(void)willExitHelpMode;

// Analytics
-(void)m_logAnalyticsScreenEntry;

/* NSFetchedResultsController */
// Override and return one instance here if you want to enable fetched results controller functionality
-(NSFetchedResultsController*)m_fetchedResultsController;
// This can be overriden to provide a different delegate for the fetched results controller or even to nil it to prevent the standard UI updates from occurring
-(id<NSFetchedResultsControllerDelegate>)m_fetchedResultsControllerDelegate;
// This can also be overriden by subclasses to provide custom behaviour
-(void)m_configureFetchedResultsControllerAndPerformFetch;

@end
