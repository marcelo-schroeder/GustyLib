//
//  IFAHelpPopTipView.m
//  Gusty
//
//  Created by Marcelo Schroeder on 17/04/12.
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

@interface IFAHelpPopTipView ()

@property (strong, nonatomic) UIWebView *ifa_webView;
@property (strong, nonatomic) UIView *ifa_viewPointedAt;
@property (strong, nonatomic) UIView *ifa_viewPresentedIn;
@property (strong, nonatomic) IFAHtmlDocument *ifa_htmlDocument;
@property (strong, nonatomic) UITapGestureRecognizer *ifa_tapGestureRecognizer;
@property (strong, nonatomic) void (^ifa_completionBlock)(void);

@end

@implementation IFAHelpPopTipView {
    @private
    BOOL v_maximised;
}

#pragma mark - Private

- (void)ifa_onTapGestureRecognizerAction:(id)sender {
    [self onUserDismissal];
}

-(CGFloat)ifa_calculateWidth {
    CGFloat l_width = 0;
    if (self.maximised) {
        l_width = [IFAUIUtils widthForPortraitNumerator:0.9 portraitDenominator:1 landscapeNumerator:0.9
                                   landscapeDenominator:1];
    }else{
        l_width = [IFAUIUtils widthForPortraitNumerator:3 portraitDenominator:4 landscapeNumerator:2
                                   landscapeDenominator:3];
    }
    return l_width;
}

#pragma mark - Public

-(void)setMaximised:(BOOL)a_maximised{
    v_maximised = a_maximised;
    // Recalculate web view frame
    CGRect l_webViewFrame = self.ifa_webView.frame;
    self.ifa_webView.frame = CGRectMake(l_webViewFrame.origin.x, l_webViewFrame.origin.y, [self ifa_calculateWidth], l_webViewFrame.size.height);
}

-(BOOL)maximised {
    return v_maximised;
}

-(void)presentWithTitle:(NSString *)a_title description:(NSString *)a_description
         pointingAtView:(UIView *)a_viewPointedAt inView:(UIView *)a_viewPresentedIn completionBlock:(void (^)(void))a_completionBlock{
    
    self.presentationRequestInProgress = YES;
    
    // Save this infor for later when the webview has finished loading
    self.ifa_viewPointedAt = a_viewPointedAt;
    self.ifa_viewPresentedIn = a_viewPresentedIn;
    self.ifa_completionBlock = a_completionBlock;
    
    // Set the title
    self.helpTargetTitleLabel.text = a_title;
    self.helpTargetTitleLabel.hidden = !a_title || !self.isTitlePositionFixed;
    
    // Load the description in a webview
    NSString *l_htmlBody = nil;
    if (a_title && !self.isTitlePositionFixed) {
        l_htmlBody = [NSString stringWithFormat:@"<h1>%@</h1>%@", a_title, a_description];
    }else{
        l_htmlBody = a_description;
    }
    NSString  *l_htmlString = [self.ifa_htmlDocument htmlStringWithBody:l_htmlBody];
    [self.ifa_webView loadHTMLString:l_htmlString baseURL:nil];

    // Add the web view to the container view provided temporarily so its size can be recalculated automatically once the contents load
    //  At this point the web view is hidden
    [a_viewPresentedIn addSubview:self.ifa_webView];
    
}

#pragma mark - Overrides

-(id)init{

    if (self=[super initWithFrame:CGRectZero]) {

        // Configure the superclass
        self.delegate = self;
        self.disableTapToDismiss = YES;
        self.backgroundColor = [IFAUIUtils colorForInfoPlistKey:@"IFAHelpPopTipBackgroundColour"];
        if (!self.backgroundColor) {
            self.backgroundColor = [UIColor lightGrayColor];
        }
        self.cornerRadius = 8;
        
        // Load the XIB
        [[NSBundle mainBundle] loadNibNamed:@"IFAHelpPopTipCustomView" owner:self options:nil];
        self.helpTargetTitleLabel.textColor = [IFAUIUtils colorForInfoPlistKey:@"IFAHelpPopTipTitleColour"];
        if (!self.helpTargetTitleLabel.textColor) {
            self.helpTargetTitleLabel.textColor = [UIColor blackColor];
        }

        // Configure the webview
        self.ifa_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [self ifa_calculateWidth], 1)];
        self.ifa_webView.delegate = self;
        self.ifa_webView.opaque = NO;
        self.ifa_webView.backgroundColor = [IFAUIUtils colorForInfoPlistKey:@"IFAHelpPopTipContentBackgroundColour"];
        if (!self.ifa_webView.backgroundColor) {
            self.ifa_webView.backgroundColor = [UIColor clearColor];
        }
        self.ifa_webView.hidden = YES;
        self.ifa_webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.ifa_webView.scrollView.alwaysBounceVertical = NO;
        [self.ifa_webView IFA_removeShadow];
        self.ifa_webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
        
        // Configure the HTML document
        NSString *l_htmlStyleResourceName = [[IFAUtils infoPList] valueForKey:@"IFAHelpPopTipBodyCss"];
        if (!l_htmlStyleResourceName) {
            l_htmlStyleResourceName = @"IFAHelpPopTipView.css";
        }
        self.ifa_htmlDocument = [[IFAHtmlDocument alloc] initWithHtmlStyleResourceName:l_htmlStyleResourceName];
        self.ifa_htmlDocument.htmlMetaString = @"";
        
        // Configure tap gesture recognizer
        self.ifa_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(ifa_onTapGestureRecognizerAction:)];
        self.ifa_tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.ifa_tapGestureRecognizer];

    }

    return self;

}

