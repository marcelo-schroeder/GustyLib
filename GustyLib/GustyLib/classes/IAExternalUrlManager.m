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

#import "IACommon.h"

@interface IAExternalUrlManager ()
@property(nonatomic, strong) NSURL *p_urlToOpen;
@end

@implementation IAExternalUrlManager {

}

#pragma mark - Private

-(void)m_openSavedUrl{
    if (self.p_urlToOpen) {
        [[UIApplication sharedApplication] openURL:self.p_urlToOpen];
        self.p_urlToOpen = nil;
    }
}

#pragma mark - Public

-(void)openUrl:(NSURL*)a_url{
    self.p_urlToOpen = a_url;
    NSString *l_message = [NSString stringWithFormat:@"You will now leave the %@ app", [IAUtils appName]];
    UIAlertView *l_alert = [[UIAlertView alloc] initWithTitle:nil message:l_message
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"OK", nil];
    [l_alert show];
}

+ (IAExternalUrlManager*)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IAExternalUrlManager *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        [self m_openSavedUrl];
    }
}

@end