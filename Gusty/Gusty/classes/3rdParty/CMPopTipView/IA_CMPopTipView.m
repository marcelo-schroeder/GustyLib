//
//  CMPopTipView.m
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

#import "IA_CMPopTipView.h"

@interface IA_CMPopTipView ()
@property (nonatomic, retain, readwrite)	id	targetObject;
@end


@implementation IA_CMPopTipView

- (CGRect)bubbleFrame {
	CGRect bubbleFrame;
	if (pointDirection == IA_CMPointDirectionUp) {
		bubbleFrame = CGRectMake(2.0, targetPoint.y+self.pointerSize, bubbleSize.width, bubbleSize.height);
	}
	else {
		bubbleFrame = CGRectMake(2.0, targetPoint.y-self.pointerSize-bubbleSize.height, bubbleSize.width, bubbleSize.height);
	}
	return bubbleFrame;
}

- (CGRect)contentFrame {
	CGRect bubbleFrame = [self bubbleFrame];
	CGRect contentFrame = CGRectMake(bubbleFrame.origin.x + self.cornerRadius,
									 bubbleFrame.origin.y + self.cornerRadius,
									 bubbleFrame.size.width - self.cornerRadius*2,
									 bubbleFrame.size.height - self.cornerRadius*2);
	return contentFrame;
}

- (void)layoutSubviews {
	if (self.customView) {
		
		CGRect contentFrame = [self contentFrame];
        [self.customView setFrame:contentFrame];
    }
}

- (void)drawRect:(CGRect)rect {
	
	CGRect bubbleRect = [self bubbleFrame];
	
	CGContextRef c = UIGraphicsGetCurrentContext(); 
	
	CGContextSetRGBStrokeColor(c, 0.0, 0.0, 0.0, 1.0);	// black
	CGContextSetLineWidth(c, 1.0);
    
	CGMutablePathRef bubblePath = CGPathCreateMutable();
	
	if (pointDirection == IA_CMPointDirectionUp) {
		CGPathMoveToPoint(bubblePath, NULL, targetPoint.x, targetPoint.y);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x+self.pointerSize, targetPoint.y+self.pointerSize);
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+self.cornerRadius,
							self.cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x+bubbleRect.size.width-self.cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
							self.cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-self.cornerRadius,
							self.cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y,
							bubbleRect.origin.x+self.cornerRadius, bubbleRect.origin.y,
							self.cornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x-self.pointerSize, targetPoint.y+self.pointerSize);
	}
	else {
		CGPathMoveToPoint(bubblePath, NULL, targetPoint.x, targetPoint.y);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x-self.pointerSize, targetPoint.y-self.pointerSize);
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-self.cornerRadius,
							self.cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y,
							bubbleRect.origin.x+self.cornerRadius, bubbleRect.origin.y,
							self.cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+self.cornerRadius,
							self.cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x+bubbleRect.size.width-self.cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
							self.cornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x+self.pointerSize, targetPoint.y-self.pointerSize);
	}
    
	CGPathCloseSubpath(bubblePath);
    
	
	// Draw shadow
	CGContextAddPath(c, bubblePath);
    CGContextSaveGState(c);
	CGContextSetShadow(c, CGSizeMake(0, 3), 5);
	CGContextSetRGBFillColor(c, 0.0, 0.0, 0.0, 0.9);
	CGContextFillPath(c);
    CGContextRestoreGState(c);
    
	
	// Draw clipped background gradient
	CGContextAddPath(c, bubblePath);
	CGContextClip(c);
	
	CGFloat bubbleMiddle = (bubbleRect.origin.y+(bubbleRect.size.height/2)) / self.bounds.size.height;
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorSpace;
	size_t locationCount = 5;
	CGFloat locationList[] = {0.0, bubbleMiddle-0.03, bubbleMiddle, bubbleMiddle+0.03, 1.0};
    
	CGFloat colourHL = 0.0;
	if (highlight) {
		colourHL = 0.25;
	}
	
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	CGFloat alpha;
	int numComponents = CGColorGetNumberOfComponents([self.backgroundColor CGColor]);
	const CGFloat *components = CGColorGetComponents([self.backgroundColor CGColor]);
	if (numComponents == 2) {
		red = components[0];
		green = components[0];
		blue = components[0];
		alpha = components[1];
	}
	else {
		red = components[0];
		green = components[1];
		blue = components[2];
		alpha = components[3];
	}
	CGFloat colorList[] = {
		//red, green, blue, alpha 
		red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
		red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
		red*1.08+colourHL, green*1.08+colourHL, blue*1.08+colourHL, alpha,
		red     +colourHL, green     +colourHL, blue     +colourHL, alpha,
		red     +colourHL, green     +colourHL, blue     +colourHL, alpha
	};
	myColorSpace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents(myColorSpace, colorList, locationList, locationCount);
	CGPoint startPoint, endPoint;
	startPoint.x = 0;
	startPoint.y = 0;
	endPoint.x = 0;
	endPoint.y = CGRectGetMaxY(self.bounds);
	
	CGContextDrawLinearGradient(c, myGradient, startPoint, endPoint,0);
	CGGradientRelease(myGradient);
	CGColorSpaceRelease(myColorSpace);
	
	CGContextSetRGBStrokeColor(c, 0.4, 0.4, 0.4, 1.0);
	CGContextAddPath(c, bubblePath);
	CGContextDrawPath(c, kCGPathStroke);
	
	CGPathRelease(bubblePath);
	
	// Draw text
	
	if (self.message) {
		[self.textColor set];
		CGRect textFrame = [self contentFrame];
        [self.message drawInRect:textFrame
                        withFont:self.textFont
                   lineBreakMode:UILineBreakModeWordWrap
                       alignment:UITextAlignmentCenter];
    }
}

