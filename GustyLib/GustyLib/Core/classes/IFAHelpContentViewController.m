//
// Created by Marcelo Schroeder on 24/09/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import "GustyLibHelp.h"

//wip: move styling to appearance theme
@interface IFAHelpContentViewController ()
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) IFAHtmlDocument *IFA_htmlDocument;
@property(nonatomic, strong) void (^IFA_completion)();
@end

@implementation IFAHelpContentViewController {

}

#pragma mark - Public

- (void)loadWebViewWithHtmlBody:(NSString *)a_htmlBody completion:(void (^)())a_completion {
    self.IFA_completion = a_completion;
    [self view];    // Make sure the view is initialised
    NSString  *l_htmlString = [self.IFA_htmlDocument htmlStringWithBody:a_htmlBody];
    [self.webView loadHTMLString:l_htmlString baseURL:nil];
}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.webView];
    [self.webView ifa_addLayoutConstraintsToFillSuperview];
}

- (CGSize)preferredContentSize {
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.webView.scrollView.contentSize.height;
    return CGSizeMake(width, height);
}

#pragma mark - UIWebViewDelegate protocol

//wip: clean up
-(void)webViewDidFinishLoad:(UIWebView *)webView{

    if (self.IFA_completion) {
        self.IFA_completion();
    }

//    // Reposition the web view
//    CGFloat l_webViewY = (self.helpTargetTitleLabel.hidden ? 0 : self.helpTargetTitleLabel.frame.size.height);
//    self.webView.frame = CGRectMake(self.webView.frame.origin.x, l_webViewY, self.webView.frame.size.width, self.webView.frame.size.height);
//
//    // Configure views
//    self.customContainerView.frame = CGRectMake(0, 0, self.webView.frame.size.width, self.webView.frame.origin.y+self.webView.frame.size.height);
//    [self.customContainerView addSubview:self.webView];
//    self.customView = self.customContainerView;
//    [self addSubview:self.customView];
//
//    BOOL l_shouldInvertLandscapeFrame = YES;    //wip: is this still required?
//    if ([[IFAHelpManager sharedInstance].helpTargetViewController isKindOfClass:[IFAAbstractFieldEditorViewController class]]) { // Simple Help
//        l_shouldInvertLandscapeFrame = NO;
//    }
//
//    // Check final height and make any adjustments if required
//    CGRect l_finalFrame = [self finalFramePointingAtView:self.IFA_viewPointedAt inView:self.IFA_viewPresentedIn
//                              shouldInvertLandscapeFrame:l_shouldInvertLandscapeFrame];
////    NSLog(@"l_finalFrame: %@", NSStringFromCGRect(l_finalFrame));
//    NSInteger l_offScreenHeight = 0;
//    CGFloat l_height = [IFAUIUtils isDeviceInLandscapeOrientation] && l_shouldInvertLandscapeFrame ? self.IFA_viewPresentedIn.frame.size.width : self.IFA_viewPresentedIn.frame.size.height;
//    if ( ( l_offScreenHeight = (l_finalFrame.origin.y + l_finalFrame.size.height) - l_height) > 0 ) {
//        // Handles offscreen bottom
//        self.customContainerView.frame = CGRectMake(self.customContainerView.frame.origin.x, self.customContainerView.frame.origin.y, self.customContainerView.frame.size.width, self.customContainerView.frame.size.height - l_offScreenHeight);
//    }else if ( ( l_offScreenHeight = [IFAUIUtils statusBarSizeForCurrentOrientation].height - l_finalFrame.origin.y) > 0 ) {
//        // Handles offscreen top
//        self.customContainerView.frame = CGRectMake(self.customContainerView.frame.origin.x, [IFAUIUtils statusBarSizeForCurrentOrientation].height, self.customContainerView.frame.size.width, self.customContainerView.frame.size.height - l_offScreenHeight);
//    }
//
//    // Present the pop tip view
//    [self presentPointingAtView:self.IFA_viewPointedAt inView:self.IFA_viewPresentedIn animated:YES
//     shouldInvertLandscapeFrame:l_shouldInvertLandscapeFrame];
//
//    // Show the web view
//    self.webView.hidden = NO;
//    __weak __typeof(self) l_weakSelf = self;
//    [IFAUtils dispatchAsyncMainThreadBlock:^{
//        [l_weakSelf.webView.scrollView flashScrollIndicators];
//    }                           afterDelay:0.1];
//
//    self.presentationRequestInProgress = NO;
//
//    // Run completion block
//    if (self.IFA_completionBlock) {
//        self.IFA_completionBlock();
//    }
//    self.IFA_completionBlock = nil;

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self webViewDidFinishLoad:webView];
}

#pragma mark - Private

- (UIWebView *)webView {
    if (!_webView) {

        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];    //wip: hardcoded
//        _webView.clipsToBounds = NO;  //wip: clean up
        _webView.delegate = self;
        _webView.opaque = NO;
//        _webView.scalesPageToFit = YES;

//        _webView.backgroundColor = [IFAUIUtils colorForInfoPlistKey:@"IFAHelpPopTipContentBackgroundColour"];   //wip: retire this
//        if (!_webView.backgroundColor) {
            //wip: review
            _webView.backgroundColor = [UIColor clearColor];
//            _webView.backgroundColor = [UIColor orangeColor];
//        }
//        _webView.hidden = YES;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//        [_webView ifa_removeShadow];  //wip: clean up

        // Configure scroll view
        UIScrollView *scrollView = _webView.scrollView;
        scrollView.contentInset = UIEdgeInsetsMake(8, 0, 8, 0);
        scrollView.alwaysBounceVertical = NO;
        scrollView.scrollIndicatorInsets = scrollView.contentInset;
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    }
    return _webView;
}

- (IFAHtmlDocument *)IFA_htmlDocument {
    if (!_IFA_htmlDocument) {
        NSString *l_htmlStyleResourceName = [[IFAUtils infoPList] valueForKey:@"IFAHelpPopTipBodyCss"]; //wip: rename this plist property name (it is no longer a pop tip)
        if (!l_htmlStyleResourceName) {
            l_htmlStyleResourceName = @"IFAHelpPopTipView.css";
        }
        _IFA_htmlDocument = [[IFAHtmlDocument alloc] initWithHtmlStyleResourceName:l_htmlStyleResourceName];
        _IFA_htmlDocument.htmlMetaString = @"";
    }
    return _IFA_htmlDocument;
}

@end