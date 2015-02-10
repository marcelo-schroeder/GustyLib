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
#import "CoreData/CoreData.h"
#import "UIViewController+IFA_KNSemiModal.h"

@class IFAAsynchronousWorkManager;
@class IFANavigationItemTitleView;
@class ODRefreshControl;

@protocol IFAAppearanceTheme;
@class IFAPassthroughView;
@protocol IFAViewControllerDelegate;

@interface UIViewController (IFACoreUI) <IFAPresenter, UIPopoverControllerDelegate>

@property (nonatomic, readonly) BOOL ifa_presentedAsModal;
@property (nonatomic, readonly) BOOL ifa_isMasterViewController;
@property (nonatomic, readonly) BOOL ifa_isDetailViewController;
@property (nonatomic, readonly) BOOL ifa_needsToolbar;
@property (nonatomic, readonly) BOOL ifa_changesMadeByPresentedViewController;
@property (nonatomic, readonly) IFAAsynchronousWorkManager *ifa_asynchronousWorkManager;
@property (nonatomic, weak) id<IFAPresenter> ifa_presenter;
@property (nonatomic, weak) id<IFAViewControllerDelegate> ifa_delegate;
@property (nonatomic, strong, readonly) UIPopoverController *ifa_activePopoverController;
@property (nonatomic, strong, readonly) UIBarButtonItem *ifa_activePopoverControllerBarButtonItem;
@property (nonatomic, strong) NSString *ifa_subTitle;
@property (nonatomic, strong) IFANavigationItemTitleView *ifa_titleViewDefault;
@property (nonatomic, strong) IFANavigationItemTitleView *ifa_titleViewLandscapePhone;
@property (nonatomic, strong) ODRefreshControl *ifa_refreshControl;
@property (nonatomic, readonly) BOOL ifa_hasViewAppeared;
@property (nonatomic, strong) UIBarButtonItem *IFA_modalDismissalDoneBarButtonItem;

/**
* IMPORTANT: there is currently a potential issue if enabling this property. Refer to API documentation for the shouldDismissKeyboardOnNonTextInputInteractions property in IFAPassthroughView.h
*/
@property (nonatomic) BOOL ifa_shouldUseKeyboardPassthroughView;

// to be overriden by subclasses
@property (nonatomic, readonly) BOOL ifa_manageToolbar;
@property (nonatomic, readonly) BOOL ifa_doneButtonSaves;
@property (nonatomic, weak) UIViewController *ifa_previousVisibleViewController;

/**
* Adds a child view controller to self.
*
* The presentation transition is not animated.
* It also adds auto layout constraints so that the child view controller's view has the same size as the parent view.
* The implementation of this method conforms to the view controller containment patterns.
*
* @param a_childViewController Child view controller to add to self.
* @param a_parentView Parent view to add the child view controller's view as a subview of.
*/
- (void)ifa_addChildViewController:(UIViewController *)a_childViewController parentView:(UIView *)a_parentView;

/**
* Adds a child view controller to self.
*
* The presentation transition is not animated.
* The implementation of this method conforms to the view controller containment patterns.
*
* @param a_childViewController Child view controller to add to self.
* @param a_parentView Parent view to add the child view controller's view as a subview of.
* @param a_shouldFillParentView Indicates whether auto layout constraints should be added so that the child view controller's view has the same size as the parent view.
*/
- (void)ifa_addChildViewController:(UIViewController *)a_childViewController
                        parentView:(UIView *)a_parentView
               shouldFillSuperview:(BOOL)a_shouldFillParentView;

/**
* Adds a child view controller to self.
*
* The implementation of this method conforms to the view controller containment patterns.
*
* @param a_childViewController Child view controller to add to self.
* @param a_parentView Parent view to add the child view controller's view as a subview of.
* @param a_shouldFillParentView Indicates whether auto layout constraints should be added so that the child view controller's view has the same size as the parent view.
* @param a_animationDuration Duration of the presentation transition animation (in seconds). If set to 0, then no animation is used.
* @param a_completion Block to execute after the presentation transition has completed.
*/
- (void)ifa_addChildViewController:(UIViewController *)a_childViewController
                        parentView:(UIView *)a_parentView
               shouldFillSuperview:(BOOL)a_shouldFillParentView
                 animationDuration:(NSTimeInterval)a_animationDuration
                        completion:(void (^)(BOOL a_finished))a_completion;

