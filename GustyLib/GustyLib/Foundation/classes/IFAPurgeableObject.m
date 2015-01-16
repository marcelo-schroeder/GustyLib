//
//  IFAPurgeableObject.m
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

//TODO: not being used currently - see explanations in applicationDidReceiveMemoryWarning method in IFAApplicationDelegate

@implementation IFAPurgeableObject


- (id)initWithObject:(id)anObj{
    if ((self = [super init])) {
		//NSLog(@"*** IFAPurgeableObject.initWithObject: %p", self);
		self.obj = anObj;
		contentAccessCount = 0;
		contentDiscarded = NO;
		AssertTrue([self beginContentAccess]);
    }
	return self;
}

- (BOOL)beginContentAccess{
//	NSLog(@"IFAPurgeableObject.beginContentAccess: %p", self);
	if ([self isContentDiscarded]) {
		//NSLog(@"   NO");
		return NO;
	}else{
		contentAccessCount++;
		//NSLog(@"   YES");
		return YES;
	}
}

- (void)endContentAccess{
	//NSLog(@"IFAPurgeableObject.endContentAccess: %p", self);
	if (![self isContentDiscarded] && contentAccessCount>0) {
		//NSLog(@"   contentAccessCount--");
		contentAccessCount--;
	}
}

- (void)discardContentIfPossible{
	//NSLog(@"IFAPurgeableObject.discardContentIfPossible: %p", self);
	if (![self isContentDiscarded] && contentAccessCount==0) {
		//NSLog(@"   contentDiscarded = YES");
		contentDiscarded = YES;
	}
}

- (BOOL)isContentDiscarded{
	//NSLog(@"IFAPurgeableObject.isContentDiscarded: %p", self);
	//NSLog(@"   contentDiscarded: %@", contentDiscarded?@"YES":@"NO");
	return contentDiscarded;
}

@end
