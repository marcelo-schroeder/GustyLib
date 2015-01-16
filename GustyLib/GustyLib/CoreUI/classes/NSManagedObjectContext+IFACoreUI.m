//
//  NSManagedObjectContext+IFACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 17/02/13.
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

#import "GustyLibCoreUI.h"

static char c_isCurrentManagedObjectDirtyKey;

@implementation NSManagedObjectContext (IFACoreUI)

#pragma mark - Public

-(BOOL)ifa_isCurrentManagedObjectDirty {
    return ((NSNumber*)objc_getAssociatedObject(self, &c_isCurrentManagedObjectDirtyKey)).boolValue;
}

-(void)setIfa_isCurrentManagedObjectDirty:(BOOL)a_isCurrentManagedObjectDirty{
    objc_setAssociatedObject(self, &c_isCurrentManagedObjectDirtyKey, @(a_isCurrentManagedObjectDirty), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
