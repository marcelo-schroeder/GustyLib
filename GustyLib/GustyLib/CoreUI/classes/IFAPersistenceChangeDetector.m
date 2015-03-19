//
// Created by Marcelo Schroeder on 18/03/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCoreUI.h"


@interface IFAPersistenceChangeDetector ()
@property(nonatomic) BOOL changed;
@property(nonatomic) NSMutableDictionary *persistentEntityChangeNotificationUserInfoDictionariesByEntityName;
@property(nonatomic) BOOL IFA_observerAdded;
@end

@implementation IFAPersistenceChangeDetector {

}

#pragma mark - Public

- (void)reset {
    self.changed = NO;
    [self.persistentEntityChangeNotificationUserInfoDictionariesByEntityName removeAllObjects];
}

- (BOOL)changedForManagedObject:(NSManagedObject *)a_managedObject {
    if (a_managedObject && self.changed) {
        NSArray *timerUserInfoDictionaries = self.persistentEntityChangeNotificationUserInfoDictionariesByEntityName[a_managedObject.ifa_entityName];
        if (timerUserInfoDictionaries) {
            for (NSDictionary *userInfoDictionary in timerUserInfoDictionaries) {
                NSManagedObjectID *objectID = a_managedObject.objectID;
                if ([self IFA_changedObjectsSet:userInfoDictionary[IFAKeyUpdatedObjects]
                    containsManagedObjectWithId:objectID]) {
                    return YES;
                } else if ([self IFA_changedObjectsSet:userInfoDictionary[IFAKeyDeletedObjects]
                           containsManagedObjectWithId:objectID]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (NSMutableDictionary *)persistentEntityChangeNotificationUserInfoDictionariesByEntityName {
    if (!_persistentEntityChangeNotificationUserInfoDictionariesByEntityName) {
        _persistentEntityChangeNotificationUserInfoDictionariesByEntityName = [NSMutableDictionary new];
    }
    return _persistentEntityChangeNotificationUserInfoDictionariesByEntityName;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (enabled) {
        [self IFA_addObserver];
    } else {
        [self IFA_removeObserver];
    }
}

#pragma mark - Overrides

- (void)dealloc {
    [self IFA_removeObserver];
}

#pragma mark - Private

- (void)IFA_onPersistentEntityChangeNotification:(NSNotification *)a_notification {
    self.changed = YES;
    NSString *entityName = [((Class) a_notification.object) ifa_entityName];
    NSMutableArray *userInfoDictionaries = self.persistentEntityChangeNotificationUserInfoDictionariesByEntityName[entityName];
    if (!userInfoDictionaries) {
        userInfoDictionaries = [NSMutableArray new];
        self.persistentEntityChangeNotificationUserInfoDictionariesByEntityName[entityName] = userInfoDictionaries;
    }
    [userInfoDictionaries addObject:a_notification.userInfo];
}

- (void)IFA_addObserver {
    if (!self.IFA_observerAdded) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(IFA_onPersistentEntityChangeNotification:)
                                                     name:IFANotificationPersistentEntityChange
                                                   object:nil];
        self.IFA_observerAdded = YES;
    }
}

- (void)IFA_removeObserver {
    if (self.IFA_observerAdded) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:IFANotificationPersistentEntityChange
                                                      object:nil];
        self.IFA_observerAdded = NO;
    }
}

- (BOOL)IFA_changedObjectsSet:(NSSet *)a_changedObjectsSet
  containsManagedObjectWithId:(NSManagedObjectID *)a_managedObjectId{
    for (NSManagedObject *object in a_changedObjectsSet) {
        if ([object.objectID isEqual:a_managedObjectId]) {
            return YES;
        }
    }
    return NO;
}

@end