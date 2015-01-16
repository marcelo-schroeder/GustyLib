//
// Created by Marcelo Schroeder on 14/10/13.
// Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
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


#import "IFASubjectActivityItem.h"


@interface IFASubjectActivityItem ()
@property(nonatomic, strong) NSString *IFA_subject;
@end

@implementation IFASubjectActivityItem {

}

#pragma mark - Public

- (id)initWithSubject:(NSString *)a_subject {
    self = [super init];
    if (self) {
        self.IFA_subject = a_subject;
    }
    return self;
}

#pragma mark - UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return [self activityViewController:activityViewController
                    itemForActivityType:nil];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType {
    return self.IFA_subject;
}

// Provides the Subject value for when sharing via email (iOS 7 or greater)
- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
              subjectForActivityType:(NSString *)activityType {
    return [self activityViewController:activityViewController
                    itemForActivityType:activityType];
}

@end