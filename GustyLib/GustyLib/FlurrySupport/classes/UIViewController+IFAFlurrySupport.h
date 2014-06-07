//
// Created by Marcelo Schroeder on 7/06/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (IFAFlurrySupport)
/**
* Logs a screen entry event to Flurry analytics.
* It automatically uses the view controller title as the screen name for the entry event.
*/
-(void)ifa_logFlurryAnalyticsScreenEntry;
@end