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

#import "IFACommon.h"

@interface IFAInternalWebBrowserViewController ()
@property(nonatomic, strong) UIBarButtonItem *ifa_actionBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *ifa_previousBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *ifa_nextBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *ifa_stopBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *ifa_refreshBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *ifa_refreshStopBarButtonItem;
@property(nonatomic, strong) UIActivityIndicatorView *ifa_activityIndicatorView;
@property(nonatomic, strong) UIBarButtonItem *ifa_activityIndicatorBarButtonItem;

@end

@implementation IFAInternalWebBrowserViewController {

}
#pragma mark - Private

- (UIActivityIndicatorView *)ifa_activityIndicatorView {
    if (!_ifa_activityIndicatorView) {
        _ifa_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _ifa_activityIndicatorView.color = [UIColor blackColor];
        [_ifa_activityIndicatorView sizeToFit];
        [_ifa_activityIndicatorView startAnimating];
    }
    return _ifa_activityIndicatorView;
}

-(void)ifa_onActionBarButtonTap:(UIBarButtonItem*)a_button{
    [self IFA_presentActivityViewControllerFromBarButtonItem:a_button webView:self.mainWebView];
}

- (void)ifa_configureBrowserButtons {

    self.ifa_actionBarButtonItem = [self.delegate newActionBarButtonItem];
    self.ifa_actionBarButtonItem.target = self;
    self.ifa_actionBarButtonItem.action = @selector(ifa_onActionBarButtonTap:);

    self.ifa_previousBarButtonItem = [self.delegate newPreviousBarButtonItem];
    self.ifa_previousBarButtonItem.target = self;
    self.ifa_previousBarButtonItem.action = @selector(goBackClicked:);

    self.ifa_nextBarButtonItem = [self.delegate newNextBarButtonItem];
    self.ifa_nextBarButtonItem.target = self;
    self.ifa_nextBarButtonItem.action = @selector(goForwardClicked:);

    self.ifa_stopBarButtonItem = [self.delegate newStopBarButtonItem];
    self.ifa_stopBarButtonItem.target = self;
    self.ifa_stopBarButtonItem.action = @selector(stopClicked:);

    self.ifa_refreshBarButtonItem = [self.delegate newRefreshBarButtonItem];
    self.ifa_refreshBarButtonItem.target = self;
    self.ifa_refreshBarButtonItem.action = @selector(reloadClicked:);

    self.ifa_activityIndicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.ifa_activityIndicatorView];
    self.ifa_activityIndicatorBarButtonItem.width = self.ifa_activityIndicatorView.frame.size.width;

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
    self.delegate = self;
    [self ifa_configureBrowserButtons];
    [super viewDidLoad];
    if (self.IFA_presentedAsModal) {
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
    self.ifa_previousBarButtonItem.enabled = self.mainWebView.canGoBack;
    self.ifa_nextBarButtonItem.enabled = self.mainWebView.canGoForward;
    [self IFA_removeRightBarButtonItem:self.ifa_refreshStopBarButtonItem];
    self.ifa_refreshStopBarButtonItem = self.urlLoadCount ? self.ifa_stopBarButtonItem : self.ifa_refreshBarButtonItem;
    NSUInteger i = 0;
    [self IFA_insertRightBarButtonItem:self.ifa_actionBarButtonItem atIndex:i++];
    [self IFA_insertRightBarButtonItem:self.ifa_nextBarButtonItem atIndex:i++];
    [self IFA_insertRightBarButtonItem:self.ifa_previousBarButtonItem atIndex:i++];
    [self IFA_insertRightBarButtonItem:self.ifa_refreshStopBarButtonItem atIndex:i++];
    [self IFA_insertRightBarButtonItem:self.ifa_activityIndicatorBarButtonItem atIndex:i];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [super webViewDidStartLoad:webView];
    [self.ifa_activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
//    self.navigationItem.title = nil;
    [self.ifa_activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [super webView:webView didFailLoadWithError:error];
    [self.ifa_activityIndicatorView stopAnimating];
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