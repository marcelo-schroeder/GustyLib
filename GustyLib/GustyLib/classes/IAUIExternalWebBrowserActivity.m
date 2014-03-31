//
// Created by Marcelo Schroeder on 28/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IAUIExternalWebBrowserActivity.h"
#import "IAExternalUrlManager.h"


@implementation IAUIExternalWebBrowserActivity {

}

#pragma mark - Overrides

-(NSString *)activityType{
    return @"IAExternalWebBrowser";
}

- (void)performActivity {
    [[IAExternalUrlManager m_instance] m_openUrl:self.p_url];
    [self activityDidFinish:YES];
}

@end