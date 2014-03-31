//
// Created by Marcelo Schroeder on 14/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IAUICustomLayoutSupport.h"


@interface IAUICustomLayoutSupport ()
@property(nonatomic) CGFloat p_length;
@end

@implementation IAUICustomLayoutSupport {

}

#pragma mark - Public

- (id)initWithLength:(CGFloat)a_length {
    self = [super init];
    if (self) {
        self.p_length = a_length;
    }
    return self;
}

#pragma mark - UILayoutSupport

- (CGFloat)length {
    return self.p_length;
}

@end