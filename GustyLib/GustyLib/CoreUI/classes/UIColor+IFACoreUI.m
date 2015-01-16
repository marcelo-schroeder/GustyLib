//
//  UIColor+IFACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 26/06/12.
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

#import "UIColor+IFACoreUI.h"

@implementation UIColor (IFACoreUI)

-(CGFloat)ifa_hue {
    CGFloat l_hue=0, l_saturation=0, l_brightness=0, l_alpha=0;
    [self getHue:&l_hue saturation:&l_saturation brightness:&l_brightness alpha:&l_alpha];
    return l_hue;
}

-(NSString *)ifa_hexString {
    CGFloat l_red = 0.0, l_green = 0.0, l_blue = 0.0, l_alpha = 0.0;
    [self getRed:&l_red green:&l_green blue:&l_blue alpha:&l_alpha];
    return [NSString stringWithFormat:@"%02X%02X%02X", (int)(l_red * 255), (int)(l_green * 255), (int)(l_blue * 255)];
}

+ (UIColor *)ifa_colorWithRed:(NSUInteger)a_red green:(NSUInteger)a_green blue:(NSUInteger)a_blue{
    return [self ifa_colorWithRed:a_red green:a_green blue:a_blue alpha:1.0];
}

+ (UIColor *)ifa_colorWithRed:(NSUInteger)a_red green:(NSUInteger)a_green blue:(NSUInteger)a_blue alpha:(CGFloat)a_alpha{
    return [UIColor colorWithRed:(CGFloat) (a_red / 255.0) green:(CGFloat) (a_green / 255.0) blue:(CGFloat) (a_blue / 255.0)
                           alpha:a_alpha];
}

+ (UIColor *)ifa_colorWithHue:(NSUInteger)a_hue saturation:(NSUInteger)a_saturation brightness:(NSUInteger)a_brightness{
    return [self ifa_colorWithHue:a_hue saturation:a_saturation brightness:a_brightness alpha:1.0];
}

+ (UIColor *)ifa_colorWithHue:(NSUInteger)a_hue saturation:(NSUInteger)a_saturation brightness:(NSUInteger)a_brightness
                        alpha:(CGFloat)a_alpha{
    return [UIColor colorWithHue:(CGFloat) (a_hue / 360.0) saturation:(CGFloat) (a_saturation / 100.0)
                      brightness:(CGFloat) (a_brightness / 100.0) alpha:a_alpha];
}

+ (UIColor *)ifa_grayColorWithRGB:(NSUInteger)a_rgb {
    return [self ifa_colorWithRed:a_rgb green:a_rgb blue:a_rgb];
}

+ (UIColor *)ifa_colorWithSpaceOrTabDelimitedRGB:(NSString *)a_rgb {
    NSArray *l_components = [a_rgb componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSUInteger l_red = (NSUInteger) ((NSString *) l_components[0]).integerValue;
    NSUInteger l_green = (NSUInteger) ((NSString *) l_components[1]).integerValue;
    NSUInteger l_blue = (NSUInteger) ((NSString *) l_components[2]).integerValue;
    return [self ifa_colorWithRed:l_red green:l_green blue:l_blue];
}

+(void)ifa_logFontNamesPerFamily {
    NSLog(@"*** Font names per family - START ***");
    for (NSString *l_familyName in [UIFont familyNames]) {
        NSLog(@"   Font Family: %@", l_familyName);
        for (NSString *l_fontName in [UIFont fontNamesForFamilyName:l_familyName]) {
            NSLog(@"      Font Name: %@", l_fontName);
        }
    }
    NSLog(@"*** Font names per family - END ***");
}

@end
