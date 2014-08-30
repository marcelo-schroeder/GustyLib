//
// Created by Marcelo Schroeder on 31/08/2014.
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

#import <Foundation/Foundation.h>

/**
* This class can be used in cases where a 'zeroing' weak reference behaviour cannot be obtained such as using associative references in categories.
*/
@interface IFAZeroingWeakReferenceContainer : NSObject
@property (nonatomic, weak) id weakReference;
- (instancetype)initWithWeakReference:(id)a_weakReference;
@end