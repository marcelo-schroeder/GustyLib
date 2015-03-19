//
//  TestCoreDataEntity2.h
//  GustyLib
//
//  Created by Marcelo Schroeder on 18/03/2015.
//  Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TestCoreDataEntity2 : NSManagedObject

@property (nonatomic, retain) NSString * attribute1;
@property (nonatomic, retain) NSNumber * attribute2;

@end
