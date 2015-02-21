//
//  IFAPersistenceManager.h
//  Gusty
//
//  Created by Marcelo Schroeder on 11/06/10.
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

#import <CoreData/CoreData.h>

@class IFAEntityConfig;
@class NSPersistentStore;
@class NSManagedObject;
@class NSFetchRequest;
@class NSManagedObjectID;
@class NSFetchedResultsController;

@interface IFAPersistenceManager : NSObject

@property (strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, readonly) NSManagedObjectContext *privateQueueManagedObjectContext;
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, readonly) NSPersistentStore *persistentStore;
@property (strong, readonly) IFAEntityConfig *entityConfig;

@property (nonatomic) BOOL isCurrentManagedObjectDirty;

@property (nonatomic) BOOL savesInMainThreadOnly;

- (void) resetEditSession;

- (BOOL)validateValue:(id *)a_value forProperty:(NSString *)a_propertyName inManagedObject:a_managedObject alertPresenter:(UIViewController *)a_alertPresenter;
- (BOOL)saveManagedObjectContext:(NSManagedObjectContext*)a_moc;
- (BOOL)saveMainManagedObjectContext;
- (BOOL)saveObject:(NSManagedObject *)aManagedObject validationAlertPresenter:(UIViewController *)a_validationAlertPresenter;
- (BOOL)save;
- (BOOL)deleteObject:(NSManagedObject *)aManagedObject validationAlertPresenter:(UIViewController *)a_validationAlertPresenter;
- (BOOL)deleteAndSaveObject:(NSManagedObject *)aManagedObject validationAlertPresenter:(UIViewController *)a_validationAlertPresenter;
- (void)rollback;
//- (void)undo;
- (NSUInteger) countEntity:(NSString*)anEntityName;
- (NSUInteger) countEntity:(NSString*)anEntityName keysAndValues:(NSDictionary*)aDictionary;
- (BOOL)validateForSave:(NSManagedObject *)aManagedObject validationAlertPresenter:(UIViewController *)a_validationAlertPresenter;

- (NSManagedObject *)instantiate:(NSString *)entityName;
- (NSMutableArray *) findAllForEntity:(NSString *)entityName;
- (NSMutableArray *) findAllForEntity:(NSString *)entityName includePendingChanges:(BOOL)a_includePendingChanges;
- (NSMutableArray *) findAllForEntity:(NSString *)entityName includePendingChanges:(BOOL)a_includePendingChanges includeSubentities:(BOOL)a_includeSubentities;
- (void) deleteAllForEntityAndSave:(NSString *)entityName validationAlertPresenter:(UIViewController *)a_validationAlertPresenter;
- (NSManagedObject *) findSystemEntityById:(NSUInteger)anId entity:(NSString *)anEntityName;
- (NSManagedObject *) findByName:(NSString*)aName entity:(NSString *)anEntityName;
- (NSManagedObject *) findById:(NSManagedObjectID*)anObjectId;
- (NSManagedObject *) findByStringId:(NSString*)aStringId;
-(NSArray*)findByKeysAndValues:(NSDictionary*)aDictionary entity:(NSString *)anEntityName;
-(NSManagedObject*)findSingleByKeysAndValues:(NSDictionary*)aDictionary entity:(NSString *)anEntityName;
- (BOOL)isSystemEntityForEntity:(NSString*)anEntityName;

- (NSArray*) fetchWithPredicate:(NSPredicate*)aPredicate
						 entity:(NSString*)anEntityName;
- (NSArray*) fetchWithPredicate:(NSPredicate*)aPredicate
						 entity:(NSString*)anEntityName
                          block:(void (^)(NSFetchRequest *aFetchRequest))aBlock;
- (NSArray*) fetchWithPredicate:(NSPredicate*)aPredicate
						 entity:(NSString*)anEntityName
                      countOnly:(BOOL)aCountOnlyFlag;
- (NSArray*) fetchWithPredicate:(NSPredicate*)aPredicate 
				 sortDescriptor:(NSSortDescriptor*)aSortDescriptor
						 entity:(NSString*)anEntityName;
- (NSArray*) fetchWithPredicate:(NSPredicate*)aPredicate 
				 sortDescriptor:(NSSortDescriptor*)aSortDescriptor
						 entity:(NSString*)anEntityName
                          limit:(NSUInteger)aLimit;
- (NSArray*) fetchWithPredicate:(NSPredicate*)aPredicate 
				sortDescriptors:(NSArray*)aSortDescriptorArray
						 entity:(NSString*)anEntityName;
- (NSArray*) fetchWithPredicate:(NSPredicate*)aPredicate 
				sortDescriptors:(NSArray*)aSortDescriptorArray
						 entity:(NSString*)anEntityName
                          limit:(NSUInteger)aLimit;
