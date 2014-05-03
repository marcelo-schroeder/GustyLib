//
//  IAUIPreferencesFormViewControllerViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 30/04/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

#import "IACommon.h"

@interface IAUIPreferencesFormViewController ()

@end

@implementation IAUIPreferencesFormViewController

#pragma mark - Private

-(id)m_init{
    self.readOnlyMode = NO;
    self.createMode = NO;
    self.p_object = [[IAPreferencesManager sharedInstance] preferences];
    self.formName = IA_ENTITY_CONFIG_FORM_NAME_DEFAULT;
    self.isSubForm = NO;
    return self;
}

#pragma mark - Overrides

-(id)init{
    return [[super initWithStyle:UITableViewStyleGrouped] m_init];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    return [[super initWithCoder:aDecoder] m_init];
}

- (NSArray*)m_editModeToolbarItems{
    // Preference cannot be deleted, so return an empty toolbar
    return nil;
}

@end
