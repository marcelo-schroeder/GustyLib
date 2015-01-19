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

#import "IFAAbstractWebBrowserActivity.h"


@interface IFAAbstractWebBrowserActivity ()
@property (nonatomic, strong) NSURL *url;
@end

@implementation IFAAbstractWebBrowserActivity {

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
            self.url = l_activityItem;
        }
    }
}

@end