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

@interface IFAHelpModeOverlaySpotlightMaskView : UIView

@end

@interface IFAHelpModeOverlayView ()

@property (nonatomic) BOOL XYZ_shouldSpotlight;
@property (nonatomic) BOOL XYZ_showingSpotlight;
@property (nonatomic) BOOL XYZ_finalDrawing;
@property (nonatomic) BOOL XYZ_removeSpotlightWithAnimation;
@property (nonatomic) CGRect XYZ_spotlightRect;

@property (nonatomic, strong) IFAHelpModeOverlaySpotlightMaskView *XYZ_spotlightMask;

@end

@implementation IFAHelpModeOverlayView {
    
}

#pragma mark - Private

+(UIColor*)XYZ_backgroundColour {
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
    CGContextSetFillColorWithColor(l_context, [IFAHelpModeOverlayView XYZ_backgroundColour].CGColor);
    CGContextFillRect(l_context, rect);
    
    IFAHelpModeOverlaySpotlightMaskView *l_previousSpotlightMask = nil;
    if (!self.XYZ_finalDrawing) {
        
        if (self.XYZ_showingSpotlight && self.XYZ_removeSpotlightWithAnimation) {
            
            l_previousSpotlightMask = self.XYZ_spotlightMask;
            
            // Draw spotlight
            CGContextSetFillColorWithColor(l_context, [UIColor clearColor].CGColor);
            CGContextSetBlendMode(l_context, kCGBlendModeClear);
            CGContextFillEllipseInRect(l_context, l_previousSpotlightMask.frame);
            
        }
        
        // Add spotlight mask
        if (self.XYZ_shouldSpotlight) {
            self.XYZ_spotlightMask = [[IFAHelpModeOverlaySpotlightMaskView alloc] initWithFrame:self.XYZ_spotlightRect];
            [self addSubview:self.XYZ_spotlightMask];
        }
        
    }
    
    // Draw spotlight if required
    if (self.XYZ_shouldSpotlight) {
        CGContextSetFillColorWithColor(l_context, [UIColor clearColor].CGColor);
        CGContextSetBlendMode(l_context, kCGBlendModeClear);
        CGContextFillEllipseInRect(l_context, self.XYZ_spotlightRect);
        self.XYZ_showingSpotlight = YES;
    }else {
        self.XYZ_showingSpotlight = NO;
    }
    
    if (!self.XYZ_finalDrawing) {
        
        self.XYZ_finalDrawing = YES;
        
        // Schedule animations
        [IFAUtils dispatchAsyncMainThreadBlock:^{

            BOOL l_removeSpotlightWithAnimation = self.XYZ_removeSpotlightWithAnimation;

            [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                if (self.XYZ_shouldSpotlight) {
                                    [self.XYZ_spotlightMask removeFromSuperview];
                                }
                                if (self.XYZ_removeSpotlightWithAnimation) {
                                    if (l_previousSpotlightMask) {
                                        [self addSubview:l_previousSpotlightMask];
                                    }
                                }
                            } completion:^(BOOL finished) {
                if (l_removeSpotlightWithAnimation) {
                    [l_previousSpotlightMask removeFromSuperview];
                    [self setNeedsDisplay];
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
    self.XYZ_spotlightRect = l_correctedRect;
    self.XYZ_shouldSpotlight = YES;
    [self.XYZ_spotlightMask setNeedsDisplay];
    
    // Draw spotlight
    self.XYZ_finalDrawing = NO;
    self.XYZ_removeSpotlightWithAnimation = NO;
    [self setNeedsDisplay];
    
}

-(void)removeSpotlightWithAnimation:(BOOL)a_animate{
    
    self.XYZ_shouldSpotlight = NO;
    self.XYZ_finalDrawing = NO;
    self.XYZ_removeSpotlightWithAnimation = a_animate;
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
    CGContextSetFillColorWithColor(l_context, [IFAHelpModeOverlayView XYZ_backgroundColour].CGColor);
    CGContextFillEllipseInRect(l_context, rect);
    
}

@end
