//
//  IFAOperation.m
//  Gusty
//
//  Created by Marcelo Schroeder on 2/09/11.
//  Copyright 2011 InfoAccent Pty Limited. All rights reserved.
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

@interface IFAOperation ()
@end

@implementation IFAOperation

#pragma mark - Overrides

-(id)init{
    if (self=[super init]) {
        self.allowsCancellation = YES;
        [self IFA_addObservers];
    }
    return self;
}

- (void)dealloc {
    [self IFA_removeObservers];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
    id newValue = change[@"new"];
    // The assumption here is that these observations are being done on a thread other than the main thread,
    // so dispatch UI work back to the main thread
    [IFAUtils dispatchAsyncMainThreadBlock:^{
        if ([keyPath isEqualToString:@"determinateProgress"]) {
            BOOL determinateProgress = [newValue boolValue];
//            NSLog(@"determinateProgress: %u", determinateProgress);
            self.workInProgressModalViewManager.determinateProgress = determinateProgress;
        } else if ([keyPath isEqualToString:@"determinateProgressPercentage"]) {
            CGFloat determinateProgressPercentage = [newValue floatValue];
//            NSLog(@"determinateProgressPercentage: %f", determinateProgressPercentage);
            self.workInProgressModalViewManager.determinateProgressPercentage = determinateProgressPercentage;
        } else if ([keyPath isEqualToString:@"progressMessage"]) {
            NSString *progressMessage = newValue;
//            NSLog(@"progressMessage: %@", progressMessage);
            self.workInProgressModalViewManager.progressMessage = progressMessage;
        } else {
            NSAssert(NO, @"Unexpected key path: %@", keyPath);
        }
    }];
}

#pragma mark - Private

- (void)IFA_addObservers {
    [self addObserver:self forKeyPath:@"determinateProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"determinateProgressPercentage" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"progressMessage" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)IFA_removeObservers {
    [self removeObserver:self forKeyPath:@"determinateProgress"];
    [self removeObserver:self forKeyPath:@"determinateProgressPercentage"];
    [self removeObserver:self forKeyPath:@"progressMessage"];
}

@end
