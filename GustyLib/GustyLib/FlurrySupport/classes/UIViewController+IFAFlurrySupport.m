//
// Created by Marcelo Schroeder on 7/06/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import "UIViewController+IFAFlurrySupport.h"
#import "IFAFlurrySupportUtils.h"
#import "UIViewController+IFACategory.h"


@implementation UIViewController (IFAFlurrySupport)

#pragma mark - Public

-(void)ifa_logFlurryAnalyticsScreenEntry {
    if (![self ifa_isReturningVisibleViewController]) {
        [IFAFlurrySupportUtils logEntryForScreenName:self.navigationItem.title];
    }
}

@end