//
//  IFAWebViewController.m
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

#import "IFACommon.h"

@interface IFAWebViewController ()

@property (nonatomic, strong) UIWebView *IFA_webView;
@property (nonatomic, strong) IFAHtmlDocument *IFA_htmlDocument;

@end

@implementation IFAWebViewController {
    
}

#pragma mark - Overrides

-(void)viewDidLoad{
    [super viewDidLoad];
    self.IFA_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.IFA_webView.autoresizingMask = [IFAUIUtils fullAutoresizingMask];
    self.IFA_webView.delegate = self;
    [self.view addSubview:self.IFA_webView];
    self.IFA_htmlDocument = [[IFAHtmlDocument alloc] init];
    self.IFA_htmlDocument.htmlBodyString = [IFAUtils stringFromResource:self.htmlResourceName type:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.IFA_webView loadHTMLString:[self.IFA_htmlDocument htmlString] baseURL:nil];
}

#pragma mark - UIWebViewDelegate protocol

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [IFAUtils dispatchAsyncMainThreadBlock:^{
        [self.IFA_webView.scrollView flashScrollIndicators];
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
