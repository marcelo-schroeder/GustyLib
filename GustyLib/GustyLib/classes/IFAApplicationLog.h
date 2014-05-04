//
//  IFAApplicationLog.h
//  Gusty
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


@interface IFAApplicationLog : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * isError;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSNumber * horizontalAccuracy;
@property (nonatomic, strong) NSString * errorDescription;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSNumber * isLocationAware;
@property (nonatomic, strong) NSNumber * errorCode;

@end
