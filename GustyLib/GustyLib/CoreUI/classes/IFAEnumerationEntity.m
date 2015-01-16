//
//  IFAEnumerationEntity.m
//  Gusty
//
//  Created by Marcelo Schroeder on 24/09/11.
//  Copyright 2011 InfoAccent Pty Limited. All rights reserved.
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

@implementation IFAEnumerationEntity


#pragma mark - Public

+(IFAEnumerationEntity *)enumerationEntityForId:(NSNumber*)a_id entities:(NSArray*)a_entities{
    for (IFAEnumerationEntity *l_enumEntity in a_entities) {
        if ([l_enumEntity.enumerationEntityId isEqual:a_id]) {
            return l_enumEntity;
        }
    }
    return nil;
}

#pragma mark - Overrides

- (NSString *)description{
    return [NSString stringWithFormat:@"id: %@, name: %@", [self.enumerationEntityId description], self.name];
}

-(NSString*)label{
    return self.name;
}

@end
