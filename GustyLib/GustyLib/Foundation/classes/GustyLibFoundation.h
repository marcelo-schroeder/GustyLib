//
//  GustyLibFoundation.h
//  GustyLib
//
//  Created by Marcelo Schroeder on 16/01/2015.
//  Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
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

// Apple Frameworks
#import <objc/message.h>    // added so I could use objc_msgSend to get rid of ARC compiler warnings for performSelector method calls
#import <sys/utsname.h>

#import "IFAAssertionUtils.h"
#import "IFADateRange.h"
#import "IFADispatchQueueManager.h"
#import "IFADynamicCache.h"
#import "IFAFoundationConstants.h"
#import "IFAPurgeableObject.h"
#import "IFAUtils.h"
#import "IFAZeroingWeakReferenceContainer.h"
#import "NSCalendar+IFAFoundation.h"
#import "NSData+IFAFoundation.h"
#import "NSDate+IFAFoundation.h"
#import "NSDictionary+IFAFoundation.h"
#import "NSFileManager+IFAFoundation.h"
#import "NSNumberFormatter+IFAFoundation.h"
#import "NSString+IFAFoundation.h"
