//
//  IFACommon.h
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
#import <CoreData/CoreData.h>
#import <CoreText/CoreText.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import <GLKit/GLKit.h>
#import <AdSupport/AdSupport.h>
#import <objc/message.h>    // added so I could use objc_msgSend to get rid of ARC compiler warnings for performSelector method calls
#import <Accelerate/Accelerate.h>

// Had to add the below to make Google-AdMob-Ads-SDK work via Cocoapods
#import <StoreKit/StoreKit.h>

/*************/
/* 3rd party */
/*************/
// IFA_MBProgressHUD
#import "IFA_MBProgressHUD.h"
// KNSemiModal
#import "UIViewController+IFA_KNSemiModal.h"
// IFA_ECSlidingViewController
#import "IFA_ECSlidingViewController.h"
// IFA_SVWebViewController
#import "IFA_SVWebViewController.h"
// ODRefreshControl
#import "ODRefreshControl.h"
// MTStatusBarOverlay
#import "MTStatusBarOverlay.h"
// GrowingTextView
#import "IFA_HPGrowingTextView.h"

// Main
#import "IFAConstants.h"
#import "IFAUtils.h"
#import "IFAAssertionUtils.h"
#import "IFADynamicCache.h"
#import "IFAPurgeableObject.h"
#import "IFADateRange.h"
#import "IFAAppTerminator.h"
#import "IFAOperation.h"

// Model - gen
#import "IFAApplicationLog.h"
#import "IFASystemEntity.h"

// Protocols
#import "IFADynamicPagingContainerViewControllerDataSource.h"
#import "IFAPresenter.h"
#import "IFAAppearanceTheme.h"

// Helpers
#import "IFAApplicationDelegate.h"
#import "IFAEmailManager.h"
#import "IFAPreferencesManager.h"
#import "IFAAbstractAppearanceTheme.h"
#import "IFAAppearanceThemeManager.h"
#import "IFADefaultAppearanceTheme.h"
#import "IFAInternalWebBrowserActivity.h"
#import "IFACollectionViewFlowLayout.h"
#import "IFACollectionViewFetchedResultsControllerDelegate.h"
#import "IFACurrentLocationManager.h"
#import "IFASemaphoreManager.h"
#import "IFAExternalUrlManager.h"
#import "IFAExternalWebBrowserActivity.h"

// Persistence
#import "IFAPersistenceManager.h"
#import "IFAEntityConfig.h"

// Views
#import "IFAUIUtils.h"
#import "IFATableViewCell.h"
#import "IFAFormTableViewCell.h"
#import "IFASegmentedControl.h"
#import "IFASegmentedControlTableViewCell.h"
#import "IFAPinAnnotationView.h"
#import "IFASliderTableViewCell.h"
#import "IFASwitchTableViewCell.h"
#import "IFAActionSheet.h"
#import "IFAFormTextFieldTableViewCell.h"
#import "IFAFormNumberFieldTableViewCell.h"
#import "IFATextField.h"
#import "IFAView.h"
#import "IFANavigationItemTitleView.h"
#import "IFATableSectionHeaderView.h"
#import "IFATableCellSelectedBackgroundView.h"
#import "IFACollectionViewCell.h"
#import "IFATextViewContainer.h"

// Controllers
#import "IFAAsynchronousWorkManager.h"
#import "IFAViewController.h"
#import "IFASelectionManagerDelegate.h"
#import "IFASelectionManager.h"
#import "IFASingleSelectionManager.h"
#import "IFATableViewController.h"
#import "IFADynamicPagingContainerViewController.h"
#import "IFAListViewController.h"
#import "IFAAbstractFieldEditorViewController.h"
#import "IFAFormViewController.h"
#import "IFAManagedFormViewController.h"
#import "IFANavigationListViewController.h"
#import "IFAAbstractSelectionListViewController.h"
#import "IFASingleSelectionListViewController.h"
#import "IFAMultiSelectionListViewController.h"
#import "IFAModalViewController.h"
#import "IFAWorkInProgressModalViewManager.h"
#import "IFAApplicationLogViewController.h"
#import "IFATabBarController.h"
#import "IFANavigationController.h"
#import "IFADatePickerViewController.h"
#import "IFAPreferencesFormViewController.h"
#import "IFASplitViewController.h"
#import "IFAPickerViewController.h"
#import "IFAMenuViewController.h"
#import "IFAAbstractPagingContainerViewController.h"
#import "IFAStaticPagingContainerViewController.h"
#import "IFALongTextEditorViewController.h"
#import "IFAAboutViewController.h"
#import "IFASlidingViewController.h"
#import "IFAAboutFormViewController.h"
#import "IFAThirdPartyCodeCreditsViewController.h"
#import "IFAPageViewController.h"
#import "IFACollectionViewController.h"
#import "IFAFetchedResultsTableViewController.h"
#import "IFATextViewController.h"
#import "IFAMasterDetailViewController.h"
#import "IFAInternalWebBrowserViewController.h"

// Categories
#import "NSObject+IFACategory.h"
#import "NSManagedObject+IFACategory.h"
#import "NSDate+IFACategory.h"
#import "NSCalendar+IFACategory.h"
#import "IFAApplicationLog+IFACategory.h"
#import "UIViewController+IFACategory.h"
#import "UITableView+IFACategory.h"
#import "NSFileManager+IFACategory.h"
#import "UIView+IFACategory.h"
#import "UIPopoverController+IFACategory.h"
#import "UIColor+IFACategory.h"
#import "UIImage+IFACategory.h"
#import "UIWebView+IFACategory.h"
#import "NSString+IFACategory.h"
#import "NSData+IFACategory.h"
#import "UIBarButtonItem+IFACategory.h"
#import "NSManagedObjectContext+IFACategory.h"
#import "UIButton+IFACategory.h"
#import "NSAttributedString+IFACategory.h"
#import "UITableViewCell+IFACategory.h"
#import "UIScrollView+IFACategory.h"

// Model - non-gen
#import "IFAMapAnnotation.h"
#import "IFAEnumerationEntity.h"
#import "IFAAboutInfoModel.h"
#import "IFAColorScheme.h"