- (NSArray*) fetchWithPredicate:(NSPredicate*)aPredicate 
				sortDescriptors:(NSArray*)aSortDescriptorArray
						 entity:(NSString*)anEntityName
                          limit:(NSUInteger)aLimit
                      countOnly:(BOOL)aCountOnlyFlag;
- (NSArray*) fetchWithPredicate:(NSPredicate*)aPredicate
                sortDescriptors:(NSArray*)aSortDescriptorArray
                         entity:(NSString*)anEntityName
                          limit:(NSUInteger)aLimit
                      countOnly:(BOOL)aCountOnlyFlag
                          block:(void (^)(NSFetchRequest *aFetchRequest))aBlock;
- (NSManagedObject*) fetchSingleWithPredicate:(NSPredicate*)aPredicate entity:(NSString*)anEntityName;
- (NSManagedObject*) fetchSingleForEntity:(NSString*)anEntityName;
- (id)fetchWithExpression:(NSExpression *)anExpression
               resultType:(NSAttributeType)aResultType
                   entity:(NSString*)anEntityName;

- (NSFetchedResultsController*) fetchControllerWithPredicate:(NSPredicate*)aPredicate 
                                              sortDescriptor:(NSSortDescriptor*)aSortDescriptor
                                                      entity:(NSString*)anEntityName
                                          sectionNameKeyPath:(NSString *)aSectionNameKeyPath
                                                   cacheName:(NSString*)aCacheName;
- (NSFetchedResultsController*) fetchControllerWithPredicate:(NSPredicate*)aPredicate 
                                             sortDescriptors:(NSArray*)aSortDescriptorArray
                                                      entity:(NSString*)anEntityName
                                          sectionNameKeyPath:(NSString *)aSectionNameKeyPath
                                                   cacheName:(NSString*)aCacheName;

- (id) metadataValueForKey:(NSString *)aKey;
- (void) setMetadataValue:(id)aValue forKey:(NSString *)aKey;

- (NSArray*)listSortDescriptorsForEntity:(NSString*)anEntityName;

- (void)performBlock:(void (^)())a_block;
- (void)performBlockAndWait:(void (^)())a_block;

- (void)performBlockInPrivateQueue:(void (^)())a_block;
- (void)performBlockInPrivateQueueAndWait:(void (^)())a_block;

- (void)performBlock:(void (^)())a_block managedObjectContext:(NSManagedObjectContext*)a_managedObjectContext;
- (void)performBlockAndWait:(void (^)())a_block managedObjectContext:(NSManagedObjectContext*)a_managedObjectContext;

-(NSMutableArray*)managedObjectsForIds:(NSArray*)a_managedObjectIds;

/**
* Configure the persistence manager instance, including the Core Data stack.
*
* This method can configure either a SQLite store or an in memory store. The type of store will depend on the a_databaseResourceName parameter.
* After completion, the following properties will have been set: managedObjectModel, persistentStoreCoordinator, managedObjectContext, privateQueueManagedObjectContext and entityConfig.
*
* @param a_databaseResourceName Name of the SQLite database file for a SQLite store, without the ".sqlite" file suffix. If nil, an in-memory store will be created instead.
* @param a_managedObjectModelResourceName Name of Core Data data model resource, without the ".momd" suffix.
*/
- (void)configureWithDatabaseResourceName:(NSString*)a_databaseResourceName managedObjectModelResourceName:(NSString*)a_managedObjectModelResourceName;

- (void)manageDatabaseVersioningChangeWithBlock:(void (^)(NSUInteger a_oldSystemEntitiesVersion, NSUInteger a_newSystemEntitiesVersion))a_block;

-(void)pushChildManagedObjectContext;
-(void)popChildManagedObjectContext;
-(NSArray *)childManagedObjectContexts;

-(NSManagedObjectContext*)currentManagedObjectContext;

- (NSFetchRequest*) findAllFetchRequest:(NSString *)entityName includePendingChanges:(BOOL)a_includePendingChanges;
- (NSArray*) executeFetchRequest:(NSFetchRequest*)aFetchRequest;
- (NSMutableArray*) executeFetchRequestMutable:(NSFetchRequest*)aFetchRequest;

- (NSFetchRequest*) fetchRequestWithPredicate:(NSPredicate*)aPredicate
                              sortDescriptors:(NSArray*)aSortDescriptorArray
                                       entity:(NSString*)anEntityName;
- (NSFetchRequest*) fetchRequestWithPredicate:(NSPredicate*)aPredicate
                              sortDescriptors:(NSArray*)aSortDescriptorArray
                                       entity:(NSString*)anEntityName
                                        limit:(NSUInteger)aLimit
                                    countOnly:(BOOL)aCountOnlyFlag;

+ (instancetype)sharedInstance;
+ (BOOL)setValidationError:(NSError**)anError withMessage:(NSString*)anErrorMessage;
+ (NSMutableArray*)idsForManagedObjects:(NSArray*)a_managedObjects;

@end
