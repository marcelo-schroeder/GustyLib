//
//  UIImage+IFACategory.m
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

#import "GustyLibCoreUI.h"

@implementation UIImage (IFACoreUI)

#pragma mark - Public

-(UIImage*)ifa_imageWithOverlayColor:(UIColor*)a_color{

    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    
    CGContextSetFillColorWithColor(context, a_color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return image;

}

-(UIImage*)ifa_imageWithHue:(CGFloat)a_hue{
    float l_hueInDegrees = a_hue * 360; // convert hue from percentage to degrees
    return [self ifa_imageWithHueInDegrees:l_hueInDegrees];
}

-(UIImage*)ifa_imageWithHueInDegrees:(CGFloat)a_hueInDegrees{

    CIImage *l_inputImage = [[CIImage alloc] initWithImage:self];
    CIFilter *l_hueAdjust = [CIFilter filterWithName:@"CIHueAdjust"];
    [l_hueAdjust setDefaults];
    [l_hueAdjust setValue:l_inputImage forKey:@"inputImage"];
    float l_radians = GLKMathDegreesToRadians(a_hueInDegrees);
//    NSLog(@"l_radians: %f", l_radians);
    [l_hueAdjust setValue:[NSNumber numberWithFloat:l_radians] forKey:@"inputAngle"];
    CIImage *l_outputImage = [l_hueAdjust valueForKey:@"outputImage"];
    CIContext *l_context = [CIContext contextWithOptions:nil];
    CGImageRef l_cgImageRef = [l_context createCGImage:l_outputImage fromRect:l_outputImage.extent];
    UIImage *l_image = [UIImage imageWithCGImage:l_cgImageRef scale:self.scale orientation:self.imageOrientation];
    CFRelease(l_cgImageRef);
    
    return l_image;

}

- (UIImage *)ifa_imageWithBlurEffect:(IFABlurEffect)a_blurEffect {
    switch (a_blurEffect){
        case IFABlurEffectLight:
            return [self IFA_applyLightBlurEffectWithRadius:30];
        case IFABlurEffectExtraLight:
            return [self IFA_applyExtraLightBlurEffectWithRadius:20];
        case IFABlurEffectDark:
            return [self IFA_applyDarkBlurEffectWithRadius:20];
        default:
            return nil;
    }
}

- (UIImage *)ifa_imageWithBlurEffect:(IFABlurEffect)a_blurEffect radius:(CGFloat)a_radius {
    switch (a_blurEffect){
        case IFABlurEffectLight:
            return [self IFA_applyLightBlurEffectWithRadius:a_radius];
        case IFABlurEffectExtraLight:
            return [self IFA_applyExtraLightBlurEffectWithRadius:a_radius];
        case IFABlurEffectDark:
            return [self IFA_applyDarkBlurEffectWithRadius:a_radius];
        default:
            return nil;
    }
}


- (UIImage *)ifa_imageWithOrientationUp {
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;

//    NSLog(@"original orientation: %d", self.imageOrientation);

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, (CGFloat) M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, (CGFloat) M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, (CGFloat) -M_PI_2);
            break;

        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, (size_t) self.size.width, (size_t) self.size.height,
            CGImageGetBitsPerComponent(self.CGImage), 0,
            CGImageGetColorSpace(self.CGImage),
            CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (CGFloat)ifa_aspectRatio {
    return self.size.width / self.size.height;
}

+(UIImage*)ifa_imageWithColor:(UIColor *)a_color rect:(CGRect)a_rect{
    UIGraphicsBeginImageContext(a_rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [a_color CGColor]);
    CGContextFillRect(context, a_rect);
    UIImage *l_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return l_image;
}

+(UIImage*)ifa_imageWithColor:(UIColor*)a_color{
    return [self ifa_imageWithColor:a_color rect:CGRectMake(0, 0, 1, 1)];
}

+ (UIImage *)ifa_separatorImageForType:(IFASeparatorImageType)a_separatorImageType {
    NSString *l_imageName = nil;
    switch (a_separatorImageType){
        case IFASeparatorImageTypeHorizontalTop:
            l_imageName = @"IFA_1PixelLineHorizontalTop";
            break;
        case IFASeparatorImageTypeVerticalLeft:
            l_imageName = @"IFA_1PixelLineVerticalLeft";
            break;
        case IFASeparatorImageTypeHorizontalBottom:
            l_imageName = @"IFA_1PixelLineHorizontalBottom";
            break;
        case IFASeparatorImageTypeVerticalRight:
            l_imageName = @"IFA_1PixelLineVerticalRight";
            break;
        default:
            NSAssert(NO, @"Unexpected separator image type: %lu", (unsigned long)a_separatorImageType);
    }
    return [self IFA_separatorImageNamed:l_imageName];
}

- (UIImage *)ifa_imageWithTintBlurEffectForColor:(UIColor *)tintColor
{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self ifa_imageWithBlurEffectForRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}

- (UIImage *)ifa_imageWithBlurEffectForRadius:(CGFloat)a_radius tintColor:(UIColor *)a_tintColor
                        saturationDeltaFactor:(CGFloat)a_saturationDeltaFactor maskImage:(UIImage *)a_maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (a_maskImage && !a_maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", a_maskImage);
        return nil;
    }

    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;

    BOOL hasBlur = a_radius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(a_saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);

        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);

        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);

        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = a_radius * [[UIScreen mainScreen] scale];
            uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = a_saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);

    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);

    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (a_maskImage) {
            CGContextClipToMask(outputContext, imageRect, a_maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }

    // Add in color tint.
    if (a_tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, a_tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }

    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return outputImage;
}

#pragma mark - Private

+ (UIImage *)IFA_separatorImageNamed:(NSString *)a_imageName {
    return [[UIImage imageNamed:a_imageName] ifa_imageWithOverlayColor:[UITableViewCell ifa_defaultSeparatorColor]];
}

- (UIImage *)IFA_applyLightBlurEffectWithRadius:(CGFloat)a_radius {
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self ifa_imageWithBlurEffectForRadius:a_radius tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)IFA_applyExtraLightBlurEffectWithRadius:(CGFloat)a_radius {
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self ifa_imageWithBlurEffectForRadius:a_radius tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)IFA_applyDarkBlurEffectWithRadius:(CGFloat)a_radius {
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self ifa_imageWithBlurEffectForRadius:a_radius tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

@end
