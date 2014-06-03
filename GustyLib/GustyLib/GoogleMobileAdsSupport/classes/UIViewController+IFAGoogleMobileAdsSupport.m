//
// Created by Marcelo Schroeder on 27/05/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+IFAGoogleMobileAdsSupport.h"
#import "IFAUIUtils.h"
#import "GADBannerView.h"
#import "UIViewController+IFACategory.h"
#import "GADAdMobExtras.h"
#import "MTStatusBarOverlay.h"
#import "IFAGoogleMobileAdsManager.h"

NSString* const IFANotificationAdsSuspendRequest = @"ifa.adsSuspendRequest";
NSString* const IFANotificationAdsResumeRequest = @"ifa.adsResumeRequest";

static const int k_iPhoneLandscapeAdHeight = 32;

static char c_googleMobileAdsSupportDataSourceKey;
static char c_googleMobileAdContainerViewKey;
static char c_googleMobileAdsOwnershipSuspendedKey;

@implementation UIViewController (IFAGoogleMobileAdsSupport)

#pragma mark - Public

-(CGSize)ifa_googleMobileAdFrameSize {
    CGFloat l_width, l_height;
    if ([IFAUIUtils isIPad]) {
        l_width = self.view.frame.size.width;
        l_height = kGADAdSizeLeaderboard.size.height;
    }else{
        l_width = self.view.frame.size.width;
        l_height = [IFAUIUtils isDeviceInLandscapeOrientation] ? k_iPhoneLandscapeAdHeight : kGADAdSizeBanner.size.height;
    }
    CGSize l_size = CGSizeMake(l_width, l_height);
//    NSLog(@"IFA_gadAdSize: %@", NSStringFromCGSize(l_size));
    return l_size;
}

-(GADBannerView *)ifa_googleMobileAdBannerView {
    return [IFAGoogleMobileAdsManager sharedInstance].activeBannerView;
}

-(void)ifa_startGoogleMobileAdsRequests {

    if (![self ifa_shouldEnableAds] || [self ifa_googleMobileAdBannerView].superview) {
        return;
    }

    // Add ad container subview
    UIView *l_googleMobileAdContainerView = self.ifa_googleMobileAdContainerView;
    if (l_googleMobileAdContainerView) {
        l_googleMobileAdContainerView.hidden = YES;
        l_googleMobileAdContainerView.frame = CGRectMake(0, self.view.frame.size.height, l_googleMobileAdContainerView.frame.size.width, l_googleMobileAdContainerView.frame.size.height);
//        NSLog(@"adContainerView.frame 3: %@", NSStringFromCGRect(l_googleMobileAdContainerView.frame));
        [self.view addSubview:l_googleMobileAdContainerView];
    }

    [self IFA_updateAdBannerSize];

    // Add the ad view to the container view
    [self.ifa_googleMobileAdContainerView addSubview:[self ifa_googleMobileAdBannerView]];

    // Make a note of the owner view controller
    [IFAGoogleMobileAdsManager sharedInstance].adsOwnerViewController = self;

    // Configure request Google ad request
    GADRequest *l_gadRequest = [GADRequest request];
    GADAdMobExtras *l_gadExtras = [IFAGoogleMobileAdsManager sharedInstance].extras;
    if (l_gadExtras) {
        [l_gadRequest registerAdNetworkExtras:l_gadExtras];
    }

//    // Register simulator as a test device
//#if TARGET_IPHONE_SIMULATOR
//    l_gadRequest.testDevices = @[[[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)]];
//    //    NSLog(@"Configured test devices for Google Ads: %@", [l_gadRequest.testDevices description]);
//#endif

    // Initiate a generic Google ad request
    [self ifa_googleMobileAdBannerView].delegate = self;
    [self ifa_googleMobileAdBannerView].rootViewController = self;
    [[self ifa_googleMobileAdBannerView] loadRequest:l_gadRequest];

}

-(void)ifa_stopGoogleMobileAdsRequests {

    if (![self ifa_shouldEnableAds] || ![self ifa_googleMobileAdBannerView].superview) {
        return;
    }

    UIView *l_googleMobileAdContainerView = self.ifa_googleMobileAdContainerView;
    if (l_googleMobileAdContainerView) {
        [l_googleMobileAdContainerView removeFromSuperview];
        [self ifa_updateNonAdContainerViewFrameWithGoogleMobileAdBannerViewHeight:0];
    }

    [[self ifa_googleMobileAdBannerView] removeFromSuperview]; // This seems to stop ad loading
    [self ifa_googleMobileAdBannerView].delegate = nil;
    [self ifa_googleMobileAdBannerView].rootViewController = nil;

    [IFAGoogleMobileAdsManager sharedInstance].adsOwnerViewController = nil;

}

