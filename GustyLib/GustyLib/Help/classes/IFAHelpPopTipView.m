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

#import "GustyLibHelp.h"

@interface IFAHelpPopTipView ()

@property (strong, nonatomic) UIWebView *IFA_webView;
@property (strong, nonatomic) UIView *IFA_viewPointedAt;
@property (strong, nonatomic) UIView *IFA_viewPresentedIn;
@property (strong, nonatomic) IFAHtmlDocument *IFA_htmlDocument;
@property (strong, nonatomic) UITapGestureRecognizer *IFA_tapGestureRecognizer;
@property (strong, nonatomic) void (^IFA_completionBlock)(void);

@property(nonatomic) BOOL IFA_maximised;
@end

@implementation IFAHelpPopTipView

#pragma mark - Private

- (void)IFA_onTapGestureRecognizerAction:(id)sender {
    [self onUserDismissal];
}

-(CGFloat)IFA_calculateWidth {
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
    self.IFA_maximised = a_maximised;
    // Recalculate web view frame
    CGRect l_webViewFrame = self.IFA_webView.frame;
    self.IFA_webView.frame = CGRectMake(l_webViewFrame.origin.x, l_webViewFrame.origin.y, [self IFA_calculateWidth], l_webViewFrame.size.height);
}

-(BOOL)maximised {
    return self.IFA_maximised;
}

-(void)presentWithTitle:(NSString *)a_title description:(NSString *)a_description
         pointingAtView:(UIView *)a_viewPointedAt inView:(UIView *)a_viewPresentedIn completionBlock:(void (^)(void))a_completionBlock{
    
    self.presentationRequestInProgress = YES;
    
    // Save this infor for later when the webview has finished loading
    self.IFA_viewPointedAt = a_viewPointedAt;
    self.IFA_viewPresentedIn = a_viewPresentedIn;
    self.IFA_completionBlock = a_completionBlock;
    
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
    NSString  *l_htmlString = [self.IFA_htmlDocument htmlStringWithBody:l_htmlBody];
    [self.IFA_webView loadHTMLString:l_htmlString baseURL:nil];

    // Add the web view to the container view provided temporarily so its size can be recalculated automatically once the contents load
    //  At this point the web view is hidden
    [a_viewPresentedIn addSubview:self.IFA_webView];
    
}

#pragma mark - Overrides

-(id)init{

    if (self=[super initWithFrame:CGRectZero]) {

        // Configure the superclass
        self.delegate = self;
        self.disableTapToDismiss = YES;
        self.contentBackgroundColor = [IFAUIUtils colorForInfoPlistKey:@"IFAHelpPopTipBackgroundColour"];
        if (!self.contentBackgroundColor) {
            self.contentBackgroundColor = [UIColor redColor];
        }
        self.cornerRadius = 8;
        
        // Load the XIB
        [[NSBundle mainBundle] loadNibNamed:@"IFAHelpPopTipCustomView" owner:self options:nil];
        self.helpTargetTitleLabel.textColor = [IFAUIUtils colorForInfoPlistKey:@"IFAHelpPopTipTitleColour"];
        if (!self.helpTargetTitleLabel.textColor) {
            self.helpTargetTitleLabel.textColor = [UIColor blackColor];
        }

        // Configure the webview
        self.IFA_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [self IFA_calculateWidth], 1)];
        self.IFA_webView.delegate = self;
        self.IFA_webView.opaque = NO;
        self.IFA_webView.backgroundColor = [IFAUIUtils colorForInfoPlistKey:@"IFAHelpPopTipContentBackgroundColour"];
        if (!self.IFA_webView.backgroundColor) {
            self.IFA_webView.backgroundColor = [UIColor clearColor];
        }
        self.IFA_webView.hidden = YES;
        self.IFA_webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.IFA_webView.scrollView.alwaysBounceVertical = NO;
        [self.IFA_webView ifa_removeShadow];
        self.IFA_webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
        
        // Configure the HTML document
        NSString *l_htmlStyleResourceName = [[IFAUtils infoPList] valueForKey:@"IFAHelpPopTipBodyCss"];
        if (!l_htmlStyleResourceName) {
            l_htmlStyleResourceName = @"IFAHelpPopTipView.css";
        }
        self.IFA_htmlDocument = [[IFAHtmlDocument alloc] initWithHtmlStyleResourceName:l_htmlStyleResourceName];
        self.IFA_htmlDocument.htmlMetaString = @"";
        
        // Configure tap gesture recognizer
        self.IFA_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(IFA_onTapGestureRecognizerAction:)];
        self.IFA_tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.IFA_tapGestureRecognizer];

    }

    return self;

}

