//
//  GustyLibCore.h
//  GustyLib
//
//  Created by Marcelo Schroeder on 23/08/14.
//  Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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
#import <sys/utsname.h>

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
// GrowingTextView
#import "IFA_HPGrowingTextView.h"
// IBActionSheet
#import "IFA_IBActionSheet.h"

#import "IFAAboutFormViewController.h"
#import "IFAAboutInfoModel.h"
#import "IFAAboutViewController.h"
#import "IFADefaultAppearanceTheme.h"
#import "IFAAbstractFieldEditorViewController.h"
#import "IFAAbstractPagingContainerViewController.h"
#import "IFAAbstractSelectionListViewController.h"
#import "IFAAbstractWebBrowserActivity.h"
#import "IFAActionSheet.h"
#import "IFAAppearanceTheme.h"
#import "IFAAppearanceThemeManager.h"
#import "IFAApplicationDelegate.h"
#import "IFAApplicationLog.h"
#import "IFAApplicationLog+IFACategory.h"
#import "IFAApplicationLogViewController.h"
#import "IFAAppTerminator.h"
#import "IFAAssertionUtils.h"
#import "IFAAsynchronousWorkManager.h"
#import "IFACircleView.h"
#import "IFACollectionViewCell.h"
#import "IFACollectionViewController.h"
#import "IFACollectionViewFetchedResultsControllerDelegate.h"
#import "IFACollectionViewFlowLayout.h"
#import "IFAColorScheme.h"
#import "IFAConstants.h"
#import "IFACurrentLocationManager.h"
#import "IFACustomLayoutSupport.h"
#import "IFADatePickerViewController.h"
#import "IFADateRange.h"
#import "IFADefaultAppearanceTheme.h"
#import "IFADirectionsManager.h"
#import "IFADispatchQueueManager.h"
#import "IFADynamicCache.h"
#import "IFADynamicPagingContainerViewController.h"
#import "IFADynamicPagingContainerViewControllerDataSource.h"
#import "IFAEmailManager.h"
#import "IFAEntityConfig.h"
#import "IFAEnumerationEntity.h"
#import "IFAExternalUrlManager.h"
#import "IFAExternalWebBrowserActivity.h"
#import "IFAFetchedResultsTableViewController.h"
#import "IFAFormNumberFieldTableViewCell.h"
#import "IFAFormTableViewCell.h"
#import "IFAFormTableViewCellContentView.h"
#import "IFAFormTextFieldTableViewCell.h"
#import "IFAFormViewController.h"
#import "IFAInternalWebBrowserActivity.h"
#import "IFAInternalWebBrowserViewController.h"
#import "IFAListViewController.h"
#import "IFALongTextEditorViewController.h"
#import "IFAManagedFormViewController.h"
#import "IFAMapAnnotation.h"
#import "IFAMasterDetailViewController.h"
#import "IFAMenuViewController.h"
#import "IFAModalViewController.h"
#import "IFAMultiSelectionListViewController.h"
#import "IFANavigationController.h"
#import "IFANavigationItemTitleView.h"
#import "IFANavigationListViewController.h"
#import "IFAOperation.h"
#import "IFAPageViewController.h"
#import "IFAPagingStateManager.h"
#import "IFAPassthroughView.h"
#import "IFAPersistenceManager.h"
#import "IFAPhoneServiceManager.h"
#import "IFAPickerViewController.h"
#import "IFAPinAnnotationView.h"
#import "IFAPreferencesFormViewController.h"
#import "IFAPreferencesManager.h"
#import "IFAPresenter.h"
#import "IFAPurgeableObject.h"
#import "IFASegmentedControl.h"
#import "IFASegmentedControlTableViewCell.h"
#import "IFASelectionManager.h"
#import "IFASelectionManagerDelegate.h"
#import "IFASemaphoreManager.h"
#import "IFASingleSelectionListViewController.h"
#import "IFASingleSelectionManager.h"
#import "IFASliderTableViewCell.h"
#import "IFASlidingFrostedGlassViewController.h"
#import "IFASlidingViewController.h"
#import "IFASplitViewController.h"
#import "IFAStaticPagingContainerViewController.h"
#import "IFASubjectActivityItem.h"
#import "IFASwitchTableViewCell.h"
#import "IFASystemEntity.h"
#import "IFATabBarController.h"
#import "IFATableCellSelectedBackgroundView.h"
#import "IFATableSectionHeaderView.h"
#import "IFATableViewCell.h"
#import "IFATableViewController.h"
#import "IFATextField.h"
#import "IFATextViewContainer.h"
#import "IFATextViewController.h"
#import "IFAThirdPartyCodeCreditsViewController.h"
#import "IFAUIUtils.h"
#import "IFAUtils.h"
#import "IFAView.h"
#import "IFAViewController.h"
#import "IFAWorkInProgressModalViewManager.h"
#import "NSAttributedString+IFACategory.h"
#import "NSCalendar+IFACategory.h"
#import "NSData+IFACategory.h"
#import "NSDate+IFACategory.h"
#import "NSDictionary+IFACategory.h"
#import "NSFileManager+IFACategory.h"
#import "NSIndexPath+IFACategory.h"
#import "NSManagedObject+IFACategory.h"
#import "NSManagedObjectContext+IFACategory.h"
#import "NSNumberFormatter+IFACategory.h"
#import "NSObject+IFACategory.h"
#import "NSString+IFACategory.h"
#import "NSURL+IFACategory.h"
#import "UIBarButtonItem+IFACategory.h"
#import "UIButton+IFACategory.h"
#import "UICollectionView+IFACategory.h"
#import "UIColor+IFACategory.h"
#import "UIImage+IFACategory.h"
#import "UIPopoverController+IFACategory.h"
#import "UIScrollView+IFACategory.h"
#import "UIStoryboard+IFACategory.h"
#import "UITableView+IFACategory.h"
#import "UITableViewCell+IFACategory.h"
#import "UITableViewController+IFADynamicCellHeight.h"
#import "UIView+IFACategory.h"
#import "UIViewController+IFACategory.h"
#import "UIWebView+IFACategory.h"
#import "IFAGridViewController.h"
#import "IFAFormInputAccessoryView.h"

