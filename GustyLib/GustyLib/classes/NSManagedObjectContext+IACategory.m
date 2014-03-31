//
//  NSManagedObjectContext+IACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 17/02/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//

#import "IACommon.h"

static char c_isCurrentManagedObjectDirtyKey;

@implementation NSManagedObjectContext (IACategory)

#pragma mark - Public

-(BOOL)p_isCurrentManagedObjectDirty{
    return ((NSNumber*)objc_getAssociatedObject(self, &c_isCurrentManagedObjectDirtyKey)).boolValue;
}

-(void)setP_isCurrentManagedObjectDirty:(BOOL)a_isCurrentManagedObjectDirty{
    objc_setAssociatedObject(self, &c_isCurrentManagedObjectDirtyKey, @(a_isCurrentManagedObjectDirty), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
