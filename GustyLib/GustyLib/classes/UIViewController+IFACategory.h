//
//  UIViewController+IFACategory.h
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

#import "IFAPresenter.h"
#import "GADBannerViewDelegate.h"
#import "IFAHelpManager.h"
#import "CoreData/CoreData.h"

@class IFAAsynchronousWorkManager;
@class IFANavigationItemTitleView;
@class ODRefreshControl;

@protocol IFAAppearanceTheme;
@class IFAPassthroughView;
@protocol IFAViewControllerDelegate;

@interface UIViewController (IFACategory) <IFAHelpTargetContainer, IFAPresenter, GADBannerViewDelegate, NSFetchedResultsControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, readonly) BOOL IFA_presentedAsModal;
@property (nonatomic, readonly) BOOL IFA_isMasterViewController;
@property (nonatomic, readonly) BOOL IFA_isDetailViewController;
@property (nonatomic, readonly) BOOL IFA_needsToolbar;
@property (nonatomic, readonly) BOOL IFA_helpMode;
@property (nonatomic, readonly) BOOL IFA_changesMadeByPresentedViewController;
@property (nonatomic, readonly) IFAAsynchronousWorkManager *IFA_asynchronousWorkManager;
@property (nonatomic, weak) id<IFAPresenter> IFA_presenter;
@property (nonatomic, strong, readonly) UIPopoverController *IFA_activePopoverController;
@property (nonatomic, strong, readonly) UIBarButtonItem *IFA_activePopoverControllerBarButtonItem;
@property (nonatomic, strong) NSString *IFA_subTitle;
@property (nonatomic, strong) NSString *IFA_helpTargetId;
@property (nonatomic, strong) IFANavigationItemTitleView *IFA_titleViewDefault;
@property (nonatomic, strong) IFANavigationItemTitleView *IFA_titleViewLandscapePhone;
@property (nonatomic, strong) UIView *IFA_adContainerView;
@property (nonatomic, strong) ODRefreshControl *IFA_refreshControl;
@property (nonatomic, strong, readonly) NSFetchedResultsController *IFA_activeFetchedResultsController;
@property (nonatomic) BOOL IFA_shouldUseKeyboardPassthroughView;

// to be overriden by subclasses
@property (nonatomic, readonly) BOOL IFA_manageToolbar;
@property (nonatomic, readonly) BOOL IFA_doneButtonSaves;
@property (nonatomic, weak) UIViewController *IFA_previousVisibleViewController;

/**
* Adds a child view controller to self.
* It also adds auto layout constraints so that the child view controller's view has the same size as the parent view.
*
* @param a_childViewController Child view controller to add to self.
* @param a_parentView Parent view to add the child view controller's view as a subview of.
*/
- (void)IFA_addChildViewController:(UIViewController *)a_childViewController parentView:(UIView *)a_parentView;

- (void)IFA_addChildViewController:(UIViewController *)a_childViewController parentView:(UIView *)a_parentView
               shouldFillSuperview:(BOOL)a_shouldFillParentView;

/**
* Removes this view controller from its parent.
*/
- (void)IFA_removeFromParentViewController;

+ (instancetype)IFA_instantiateFromStoryboard;

+ (id)IFA_instantiateFromStoryboardWithViewControllerIdentifier:(NSString *)a_viewControllerIdentifier;

+ (NSString *)IFA_storyboardName;

+ (NSString *)IFA_storyboardNameIPhoneSuffix;

+ (NSString *)IFA_storyboardNameIPadSuffix;

+ (BOOL)IFA_isStoryboardDeviceSpecific;

- (void)IFA_onKeyboardNotification:(NSNotification *)a_notification;

-(NSString*)IFA_helpTargetIdForName:(NSString*)a_name;

- (void)IFA_updateToolbarForMode:(BOOL)anEditModeFlag animated:(BOOL)anAnimatedFlag;

-(BOOL)IFA_isReturningVisibleViewController;
-(UIView*)IFA_viewForActionSheet;

-(BOOL)IFA_hasFixedSize;

// This callback can be used to customise, for instance, the popover controller's passthroughViews array
- (void)IFA_didPresentPopoverController:(UIPopoverController *)a_popoverController;