#pragma mark - UIWebViewDelegate protocol

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    // Resize the web view now that its contents have loaded (it is still hidden at this point)
    [self.ifa_webView sizeToFit];
    
    // Reposition the web view
    CGFloat l_webViewY = (self.helpTargetTitleLabel.hidden ? 0 : self.helpTargetTitleLabel.frame.size.height);
    self.ifa_webView.frame = CGRectMake(self.ifa_webView.frame.origin.x, l_webViewY, self.ifa_webView.frame.size.width, self.ifa_webView.frame.size.height);
    
    // Configure views
    self.customContainerView.frame = CGRectMake(0, 0, self.ifa_webView.frame.size.width, self.ifa_webView.frame.origin.y+self.ifa_webView.frame.size.height);
    [self.customContainerView addSubview:self.ifa_webView];
    self.customView = self.customContainerView;
    [self addSubview:self.customView];
    
    BOOL l_shouldInvertLandscapeFrame = YES;
    if ([[IFAHelpManager sharedInstance].observedHelpTargetContainer isKindOfClass:[IFAAbstractFieldEditorViewController class]]) { // Simple Help
        l_shouldInvertLandscapeFrame = NO;
    }
    
    // Check final height and make any adjustments if required
    CGRect l_finalFrame = [self finalFramePointingAtView:self.ifa_viewPointedAt inView:self.ifa_viewPresentedIn
                              shouldInvertLandscapeFrame:l_shouldInvertLandscapeFrame];
//    NSLog(@"l_finalFrame: %@", NSStringFromCGRect(l_finalFrame));
    NSInteger l_offScreenHeight = 0;
    CGFloat l_height = [IFAUIUtils isDeviceInLandscapeOrientation] && l_shouldInvertLandscapeFrame ? self.ifa_viewPresentedIn.frame.size.width : self.ifa_viewPresentedIn.frame.size.height;
    if ( ( l_offScreenHeight = (l_finalFrame.origin.y + l_finalFrame.size.height) - l_height) > 0 ) {
        // Handles offscreen bottom
        self.customContainerView.frame = CGRectMake(self.customContainerView.frame.origin.x, self.customContainerView.frame.origin.y, self.customContainerView.frame.size.width, self.customContainerView.frame.size.height - l_offScreenHeight);
    }else if ( ( l_offScreenHeight = [IFAUIUtils statusBarSizeForCurrentOrientation].height - l_finalFrame.origin.y) > 0 ) {
        // Handles offscreen top
        self.customContainerView.frame = CGRectMake(self.customContainerView.frame.origin.x, [IFAUIUtils statusBarSizeForCurrentOrientation].height, self.customContainerView.frame.size.width, self.customContainerView.frame.size.height - l_offScreenHeight);
    }
    
    // Present the pop tip view
    [self presentPointingAtView:self.ifa_viewPointedAt inView:self.ifa_viewPresentedIn animated:YES
     shouldInvertLandscapeFrame:l_shouldInvertLandscapeFrame];
    
    // Show the web view
    self.ifa_webView.hidden = NO;
    [IFAUtils dispatchAsyncMainThreadBlock:^{
        [self.ifa_webView.scrollView flashScrollIndicators];
    }                           afterDelay:0.1];

    self.presentationRequestInProgress = NO;
    
    // Run completion block
    self.ifa_completionBlock();
    self.ifa_completionBlock = nil;
    
}

#pragma mark - CMPopTipViewDelegate protocol

- (void)popTipViewWasDismissedByUser:(IFA_CMPopTipView *)popTipView{
    [[IFAHelpManager sharedInstance] removeHelpTargetSelectionWithAnimation:YES dismissPopTipView:NO];
}

#pragma mark - UIGestureRecognizerDelegate

// Implemented this method to allow the tap gesture recognizer to work in conjunction with the child UIWebView.
//  Without this method, taps to dismiss the pop tip are not recognized in the area corresponding to child UIWebView (they are probably "swallowed" by the web view).
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