- (void)ifa_updateNonAdContainerViewFrameWithGoogleMobileAdBannerViewHeight:(CGFloat)a_adBannerViewHeight {
//    NSLog(@"m_updateNonAdContainerViewFrameWithAdBannerViewHeight BEFORE: self m_nonAdContainerView.frame: %@", NSStringFromCGRect([self ifa_nonAdContainerView].frame));
    CGRect l_newNonAdContainerViewFrame = [self IFA_nonAdContainerView].frame;
    l_newNonAdContainerViewFrame.size.height = self.view.frame.size.height - a_adBannerViewHeight;
    [self IFA_nonAdContainerView].frame = l_newNonAdContainerViewFrame;
//    NSLog(@"m_updateNonAdContainerViewFrameWithAdBannerViewHeight AFTER: self m_nonAdContainerView.frame: %@", NSStringFromCGRect([self ifa_nonAdContainerView].frame));
}

- (void)ifa_startObservingGoogleMobileAdsSupportNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onAdsSuspendRequest)
                                                 name:IFANotificationAdsSuspendRequest
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onAdsResumeRequest)
                                                 name:IFANotificationAdsResumeRequest
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onDeviceOrientationDidChangeNotification)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)ifa_stopObservingGoogleMobileAdsSupportNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationAdsSuspendRequest object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationAdsResumeRequest object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (BOOL)ifa_shouldEnableAds {
    return [self.ifa_googleMobileAdsSupportDataSource shouldEnableAdsForGoogleMobileAdsEnabledViewController:self];
}

-(void)setIfa_googleMobileAdsSupportDataSource:(id<IFAGoogleMobileAdsEnabledViewControllerDataSource>)a_googleMobileAdsSupportDataSource{
    objc_setAssociatedObject(self, &c_googleMobileAdsSupportDataSourceKey, a_googleMobileAdsSupportDataSource, OBJC_ASSOCIATION_ASSIGN);
}

-(id<IFAGoogleMobileAdsEnabledViewControllerDataSource>)ifa_googleMobileAdsSupportDataSource {
    return objc_getAssociatedObject(self, &c_googleMobileAdsSupportDataSourceKey);
}

-(UIView*)ifa_googleMobileAdContainerView {

    UIView *l_googleMobileAdContainerView = objc_getAssociatedObject(self, &c_googleMobileAdContainerViewKey);

    if (!l_googleMobileAdContainerView && [self ifa_shouldEnableAds]) {

        // Create ad container
        CGSize l_gadAdFrameSize = [self ifa_googleMobileAdFrameSize];
        CGFloat l_googleMobileAdContainerViewX = 0;
        CGFloat l_googleMobileAdContainerViewY = self.view.frame.size.height-l_gadAdFrameSize.height;
        CGFloat l_googleMobileAdContainerViewWidth = self.view.frame.size.width;
        CGFloat l_googleMobileAdContainerViewHeight = l_gadAdFrameSize.height;
        CGRect l_googleMobileAdContainerViewFrame = CGRectMake(l_googleMobileAdContainerViewX, l_googleMobileAdContainerViewY, l_googleMobileAdContainerViewWidth, l_googleMobileAdContainerViewHeight);
        l_googleMobileAdContainerView = [[UIView alloc] initWithFrame:l_googleMobileAdContainerViewFrame];
//        NSLog(@"adContainerView.frame 1: %@", NSStringFromCGRect(l_googleMobileAdContainerView.frame));
        l_googleMobileAdContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;

        // Add shadow
        l_googleMobileAdContainerView.layer.masksToBounds = NO;
        l_googleMobileAdContainerView.layer.shadowOffset = CGSizeMake(0, 2);
        l_googleMobileAdContainerView.layer.shadowOpacity = 1;

        self.ifa_googleMobileAdContainerView = l_googleMobileAdContainerView;

    }

    return l_googleMobileAdContainerView;

}

