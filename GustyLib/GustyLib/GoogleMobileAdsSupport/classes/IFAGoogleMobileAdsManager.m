//
// Created by Marcelo Schroeder on 28/05/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import "IFAGoogleMobileAdsManager.h"
#import "GADAdMobExtras.h"
#import "GADBannerView.h"
#import "IFAAppearanceThemeManager.h"
#import "IFAAppearanceTheme.h"
#import "UIViewController+IFAGoogleMobileAdsSupport.h"

@interface IFAGoogleMobileAdsManager ()
@property (nonatomic, strong) GADBannerView *activeBannerView;
@property (nonatomic) BOOL adsSuspended;
@end

@implementation IFAGoogleMobileAdsManager {

}

#pragma mark - Public

- (GADBannerView *)activeBannerView {
    if (!_activeBannerView) {
        _activeBannerView = [GADBannerView new];
        _activeBannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceForView:_activeBannerView];
    }
    _activeBannerView.adUnitID = [self.dataSource unitIdForGoogleMobileAdsManager:self];
    return _activeBannerView;
}

- (GADAdMobExtras *)extras {
    return [self.dataSource extrasForGoogleMobileAdsManager:self];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IFAGoogleMobileAdsManager *c_instance;
    void (^instanceBlock)(void) = ^(void) {
        c_instance = [self new];
    };
    dispatch_once(&c_dispatchOncePredicate, instanceBlock);
    return c_instance;
}

#pragma mark - Overrides

- (id)init {
    self = [super init];
    if (self) {
        [self IFA_addObservers];
    }
    return self;
}

- (void)dealloc {
    [self IFA_removeObservers];
}

#pragma mark - Private

- (void)IFA_addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onAdsSuspendRequest:)
                                                 name:IFANotificationAdsSuspendRequest
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onAdsResumeRequest:)
                                                 name:IFANotificationAdsResumeRequest
                                               object:nil];
}

- (void)IFA_removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationAdsSuspendRequest object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationAdsResumeRequest object:nil];
}

- (void)IFA_onAdsSuspendRequest:(NSNotification*)aNotification{
    self.adsSuspended = YES;
}

- (void)IFA_onAdsResumeRequest:(NSNotification*)aNotification{
    self.adsSuspended = NO;
}

@end