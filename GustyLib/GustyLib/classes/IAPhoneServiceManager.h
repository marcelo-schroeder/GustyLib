//
// Created by Marcelo Schroeder on 23/12/2013.
// Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IAPhoneServiceManager : NSObject
+ (IAPhoneServiceManager *)m_instance;

- (void)m_dialPhoneNumber:(NSString *)a_phoneNumber;
@end