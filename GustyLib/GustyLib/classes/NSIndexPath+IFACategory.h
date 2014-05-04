//
// Created by Marcelo Schroeder on 8/04/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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

@interface NSIndexPath (IFACategory)

/**
* Creates an array of index paths given a row range and a section.
*
* @param a_rowRange Range of rows to generate.
* @param a_section Section the index paths to be generated will belong to.
*
* @returns Array of NSIndexPath instances created based on the parameters provided.
*/
+ (NSArray *)IFA_indexPathsForRowRange:(NSRange)a_rowRange section:(NSInteger)a_section;

@end