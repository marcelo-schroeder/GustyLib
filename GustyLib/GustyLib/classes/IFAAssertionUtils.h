//
//  IFAAssertionUtils.h
//  Gusty
//
//  Created by Marcelo Schroeder on 6/07/10.
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

//TODO: I am not checking NS_BLOCK_ASSERTIONS at the moment - see the Obj-C for Java devs book for explanation

//TODO: I had to change "[OBJECT className]" to "[[OBJECT class] description]" to get rid of compiler warnings... this needs to be tested

#define RethrowAssertion(EXCEPTION) \
	if ([[EXCEPTION name] isEqualToString:NSInternalInconsistencyException]) \
		[EXCEPTION raise]
#define AssertClass(OBJECT,CLASS) \
	do { \
		if (![OBJECT isKindOfClass:[CLASS class]]) { \
			[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
				object:self \
				file:[NSString stringWithUTF8String:__FILE__] \
				lineNumber:__LINE__ \
				description:@"object isa %@@%p; expected %s", \
					[[OBJECT class] description],OBJECT,#CLASS]; \
		} \
	} while(NO)
#define AssertNotNilAndClass(OBJECT,CLASS) \
	do { \
		if ((OBJECT!=nil) && ![OBJECT isKindOfClass:[CLASS class]]) { \
			[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
				object:self \
				file:[NSString stringWithUTF8String:__FILE__] \
				lineNumber:__LINE__ \
				description:@"object isa %@@%p; expected %s", \
					[[OBJECT class] description],OBJECT,#CLASS]; \
		} \
	} while(NO)
#define AssertRespondsTo(OBJECT,MESSAGE) \
	do { \
		if (![OBJECT respondsToSelector:@selector(MESSAGE)]) { \
			[[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd \
				object:self \
				file:[NSString stringWithUTF8String:__FILE__] \
				lineNumber:__LINE__ \
				description:@"object %@@%p does not respond to %s", \
					[[OBJECT class] description],OBJECT,#MESSAGE]; \
		} \
	} while(NO)
#define AssertNotNil(OBJ) NSAssert1(OBJ!=nil,@"%s is nil",#OBJ)
#define AssertNotNull(OBJ) NSAssert1(OBJ!=NULL,@"%s is NULL",#OBJ)
#define AssertTrue NSParameterAssert

@interface IFAAssertionUtils : NSObject {

}

@end
