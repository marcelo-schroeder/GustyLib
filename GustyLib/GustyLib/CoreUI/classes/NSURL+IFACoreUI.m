//
// Created by Marcelo Schroeder on 30/04/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCoreUI.h"


@implementation NSURL (IFACoreUI)

#pragma mark - Public

- (BOOL)ifa_isAppleUrlScheme {
    return [self.scheme isEqualToString:@"mailto"]
                || [self.scheme isEqualToString:@"tel"]
                || [self.scheme isEqualToString:@"facetime"]
                || [self.scheme isEqualToString:@"sms"];
}

-(void)ifa_open{
    [self ifa_openWithAlertPresenterViewController:nil];
}

-(void)ifa_openWithAlertPresenterViewController:(UIViewController *)a_alertPresenterViewController{
    void (^actionBlock)() = ^{
        [[UIApplication sharedApplication] openURL:self];
    };
    if (a_alertPresenterViewController) {
        NSString *title = [NSString stringWithFormat:@"You will now leave the %@ app", [IFAUtils appName]];
        [a_alertPresenterViewController ifa_presentAlertControllerWithTitle:title
                                                                    message:nil
                                                                      style:UIAlertControllerStyleAlert
                                                          actionButtonTitle:@"OK"
                                                                actionBlock:actionBlock];
    }else{
        actionBlock();
    }
}

@end