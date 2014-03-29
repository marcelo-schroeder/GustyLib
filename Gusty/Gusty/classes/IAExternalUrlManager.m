//
// Created by Marcelo Schroeder on 28/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IAExternalUrlManager.h"


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

-(void)m_openUrl:(NSURL*)a_url{
    self.p_urlToOpen = a_url;
    NSString *l_message = [NSString stringWithFormat:@"You will now leave the %@ app", [IAUtils appName]];
    UIAlertView *l_alert = [[UIAlertView alloc] initWithTitle:nil message:l_message
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"OK", nil];
    [l_alert show];
}

+ (IAExternalUrlManager*)m_instance {
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