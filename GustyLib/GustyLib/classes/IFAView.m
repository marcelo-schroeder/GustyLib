//
//  IFAView.m
//  Gusty
//
//  Created by Marcelo Schroeder on 9/07/12.
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

#import "IFACommon.h"

@implementation IFAView

#pragma mark - Overrides

-(id)init{
    return [[super init] IFA_init];
}

-(id)initWithFrame:(CGRect)frame{
    return [[super initWithFrame:frame] IFA_init];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    return [[super initWithCoder:aDecoder] IFA_init];
}

-(void)awakeFromNib{
    [self IFA_awakeFromNib];
}

@end
