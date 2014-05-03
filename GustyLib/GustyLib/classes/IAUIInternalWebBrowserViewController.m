//
// Created by Marcelo Schroeder on 27/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//
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

@interface IAUIInternalWebBrowserViewController ()
@property(nonatomic, strong) UIBarButtonItem *p_actionBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *p_previousBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *p_nextBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *p_stopBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *p_refreshBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *p_refreshStopBarButtonItem;
@property(nonatomic, strong) UIActivityIndicatorView *p_activityIndicatorView;
@property(nonatomic, strong) UIBarButtonItem *p_activityIndicatorBarButtonItem;

@end

@implementation IAUIInternalWebBrowserViewController {

}
#pragma mark - Private

- (UIActivityIndicatorView *)p_activityIndicatorView {
    if (!_p_activityIndicatorView) {
        _p_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _p_activityIndicatorView.color = [UIColor blackColor];
        [_p_activityIndicatorView sizeToFit];
        [_p_activityIndicatorView startAnimating];
    }
    return _p_activityIndicatorView;
}

-(void)ifa_onActionBarButtonTap:(UIBarButtonItem*)a_button{
    [self IFA_presentActivityViewControllerFromBarButtonItem:a_button webView:self.mainWebView];
}

- (void)ifa_configureBrowserButtons {

    self.p_actionBarButtonItem = [self.p_delegate newActionBarButtonItem];
    self.p_actionBarButtonItem.target = self;
    self.p_actionBarButtonItem.action = @selector(ifa_onActionBarButtonTap:);

    self.p_previousBarButtonItem = [self.p_delegate newPreviousBarButtonItem];
    self.p_previousBarButtonItem.target = self;
    self.p_previousBarButtonItem.action = @selector(goBackClicked:);

    self.p_nextBarButtonItem = [self.p_delegate newNextBarButtonItem];
    self.p_nextBarButtonItem.target = self;
    self.p_nextBarButtonItem.action = @selector(goForwardClicked:);

    self.p_stopBarButtonItem = [self.p_delegate newStopBarButtonItem];
    self.p_stopBarButtonItem.target = self;
    self.p_stopBarButtonItem.action = @selector(stopClicked:);

    self.p_refreshBarButtonItem = [self.p_delegate newRefreshBarButtonItem];
    self.p_refreshBarButtonItem.target = self;
    self.p_refreshBarButtonItem.action = @selector(reloadClicked:);

    self.p_activityIndicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.p_activityIndicatorView];
    self.p_activityIndicatorBarButtonItem.width = self.p_activityIndicatorView.frame.size.width;

}

#pragma mark - Overrides

- (id)initWithURL:(NSURL *)url completionBlock:(void (^)(void))a_completionBlock {
    self = [super initWithURL:url completionBlock:a_completionBlock];
    if (self) {
        self.iphoneUiForAllIdioms = YES;
    }
    return self;
}

- (void)viewDidLoad {
    self.p_delegate = self;
    [self ifa_configureBrowserButtons];
    [super viewDidLoad];
    if (self.p_presentedAsModal) {
        self.navigationItem.leftBarButtonItems = nil;
        [self IFA_addLeftBarButtonItem:[[self IFA_appearanceTheme] doneBarButtonItemWithTarget:self
                                                                                      action:@selector(doneButtonClicked:)
                                                                              viewController:self]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)updateToolbarItems {
    [super updateToolbarItems];
    self.p_previousBarButtonItem.enabled = self.mainWebView.canGoBack;
    self.p_nextBarButtonItem.enabled = self.mainWebView.canGoForward;
    [self IFA_removeRightBarButtonItem:self.p_refreshStopBarButtonItem];
    self.p_refreshStopBarButtonItem = self.p_urlLoadCount ? self.p_stopBarButtonItem : self.p_refreshBarButtonItem;
    NSUInteger i = 0;
    [self IFA_insertRightBarButtonItem:self.p_actionBarButtonItem atIndex:i++];
    [self IFA_insertRightBarButtonItem:self.p_nextBarButtonItem atIndex:i++];
    [self IFA_insertRightBarButtonItem:self.p_previousBarButtonItem atIndex:i++];
    [self IFA_insertRightBarButtonItem:self.p_refreshStopBarButtonItem atIndex:i++];
    [self IFA_insertRightBarButtonItem:self.p_activityIndicatorBarButtonItem atIndex:i];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [super webViewDidStartLoad:webView];
    [self.p_activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
//    self.navigationItem.title = nil;
    [self.p_activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [super webView:webView didFailLoadWithError:error];
    [self.p_activityIndicatorView stopAnimating];
}

#pragma mark - IAUIInternalWebBrowserViewControllerDelegate

- (UIBarButtonItem *)newActionBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                         target:nil action:nil];
}

- (UIBarButtonItem *)newPreviousBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                         target:nil action:nil];
}

- (UIBarButtonItem *)newNextBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                         target:nil action:nil];
}

- (UIBarButtonItem *)newStopBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                         target:nil action:nil];
}

- (UIBarButtonItem *)newRefreshBarButtonItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                         target:nil action:nil];
}

@end