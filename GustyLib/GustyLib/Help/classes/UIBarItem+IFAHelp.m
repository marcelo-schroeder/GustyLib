//
// Created by Marcelo Schroeder on 20/06/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import "GustyLibHelp.h"

static char c_helpTargetIdKey;

@implementation UIBarItem (IFAHelp)

#pragma mark - IFAHelpTarget protocol

-(void)setHelpTargetId:(NSString *)a_helpTargetId{
    objc_setAssociatedObject(self, &c_helpTargetIdKey, a_helpTargetId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *l_accessibilityLabel = [[IFAHelpManager sharedInstance] accessibilityLabelForKeyPath:a_helpTargetId];
    if (l_accessibilityLabel) {
        self.accessibilityLabel = l_accessibilityLabel;
    }
}

-(NSString *)helpTargetId {
    return objc_getAssociatedObject(self, &c_helpTargetIdKey);
}

@end