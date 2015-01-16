//
//  IFAPreferencesManager.m
//  Gusty
//
//  Created by Marcelo Schroeder on 30/04/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

@interface IFAPreferencesManager ()

@property (nonatomic, strong) NSManagedObjectID *IFA_preferencesManagedObjectId;

@end

@implementation IFAPreferencesManager {
    
}

#pragma mark - Public

-(id)preferences {

    NSString *l_preferencesClassName = [[IFAUtils infoPList] valueForKey:IFAInfoPListPreferencesClassName];
    Class l_preferencesClass = NSClassFromString(l_preferencesClassName);
    if (l_preferencesClass) {    // App uses preferences

        if (self.IFA_preferencesManagedObjectId) {    // ID is known, so load by ID

            return [[IFAPersistenceManager sharedInstance] findById:self.IFA_preferencesManagedObjectId];

        }else{  // ID is not known

            NSManagedObject *l_mo = [[IFAPersistenceManager sharedInstance] fetchSingleForEntity:l_preferencesClassName];
            if (l_mo) { // Preferences record already exists, so make a note of the ID for later use
                self.IFA_preferencesManagedObjectId = l_mo.objectID;
            }else{  // Preferences record does not exist, so create it and make a note of the ID for later use
                self.IFA_preferencesManagedObjectId = [[IFAPersistenceManager sharedInstance] instantiate:l_preferencesClassName].objectID;
            }
            return l_mo;

        }

    }else{  // App does not use preferences

        return nil;

    }

}

+ (IFAPreferencesManager *)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IFAPreferencesManager *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

@end
