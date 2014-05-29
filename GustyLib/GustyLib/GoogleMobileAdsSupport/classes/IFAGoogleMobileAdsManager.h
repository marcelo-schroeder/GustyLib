//
// Created by Marcelo Schroeder on 28/05/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GADAdMobExtras;
@protocol IFAGoogleMobileAdsManagerDataSource;
@class GADBannerView;

//wip: final review of dependencies on anything (e.g. GustyLib, circular dependency?)
//wip: add licence and copyright info
//wip: need to find all the methods that have been re-implemented in Swavit and replace with the proper code
@interface IFAGoogleMobileAdsManager : NSObject
@property (nonatomic, weak) id<IFAGoogleMobileAdsManagerDataSource> dataSource;
@property (nonatomic, strong, readonly) GADBannerView *activeBannerView;
@property (nonatomic, readonly) BOOL adsSuspended;
- (GADAdMobExtras *)extras;
+ (instancetype)sharedInstance;
@end

@protocol IFAGoogleMobileAdsManagerDataSource <NSObject>
- (NSString *)unitIdForGoogleMobileAdsManager:(IFAGoogleMobileAdsManager *)a_manager;
- (GADAdMobExtras *)extrasForGoogleMobileAdsManager:(IFAGoogleMobileAdsManager *)a_manager;
@end