- (CGRect)finalFramePointingAtView:(UIView *)targetView inView:(UIView *)containerView{
    return [self finalFramePointingAtView:targetView inView:containerView shouldInvertLandscapeFrame:YES];
}

- (CGRect)finalFramePointingAtView:(UIView *)targetView inView:(UIView *)containerView shouldInvertLandscapeFrame:(BOOL)a_shouldInvertLandscapeFrame{
    
    BOOL l_landscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && a_shouldInvertLandscapeFrame;
    CGRect l_containerViewFrame = l_landscape ? CGRectMake(containerView.frame.origin.y, containerView.frame.origin.x, containerView.frame.size.height, containerView.frame.size.width) : containerView.frame;
    
	// Size of rounded rect
	CGFloat rectWidth;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // iPad
        if (self.maxWidth) {
            if (self.maxWidth < l_containerViewFrame.size.width) {
                rectWidth = self.maxWidth;
            }
            else {
                rectWidth = l_containerViewFrame.size.width - 20;
            }
        }
        else {
            rectWidth = (int)(l_containerViewFrame.size.width/3);
        }
    }
    else {
        // iPhone
        if (self.maxWidth) {
            if (self.maxWidth < l_containerViewFrame.size.width) {
                rectWidth = self.maxWidth;
            }
            else {
                rectWidth = l_containerViewFrame.size.width - 10;
            }
        }
        else {
            rectWidth = (int)(l_containerViewFrame.size.width*2/3);
        }
    }
    
	CGSize textSize = CGSizeZero;
    
    if (self.message!=nil) {
        textSize= [self.message sizeWithFont:self.textFont
                           constrainedToSize:CGSizeMake(rectWidth, 99999.0)
                               lineBreakMode:UILineBreakModeWordWrap];
    }
    if (self.customView != nil) {
        textSize = self.customView.frame.size;
    }
    
	bubbleSize = CGSizeMake(textSize.width + self.cornerRadius*2, textSize.height + self.cornerRadius*2);
	
	CGPoint targetRelativeOrigin    = [targetView.superview convertPoint:targetView.frame.origin toView:containerView.superview];
	CGPoint containerRelativeOrigin = [containerView.superview convertPoint:l_containerViewFrame.origin toView:containerView.superview];
    if (l_landscape) {
        targetRelativeOrigin = CGPointMake(targetRelativeOrigin.y, targetRelativeOrigin.x);
        containerRelativeOrigin = CGPointMake(containerRelativeOrigin.y, containerRelativeOrigin.x);
    }
    
	CGFloat pointerY;	// Y coordinate of pointer target (within containerView)
	
    //    NSLog(@"targetRelativeOrigin: %@", NSStringFromCGPoint(targetRelativeOrigin));
    //    NSLog(@"containerRelativeOrigin: %@", NSStringFromCGPoint(containerRelativeOrigin));
    //    NSLog(@"targetView.bounds.size: %@", NSStringFromCGSize(targetView.bounds.size));
	if (targetRelativeOrigin.y+targetView.bounds.size.height < containerRelativeOrigin.y) {
		pointerY = 0.0;
		pointDirection = IA_CMPointDirectionUp;
	}
	else if (targetRelativeOrigin.y > containerRelativeOrigin.y+containerView.bounds.size.height) {
		pointerY = containerView.bounds.size.height;
		pointDirection = IA_CMPointDirectionDown;
	}
	else {
		CGPoint targetOriginInContainer = [targetView convertPoint:CGPointMake(0.0, 0.0) toView:containerView];
		CGFloat sizeBelow = containerView.bounds.size.height - targetOriginInContainer.y;
		if (sizeBelow > targetOriginInContainer.y) {
			pointerY = targetOriginInContainer.y + targetView.bounds.size.height;
			pointDirection = IA_CMPointDirectionUp;
		}
		else {
			pointerY = targetOriginInContainer.y;
			pointDirection = IA_CMPointDirectionDown;
		}
	}
	
	CGFloat W = l_containerViewFrame.size.width;
	
	CGPoint p = [targetView.superview convertPoint:targetView.center toView:containerView];
	CGFloat x_p = p.x;
	CGFloat x_b = x_p - roundf(bubbleSize.width/2);
	if (x_b < self.sidePadding) {
		x_b = self.sidePadding;
	}
	if (x_b + bubbleSize.width + self.sidePadding > W) {
		x_b = W - bubbleSize.width - self.sidePadding;
	}
	if (x_p - self.pointerSize < x_b + self.cornerRadius) {
		x_p = x_b + self.cornerRadius + self.pointerSize;
	}
	if (x_p + self.pointerSize > x_b + bubbleSize.width - self.cornerRadius) {
		x_p = x_b + bubbleSize.width - self.cornerRadius - self.pointerSize;
	}
	
	CGFloat fullHeight = bubbleSize.height + self.pointerSize + 10.0;
	CGFloat y_b;
	if (pointDirection == IA_CMPointDirectionUp) {
		y_b = self.topMargin + pointerY;
		targetPoint = CGPointMake(x_p-x_b+2, 0);
	}
	else {
		y_b = pointerY - fullHeight;
		targetPoint = CGPointMake(x_p-x_b+2, fullHeight-2.0);
	}
	
	CGRect finalFrame = CGRectMake(x_b-self.sidePadding,
								   y_b,
								   bubbleSize.width+self.sidePadding*2,
								   fullHeight);

    return finalFrame;

}

