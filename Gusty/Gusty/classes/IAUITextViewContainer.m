//
//  IAUITextViewContainer.m
//  Gusty
//
//  Created by Marcelo Schroeder on 6/04/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//

#import "IAUITextViewContainer.h"

@implementation IAUITextViewContainer{
    
}

-(void)awakeFromNib{

    [super awakeFromNib];
    
    // Configure background view
    self.p_backgroundImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.p_backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImage *l_backgroundImage = [[UIImage imageNamed:@"textViewBorder"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 8, 15, 8)];
    self.p_backgroundImageView.image = l_backgroundImage;
    [self addSubview:self.p_backgroundImageView];

    // Configure text view
    static NSInteger const k_verticalInset = 2; // This avoids content being shown on top of the borders
    self.p_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, k_verticalInset, self.frame.size.width, self.frame.size.height-(k_verticalInset*2))];
    self.p_textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.p_textView.backgroundColor = [UIColor clearColor];
    self.p_textView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
    self.p_textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 2, 0, 2);
    [self addSubview:self.p_textView];
    
}

@end