-(void)IFA_presentModalFormViewController:(UIViewController*)a_viewController;
-(void)IFA_presentModalSelectionViewController:(UIViewController *)a_viewController fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem;
-(void)IFA_presentModalSelectionViewController:(UIViewController *)a_viewController fromRect:(CGRect)a_fromRect inView:(UIView *)a_view;
-(void)IFA_presentModalViewController:(UIViewController *)a_viewController
                    presentationStyle:(UIModalPresentationStyle)a_presentationStyle transitionStyle:(UIModalTransitionStyle)a_transitionStyle;
-(void)IFA_presentModalViewController:(UIViewController *)a_viewController
                    presentationStyle:(UIModalPresentationStyle)a_presentationStyle
                      transitionStyle:(UIModalTransitionStyle)a_transitionStyle shouldAddDoneButton:(BOOL)a_shouldAddDoneButton;

- (void)IFA_presentModalViewController:(UIViewController *)a_viewController
                     presentationStyle:(UIModalPresentationStyle)a_presentationStyle
                       transitionStyle:(UIModalTransitionStyle)a_transitionStyle
                   shouldAddDoneButton:(BOOL)a_shouldAddDoneButton customSize:(CGSize)a_customSize;

-(void)IFA_presentPopoverController:(UIPopoverController *)a_popoverController fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem;
-(void)IFA_presentPopoverController:(UIPopoverController *)a_popoverController fromRect:(CGRect)a_fromRect inView:(UIView *)a_view;

/* Presenting view controller methods */
- (void)IFA_dismissModalViewControllerWithChangesMade:(BOOL)a_changesMade data:(id)a_data;

/* Presented view controller methods */
- (void)IFA_notifySessionCompletionWithChangesMade:(BOOL)a_changesMade data:(id)a_data;
-(void)IFA_notifySessionCompletion;

-(UIViewController*)IFA_mainViewController;
-(BOOL)IFA_shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
-(NSUInteger)IFA_supportedInterfaceOrientations;
-(void)IFA_willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
-(void)IFA_willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
-(void)IFA_didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
-(void)IFA_dismissMenuPopoverController;
-(void)IFA_dismissMenuPopoverControllerWithAnimation:(BOOL)a_animated;
-(void)IFA_resetActivePopoverController;

-(void)IFA_addLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem;
-(void)IFA_insertLeftBarButtonItem:(UIBarButtonItem *)a_barButtonItem atIndex:(NSUInteger)a_index;
-(void)IFA_removeLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem;

-(void)IFA_addRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem;
-(void)IFA_insertRightBarButtonItem:(UIBarButtonItem *)a_barButtonItem atIndex:(NSUInteger)a_index;
-(void)IFA_removeRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem;

-(void)IFA_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
-(id<IFAAppearanceTheme>)IFA_appearanceTheme;
-(UIStoryboard*)IFA_commonStoryboard;

-(void)IFA_reset;

-(UINavigationItem*)IFA_navigationItem;
-(void)IFA_registerForHelp;
-(NSString*)IFA_editBarButtonItemHelpTargetId;

-(void)IFA_openUrl:(NSURL*)a_url;

-(void)IFA_releaseView;

-(NSString*)IFA_accessibilityLabelForKeyPath:(NSString*)a_keyPath;
-(NSString*)IFA_accessibilityLabelForName:(NSString*)a_name;

- (UIPopoverArrowDirection)IFA_permittedPopoverArrowDirectionForViewController:(UIViewController *)a_viewController;

- (void)IFA_presentActivityViewControllerFromBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                                                   webView:(UIWebView *)a_webView;

- (void)IFA_presentActivityViewControllerFromBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                                                   subject:(NSString *)a_subject url:(NSURL *)a_url;

- (CGSize)IFA_gadAdFrameSize;

- (GADBannerView*)IFA_gadBannerView;

// Message "beginRefreshing" to self.IFA_refreshControl but does not show control
-(void)IFA_beginRefreshingWithScrollView:(UIScrollView*)a_scrollView;
// Message "beginRefreshing" to self.IFA_refreshControl with option to show control or not
-(void)IFA_beginRefreshingWithScrollView:(UIScrollView *)a_scrollView showControl:(BOOL)a_shouldShowControl;
-(void)IFA_showRefreshControl:(UIControl *)a_control inScrollView:(UIScrollView*)a_scrollView;

