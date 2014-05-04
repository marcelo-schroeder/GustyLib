//
//  NSManagedObject+IACategory.h
//  Gusty
//
//  Created by Marcelo Schroeder on 30/07/10.
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

@interface NSManagedObject (IFACategory)

@property (nonatomic, readonly) NSString *IFA_stringId;
@property (nonatomic, readonly) NSURL *IFA_urlId;

- (NSString*)IFA_labelForKeys:(NSArray*)aKeyArray;
- (BOOL)IFA_validateForSave:(NSError**)anError;
- (void)IFA_willDelete;
- (void)IFA_didDelete;
- (BOOL)IFA_delete;
- (BOOL)IFA_deleteAndSave;
- (BOOL)IFA_hasValueChangedForKey:(NSString*)a_key;

+ (NSManagedObject*)IFA_instantiate;
+ (NSMutableArray *)IFA_findAll;
+ (void)IFA_deleteAll;
+ (void)IFA_deleteAllAndSave;

@end
