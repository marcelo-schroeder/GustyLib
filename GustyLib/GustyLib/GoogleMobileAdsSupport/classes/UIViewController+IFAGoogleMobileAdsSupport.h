//
// Created by Marcelo Schroeder on 27/05/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"

@protocol IFAGoogleMobileAdsEnabledViewControllerDataSource;

//wip: should I rename these notifications now that this is a separate project?
//wip: decide which methods below should be private or public
extern NSString* const IFANotificationAdsSuspendRequest;
extern NSString* const IFANotificationAdsResumeRequest;

@interface UIViewController (IFAGoogleMobileAdsSupport) <GADBannerViewDelegate>
@property (nonatomic, weak) id<IFAGoogleMobileAdsEnabledViewControllerDataSource> ifa_googleMobileAdsSupportDataSource;
@property (nonatomic, strong) UIView *ifa_googleMobileAdContainerView;
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