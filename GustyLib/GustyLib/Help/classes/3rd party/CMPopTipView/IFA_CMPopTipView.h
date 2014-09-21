//
//  IFA_CMPopTipView.h
//
//  Created by Chris Miles on 18/07/10.
//  Copyright (c) Chris Miles 2010-2011.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

/** \brief	Display a speech bubble-like popup on screen, pointing at the
			designated view or button.
 
	A UIView subclass drawn using core graphics. Pops up (optionally animated)
	a speech bubble-like view on screen, a rounded rectangle with a gradiant
	fill containing a specified text message, drawn with a pointer dynamically
	positioned to point at the center of the designated button or view.
 
 Example 1 - point at a UIBarButtonItem in a nav bar:
 
	- (void)showPopTipView {
		NSString *message = @"Start by adding a waterway to your favourites.";
		IFA_CMPopTipView *popTipView = [[IFA_CMPopTipView alloc] initWithMessage:message];
		popTipView.delegate = self;
		[popTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
		
		self.myPopTipView = popTipView;
		[popTipView release];
	}

	- (void)dismissPopTipView {
		[self.myPopTipView dismissAnimated:NO];
		self.myPopTipView = nil;
	}

 
	#pragma mark CMPopTipViewDelegate methods
	- (void)popTipViewWasDismissedByUser:(IFA_CMPopTipView *)popTipView {
		// User can tap IFA_CMPopTipView to dismiss it
		self.myPopTipView = nil;
	}

 Example 2 - pointing at a UIButton:

	- (IBAction)buttonAction:(id)sender {
		// Toggle popTipView when a standard UIButton is pressed
		if (nil == self.roundRectButtonPopTipView) {
			self.roundRectButtonPopTipView = [[[IFA_CMPopTipView alloc] initWithMessage:@"My message"] autorelease];
			self.roundRectButtonPopTipView.delegate = self;

			UIButton *button = (UIButton *)sender;
			[self.roundRectButtonPopTipView presentPointingAtView:button inView:self.view animated:YES];
		}
		else {
			// Dismiss
			[self.roundRectButtonPopTipView dismissAnimated:YES];
			self.roundRectButtonPopTipView = nil;
		}	
	}

	#pragma mark CMPopTipViewDelegate methods
	- (void)popTipViewWasDismissedByUser:(IFA_CMPopTipView *)popTipView {
		// User can tap IFA_CMPopTipView to dismiss it
		self.roundRectButtonPopTipView = nil;
	}
 
 */

#import <UIKit/UIKit.h>

typedef enum {
	PointDirectionUp = 0,
	PointDirectionDown
} PointDirection;

typedef enum {
    CMPopTipAnimationSlide = 0,
    CMPopTipAnimationPop,
    CMPopTipAnimationDissolve,
} CMPopTipAnimation;


@protocol CMPopTipViewDelegate;

//todo: when converting Gusty to GustyLib, I had to make changes in this class to make it compile - some thorough testing is needed at some stage
@interface IFA_CMPopTipView : UIView {
	@private
	CGSize					bubbleSize;
	BOOL					highlight;
	PointDirection			pointDirection;
	CGPoint					targetPoint;
}

@property(nonatomic, strong) UIColor *contentBackgroundColor;
@property(nonatomic, weak) id <CMPopTipViewDelegate> delegate;
@property(nonatomic) BOOL disableTapToDismiss;
@property(nonatomic, strong) NSString *message;
@property(nonatomic, strong) UIView *customView;
@property(nonatomic, readonly) id targetObject;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, strong) UIFont *textFont;
@property(nonatomic) CMPopTipAnimation animation;
@property(nonatomic) CGFloat maxWidth;
@property(nonatomic) CGFloat sidePadding;
@property(nonatomic) CGFloat topMargin;
@property(nonatomic) CGFloat cornerRadius;
@property(nonatomic) CGFloat pointerSize;

/* Contents can be either a message or a UIView */
- (id)initWithMessage:(NSString *)messageToShow;
- (id)initWithCustomView:(UIView *)aView;

- (CGRect)finalFramePointingAtView:(UIView *)targetView inView:(UIView *)containerView;
- (CGRect)finalFramePointingAtView:(UIView *)targetView inView:(UIView *)containerView shouldInvertLandscapeFrame:(BOOL)a_shouldInvertLandscapeFrame;
- (void)presentPointingAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated;
- (void)presentPointingAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated shouldInvertLandscapeFrame:(BOOL)a_shouldInvertLandscapeFrame;
//- (void)presentPointingAtBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated;  // COMMENTED OUT AS IMPLEMENTATION MAKES USE OF UNDOCUMENTED METHOD
- (void)dismissAnimated:(BOOL)animated;
- (void)onUserDismissal;

- (PointDirection) getPointDirection;

@end


@protocol CMPopTipViewDelegate <NSObject>
- (void)popTipViewWasDismissedByUser:(IFA_CMPopTipView *)popTipView;
@end
