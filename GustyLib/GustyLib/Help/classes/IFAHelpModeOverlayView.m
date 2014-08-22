//
//  IFAHelpModeOverlayView.m
//  Gusty
//
//  Created by Marcelo Schroeder on 29/03/12.
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
#import "IFAHelpModeOverlayView.h"

@interface IFAHelpModeOverlaySpotlightMaskView : UIView

@end

@interface IFAHelpModeOverlayView ()

@property (nonatomic) BOOL IFA_shouldSpotlight;
@property (nonatomic) BOOL IFA_showingSpotlight;
@property (nonatomic) BOOL IFA_finalDrawing;
@property (nonatomic) BOOL IFA_removeSpotlightWithAnimation;
@property (nonatomic) CGRect IFA_spotlightRect;

@property (nonatomic, strong) IFAHelpModeOverlaySpotlightMaskView *IFA_spotlightMask;

@end

@implementation IFAHelpModeOverlayView {
    
}

#pragma mark - Private

+(UIColor*)IFA_backgroundColour {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.70];
}

#pragma mark - Overrides

- (id)init{
    
    CGSize l_size = [IFAUIUtils screenBoundsSizeForCurrentOrientation];
    if (self = [super initWithFrame:CGRectMake(0, 0, l_size.width, l_size.height)]) {
        
        self.userInteractionEnabled = NO;
        self.tag = IFAViewTagHelpBackground;
        self.opaque = NO;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
    }
    
    return self;
    
}

- (void)drawRect:(CGRect)rect{
    
    //    NSLog(@"drawRect: %@", NSStringFromCGRect(rect));
    
    CGContextRef l_context = UIGraphicsGetCurrentContext();
    
    // Fill the rect with the background colour
    CGContextSetFillColorWithColor(l_context, [IFAHelpModeOverlayView IFA_backgroundColour].CGColor);
    CGContextFillRect(l_context, rect);
    
    IFAHelpModeOverlaySpotlightMaskView *l_previousSpotlightMask = nil;
    if (!self.IFA_finalDrawing) {
        
        if (self.IFA_showingSpotlight && self.IFA_removeSpotlightWithAnimation) {
            
            l_previousSpotlightMask = self.IFA_spotlightMask;
            
            // Draw spotlight
            CGContextSetFillColorWithColor(l_context, [UIColor clearColor].CGColor);
            CGContextSetBlendMode(l_context, kCGBlendModeClear);
            CGContextFillEllipseInRect(l_context, l_previousSpotlightMask.frame);
            
        }
        
        // Add spotlight mask
        if (self.IFA_shouldSpotlight) {
            self.IFA_spotlightMask = [[IFAHelpModeOverlaySpotlightMaskView alloc] initWithFrame:self.IFA_spotlightRect];
            [self addSubview:self.IFA_spotlightMask];
        }
        
    }
    
    // Draw spotlight if required
    if (self.IFA_shouldSpotlight) {
        CGContextSetFillColorWithColor(l_context, [UIColor clearColor].CGColor);
        CGContextSetBlendMode(l_context, kCGBlendModeClear);
        CGContextFillEllipseInRect(l_context, self.IFA_spotlightRect);
        self.IFA_showingSpotlight = YES;
    }else {
        self.IFA_showingSpotlight = NO;
    }
    
    if (!self.IFA_finalDrawing) {
        
        self.IFA_finalDrawing = YES;
        
        // Schedule animations
        __weak __typeof(self) l_weakSelf = self;
        [IFAUtils dispatchAsyncMainThreadBlock:^{

            BOOL l_removeSpotlightWithAnimation = self.IFA_removeSpotlightWithAnimation;

            [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                if (self.IFA_shouldSpotlight) {
                                    [self.IFA_spotlightMask removeFromSuperview];
                                }
                                if (self.IFA_removeSpotlightWithAnimation) {
                                    if (l_previousSpotlightMask) {
                                        [self addSubview:l_previousSpotlightMask];
                                    }
                                }
                            } completion:^(BOOL finished) {
                if (l_removeSpotlightWithAnimation) {
                    [l_previousSpotlightMask removeFromSuperview];
                    [l_weakSelf setNeedsDisplay];
                }
            }];

        }];
        
    }
    
}

#pragma mark - Public

-(void)spotlightAtRect:(CGRect)a_rect{
    
    // Correct the rect provided to compensate for shapes that are much wider than they are taller
    //  (i.e. the ellipse drawn here looks better when corrected this way)
//    NSLog(@"a_rect: %@", NSStringFromCGRect(a_rect));
    static CGFloat const k_xCorrectionFactor = 6;
    CGFloat l_widthHeightRatio = a_rect.size.width / a_rect.size.height;
//    NSLog(@"l_widthHeightRatio: %f", l_widthHeightRatio);
    CGFloat l_xCorrection = l_widthHeightRatio>=1.0 ? ((l_widthHeightRatio - 1) * k_xCorrectionFactor) : 0;
//    NSLog(@"l_xCorrection: %f", l_xCorrection);
    CGFloat l_x = a_rect.origin.x - l_xCorrection;
    CGFloat l_width = a_rect.size.width + (l_xCorrection * 2);
    CGRect l_correctedRect = CGRectMake(l_x, a_rect.origin.y, l_width, a_rect.size.height);

    // Set up correct state for the spotlight to be drawn
    self.IFA_spotlightRect = l_correctedRect;
    self.IFA_shouldSpotlight = YES;
    [self.IFA_spotlightMask setNeedsDisplay];
    
    // Draw spotlight
    self.IFA_finalDrawing = NO;
    self.IFA_removeSpotlightWithAnimation = NO;
    [self setNeedsDisplay];
    
}

-(void)removeSpotlightWithAnimation:(BOOL)a_animate{
    
    self.IFA_shouldSpotlight = NO;
    self.IFA_finalDrawing = NO;
    self.IFA_removeSpotlightWithAnimation = a_animate;
    [self setNeedsDisplay];
    
}

@end

@implementation IFAHelpModeOverlaySpotlightMaskView

#pragma mark - Overrides

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.userInteractionEnabled = NO;
        self.opaque = NO;
        
    }
    
    return self;
    
}

- (void)drawRect:(CGRect)rect{
    
    //    NSLog(@"drawRect");
    
    CGContextRef l_context = UIGraphicsGetCurrentContext();
    
    // Fill the rect with the clear background
    CGContextSetFillColorWithColor(l_context, [UIColor clearColor].CGColor);
    CGContextFillRect(l_context, rect);
    
    // Draw spotlight mask
    CGContextSetFillColorWithColor(l_context, [IFAHelpModeOverlayView IFA_backgroundColour].CGColor);
    CGContextFillEllipseInRect(l_context, rect);
    
}

@end
