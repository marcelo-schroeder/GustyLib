//
//  IFATextViewContainer.m
//  Gusty
//
//  Created by Marcelo Schroeder on 6/04/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
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

#import "IFATextViewContainer.h"

@implementation IFATextViewContainer {
    
}

-(void)awakeFromNib{

    [super awakeFromNib];
    
    // Configure background view
    self.backgroundImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImage *l_backgroundImage = [[UIImage imageNamed:@"IFA_TextViewBorder.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 8, 15, 8)];
    self.backgroundImageView.image = l_backgroundImage;
    [self addSubview:self.backgroundImageView];

    // Configure text view
    static NSInteger const k_verticalInset = 2; // This avoids content being shown on top of the borders
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, k_verticalInset, self.frame.size.width, self.frame.size.height-(k_verticalInset*2))];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 2, 0, 2);
    [self addSubview:self.textView];
    
}

@end
