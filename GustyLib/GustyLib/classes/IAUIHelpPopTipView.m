//
//  IAUIHelpPopTipView.m
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

#import "IACommon.h"

@interface IAUIHelpPopTipView ()

@property (strong, nonatomic) IBOutlet UIView *p_customContainerView;
@property (strong, nonatomic) IBOutlet UILabel *p_helpTargetTitleLabel;

@property (strong, nonatomic) UIWebView *p_webView;
@property (strong, nonatomic) UIView *p_viewPointedAt;
@property (strong, nonatomic) UIView *p_viewPresentedIn;
@property (strong, nonatomic) IAHtmlDocument *p_htmlDocument;
@property (strong, nonatomic) UITapGestureRecognizer *p_tapGestureRecognizer;
@property (strong, nonatomic) void (^p_completionBlock)(void);

@end

@implementation IAUIHelpPopTipView{
    @private
    BOOL v_maximised;
}

#pragma mark - Private

- (void)m_onTapGestureRecognizerAction:(id)sender {
    [self onUserDismissal];
}

-(CGFloat)m_calculateWidth{
    CGFloat l_width = 0;
    if (self.p_maximised) {
        l_width = [IAUIUtils m_widthForPortraitNumerator:0.9 portraitDenominator:1 landscapeNumerator:0.9 landscapeDenominator:1];
    }else{
        l_width = [IAUIUtils m_widthForPortraitNumerator:3 portraitDenominator:4 landscapeNumerator:2 landscapeDenominator:3];
    }
    return l_width;
}

#pragma mark - Public

-(void)setP_maximised:(BOOL)a_maximised{
    v_maximised = a_maximised;
    // Recalculate web view frame
    CGRect l_webViewFrame = self.p_webView.frame;
    self.p_webView.frame = CGRectMake(l_webViewFrame.origin.x, l_webViewFrame.origin.y, [self m_calculateWidth], l_webViewFrame.size.height);
}

-(BOOL)p_maximised{
    return v_maximised;
}

-(void)m_presentWithTitle:(NSString*)a_title description:(NSString*)a_description pointingAtView:(UIView *)a_viewPointedAt inView:(UIView *)a_viewPresentedIn completionBlock:(void (^)(void))a_completionBlock{
    
    self.p_presentationRequestInProgress = YES;
    
    // Save this infor for later when the webview has finished loading
    self.p_viewPointedAt = a_viewPointedAt;
    self.p_viewPresentedIn = a_viewPresentedIn;
    self.p_completionBlock = a_completionBlock;
    
    // Set the title
    self.p_helpTargetTitleLabel.text = a_title;
    self.p_helpTargetTitleLabel.hidden = !a_title || !self.p_isTitlePositionFixed;
    
    // Load the description in a webview
    NSString *l_htmlBody = nil;
    if (a_title && !self.p_isTitlePositionFixed) {
        l_htmlBody = [NSString stringWithFormat:@"<h1>%@</h1>%@", a_title, a_description];
    }else{
        l_htmlBody = a_description;
    }
    NSString  *l_htmlString = [self.p_htmlDocument m_htmlStringWithBody:l_htmlBody];
    [self.p_webView loadHTMLString:l_htmlString baseURL:nil];

    // Add the web view to the container view provided temporarily so its size can be recalculated automatically once the contents load
    //  At this point the web view is hidden
    [a_viewPresentedIn addSubview:self.p_webView];
    
}

#pragma mark - Overrides

-(id)init{

    if (self=[super initWithFrame:CGRectZero]) {

        // Configure the superclass
        self.delegate = self;
        self.disableTapToDismiss = YES;
        self.backgroundColor = [IAUIUtils m_colorForInfoPlistKey:@"IAUIHelpPopTipBackgroundColour"];
        if (!self.backgroundColor) {
            self.backgroundColor = [UIColor lightGrayColor];
        }
        self.cornerRadius = 8;
        
        // Load the XIB
        [[NSBundle mainBundle] loadNibNamed:@"IAUIHelpPopTipCustomView" owner:self options:nil];
        self.p_helpTargetTitleLabel.textColor = [IAUIUtils m_colorForInfoPlistKey:@"IAUIHelpPopTipTitleColour"];
        if (!self.p_helpTargetTitleLabel.textColor) {
            self.p_helpTargetTitleLabel.textColor = [UIColor blackColor];
        }

        // Configure the webview
        self.p_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [self m_calculateWidth], 1)];
        self.p_webView.delegate = self;
        self.p_webView.opaque = NO;
        self.p_webView.backgroundColor = [IAUIUtils m_colorForInfoPlistKey:@"IAUIHelpPopTipContentBackgroundColour"];
        if (!self.p_webView.backgroundColor) {
            self.p_webView.backgroundColor = [UIColor clearColor];
        }
        self.p_webView.hidden = YES;
        self.p_webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.p_webView.scrollView.alwaysBounceVertical = NO;
        [self.p_webView m_removeShadow];
        self.p_webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
        
        // Configure the HTML document
        NSString *l_htmlStyleResourceName = [[IAUtils infoPList] valueForKey:@"IAUIHelpPopTipBodyCss"];
        if (!l_htmlStyleResourceName) {
            l_htmlStyleResourceName = @"IAUIHelpPopTipView.css";
        }
        self.p_htmlDocument = [[IAHtmlDocument alloc] initWithHtmlStyleResourceName:l_htmlStyleResourceName];
        self.p_htmlDocument.p_htmlMetaString = @"";
        
        // Configure tap gesture recognizer
        self.p_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m_onTapGestureRecognizerAction:)];
        self.p_tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:self.p_tapGestureRecognizer];

    }

    return self;

}

