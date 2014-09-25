//
// Created by Marcelo Schroeder on 25/09/2014.
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

#import <Foundation/Foundation.h>
#import "IFAViewControllerAnimatedTransitioning.h"

/**
* View controller animated transitioning object that fades the presented view controller into view.
* On dismissal it fades from the presented view controller back to the presenting view controller.
*/
@interface IFAViewControllerFadeTransitioning : IFAViewControllerAnimatedTransitioning
@end