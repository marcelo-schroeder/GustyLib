//
// Created by Marcelo Schroeder on 14/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

#import "IFACustomLayoutSupport.h"


@interface IFACustomLayoutSupport ()
@property(nonatomic) CGFloat IFA_length;
@end

@implementation IFACustomLayoutSupport {

}

#pragma mark - Public

- (id)initWithLength:(CGFloat)a_length {
    self = [super init];
    if (self) {
        self.IFA_length = a_length;
    }
    return self;
}

#pragma mark - UILayoutSupport

- (CGFloat)length {
    return self.IFA_length;
}

@end