-(UIPopoverController*)IFA_newPopoverControllerWithContentViewController:(UIViewController*)a_contentViewController;

/* to be overriden by subclasses */

- (NSArray*)IFA_editModeToolbarItems;
- (NSArray*)IFA_nonEditModeToolbarItems;
- (void)IFA_viewWillAppear;

- (BOOL)IFA_shouldShowLeftSlidingPaneButton;

- (void)IFA_addToNavigationBarForSlidingMenuBarButtonItem:(UIBarButtonItem *)a_slidingMenuBarButtonItem;

- (void)IFA_viewDidAppear;
- (void)IFA_viewWillDisappear;
- (void)IFA_viewDidDisappear;
- (void)IFA_viewDidLoad;
- (void)IFA_viewDidUnload;
- (void)IFA_onApplicationWillEnterForegroundNotification:(NSNotification*)aNotification;
- (void)IFA_onApplicationDidBecomeActiveNotification:(NSNotification*)aNotification;
- (void)IFA_onApplicationWillResignActiveNotification:(NSNotification*)aNotification;
- (void)IFA_onApplicationDidEnterBackgroundNotification:(NSNotification *)aNotification;

- (void)IFA_dealloc;
-(UIView*)IFA_nonAdContainerView;
-(BOOL)IFA_shouldEnableAds;

// UI state update callbacks
-(void)IFA_updateScreenDecorationState;
-(void)IFA_updateNavigationItemState;
-(void)IFA_updateToolbarNavigationButtonState;

-(void)IFA_onDoneButtonTap:(UIBarButtonItem*)a_barButtonItem;

-(void)IFA_startAdRequests;
-(void)IFA_stopAdRequests;

/**
* Indicates the various times when notification observers should be removed at.
*/
typedef enum{
    IFAViewControllerNotificationObserverRemovalTimeNone,               // The observer will not be removed.
    IFAViewControllerNotificationObserverRemovalTimeDealloc,            // The observer will be removed when this object's dealloc method runs.
} IFAViewControllerNotificationObserverRemovalTime;

/**
* Convenience method for adding notification observers with automated removal.
* The initial parameters are identical to the ones taken by addObserverForName:object:queue:usingBlock: from NSNotificationCenter.
* The observer created will then be removed at the time indicated.
* Observer removal automation only works with certain GustyLib classes or subclasses.
* Currently these are the classes that support observer removal automation: IFACollectionViewController, IFAPageViewController, IFATableViewController and IFAViewController.
* @param a_name The name of the notification for which to register the observer; that is, only notifications with this name are used to add the block to the operation queue. If you pass nil, the notification center doesn’t use a notification’s name to decide whether to add the block to the operation queue.
* @param a_obj The object whose notifications you want to add the block to the operation queue. If you pass nil, the notification center doesn’t use a notification’s sender to decide whether to add the block to the operation queue.
* @param a_queue The operation queue to which block should be added. If you pass nil, the block is run synchronously on the posting thread.
* @param a_block The block to be executed when the notification is received. The block is copied by the notification center and (the copy) held until the observer registration is removed. The block takes one argument: notification. The notification.
* @param a_removalTime Indicates when the observer should be removed. Please read the typedef's declaration comments for further details.
*/
- (void)addNotificationObserverForName:(NSString *)a_name object:(id)a_obj queue:(NSOperationQueue *)a_queue
                            usingBlock:(void (^)(NSNotification *a_note))a_block
                           removalTime:(IFAViewControllerNotificationObserverRemovalTime)a_removalTime;

#pragma mark - IFAHelpTargetContainer

- (BOOL)IFA_isVisibleTopViewController;

- (void)IFA_updateNonAdContainerViewFrameWithAdBannerViewHeight:(CGFloat)a_adBannerViewHeight;

// Analytics
-(void)IFA_logAnalyticsScreenEntry;

/* NSFetchedResultsController */
// Override and return one instance here if you want to enable fetched results controller functionality
-(NSFetchedResultsController*)IFA_fetchedResultsController;
// This can be overriden to provide a different delegate for the fetched results controller or even to nil it to prevent the standard UI updates from occurring
-(id<NSFetchedResultsControllerDelegate>)IFA_fetchedResultsControllerDelegate;
// This can also be overriden by subclasses to provide custom behaviour
-(void)IFA_configureFetchedResultsControllerAndPerformFetch;

@end
