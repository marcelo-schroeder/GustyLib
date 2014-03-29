//
// Created by Marcelo Schroeder on 28/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IAUIAbstractWebBrowserActivity.h"


@interface IAUIAbstractWebBrowserActivity ()
@property (nonatomic, strong) NSURL *p_url;
@end

@implementation IAUIAbstractWebBrowserActivity {

}

#pragma mark - Overrides

-(NSString *)activityTitle{
    return @"Web Browser";
}

-(UIImage *)activityImage{
    return [UIImage imageNamed:@"internalWebBrowserActivity"];
}

-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems{
    for (id l_activityItem in activityItems) {
        if ([l_activityItem isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    return NO;
}

-(void)prepareWithActivityItems:(NSArray *)activityItems{
    for (id l_activityItem in activityItems) {
        if ([l_activityItem isKindOfClass:[NSURL class]]) {
            self.p_url = l_activityItem;
        }
    }
}

@end