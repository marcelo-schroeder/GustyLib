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
@property (nonatomic, strong, readonly) UICollectionViewFlowLayout *p_layout;

@end

@protocol IAUIGridViewDataSource <NSObject>

- (NSUInteger)m_numberOfRows;
- (NSUInteger)m_numberOfColumns;
- (CGFloat)m_interTileSpace;
- (UICollectionViewScrollDirection)m_scrollDirection;

@optional

// Used to set the collection view's content inset
- (UIEdgeInsets)m_contentInset;

// Used to set the collection view's section inset
- (UIEdgeInsets)m_sectionInset;

// Used in size calculations only to reserve space for bars, revealing collection items partially, inter page spacing, etc
- (UIEdgeInsets)m_reservedEdgeSpace;

- (BOOL)m_shouldAdjustLastColumnWidth;
- (BOOL)m_shouldAdjustLastRowHeight;

/**
* Implement this method to force the item width calculation to be based on the item height.
* When this method is implemented, implementing m_shouldAdjustLastColumnWidth will have no effect.
*
* @returns Number that multiplied by the item height will result in the item width. Returning zero will have no effect.
*/
- (CGFloat)m_itemHeightMultiplierForItemWidth;

/**
* Implement this method to force the item height calculation to be based on the item width.
* When this method is implemented, implementing m_shouldAdjustLastRowHeight will have no effect.
*
* @returns Number that multiplied by the item width will result in the item height. Returning zero will have no effect.
*/
- (CGFloat)m_itemWidthMultiplierForItemHeight;

@end

@protocol IAUIGridViewDelegate <NSObject>

@optional

// Called at various life cycle phases when the view layout needs to be updated (if required)
// Extra configuration can be done here
- (void)m_didUpdateCollectionViewFlowLayout:(UICollectionViewFlowLayout *)a_collectionViewFlowLayout;

@end