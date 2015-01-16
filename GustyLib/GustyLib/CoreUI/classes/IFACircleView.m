//
// Created by Marcelo Schroeder on 30/04/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import "IFACircleView.h"


@implementation IFACircleView {

}

#pragma mark - Overrides

- (void)ifa_commonInit {
    self.backgroundColor = [UIColor clearColor];
}

- (id)init {
    self = [super init];
    if (self) {
        [self ifa_commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ifa_commonInit];
    }
   return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self ifa_commonInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, rect);
    UIColor *l_color = self.foregroundColor;
    l_color = l_color?:[UIColor redColor];
    CGContextSetFillColor(ctx, CGColorGetComponents([l_color CGColor]));
    CGContextFillPath(ctx);
}

@end