/**
* Removes this view controller from its parent.
*
* The dismissal transition is not animated.
*/
- (void)ifa_removeFromParentViewController;

/**
* Removes this view controller from its parent.
*
* @param a_animationDuration Duration of the dismissal transition animation (in seconds). If set to 0, then no animation is used.
* @param a_completion Block to execute after the dismissal transition has completed.
*/
- (void)ifa_removeFromParentViewControllerWithAnimationDuration:(NSTimeInterval)a_animationDuration completion:(void (^)(BOOL a_finished))a_completion;

+ (instancetype)ifa_instantiateFromStoryboard;

+ (id)ifa_instantiateFromStoryboardWithViewControllerIdentifier:(NSString *)a_viewControllerIdentifier;

+ (NSString *)ifa_storyboardName;

+ (NSString *)ifa_storyboardNameIPhoneSuffix;

+ (NSString *)ifa_storyboardNameIPadSuffix;

+ (BOOL)ifa_isStoryboardDeviceSpecific;

/**
* @returns Thread safe calendar.
*/
- (NSCalendar *)ifa_calendar;

/**
* Presents an instance of a UIAlertController according to the specifications provided.
* It animates transitions by default.
* @param a_title The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
* @param a_message Descriptive text that provides additional details about the reason for the alert.
* @param a_style The style to use when presenting the alert controller. Use this parameter to configure the alert controller as an action sheet or as a modal alert.
* @param a_actions An array of UIAlertAction instances.
* @param a_completion A completion block to be executed after the view transition has been completed.
*/
- (void)ifa_presentAlertControllerWithTitle:(NSString *)a_title
                                    message:(NSString *)a_message
                                      style:(UIAlertControllerStyle)a_style
                                    actions:(NSArray *)a_actions
                                 completion:(void (^)(void))a_completion;

/**
* Presents an instance of a UIAlertController with title and message provided.
* It animates transitions by default and it shows a single button to dismiss the alert: "Continue".
* @param a_title The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
* @param a_message Descriptive text that provides additional details about the reason for the alert.
*/
- (void)ifa_presentAlertControllerWithTitle:(NSString *)a_title
                                    message:(NSString *)a_message;

/**
* Presents an instance of a UIAlertController according to the specifications provided.
* It animates transitions by default and it shows two buttons: an action button with the title provided and a "Cancel" button.
* @param a_title The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
* @param a_message Descriptive text that provides additional details about the reason for the alert.
* @param a_style The style to use when presenting the alert controller. Use this parameter to configure the alert controller as an action sheet or as a modal alert.
* @param a_actionButtonTitle Title for the action button.
* @param a_actionBlock Block to be executed when the action button is tapped.
*/
- (void)ifa_presentAlertControllerWithTitle:(NSString *)a_title message:(NSString *)a_message
                                      style:(UIAlertControllerStyle)a_style
                          actionButtonTitle:(NSString *)a_actionButtonTitle actionBlock:(void (^)())a_actionBlock;

/**
* Presents a destructive action version of a UIAlertController according to the specifications provided.
* It animates transitions by default and it shows two buttons: a destructive action button with the title provided and a "Cancel" button.
* @param a_title The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
* @param a_message Descriptive text that provides additional details about the reason for the alert.
* @param a_destructiveActionButtonTitle Title for the destructive action button.
* @param a_destructiveActionBlock Block to be executed when the destructive action button is tapped.
* @param a_cancelBlock Block to be executed when the cancel button is tapped.
*/
- (void)ifa_presentAlertControllerWithTitle:(NSString *)a_title message:(NSString *)a_message
               destructiveActionButtonTitle:(NSString *)a_destructiveActionButtonTitle
                     destructiveActionBlock:(void (^)())a_destructiveActionBlock
                                cancelBlock:(void (^)())a_cancelBlock;

- (void)ifa_onKeyboardNotification:(NSNotification *)a_notification;