- (void)presentPointingAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated {
    [self presentPointingAtView:targetView inView:containerView animated:animated shouldInvertLandscapeFrame:YES];
}

- (void)presentPointingAtView:(UIView *)targetView inView:(UIView *)containerView animated:(BOOL)animated shouldInvertLandscapeFrame:(BOOL)a_shouldInvertLandscapeFrame{
	if (!self.targetObject) {
		self.targetObject = targetView;
	}
	
	[containerView addSubview:self];
    
    CGRect finalFrame = [self finalFramePointingAtView:targetView inView:containerView shouldInvertLandscapeFrame:a_shouldInvertLandscapeFrame];
   	
	if (animated) {
        if (self.animation == IA_CMPopTipAnimationSlide) {
            self.alpha = 0.0;
            CGRect startFrame = finalFrame;
            startFrame.origin.y += 10;
            self.frame = startFrame;
        }
		else if (self.animation == IA_CMPopTipAnimationPop) {
            self.frame = finalFrame;
            self.alpha = 0.5;
            
            // start a little smaller
            self.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
            
            // animate to a bigger size
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(popAnimationDidStop:finished:context:)];
            [UIView setAnimationDuration:0.15f];
            self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
            self.alpha = 1.0;
            [UIView commitAnimations];
        }
		
		[self setNeedsDisplay];
		
		if (self.animation == IA_CMPopTipAnimationSlide) {
			[UIView beginAnimations:nil context:nil];
			self.alpha = 1.0;
			self.frame = finalFrame;
			[UIView commitAnimations];
		}
	}
	else {
		// Not animated
		[self setNeedsDisplay];
		self.frame = finalFrame;
	}
}

