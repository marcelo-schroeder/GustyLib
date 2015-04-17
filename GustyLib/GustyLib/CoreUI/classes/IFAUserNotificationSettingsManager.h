//
// Created by Marcelo Schroeder on 17/04/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* User notification settings registration completion block.
* @param The user notifications settings that have been registered.
*/
typedef void (^IFAUserNotificationSettingsManagerCompletionBlock)(UIUserNotificationSettings *a_notificationSettings);

/**
* Convenience class to manage the registration of user notification settings.
*/
@interface IFAUserNotificationSettingsManager : NSObject

/**
* Automatically called by the application delegate to notify the receiver that user notification settings have been registered.
* @param a_notificationSettings The user notifications settings that have been registered.
*/
- (void)notifyRegistrationOfUserNotificationSettings:(UIUserNotificationSettings *)a_notificationSettings;

/**
* Convenience method to register user notification settings with a completion block.
* @param a_notificationSettings User notification settings to register.
* @param a_completionBlock Completion block executed after registration.
*/
+ (void)registerUserNotificationSettings:(UIUserNotificationSettings *)a_notificationSettings
                         completionBlock:(IFAUserNotificationSettingsManagerCompletionBlock)a_completionBlock;

/**
* Singleton instance.
*/
+ (instancetype)sharedInstance;

@end