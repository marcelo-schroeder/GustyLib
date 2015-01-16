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

#import "UICollectionView+IFACoreUI.h"


@implementation UICollectionView (IFACoreUI)

#pragma mark - Public

- (void)ifa_updateContentOffsetForPagination {
    CGFloat l_contentOffsetX = self.contentOffset.x;
    CGFloat l_contentOffsetY = self.contentOffset.y;
    CGFloat l_width = self.frame.size.width;
    self.contentOffset = CGPointMake((CGFloat) (ceil(l_contentOffsetX / l_width) * l_width), l_contentOffsetY);
}

- (NSUInteger)ifa_horizontalPageIndex{
    return (NSUInteger) (self.contentOffset.x / self.frame.size.width);
}

- (NSUInteger)ifa_verticalPageIndex{
    return (NSUInteger) (self.contentOffset.y / self.frame.size.height);
}

@end