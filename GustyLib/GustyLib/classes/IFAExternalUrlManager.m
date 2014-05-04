//
// Created by Marcelo Schroeder on 28/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

#import "IFACommon.h"

@interface IFAExternalUrlManager ()
@property(nonatomic, strong) NSURL *ifa_urlToOpen;
@end

@implementation IFAExternalUrlManager {

}

#pragma mark - Private

-(void)ifa_openSavedUrl {
    if (self.ifa_urlToOpen) {
        [[UIApplication sharedApplication] openURL:self.ifa_urlToOpen];
        self.ifa_urlToOpen = nil;
    }
}

#pragma mark - Public

-(void)openUrl:(NSURL*)a_url{
    self.ifa_urlToOpen = a_url;
    NSString *l_message = [NSString stringWithFormat:@"You will now leave the %@ app", [IFAUtils appName]];
    UIAlertView *l_alert = [[UIAlertView alloc] initWithTitle:nil message:l_message
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"OK", nil];
    [l_alert show];
}

+ (IFAExternalUrlManager *)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IFAExternalUrlManager *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        [self ifa_openSavedUrl];
    }
}

@end