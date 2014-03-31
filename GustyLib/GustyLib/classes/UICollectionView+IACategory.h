//
// Created by Marcelo Schroeder on 20/02/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UICollectionView (IACategory)

// This method can be called, for instance, in willAnimateRotationToInterfaceOrientation
//   to correct the content offset when collection view paging is enabled and the
//   device orientation changes.
// This method is useful because the content offset may be incorrect after a device
//   orientation change in some situations (e.g. from portrait to landscape on 2nd page of a collection view)
- (void)m_updateContentOffsetForPagination;

@end