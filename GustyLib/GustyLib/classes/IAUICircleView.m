//
// Created by Marcelo Schroeder on 30/04/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import "IAUICircleView.h"


@implementation IAUICircleView {

}

#pragma mark - Overrides

- (void)IFA_commonInit {
    self.backgroundColor = [UIColor clearColor];
}

- (id)init {
    self = [super init];
    if (self) {
        [self IFA_commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self IFA_commonInit];
    }
   return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self IFA_commonInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    UIColor *l_color = self.p_foregroundColor;
    l_color = l_color?:[UIColor redColor];
    CGContextSetFillColor(ctx, CGColorGetComponents([l_color CGColor]));
    CGContextFillPath(ctx);
}

@end