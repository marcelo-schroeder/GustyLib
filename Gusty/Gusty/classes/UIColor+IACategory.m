//
//  UIColor+IACategory.m
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

#import "UIColor+IACategory.h"

@implementation UIColor (IACategory)

-(CGFloat)m_hue{
    CGFloat l_hue=0, l_saturation=0, l_brightness=0, l_alpha=0;
    [self getHue:&l_hue saturation:&l_saturation brightness:&l_brightness alpha:&l_alpha];
    return l_hue;
}

-(NSString *)m_hexString{
    CGFloat l_red = 0.0, l_green = 0.0, l_blue = 0.0, l_alpha = 0.0;
    [self getRed:&l_red green:&l_green blue:&l_blue alpha:&l_alpha];
    return [NSString stringWithFormat:@"%02X%02X%02X", (int)(l_red * 255), (int)(l_green * 255), (int)(l_blue * 255)];
}

+ (UIColor *)m_colorWithRed:(NSUInteger)a_red green:(NSUInteger)a_green blue:(NSUInteger)a_blue{
    return [self m_colorWithRed:a_red green:a_green blue:a_blue alpha:1.0];
}

+ (UIColor *)m_colorWithRed:(NSUInteger)a_red green:(NSUInteger)a_green blue:(NSUInteger)a_blue alpha:(CGFloat)a_alpha{
    return [UIColor colorWithRed:a_red/255.0 green:a_green/255.0 blue:a_blue/255.0 alpha:a_alpha];
}

+ (UIColor *)m_colorWithHue:(NSUInteger)a_hue saturation:(NSUInteger)a_saturation brightness:(NSUInteger)a_brightness{
    return [self m_colorWithHue:a_hue saturation:a_saturation brightness:a_brightness alpha:1.0];
}

+ (UIColor *)m_colorWithHue:(NSUInteger)a_hue saturation:(NSUInteger)a_saturation brightness:(NSUInteger)a_brightness alpha:(CGFloat)a_alpha{
    return [UIColor colorWithHue:a_hue/360.0 saturation:a_saturation/100.0 brightness:a_brightness/100.0 alpha:a_alpha];
}

+(void)m_logFontNamesPerFamily{
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