-(void)setIfa_googleMobileAdContainerView:(UIView*)a_googleMobileAdContainerView{
    objc_setAssociatedObject(self, &c_googleMobileAdContainerViewKey, a_googleMobileAdContainerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {

//    NSLog(@"adViewDidReceiveAd in %@ - bannerView.frame: %@", [self description], NSStringFromCGRect(bannerView.frame));

    if ([self ifa_shouldEnableAds]) {

        if (![IFAGoogleMobileAdsManager sharedInstance].adsSuspended) {
            UIView *l_googleMobileAdContainerView = self.ifa_googleMobileAdContainerView;
            if (l_googleMobileAdContainerView.hidden) {
                [UIView animateWithDuration:0.2 animations:^{
                    l_googleMobileAdContainerView.hidden = NO;
                    CGFloat l_bannerViewHeight = bannerView.frame.size.height;
                    [self ifa_updateNonAdContainerViewFrameWithGoogleMobileAdBannerViewHeight:l_bannerViewHeight];
                    [self IFA_updateAdContainerViewFrameWithAdBannerViewHeight:l_bannerViewHeight];
                }];
            }
        }

    }else{

        // This can occur if ads were previously enabled but have now been disabled and the UI has not been reloaded yet
        [self ifa_stopGoogleMobileAdsRequests];

    }

}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error{

    NSLog(@"didFailToReceiveAdWithError: %@", [error description]);

    if ([self ifa_shouldEnableAds]) {
        // This can occur if ads were previously enabled but have now been disabled and the UI has not been reloaded yet
        [self ifa_stopGoogleMobileAdsRequests];
    }

}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{

    //    NSLog(@"adViewWillPresentScreen");

    // Hides the status overlay in case it is being used
    [[MTStatusBarOverlay sharedInstance] hide];

}

#pragma mark - Private

- (UIView *)IFA_nonAdContainerView {
    return [self.ifa_googleMobileAdsSupportDataSource nonAdContainerViewForGoogleMobileAdsEnabledViewController:self];
}

-(GADAdSize)IFA_gadAdSize {
    return GADAdSizeFromCGSize([self ifa_googleMobileAdFrameSize]);
}

- (void)IFA_updateAdBannerSize {
//    NSLog(@"IFA_updateAdBannerSize");
    GADBannerView *l_bannerView = [self ifa_googleMobileAdBannerView];
    CGRect l_newAdBannerViewFrame = CGRectZero;
    l_newAdBannerViewFrame.size = [self ifa_googleMobileAdFrameSize];
    l_bannerView.frame = l_newAdBannerViewFrame;
//    NSLog(@"          l_bannerView.frame: %@", NSStringFromCGRect(l_bannerView.frame));
//    NSLog(@"self.ifa_googleMobileAdContainerView.frame: %@", NSStringFromCGRect(self.ifa_googleMobileAdContainerView.frame));
    l_bannerView.adSize = [self IFA_gadAdSize];
//    NSLog(@"    l_bannerView.adSize.size: %@", NSStringFromCGSize(l_bannerView.adSize.size));
//    NSLog(@"   l_bannerView.adSize.flags: %u", l_bannerView.adSize.flags);
}

- (void)IFA_updateAdContainerViewFrameWithAdBannerViewHeight:(CGFloat)a_adBannerViewHeight {
    UIView *l_googleMobileAdContainerView = self.ifa_googleMobileAdContainerView;
    CGRect l_newAdContainerViewFrame = l_googleMobileAdContainerView.frame;
    l_newAdContainerViewFrame.origin.y = self.view.frame.size.height - a_adBannerViewHeight;
    l_newAdContainerViewFrame.size.height = a_adBannerViewHeight;
    l_googleMobileAdContainerView.frame = l_newAdContainerViewFrame;
//    NSLog(@"adContainerView.frame 2: %@", NSStringFromCGRect(l_googleMobileAdContainerView.frame));
}

- (void)IFA_onAdsSuspendRequest{
    [self ifa_stopGoogleMobileAdsRequests];
}

- (void)IFA_onAdsResumeRequest {
    if (self.ifa_googleMobileAdsOwnershipSuspended) {
        return;
    }
    if ([self ifa_shouldEnableAds]) {
        [self ifa_startGoogleMobileAdsRequests];
    }
}

- (void)IFA_onDeviceOrientationDidChangeNotification {

    if (self.ifa_googleMobileAdsOwnershipSuspended) {
        return;
    }

    // Hide ad container (but it should be offscreen at this point)
    self.ifa_googleMobileAdContainerView.hidden = YES;

    if ([self ifa_shouldEnableAds]) {
        [self ifa_startGoogleMobileAdsRequests];
    }

}

-(BOOL)ifa_googleMobileAdsOwnershipSuspended {
    return ((NSNumber*)objc_getAssociatedObject(self, &c_googleMobileAdsOwnershipSuspendedKey)).boolValue;
}

-(void)setIfa_googleMobileAdsOwnershipSuspended:(BOOL)a_adsOwnershipSuspended{
    objc_setAssociatedObject(self, &c_googleMobileAdsOwnershipSuspendedKey, @(a_adsOwnershipSuspended), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end