- (void)ifa_updateToolbarForEditing:(BOOL)a_editing animated:(BOOL)a_animated;

-(BOOL)ifa_isReturningVisibleViewController;
-(UIView*)ifa_viewForActionSheet;

-(BOOL)ifa_hasFixedSize;

// This callback can be used to customise, for instance, the popover controller's passthroughViews array
- (void)ifa_didPresentPopoverController:(UIPopoverController *)a_popoverController;

-(void)ifa_presentModalFormViewController:(UIViewController*)a_viewController;

/* Presenting modeal selection view controllers */
- (void)ifa_presentModalSelectionViewController:(UIViewController *)a_viewController
                              fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem
             shouldWrapWithNavigationController:(BOOL)a_shouldWrapWithNavigationController;

- (void)ifa_presentModalSelectionViewController:(UIViewController *)a_viewController
                              fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem;

- (void)ifa_presentModalSelectionViewController:(UIViewController *)a_viewController fromRect:(CGRect)a_fromRect
                                         inView:(UIView *)a_view
             shouldWrapWithNavigationController:(BOOL)a_shouldWrapWithNavigationController;

- (void)ifa_presentModalSelectionViewController:(UIViewController *)a_viewController fromRect:(CGRect)a_fromRect
                                         inView:(UIView *)a_view;

-(void)ifa_presentModalViewController:(UIViewController *)a_viewController
                    presentationStyle:(UIModalPresentationStyle)a_presentationStyle transitionStyle:(UIModalTransitionStyle)a_transitionStyle;
-(void)ifa_presentModalViewController:(UIViewController *)a_viewController
                    presentationStyle:(UIModalPresentationStyle)a_presentationStyle
                      transitionStyle:(UIModalTransitionStyle)a_transitionStyle shouldAddDoneButton:(BOOL)a_shouldAddDoneButton;

- (void)ifa_presentModalViewController:(UIViewController *)a_viewController
                     presentationStyle:(UIModalPresentationStyle)a_presentationStyle
                       transitionStyle:(UIModalTransitionStyle)a_transitionStyle
                   shouldAddDoneButton:(BOOL)a_shouldAddDoneButton customSize:(CGSize)a_customSize;

/* Presenting popover controllers */
-(void)ifa_presentPopoverController:(UIPopoverController *)a_popoverController fromBarButtonItem:(UIBarButtonItem *)a_fromBarButtonItem;
-(void)ifa_presentPopoverController:(UIPopoverController *)a_popoverController fromRect:(CGRect)a_fromRect inView:(UIView *)a_view;

/* Presenting view controller methods */
- (void)ifa_dismissModalViewControllerWithChangesMade:(BOOL)a_changesMade data:(id)a_data;
- (void)ifa_dismissModalViewControllerWithChangesMade:(BOOL)a_changesMade data:(id)a_data animated:(BOOL)a_animate;

/* Presented view controller methods */
- (void)ifa_notifySessionCompletionWithChangesMade:(BOOL)a_changesMade data:(id)a_data;
- (void)ifa_notifySessionCompletionWithChangesMade:(BOOL)a_changesMade data:(id)a_data animated:(BOOL)a_animated;
-(void)ifa_notifySessionCompletion;
- (void)ifa_notifySessionCompletionAnimated:(BOOL)a_animate;

-(UIViewController*)ifa_mainViewController;
-(BOOL)ifa_shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
-(NSUInteger)ifa_supportedInterfaceOrientations;
-(void)ifa_willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
-(void)ifa_willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
-(void)ifa_didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
-(void)ifa_dismissMenuPopoverController;
-(void)ifa_dismissMenuPopoverControllerWithAnimation:(BOOL)a_animated;
-(void)ifa_resetActivePopoverController;

-(void)ifa_addLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem;
-(void)ifa_insertLeftBarButtonItem:(UIBarButtonItem *)a_barButtonItem atIndex:(NSUInteger)a_index;
-(void)ifa_removeLeftBarButtonItem:(UIBarButtonItem*)a_barButtonItem;

-(void)ifa_addRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem;
-(void)ifa_insertRightBarButtonItem:(UIBarButtonItem *)a_barButtonItem atIndex:(NSUInteger)a_index;
-(void)ifa_removeRightBarButtonItem:(UIBarButtonItem*)a_barButtonItem;

