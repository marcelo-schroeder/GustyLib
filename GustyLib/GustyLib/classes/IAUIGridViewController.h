//
// Created by Marcelo Schroeder on 17/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IAUICollectionViewController.h"

@protocol IAUIGridViewDataSource;
@protocol IAUIGridViewDelegate;

@interface IAUIGridViewController : IAUICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<IAUIGridViewDataSource> p_gridViewDataSource;
@property (nonatomic, weak) id<IAUIGridViewDelegate> p_gridViewDelegate;

@end

@protocol IAUIGridViewDataSource <NSObject>

- (NSUInteger)m_numberOfRows;
- (NSUInteger)m_numberOfColumns;
- (CGFloat)m_interTileSpace;
- (UICollectionViewScrollDirection)m_scrollDirection;

@optional

// Used to set the collection view's content inset
- (UIEdgeInsets)m_contentInset;

// Used in size calculations only to reserve space for bars, revealing collection items partially, inter page spacing, etc
- (UIEdgeInsets)m_reservedEdgeSpace;

- (BOOL)m_shouldAdjustLastColumnWidth;
- (BOOL)m_shouldAdjustLastRowHeight;

@end

@protocol IAUIGridViewDelegate <NSObject>

@optional

// Called at various life cycle phases when the view layout needs to be updated (if required)
// Extra configuration can be done here
- (void)m_didUpdateCollectionViewFlowLayout:(UICollectionViewFlowLayout *)a_collectionViewFlowLayout;

@end