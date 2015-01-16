//
//  IFADynamicCache.m
//  Gusty
//
//  Created by Marcelo Schroeder on 23/07/10.
//  Copyright 2010 InfoAccent Pty Limited. All rights reserved.
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

#import "GustyLibFoundation.h"

@implementation IFADynamicCache

- (id)init{
	if((self=[super init])){
//		[self setEvictsObjectsWithDiscardedContent:NO];
		[self setDelegate:self];
	}
	return self;
}

//- (BOOL)containsObjectForKey:(id)key{
//	return [self objectForKey:key] != NULL;
//}

- (void)setObject:(id)obj forKey:(id)key{
	//NSLog(@"IFADynamicCache setObject: %p forKey: %@", obj, key);
	[super setObject:obj forKey:key];
}

/*

- (id)purgeableObjectForKey:(id)key{
	IFAPurgeableObject *pObj = ((IFAPurgeableObject*)[self objectForKey:key]);
	return pObj.obj;
}

- (void)setPurgeableObject:(id)obj forKey:(id)key{
	IFAPurgeableObject *pObj = [[[IFAPurgeableObject alloc] initWithObject:obj] autorelease];
	//NSLog(@"IFADynamicCache.setPurgeableObject: %p", pObj);
	[self setObject:pObj forKey:key];
}

- (BOOL)retainPurgeableObjectForKey:(id)key{
	IFAPurgeableObject *pObj = [self objectForKey:key];
	if (pObj==NULL) {
		return NO;
	}else {
		[pObj beginContentAccess];
		return YES;
	}
}

- (BOOL)releasePurgeableObjectForKey:(id)key{
	IFAPurgeableObject *pObj = [self objectForKey:key];
	if (pObj==NULL) {
		return NO;
	}else {
		[pObj endContentAccess];
		return YES;
	}
}
 
*/

- (void)cache:(NSCache *)cache willEvictObject:(id)obj{
//	NSLog(@"IFADynamicCache willEvictObject: %p", obj);
}

#pragma mark - Singleton functions

+ (IFADynamicCache *)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IFADynamicCache *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

@end
