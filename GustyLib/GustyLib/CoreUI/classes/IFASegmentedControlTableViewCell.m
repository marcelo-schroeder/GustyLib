//
//  IFASegmentedControlTableViewCell.m
//  Gusty
//
//  Created by Marcelo Schroeder on 10/12/10.
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

#import "GustyLibCoreUI.h"


@implementation IFASegmentedControlTableViewCell


- (id)initWithReuseIdentifier:(NSString *)a_reuseIdentifier object:(NSObject *)a_object
                 propertyName:(NSString *)a_propertyName indexPath:(NSIndexPath *)a_indexPath
           formViewController:(IFAFormViewController *)a_formViewController
             segmentedControl:(IFASegmentedControl *)a_segmentedControl {
    if ((self = [super initWithReuseIdentifier:a_reuseIdentifier propertyName:a_propertyName indexPath:a_indexPath
                            formViewController:a_formViewController])) {
        self.segmentedControl = a_segmentedControl;
        [self.customContentView removeFromSuperview];
    }
    return self;
}

@end
