//
//  IAUIColorSchemeTest.m
//  Gusty
//
//  Created by Marcelo Schroeder on 13/11/12.
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

#import "IAUIColorSchemeTest.h"

@implementation IAUIColorSchemeTest

-(void)testEquality{
    
    // Equal
    NSArray *l_colors1 = @[
    [UIColor colorWithRed:0.0 green:0.1 blue:0.2 alpha:0.3],
    [UIColor colorWithRed:0.4 green:0.5 blue:0.6 alpha:0.7],
    ];
    NSArray *l_colors2 = @[
    [UIColor colorWithRed:0.0 green:0.1 blue:0.2 alpha:0.3],
    [UIColor colorWithRed:0.4 green:0.5 blue:0.6 alpha:0.7],
    ];
    STAssertTrue([l_colors1 isEqual:l_colors1], nil);
    IAUIColorScheme *l_colorScheme1 = [[IAUIColorScheme alloc] initWithColors:l_colors1];
    IAUIColorScheme *l_colorScheme2 = [[IAUIColorScheme alloc] initWithColors:l_colors2];
    STAssertTrue([l_colorScheme1 isEqual:l_colorScheme2], nil);
    
    // Not Equal
    NSArray *l_colors3 = @[
    [UIColor colorWithRed:0.0 green:0.1 blue:0.2 alpha:0.3],
    [UIColor colorWithRed:0.4 green:0.5 blue:0.6 alpha:0.7],
    ];
    NSArray *l_colors4 = @[
    [UIColor colorWithRed:0.0 green:0.1 blue:0.2 alpha:0.3],
    [UIColor colorWithRed:0.4 green:0.5 blue:0.6 alpha:0.8],
    ];
    STAssertFalse([l_colors3 isEqual:l_colors4], nil);
    IAUIColorScheme *l_colorScheme3 = [[IAUIColorScheme alloc] initWithColors:l_colors3];
    IAUIColorScheme *l_colorScheme4 = [[IAUIColorScheme alloc] initWithColors:l_colors4];
    STAssertFalse([l_colorScheme3 isEqual:l_colorScheme4], nil);

}

@end
