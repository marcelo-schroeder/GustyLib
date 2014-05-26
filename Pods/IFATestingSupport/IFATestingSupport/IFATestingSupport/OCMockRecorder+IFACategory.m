//
// Created by Marcelo Schroeder on 29/04/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import <CoreGraphics/CoreGraphics.h>
#import "OCMockRecorder.h"

@implementation OCMockRecorder (IFACategory)

#pragma mark - Public

- (id)ifa_andReturnUnsignedInteger:(NSUInteger)a_value {
    NSValue *l_value = [NSValue value:&a_value withObjCType:@encode(unsigned int)];
    return [self andReturnValue:l_value];
}

- (id)ifa_andReturnInteger:(NSInteger)a_value {
    NSValue *l_value = [NSValue value:&a_value withObjCType:@encode(int)];
    return [self andReturnValue:l_value];
}

- (id)ifa_andReturnFloat:(CGFloat)a_value{
    NSValue *l_value = [NSValue value:&a_value withObjCType:@encode(float)];
    return [self andReturnValue:l_value];
}

- (id)ifa_andReturnBool:(BOOL)a_value{
    NSValue *l_value = [NSValue value:&a_value withObjCType:@encode(signed char)];
    return [self andReturnValue:l_value];
}

- (id)ifa_andReturnStruct:(void *)aValue objCType:(const char *)type{
    NSValue *l_value = [NSValue valueWithBytes:aValue
                                  objCType:type];

    return [self andReturnValue:l_value];
}

@end
