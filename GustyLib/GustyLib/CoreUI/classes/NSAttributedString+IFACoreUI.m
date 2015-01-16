//
// Created by Marcelo Schroeder on 31/07/13.
// Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
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

@implementation NSAttributedString (IFACoreUI)

+ (NSAttributedString *)ifa_attributedStringWithText:(NSString *)a_text font:(UIFont *)a_font colour:(UIColor *)a_colour
                                          lineheight:(CGFloat)a_lineHeight {
    NSMutableParagraphStyle *l_paragraphStyle = [NSMutableParagraphStyle new];
    l_paragraphStyle.minimumLineHeight = a_lineHeight;
    l_paragraphStyle.maximumLineHeight = a_lineHeight;
    l_paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary *l_attributes = @{
            NSFontAttributeName : a_font,
            NSForegroundColorAttributeName : a_colour,
            NSParagraphStyleAttributeName : l_paragraphStyle,
    };
    return [[NSAttributedString alloc] initWithString:a_text attributes:l_attributes];
}

@end