//
//  IFASystemEntity.h
//  GustyLib
//
//  Created by Marcelo Schroeder on 16/06/11.
//  Copyright (c) 2011 InfoAccent Pty Limited. All rights reserved.
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
#import <CoreData/CoreData.h>


@interface IFASystemEntity : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * systemEntityId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSNumber * systemUseOnly;
@property (nonatomic, strong) NSNumber * index;

/**
* Finds an instance of this class (or subclass) by system entity ID.
* @param a_systemEntityId System entity ID to match.
* @returns An instance of this class (or subclass) matching the provided system entity ID.
*/
+ (instancetype)findBySystemEntityId:(NSUInteger)a_systemEntityId;

@end