// COMMENTED OUT AS IMPLEMENTATION MAKES USE OF UNDOCUMENTED METHOD
//- (void)presentPointingAtBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated {
//	UIView *targetView = (UIView *)[barButtonItem performSelector:@selector(view)];
//	UIView *targetSuperview = [targetView superview];
//	UIView *containerView = nil;
//	if ([targetSuperview isKindOfClass:[UINavigationBar class]]) {
//		UINavigationController *navController = [(UINavigationBar *)targetSuperview delegate];
//		containerView = [[navController topViewController] view];
//	}
//	else if ([targetSuperview isKindOfClass:[UIToolbar class]]) {
//		containerView = [targetSuperview superview];
//	}
//	
//	if (nil == containerView) {
//		NSLog(@"Cannot determine container view from UIBarButtonItem: %@", barButtonItem);
//		self.targetObject = nil;
//		return;
//	}
//	
//	self.targetObject = barButtonItem;
//	
//	[self presentPointingAtView:targetView inView:containerView animated:animated];
//}

- (void)finaliseDismiss {
	[self removeFromSuperview];
	highlight = NO;
	self.targetObject = nil;
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self finaliseDismiss];
}

- (void)dismissAnimated:(BOOL)animated {
	
	if (animated) {
		CGRect frame = self.frame;
		frame.origin.y += 10.0;
		
		[UIView beginAnimations:nil context:nil];
		self.alpha = 0.0;
		self.frame = frame;
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
	else {
		[self finaliseDismiss];
	}
}

- (void)onUserDismissal{

	highlight = YES;
	[self setNeedsDisplay];
	
	[self dismissAnimated:YES];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(popTipViewWasDismissedByUser:)]) {
		[self.delegate popTipViewWasDismissedByUser:self];
	}

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.disableTapToDismiss) {
		[super touchesBegan:touches withEvent:event];
		return;
	}
	[self onUserDismissal];
}

- (void)popAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // at the end set to normal size
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.opaque = NO;
		
		self.cornerRadius = 10.0;
		self.topMargin = 2.0;
		self.pointerSize = 12.0;
		self.sidePadding = 2.0;
		
		self.textFont = [UIFont boldSystemFontOfSize:14.0];
		self.textColor = [UIColor whiteColor];
		self.textAlignment = UITextAlignmentCenter;
		self.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:60.0/255.0 blue:154.0/255.0 alpha:1.0];
        self.animation = IA_CMPopTipAnimationSlide;
    }
    return self;
}

- (IA_CMPointDirection) getPointDirection {
  return pointDirection;
}

- (id)initWithMessage:(NSString *)messageToShow {
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.message = messageToShow;
	}
	return self;
}

- (id)initWithCustomView:(UIView *)aView {
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.customView = aView;
        [self addSubview:self.customView];
	}
	return self;
}

@end
