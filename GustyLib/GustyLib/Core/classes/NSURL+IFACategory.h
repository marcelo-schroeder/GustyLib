//
// Created by Marcelo Schroeder on 30/04/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (IFACategory)

- (BOOL)ifa_isAppleUrlScheme;

/**
* Convenience method for opening the receiver by an external app.
*/
- (void)ifa_open;

/**
* Convenience method for opening the receiver by an external app with the option to ask for user confirmation before leaving the host app.
* @param a_alertPresenterViewController If provided, this view controller will present an alert asking the user whether it is ok to navigate to another app which will open the URL.
*/
- (void)ifa_openWithAlertPresenterViewController:(UIViewController *)a_alertPresenterViewController;

@end