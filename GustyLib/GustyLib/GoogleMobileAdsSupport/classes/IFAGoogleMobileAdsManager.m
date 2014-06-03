//
// Created by Marcelo Schroeder on 28/05/2014.
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
                                             selector:@selector(IFA_onAdsSuspendRequest)
                                                 name:IFANotificationGoogleMobileAdsSuspendRequest
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onAdsResumeRequest)
                                                 name:IFANotificationGoogleMobileAdsResumeRequest
                                               object:nil];
}

- (void)IFA_removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationGoogleMobileAdsSuspendRequest
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFANotificationGoogleMobileAdsResumeRequest
                                                  object:nil];
}

- (void)IFA_onAdsSuspendRequest{
    self.adsSuspended = YES;
}

- (void)IFA_onAdsResumeRequest{
    self.adsSuspended = NO;
}

@end