#pragma mark - UIWebViewDelegate protocol

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    // Resize the web view now that its contents have loaded (it is still hidden at this point)
    [self.IFA_webView sizeToFit];
    
    // Reposition the web view
    CGFloat l_webViewY = (self.helpTargetTitleLabel.hidden ? 0 : self.helpTargetTitleLabel.frame.size.height);
    self.IFA_webView.frame = CGRectMake(self.IFA_webView.frame.origin.x, l_webViewY, self.IFA_webView.frame.size.width, self.IFA_webView.frame.size.height);
    
    // Configure views
    self.customContainerView.frame = CGRectMake(0, 0, self.IFA_webView.frame.size.width, self.IFA_webView.frame.origin.y+self.IFA_webView.frame.size.height);
    [self.customContainerView addSubview:self.IFA_webView];
    self.customView = self.customContainerView;
    [self addSubview:self.customView];
    
    BOOL l_shouldInvertLandscapeFrame = YES;
    if ([[IFAHelpManager sharedInstance].observedHelpTargetContainer isKindOfClass:[IFAAbstractFieldEditorViewController class]]) { // Simple Help
        l_shouldInvertLandscapeFrame = NO;
    }
    
    // Check final height and make any adjustments if required
    CGRect l_finalFrame = [self finalFramePointingAtView:self.IFA_viewPointedAt inView:self.IFA_viewPresentedIn
                              shouldInvertLandscapeFrame:l_shouldInvertLandscapeFrame];
//    NSLog(@"l_finalFrame: %@", NSStringFromCGRect(l_finalFrame));
    NSInteger l_offScreenHeight = 0;
    CGFloat l_height = [IFAUIUtils isDeviceInLandscapeOrientation] && l_shouldInvertLandscapeFrame ? self.IFA_viewPresentedIn.frame.size.width : self.IFA_viewPresentedIn.frame.size.height;
    if ( ( l_offScreenHeight = (l_finalFrame.origin.y + l_finalFrame.size.height) - l_height) > 0 ) {
        // Handles offscreen bottom
        self.customContainerView.frame = CGRectMake(self.customContainerView.frame.origin.x, self.customContainerView.frame.origin.y, self.customContainerView.frame.size.width, self.customContainerView.frame.size.height - l_offScreenHeight);
    }else if ( ( l_offScreenHeight = [IFAUIUtils statusBarSizeForCurrentOrientation].height - l_finalFrame.origin.y) > 0 ) {
        // Handles offscreen top
        self.customContainerView.frame = CGRectMake(self.customContainerView.frame.origin.x, [IFAUIUtils statusBarSizeForCurrentOrientation].height, self.customContainerView.frame.size.width, self.customContainerView.frame.size.height - l_offScreenHeight);
    }
    
    // Present the pop tip view
    [self presentPointingAtView:self.IFA_viewPointedAt inView:self.IFA_viewPresentedIn animated:YES
     shouldInvertLandscapeFrame:l_shouldInvertLandscapeFrame];
    
    // Show the web view
    self.IFA_webView.hidden = NO;
    __weak __typeof(self) l_weakSelf = self;
    [IFAUtils dispatchAsyncMainThreadBlock:^{
        [l_weakSelf.IFA_webView.scrollView flashScrollIndicators];
    }                           afterDelay:0.1];

    self.presentationRequestInProgress = NO;
    
    // Run completion block
    self.IFA_completionBlock();
    self.IFA_completionBlock = nil;
    
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
