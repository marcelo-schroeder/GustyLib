//
//  IACommon.h
//  Gusty
//
//  Created by Marcelo Schroeder on 30/07/10.
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

// Frameworks
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <GLKit/GLKit.h>
#import <AdSupport/AdSupport.h>
#import <objc/message.h>    // added so I could use objc_msgSend to get rid of ARC compiler warnings for performSelector method calls

/*************/
/* 3rd party */
/*************/
// Crashlytics
#import <Crashlytics/Crashlytics.h>
// MBProgressHUD
#import "MBProgressHUD.h"
// CMPopTipView
//#import "CMPopTipView.h"
// CLTickerView
#import "CLTickerView.h"
// KNSemiModal
#import "UIViewController+KNSemiModal.h"
// ECSlidingViewController
#import "ECSlidingViewController.h"
// SVWebViewController
#import "SVWebViewController.h"
// AdMob
#import "GADBannerView.h"
#import "GADAdMobExtras.h"
// ODRefreshControl
#import "ODRefreshControl.h"
// MTStatusBarOverlay
#import "MTStatusBarOverlay.h"
// Flurry
#import "Flurry.h"
// GrowingTextView
#import "HPGrowingTextView.h"

// Main
#import "IAConstants.h"
#import "IAUtils.h"
#import "IAAssertionUtils.h"
#import "IADynamicCache.h"
#import "IAPurgeableObject.h"
#import "IADateRange.h"
#import "IAAppTerminator.h"
#import "IAOperation.h"

// Model - gen
#import "IAApplicationLog.h"
#import "S_SystemEntity.h"

// Protocols
#import "IAUIDynamicPagingContainerViewControllerDataSource.h"
#import "IAUIPresenter.h"
#import "IAUIAppearanceTheme.h"

// Helpers
#import "IAUIApplicationDelegate.h"
#import "IAEmailManager.h"
#import "IAHelpManager.h"
#import "IAPreferencesManager.h"
#import "IAUIAbstractAppearanceTheme.h"
#import "IAUIAppearanceThemeManager.h"
#import "IAUIDefaultAppearanceTheme.h"
#import "IAUIInternalWebBrowserActivity.h"
#import "IAUICollectionViewFlowLayout.h"
#import "IAAnalyticsUtils.h"
#import "IAUICollectionViewFetchedResultsControllerDelegate.h"

// Persistence
#import "IAPersistenceManager.h"
#import "IAEntityConfig.h"

// Views
#import "IAUIUtils.h"
#import "IAUITableViewCell.h"
#import "IAUIFormTableViewCell.h"
#import "IAUISegmentedControl.h"
#import "IAUISegmentedControlTableViewCell.h"
#import "IAUIPinAnnotationView.h"
#import "IAUISliderTableViewCell.h"
#import "IAUISwitchTableViewCell.h"
#import "IAUIHelpModeOverlayView.h"
#import "IAUIActionSheet.h"
#import "IAUIHelpPopTipView.h"
#import "IAUIFormTextFieldTableViewCell.h"
#import "IAUIFormNumberFieldTableViewCell.h"
#import "IAUITextField.h"
#import "IAUIView.h"
#import "IAUINavigationItemTitleView.h"
#import "IAUIHelpTargetView.h"
#import "IAUITableSectionHeaderView.h"
#import "IAUITableCellSelectedBackgroundView.h"
#import "IAUICollectionViewCell.h"
#import "IAUITextViewContainer.h"

// Controllers
#import "IAAsynchronousWorkManager.h"
#import "IAUIViewController.h"
#import "IAUISelectionManagerDelegate.h"
#import "IAUISelectionManager.h"
#import "IAUISingleSelectionManager.h"
#import "IAUITableViewController.h"
#import "IAUIDynamicPagingContainerViewController.h"
#import "IAUIListViewController.h"
#import "IAUIAbstractFieldEditorViewController.h"
#import "IAUIFormViewController.h"
#import "IAUIManagedFormViewController.h"
#import "IAUINavigationListViewController.h"
#import "IAUIAbstractSelectionListViewController.h"
#import "IAUISingleSelectionListViewController.h"
#import "IAUIMultiSelectionListViewController.h"
#import "IAUIModalViewController.h"
#import "IAUIWorkInProgressModalViewManager.h"
#import "IAUIApplicationLogViewController.h"
#import "IAUITabBarController.h"
#import "IAUINavigationController.h"
#import "IAUIDatePickerViewController.h"
#import "IAUIPreferencesFormViewController.h"
#import "IAUISplitViewController.h"
#import "IAUIPickerViewController.h"
#import "IAUIMenuViewController.h"
#import "IAUIAbstractPagingContainerViewController.h"
#import "IAUIStaticPagingContainerViewController.h"
#import "IAUILongTextEditorViewController.h"
#import "IAUIAboutViewController.h"
#import "IAUISlidingViewController.h"
#import "IAUIAboutFormViewController.h"
#import "IAUIWebViewController.h"
#import "IAUIThirdPartyCodeCreditsViewController.h"
#import "IAUIPageViewController.h"
#import "IAUICollectionViewController.h"
#import "IAUIFetchedResultsTableViewController.h"
#import "IAUITextViewController.h"

// Categories
#import "NSObject+IACategory.h"
#import "NSManagedObject+IACategory.h"
#import "NSDate+IACategory.h"
#import "NSCalendar+IACategory.h"
#import "IAApplicationLog+IACategory.h"
#import "UIViewController+IACategory.h"
#import "UITableView+IACategory.h"
#import "NSFileManager+IACategory.h"
#import "UIView+IACategory.h"
#import "UIBarItem+IACategory.h"
#import "UIPopoverController+IACategory.h"
#import "UIColor+IACategory.h"
#import "UIImage+IACategory.h"
#import "UIWebView+IACategory.h"
#import "NSString+IACategory.h"
#import "NSData+IACategory.h"
#import "UIBarButtonItem+IACategory.h"
#import "NSManagedObjectContext+IACategory.h"
#import "UIButton+IACategory.h"
#import "NSAttributedString+IACategory.h"
#import "UITableViewCell+IACategory.h"

// Model - non-gen
#import "IAMapAnnotation.h"
#import "IAEnumerationEntity.h"
#import "IAHtmlDocument.h"
#import "IAAboutInfoModel.h"
#import "IAUIColorScheme.h"