//
// Created by Marcelo Schroeder on 28/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IAExternalUrlManager : NSObject <UIAlertViewDelegate>
- (void)m_openUrl:(NSURL *)a_url;

+ (IAExternalUrlManager *)m_instance;
@end