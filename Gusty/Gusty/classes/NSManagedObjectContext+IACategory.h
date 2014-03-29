//
//  NSManagedObjectContext+IACategory.h
//  Gusty
//
//  Created by Marcelo Schroeder on 17/02/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (IACategory)

@property BOOL p_isCurrentManagedObjectDirty;

@end
