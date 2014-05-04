//
//  IAUIWebViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 4/10/12.
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

#import "IACommon.h"

@interface IAUIWebViewController ()

@property (nonatomic, strong) UIWebView *ifa_webView;
@property (nonatomic, strong) IAHtmlDocument *ifa_htmlDocument;

@end

@implementation IAUIWebViewController{
    
}

#pragma mark - Overrides

-(void)viewDidLoad{
    [super viewDidLoad];
    self.ifa_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.ifa_webView.autoresizingMask = [IAUIUtils fullAutoresizingMask];
    self.ifa_webView.delegate = self;
    [self.view addSubview:self.ifa_webView];
    self.ifa_htmlDocument = [[IAHtmlDocument alloc] init];
    self.ifa_htmlDocument.htmlBodyString = [IAUtils stringFromResource:self.htmlResourceName type:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.ifa_webView loadHTMLString:[self.ifa_htmlDocument htmlString] baseURL:nil];
}

#pragma mark - UIWebViewDelegate protocol

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [IAUtils dispatchAsyncMainThreadBlock:^{
        [self.ifa_webView.scrollView flashScrollIndicators];
    }];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}

@end
