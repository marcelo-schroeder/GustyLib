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

#import "GustyLibCoreUI.h"

@interface IFAInternalWebBrowserViewController ()
@property(nonatomic, strong) UIBarButtonItem *IFA_actionBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *IFA_previousBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *IFA_nextBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *IFA_stopBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *IFA_refreshBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *IFA_refreshStopBarButtonItem;
@property(nonatomic, strong) UIActivityIndicatorView *IFA_activityIndicatorView;
@property(nonatomic, strong) UIBarButtonItem *IFA_activityIndicatorBarButtonItem;

@end

@implementation IFAInternalWebBrowserViewController {

}
#pragma mark - Private

- (UIActivityIndicatorView *)IFA_activityIndicatorView {
    if (!_IFA_activityIndicatorView) {
        _IFA_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _IFA_activityIndicatorView.color = [UIColor blackColor];
        [_IFA_activityIndicatorView sizeToFit];
        [_IFA_activityIndicatorView startAnimating];
    }
    return _IFA_activityIndicatorView;
}

-(void)IFA_onActionBarButtonTap:(UIBarButtonItem*)a_button{
    [self ifa_presentActivityViewControllerFromBarButtonItem:a_button webView:self.mainWebView];
}

- (void)IFA_configureBrowserButtons {

    self.IFA_actionBarButtonItem = [self.delegate newActionBarButtonItem];
    self.IFA_actionBarButtonItem.target = self;
    self.IFA_actionBarButtonItem.action = @selector(IFA_onActionBarButtonTap:);

    self.IFA_previousBarButtonItem = [self.delegate newPreviousBarButtonItem];
    self.IFA_previousBarButtonItem.target = self;
    self.IFA_previousBarButtonItem.action = @selector(goBackClicked:);

    self.IFA_nextBarButtonItem = [self.delegate newNextBarButtonItem];
    self.IFA_nextBarButtonItem.target = self;
    self.IFA_nextBarButtonItem.action = @selector(goForwardClicked:);

    self.IFA_stopBarButtonItem = [self.delegate newStopBarButtonItem];
    self.IFA_stopBarButtonItem.target = self;
    self.IFA_stopBarButtonItem.action = @selector(stopClicked:);

    self.IFA_refreshBarButtonItem = [self.delegate newRefreshBarButtonItem];
    self.IFA_refreshBarButtonItem.target = self;
    self.IFA_refreshBarButtonItem.action = @selector(reloadClicked:);

    self.IFA_activityIndicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.IFA_activityIndicatorView];
    self.IFA_activityIndicatorBarButtonItem.width = self.IFA_activityIndicatorView.frame.size.width;

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
    [self IFA_configureBrowserButtons];
    [super viewDidLoad];
    if (self.ifa_presentedAsModal) {
        self.navigationItem.leftBarButtonItems = nil;
        [self ifa_addLeftBarButtonItem:[[self ifa_appearanceTheme] doneBarButtonItemWithTarget:self
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
    self.IFA_previousBarButtonItem.enabled = self.mainWebView.canGoBack;
    self.IFA_nextBarButtonItem.enabled = self.mainWebView.canGoForward;
    [self ifa_removeRightBarButtonItem:self.IFA_refreshStopBarButtonItem];
    self.IFA_refreshStopBarButtonItem = self.urlLoadCount ? self.IFA_stopBarButtonItem : self.IFA_refreshBarButtonItem;
    NSUInteger i = 0;
    [self ifa_insertRightBarButtonItem:self.IFA_actionBarButtonItem atIndex:i++];
    [self ifa_insertRightBarButtonItem:self.IFA_nextBarButtonItem atIndex:i++];
    [self ifa_insertRightBarButtonItem:self.IFA_previousBarButtonItem atIndex:i++];
    [self ifa_insertRightBarButtonItem:self.IFA_refreshStopBarButtonItem atIndex:i++];
    [self ifa_insertRightBarButtonItem:self.IFA_activityIndicatorBarButtonItem atIndex:i];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [super webViewDidStartLoad:webView];
    [self.IFA_activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
//    self.navigationItem.title = nil;
    [self.IFA_activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [super webView:webView didFailLoadWithError:error];
    [self.IFA_activityIndicatorView stopAnimating];
}

#pragma mark - IFAInternalWebBrowserViewControllerDelegate

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