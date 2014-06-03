//
// Created by Marcelo Schroeder on 27/05/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"

@protocol IFAGoogleMobileAdsEnabledViewControllerDataSource;

extern NSString* const IFANotificationGoogleMobileAdsSuspendRequest;
extern NSString* const IFANotificationGoogleMobileAdsResumeRequest;

@interface UIViewController (IFAGoogleMobileAdsSupport) <GADBannerViewDelegate>
@property (nonatomic, weak) id<IFAGoogleMobileAdsEnabledViewControllerDataSource> ifa_googleMobileAdsSupportDataSource;
@property (nonatomic, strong) UIView *ifa_googleMobileAdContainerView;
@property (nonatomic) BOOL ifa_googleMobileAdsOwnershipSuspended;
- (GADBannerView*)ifa_googleMobileAdBannerView;
- (CGSize)ifa_googleMobileAdFrameSize;

-(void)ifa_startGoogleMobileAdsRequests;
-(void)ifa_stopGoogleMobileAdsRequests;

- (void)ifa_updateNonAdContainerViewFrameWithGoogleMobileAdBannerViewHeight:(CGFloat)a_adBannerViewHeight;

- (void)ifa_startObservingGoogleMobileAdsSupportNotifications;
- (void)ifa_stopObservingGoogleMobileAdsSupportNotifications;

- (BOOL)ifa_shouldEnableAds;
@end

@protocol IFAGoogleMobileAdsEnabledViewControllerDataSource <NSObject>
- (UIView *)nonAdContainerViewForGoogleMobileAdsEnabledViewController:(UIViewController *)a_viewController;
- (BOOL)shouldEnableAdsForGoogleMobileAdsEnabledViewController:(UIViewController *)a_viewController;
@end