-(void)ifa_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
-(id<IFAAppearanceTheme>)ifa_appearanceTheme;
-(UIStoryboard*)ifa_commonStoryboard;

-(void)ifa_reset;

-(UINavigationItem*)ifa_navigationItem;

//-(void)ifa_releaseView;

- (UIPopoverArrowDirection)ifa_permittedPopoverArrowDirectionForViewController:(UIViewController *)a_viewController;

- (void)ifa_presentActivityViewControllerFromBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                                                   webView:(UIWebView *)a_webView;

- (void)ifa_presentActivityViewControllerFromBarButtonItem:(UIBarButtonItem *)a_barButtonItem
                                                   subject:(NSString *)a_subject url:(NSURL *)a_url;

// Message "beginRefreshing" to self.ifa_refreshControl but does not show control
-(void)ifa_beginRefreshingWithScrollView:(UIScrollView*)a_scrollView;
// Message "beginRefreshing" to self.ifa_refreshControl with option to show control or not
-(void)ifa_beginRefreshingWithScrollView:(UIScrollView *)a_scrollView showControl:(BOOL)a_shouldShowControl;
-(void)ifa_showRefreshControl:(UIControl *)a_control inScrollView:(UIScrollView*)a_scrollView;

-(UIPopoverController*)ifa_newPopoverControllerWithContentViewController:(UIViewController*)a_contentViewController;

/* to be overriden by subclasses */

- (NSArray*)ifa_editModeToolbarItems;
- (NSArray*)ifa_nonEditModeToolbarItems;

- (BOOL)ifa_shouldShowLeftSlidingPaneButton;

- (void)ifa_addToNavigationBarForSlidingMenuBarButtonItem:(UIBarButtonItem *)a_slidingMenuBarButtonItem;

- (void)ifa_viewWillAppear;
- (void)ifa_viewDidAppear;
- (void)ifa_viewWillDisappear;
- (void)ifa_viewDidDisappear;
- (void)ifa_viewDidLoad;
- (void)ifa_viewDidUnload;
- (void)ifa_onApplicationWillEnterForegroundNotification:(NSNotification*)aNotification;
- (void)ifa_onApplicationDidBecomeActiveNotification:(NSNotification*)aNotification;
- (void)ifa_onApplicationWillResignActiveNotification:(NSNotification*)aNotification;
- (void)ifa_onApplicationDidEnterBackgroundNotification:(NSNotification *)aNotification;
- (void)ifa_setEditing:(BOOL)a_editing animated:(BOOL)a_animated;

- (void)ifa_dealloc;

// UI state update callbacks
-(void)ifa_updateScreenDecorationState;
-(void)ifa_updateNavigationItemState;
-(void)ifa_updateToolbarNavigationButtonState;

-(void)ifa_onDoneButtonTap:(UIBarButtonItem*)a_barButtonItem;

/**
* Indicates the various times when notification observers should be removed at.
*/
typedef NS_ENUM(NSUInteger, IFAViewControllerNotificationObserverRemovalTime) {
    IFAViewControllerNotificationObserverRemovalTimeNone,               // The observer will not be removed.
    IFAViewControllerNotificationObserverRemovalTimeDealloc,            // The observer will be removed when this object's dealloc method runs.
};

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
- (void)ifa_addNotificationObserverForName:(NSString *)a_name object:(id)a_obj queue:(NSOperationQueue *)a_queue
                                usingBlock:(void (^)(NSNotification *a_note))a_block
                               removalTime:(IFAViewControllerNotificationObserverRemovalTime)a_removalTime;

- (BOOL)ifa_isVisibleTopViewController;

@end

@protocol IFAViewControllerDelegate <NSObject>

@optional

/**
* Delegate callback to notify that the content size category has changed (i.e. user's preferred font size).
* @param a_viewController The sender.
* @param a_contentSizeCategory The new user's preferred font size.
*/
- (void)viewController:(UIViewController *)a_viewController didChangeContentSizeCategory:(NSString *)a_contentSizeCategory;

@end
