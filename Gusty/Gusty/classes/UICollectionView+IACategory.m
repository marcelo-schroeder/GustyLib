//
// Created by Marcelo Schroeder on 20/02/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "UICollectionView+IACategory.h"


@implementation UICollectionView (IACategory)

#pragma mark - Public

- (void)m_updateContentOffsetForPagination {
    CGFloat l_contentOffsetX = self.contentOffset.x;
    CGFloat l_contentOffsetY = self.contentOffset.y;
    CGFloat l_width = self.frame.size.width;
    self.contentOffset = CGPointMake((CGFloat) (ceil(l_contentOffsetX / l_width) * l_width), l_contentOffsetY);
}

@end