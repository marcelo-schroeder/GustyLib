//
// Created by Marcelo Schroeder on 17/04/15.
// Copyright (c) 2015 InfoAccent Pty Ltd. All rights reserved.
//

#import "GustyLibCoreUI.h"


@interface IFAUserNotificationSettingsManager ()
@property(nonatomic, strong) IFAUserNotificationSettingsManagerCompletionBlock pendingRegistrationCompletionBlock;
@end

@implementation IFAUserNotificationSettingsManager {

}

#pragma mark - Public

- (void)notifyRegistrationOfUserNotificationSettings:(UIUserNotificationSettings *)a_notificationSettings {
    if (self.pendingRegistrationCompletionBlock) {
        self.pendingRegistrationCompletionBlock(a_notificationSettings);
        self.pendingRegistrationCompletionBlock = nil;
    }
}

+ (void)registerUserNotificationSettings:(UIUserNotificationSettings *)a_notificationSettings
                         completionBlock:(IFAUserNotificationSettingsManagerCompletionBlock)a_completionBlock {
    [IFAUserNotificationSettingsManager sharedInstance].pendingRegistrationCompletionBlock = a_completionBlock;
    [[UIApplication sharedApplication] registerUserNotificationSettings:a_notificationSettings];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static id c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

@end