//
// Created by Marcelo Schroeder on 27/05/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+IFAGoogleMobileAdsSupport.h"
#import "IFAUIUtils.h"
#import "GADBannerView.h"
#import "IFAApplicationDelegate.h"
#import "UIViewController+IFACategory.h"
#import "GADAdMobExtras.h"
#import "MTStatusBarOverlay.h"
#import "IFAGoogleMobileAdsManager.h"

NSString* const IFANotificationAdsSuspendRequest = @"ifa.adsSuspendRequest";
NSString* const IFANotificationAdsResumeRequest = @"ifa.adsResumeRequest";

static const int k_iPhoneLandscapeAdHeight = 32;

static char c_adContainerViewKey;

//wip: code is not organised in pragma sections properly
@implementation UIViewController (IFAGoogleMobileAdsSupport)

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

-(GADAdSize)IFA_gadAdSize {
    return GADAdSizeFromCGSize([self ifa_googleMobileAdFrameSize]);
}

-(GADBannerView *)ifa_googleMobileAdBannerView {
    return [IFAGoogleMobileAdsManager sharedInstance].activeBannerView;
}

- (void)IFA_updateAdBannerSize {
//    NSLog(@"IFA_updateAdBannerSize");
    GADBannerView *l_bannerView = [self ifa_googleMobileAdBannerView];
    CGRect l_newAdBannerViewFrame = CGRectZero;
    l_newAdBannerViewFrame.size = [self ifa_googleMobileAdFrameSize];
    l_bannerView.frame = l_newAdBannerViewFrame;
//    NSLog(@"          l_bannerView.frame: %@", NSStringFromCGRect(l_bannerView.frame));
//    NSLog(@"self.ifa_adContainerView.frame: %@", NSStringFromCGRect(self.ifa_adContainerView.frame));
    l_bannerView.adSize = [self IFA_gadAdSize];
//    NSLog(@"    l_bannerView.adSize.size: %@", NSStringFromCGSize(l_bannerView.adSize.size));
//    NSLog(@"   l_bannerView.adSize.flags: %u", l_bannerView.adSize.flags);
}

-(void)ifa_startGoogleMobileAdsRequests {

    if (![self ifa_shouldEnableAds] || [self ifa_googleMobileAdBannerView].superview) {
        return;
    }

    // Add ad container subview
    UIView *l_adContainerView = self.ifa_adContainerView;
    if (l_adContainerView) {
        l_adContainerView.hidden = YES;
        l_adContainerView.frame = CGRectMake(0, self.view.frame.size.height, l_adContainerView.frame.size.width, l_adContainerView.frame.size.height);
//        NSLog(@"adContainerView.frame 3: %@", NSStringFromCGRect(l_adContainerView.frame));
        [self.view addSubview:l_adContainerView];
    }

    [self IFA_updateAdBannerSize];

    // Add the ad view to the container view
    [self.ifa_adContainerView addSubview:[self ifa_googleMobileAdBannerView]];

    // Make a note of the owner view controller
    [IFAApplicationDelegate sharedInstance].adsOwnerViewController = self;

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

    UIView *l_adContainerView = self.ifa_adContainerView;
    if (l_adContainerView) {
        [l_adContainerView removeFromSuperview];
        [self ifa_updateNonAdContainerViewFrameWithGoogleMobileAdBannerViewHeight:0];
    }

    [[self ifa_googleMobileAdBannerView] removeFromSuperview]; // This seems to stop ad loading
    [self ifa_googleMobileAdBannerView].delegate = nil;
    [self ifa_googleMobileAdBannerView].rootViewController = nil;

    [IFAApplicationDelegate sharedInstance].adsOwnerViewController = self;

}

- (void)IFA_updateAdContainerViewFrameWithAdBannerViewHeight:(CGFloat)a_adBannerViewHeight {
    UIView *l_adContainerView = self.ifa_adContainerView;
    CGRect l_newAdContainerViewFrame = l_adContainerView.frame;
    l_newAdContainerViewFrame.origin.y = self.view.frame.size.height - a_adBannerViewHeight;
    l_newAdContainerViewFrame.size.height = a_adBannerViewHeight;
    l_adContainerView.frame = l_newAdContainerViewFrame;
//    NSLog(@"adContainerView.frame 2: %@", NSStringFromCGRect(l_adContainerView.frame));
}

-(UIView*)ifa_adContainerView {

    UIView *l_adContainerView = objc_getAssociatedObject(self, &c_adContainerViewKey);

    if (!l_adContainerView && [self ifa_shouldEnableAds]) {

        // Create ad container
        CGSize l_gadAdFrameSize = [self ifa_googleMobileAdFrameSize];
        CGFloat l_adContainerViewX = 0;
        CGFloat l_adContainerViewY = self.view.frame.size.height-l_gadAdFrameSize.height;
        CGFloat l_adContainerViewWidth = self.view.frame.size.width;
        CGFloat l_adContainerViewHeight = l_gadAdFrameSize.height;
        CGRect l_adContainerViewFrame = CGRectMake(l_adContainerViewX, l_adContainerViewY, l_adContainerViewWidth, l_adContainerViewHeight);
        l_adContainerView = [[UIView alloc] initWithFrame:l_adContainerViewFrame];
//        NSLog(@"adContainerView.frame 1: %@", NSStringFromCGRect(l_adContainerView.frame));
        l_adContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;

        // Add shadow
        l_adContainerView.layer.masksToBounds = NO;
        l_adContainerView.layer.shadowOffset = CGSizeMake(0, 2);
        l_adContainerView.layer.shadowOpacity = 1;

        self.ifa_adContainerView = l_adContainerView;

    }

    return l_adContainerView;

}

-(void)setIfa_adContainerView:(UIView*)a_adContainerView{
    objc_setAssociatedObject(self, &c_adContainerViewKey, a_adContainerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)ifa_didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

    //wip: issue here - call super in a category?

    // Hide ad container (but it should be offscreen at this point)
    self.ifa_adContainerView.hidden = YES;

    if ([self ifa_shouldEnableAds]) {
        [self ifa_startGoogleMobileAdsRequests];
    }

}

- (void)IFA_onAdsSuspendRequest:(NSNotification*)aNotification{
    [self ifa_stopGoogleMobileAdsRequests];
}

- (void)IFA_onAdsResumeRequest:(NSNotification*)aNotification{
    if ([self ifa_shouldEnableAds]) {
        [self ifa_startGoogleMobileAdsRequests];
    }
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
                                             selector:@selector(IFA_onAdsSuspendRequest:)
                                                 name:IFANotificationAdsSuspendRequest
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onAdsResumeRequest:)
                                                 name:IFANotificationAdsResumeRequest
                                               object:nil];
}

- (void)ifa_stopObservingGoogleMobileAdsSupportNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationAdsSuspendRequest object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationAdsResumeRequest object:nil];
}

#pragma mark - Public

- (BOOL)ifa_shouldEnableAds {
    return [self.ifa_googleMobileAdsSupportDataSource shouldEnableAdsForGoogleMobileAdsEnabledViewController:self];
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {

//    NSLog(@"adViewDidReceiveAd in %@ - bannerView.frame: %@", [self description], NSStringFromCGRect(bannerView.frame));

    if ([self ifa_shouldEnableAds]) {

        if (![IFAGoogleMobileAdsManager sharedInstance].adsSuspended) {
            UIView *l_adContainerView = self.ifa_adContainerView;
            if (l_adContainerView.hidden) {
                [UIView animateWithDuration:0.2 animations:^{
                    l_adContainerView.hidden = NO;
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

@end