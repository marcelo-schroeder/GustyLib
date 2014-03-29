//
//  UIWebView+IACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 19/10/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

#import "UIWebView+IACategory.h"

@implementation UIWebView (IACategory)

#pragma mark - Public

-(void)m_removeShadow{
    for(UIScrollView* webScrollView in [self subviews]){
        if ([webScrollView isKindOfClass:[UIScrollView class]]){
            for(UIView* subview in [webScrollView subviews]){
                if ([subview isKindOfClass:[UIImageView class]]){
                    ((UIImageView*)subview).image = nil;
                    subview.backgroundColor = [UIColor clearColor];
                }
            }
        }
    }
}

-(void)m_updateViewPortWidth{
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d, initial-scale=1.0, maximum-scale=1.0', false); ", (int)self.self.frame.size.width]];
}

- (NSString *)m_html{
    return [self stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
}

@end
