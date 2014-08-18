//
//  IFAFormTableViewCell.h
//  Gusty
//
//  Created by Marcelo Schroeder on 28/10/11.
//  Copyright (c) 2011 InfoAccent Pty Limited. All rights reserved.
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

#import "IFATableViewCell.h"
#import "IFAFormViewController.h"

@class IFAFormTableViewCellContentView;

@interface IFAFormTableViewCell : IFATableViewCell

@property (strong, nonatomic) IBOutlet IFAFormTableViewCellContentView *customContentView;
@property (strong, nonatomic) IBOutlet UIView *leftContainerView;
@property (strong, nonatomic) IBOutlet UILabel *leftLabel;
@property (strong, nonatomic) IBOutlet UIView *rightContainerView;
@property (strong, nonatomic) IBOutlet UILabel *rightLabel;

@property (nonatomic, weak) IFAFormViewController *formViewController;

//-(CGFloat)calculateFieldX;
//-(CGFloat)calculateFieldWidth;

@end
