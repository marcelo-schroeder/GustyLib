//
//  UIImage+IACategory.h
//  Gusty
//
//  Created by Marcelo Schroeder on 13/07/12.
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

#import <UIKit/UIKit.h>

@interface UIImage (IFACategory)

-(UIImage*)IFA_imageWithOverlayColor:(UIColor*)a_color;
-(UIImage*)IFA_imageWithHue:(CGFloat)a_hue;
-(UIImage*)IFA_imageWithHueInDegrees:(CGFloat)a_hueInDegrees;

- (UIImage *)IFA_applyLightBlurEffect;

- (UIImage *)IFA_applyExtraLightBlurEffect;

- (UIImage *)IFA_applyDarkBlurEffect;

- (UIImage *)IFA_applyTintBlurEffectWithColor:(UIColor *)tintColor;

- (UIImage *)IFA_applyBlurEffectWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor
                     saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

- (UIImage *)IFA_imageWithOrientationUp;

/**
* @returns Image's aspect ratio (width divided by height)
*/
- (CGFloat)IFA_aspectRatio;

+(UIImage*)IFA_imageWithColor:(UIColor *)a_color rect:(CGRect)a_rect;
+(UIImage*)IFA_imageWithColor:(UIColor*)a_color;

@end
