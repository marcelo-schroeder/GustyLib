//
// Created by Marcelo Schroeder on 20/02/2014.
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

@interface UICollectionView (IFACoreUI)

// This method can be called, for instance, in willAnimateRotationToInterfaceOrientation
//   to correct the content offset when collection view paging is enabled and the
//   device orientation changes.
// This method is useful because the content offset may be incorrect after a device
//   orientation change in some situations (e.g. from portrait to landscape on 2nd page of a collection view)
- (void)ifa_updateContentOffsetForPagination;

/**
* Calculates horizontal page index based on current width and content X offset
* @returns Current horizontal page index.
*/
- (NSUInteger)ifa_horizontalPageIndex;

/**
* Calculates vertical page index based on current height and content Y offset
* @returns Current vertical page index.
*/
- (NSUInteger)ifa_verticalPageIndex;
@end