#pragma mark - UIWebViewDelegate protocol

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    // Resize the web view now that its contents have loaded (it is still hidden at this point)
    [self.p_webView sizeToFit];
    
    // Reposition the web view
    CGFloat l_webViewY = (self.p_helpTargetTitleLabel.hidden ? 0 : self.p_helpTargetTitleLabel.frame.size.height);
    self.p_webView.frame = CGRectMake(self.p_webView.frame.origin.x, l_webViewY, self.p_webView.frame.size.width, self.p_webView.frame.size.height);
    
    // Configure views
    self.p_customContainerView.frame = CGRectMake(0, 0, self.p_webView.frame.size.width, self.p_webView.frame.origin.y+self.p_webView.frame.size.height);
    [self.p_customContainerView addSubview:self.p_webView];
    self.customView = self.p_customContainerView;
    [self addSubview:self.customView];
    
    BOOL l_shouldInvertLandscapeFrame = YES;
    if ([[IAHelpManager m_instance].p_observedHelpTargetContainer isKindOfClass:[IAUIAbstractFieldEditorViewController class]]) { // Simple Help
        l_shouldInvertLandscapeFrame = NO;
    }
    
    // Check final height and make any adjustments if required
    CGRect l_finalFrame = [self finalFramePointingAtView:self.p_viewPointedAt inView:self.p_viewPresentedIn shouldInvertLandscapeFrame:l_shouldInvertLandscapeFrame];
//    NSLog(@"l_finalFrame: %@", NSStringFromCGRect(l_finalFrame));
    NSInteger l_offScreenHeight = 0;
    CGFloat l_height = [IAUIUtils isDeviceInLandscapeOrientation] && l_shouldInvertLandscapeFrame ? self.p_viewPresentedIn.frame.size.width : self.p_viewPresentedIn.frame.size.height;
    if ( ( l_offScreenHeight = (l_finalFrame.origin.y + l_finalFrame.size.height) - l_height) > 0 ) {
        // Handles offscreen bottom
        self.p_customContainerView.frame = CGRectMake(self.p_customContainerView.frame.origin.x, self.p_customContainerView.frame.origin.y, self.p_customContainerView.frame.size.width, self.p_customContainerView.frame.size.height - l_offScreenHeight);
    }else if ( ( l_offScreenHeight = [IAUIUtils statusBarSizeForCurrentOrientation].height - l_finalFrame.origin.y) > 0 ) {
        // Handles offscreen top
        self.p_customContainerView.frame = CGRectMake(self.p_customContainerView.frame.origin.x, [IAUIUtils statusBarSizeForCurrentOrientation].height, self.p_customContainerView.frame.size.width, self.p_customContainerView.frame.size.height - l_offScreenHeight);
    }
    
    // Present the pop tip view
    [self presentPointingAtView:self.p_viewPointedAt inView:self.p_viewPresentedIn animated:YES shouldInvertLandscapeFrame:l_shouldInvertLandscapeFrame];
    
    // Show the web view
    self.p_webView.hidden = NO;
    [IAUtils m_dispatchAsyncMainThreadBlock:^{
        [self.p_webView.scrollView flashScrollIndicators];
    } afterDelay:0.1];

    self.p_presentationRequestInProgress = NO;
    
    // Run completion block
    self.p_completionBlock();
    self.p_completionBlock = nil;
    
}

#pragma mark - CMPopTipViewDelegate protocol

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView{
    [[IAHelpManager m_instance] m_removeHelpTargetSelectionWithAnimation:YES dismissPopTipView:NO];
}

#pragma mark - UIGestureRecognizerDelegate

// Implemented this method to allow the tap gesture recognizer to work in conjunction with the child UIWebView.
//  Without this method, taps to dismiss the pop tip are not recognized in the area corresponding to child UIWebView (they are probably "swallowed" by the web view).
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
