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
@property(nonatomic, strong) UIBarButtonItem *XYZ_actionBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *XYZ_previousBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *XYZ_nextBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *XYZ_stopBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *XYZ_refreshBarButtonItem;
@property(nonatomic, strong) UIBarButtonItem *XYZ_refreshStopBarButtonItem;
@property(nonatomic, strong) UIActivityIndicatorView *XYZ_activityIndicatorView;
@property(nonatomic, strong) UIBarButtonItem *XYZ_activityIndicatorBarButtonItem;

@end

@implementation IFAInternalWebBrowserViewController {

}
#pragma mark - Private

- (UIActivityIndicatorView *)XYZ_activityIndicatorView {
    if (!_XYZ_activityIndicatorView) {
        _XYZ_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _XYZ_activityIndicatorView.color = [UIColor blackColor];
        [_XYZ_activityIndicatorView sizeToFit];
        [_XYZ_activityIndicatorView startAnimating];
    }
    return _XYZ_activityIndicatorView;
}

-(void)XYZ_onActionBarButtonTap:(UIBarButtonItem*)a_button{
    [self ifa_presentActivityViewControllerFromBarButtonItem:a_button webView:self.mainWebView];
}

- (void)XYZ_configureBrowserButtons {

    self.XYZ_actionBarButtonItem = [self.delegate newActionBarButtonItem];
    self.XYZ_actionBarButtonItem.target = self;
    self.XYZ_actionBarButtonItem.action = @selector(XYZ_onActionBarButtonTap:);

    self.XYZ_previousBarButtonItem = [self.delegate newPreviousBarButtonItem];
    self.XYZ_previousBarButtonItem.target = self;
    self.XYZ_previousBarButtonItem.action = @selector(goBackClicked:);

    self.XYZ_nextBarButtonItem = [self.delegate newNextBarButtonItem];
    self.XYZ_nextBarButtonItem.target = self;
    self.XYZ_nextBarButtonItem.action = @selector(goForwardClicked:);

    self.XYZ_stopBarButtonItem = [self.delegate newStopBarButtonItem];
    self.XYZ_stopBarButtonItem.target = self;
    self.XYZ_stopBarButtonItem.action = @selector(stopClicked:);

    self.XYZ_refreshBarButtonItem = [self.delegate newRefreshBarButtonItem];
    self.XYZ_refreshBarButtonItem.target = self;
    self.XYZ_refreshBarButtonItem.action = @selector(reloadClicked:);

    self.XYZ_activityIndicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.XYZ_activityIndicatorView];
    self.XYZ_activityIndicatorBarButtonItem.width = self.XYZ_activityIndicatorView.frame.size.width;

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
    [self XYZ_configureBrowserButtons];
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
    self.XYZ_previousBarButtonItem.enabled = self.mainWebView.canGoBack;
    self.XYZ_nextBarButtonItem.enabled = self.mainWebView.canGoForward;
    [self ifa_removeRightBarButtonItem:self.XYZ_refreshStopBarButtonItem];
    self.XYZ_refreshStopBarButtonItem = self.urlLoadCount ? self.XYZ_stopBarButtonItem : self.XYZ_refreshBarButtonItem;
    NSUInteger i = 0;
    [self ifa_insertRightBarButtonItem:self.XYZ_actionBarButtonItem atIndex:i++];
    [self ifa_insertRightBarButtonItem:self.XYZ_nextBarButtonItem atIndex:i++];
    [self ifa_insertRightBarButtonItem:self.XYZ_previousBarButtonItem atIndex:i++];
    [self ifa_insertRightBarButtonItem:self.XYZ_refreshStopBarButtonItem atIndex:i++];
    [self ifa_insertRightBarButtonItem:self.XYZ_activityIndicatorBarButtonItem atIndex:i];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [super webViewDidStartLoad:webView];
    [self.XYZ_activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
//    self.navigationItem.title = nil;
    [self.XYZ_activityIndicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [super webView:webView didFailLoadWithError:error];
    [self.XYZ_activityIndicatorView stopAnimating];
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