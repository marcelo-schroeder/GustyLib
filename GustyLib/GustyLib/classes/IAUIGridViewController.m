//
// Created by Marcelo Schroeder on 17/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IAUIGridViewController.h"
#import "UICollectionView+IACategory.h"

@interface IAUIGridViewController ()
@property(nonatomic) BOOL p_firstLoadDone;
@property(nonatomic) BOOL p_interfaceIsRotating;
@end

@implementation IAUIGridViewController {

}

#pragma mark - Private

- (void)m_updateGridLayoutInCaseDeviceOrientationChangedWhileViewWasNotVisible {
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];
    [self.collectionView reloadData];
}

- (void)m_doFirstLoadConfiguration {
    if (!self.p_firstLoadDone) {

        [self m_configureCollectionViewLayout];


        self.p_firstLoadDone = YES;
    }
}

- (void)m_onApplicationWillChangeStatusBarFrameNotification:(NSNotification *)a_notification {
    if (!self.p_interfaceIsRotating) {  // If interface is rotating then layout will be taken care of somewhere else
        // Force collection views re-layout
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

- (CGFloat)m_calculateCollectionItemWidthForIndexPath:(NSIndexPath *)a_indexPath{

    UICollectionViewFlowLayout *l_layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    CGFloat l_numberOfColumns = [self.p_gridViewDataSource m_numberOfColumns];
    CGFloat l_numberOfRows = [self.p_gridViewDataSource m_numberOfRows];
    CGFloat l_numberOfTiles = l_numberOfColumns * l_numberOfRows;
    UIEdgeInsets l_reservedEdgeSpace = UIEdgeInsetsZero;
    if ([self.p_gridViewDataSource respondsToSelector:@selector(m_reservedEdgeSpace)]) {
        l_reservedEdgeSpace = [self.p_gridViewDataSource m_reservedEdgeSpace];
    }

    CGFloat l_horizontalSpace = self.view.frame.size.width;
    CGFloat l_horizontalSpaceUnavailable = (l_layout.minimumInteritemSpacing * (l_numberOfColumns - 1)) + l_reservedEdgeSpace.left + l_reservedEdgeSpace.right;
    CGFloat l_horizontalSpaceAvailable = l_horizontalSpace - l_horizontalSpaceUnavailable;
    CGFloat l_itemWidth = (CGFloat) floor(l_horizontalSpaceAvailable / l_numberOfColumns);

    CGFloat l_lastColumnTileWidthAdjustment = 0;
    BOOL l_shouldAdjustLastColumnWidth = NO;
    if ([self.p_gridViewDataSource respondsToSelector:@selector(m_shouldAdjustLastColumnWidth)]) {
        l_shouldAdjustLastColumnWidth = [self.p_gridViewDataSource m_shouldAdjustLastColumnWidth];
    }
    if (l_shouldAdjustLastColumnWidth) {
        BOOL l_isLastColumn;
        if (l_layout.scrollDirection==UICollectionViewScrollDirectionHorizontal) {
            l_isLastColumn = a_indexPath.item >= l_numberOfTiles - l_numberOfRows;
        }else{
            l_isLastColumn = (((NSUInteger)a_indexPath.item + 1) % (NSUInteger)l_numberOfColumns) == 0;
        }
        if (l_isLastColumn) {
            l_lastColumnTileWidthAdjustment = l_horizontalSpaceAvailable - l_itemWidth * l_numberOfColumns;
        }
        l_itemWidth += l_lastColumnTileWidthAdjustment;
//        NSLog(@"  l_isLastColumn: %u", l_isLastColumn);
    }

//    NSLog(@"  l_horizontalSpace: %f", l_horizontalSpace);
//    NSLog(@"  l_horizontalSpaceUnavailable: %f", l_horizontalSpaceUnavailable);
//    NSLog(@"  l_horizontalSpaceAvailable: %f", l_horizontalSpaceAvailable);
//    NSLog(@"  l_lastColumnTileWidthAdjustment: %f", l_lastColumnTileWidthAdjustment);
    
    return l_itemWidth;

}

- (CGFloat)m_calculateCollectionItemHeightForIndexPath:(NSIndexPath *)a_indexPath{

    UICollectionViewFlowLayout *l_layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    CGFloat l_numberOfColumns = [self.p_gridViewDataSource m_numberOfColumns];
    CGFloat l_numberOfRows = [self.p_gridViewDataSource m_numberOfRows];
    CGFloat l_numberOfTiles = l_numberOfColumns * l_numberOfRows;
    UIEdgeInsets l_reservedEdgeSpace = UIEdgeInsetsZero;
    if ([self.p_gridViewDataSource respondsToSelector:@selector(m_reservedEdgeSpace)]) {
        l_reservedEdgeSpace = [self.p_gridViewDataSource m_reservedEdgeSpace];
    }

    CGFloat l_verticalSpace = self.view.frame.size.height;
    CGFloat l_verticalSpaceUnavailable = (l_layout.minimumLineSpacing * (l_numberOfRows - 1)) + l_reservedEdgeSpace.top + l_reservedEdgeSpace.bottom;
    CGFloat l_verticalSpaceAvailable = l_verticalSpace - l_verticalSpaceUnavailable;
    CGFloat l_itemHeight = (CGFloat) floor(l_verticalSpaceAvailable / l_numberOfRows);

    CGFloat l_lastRowTileHeightAdjustment = 0;
    BOOL l_shouldAdjustLastRowHeight = NO;
    if ([self.p_gridViewDataSource respondsToSelector:@selector(m_shouldAdjustLastRowHeight)]) {
        l_shouldAdjustLastRowHeight = [self.p_gridViewDataSource m_shouldAdjustLastRowHeight];
    }
    if (l_shouldAdjustLastRowHeight) {
        BOOL l_isLastRow;
        if (l_layout.scrollDirection==UICollectionViewScrollDirectionHorizontal) {
            l_isLastRow = (((NSUInteger)a_indexPath.item + 1) % (NSUInteger)l_numberOfRows) == 0;
        }else{
            l_isLastRow = a_indexPath.item >= l_numberOfTiles - l_numberOfColumns;
        }
        if (l_isLastRow) {
            l_lastRowTileHeightAdjustment = l_verticalSpaceAvailable - l_itemHeight * l_numberOfRows;
        }
        l_itemHeight += l_lastRowTileHeightAdjustment;
//        NSLog(@"  l_isLastRow: %u", l_isLastRow);
    }

//    NSLog(@"  l_verticalSpace: %f", l_verticalSpace);
//    NSLog(@"  l_verticalSpaceUnavailable: %f", l_verticalSpaceUnavailable);
//    NSLog(@"  l_verticalSpaceAvailable: %f", l_verticalSpaceAvailable);
//    NSLog(@"  l_lastRowTileHeightAdjustment: %f", l_lastRowTileHeightAdjustment);

    return l_itemHeight;
    
}

- (CGSize)m_calculateCollectionItemSizeForIndexPath:(NSIndexPath *)a_indexPath{
//    NSLog(@"m_calculateCollectionItemSizeForIndexPath: %@", [a_indexPath description]);
    CGFloat l_itemWidth = [self m_calculateCollectionItemWidthForIndexPath:a_indexPath];
    CGFloat l_itemHeight = [self m_calculateCollectionItemHeightForIndexPath:a_indexPath];
    CGSize l_collectionItemSize = CGSizeMake(l_itemWidth, l_itemHeight);
//    NSLog(@"  l_collectionItemSize: %@", NSStringFromCGSize(l_collectionItemSize));
    return l_collectionItemSize;
}

- (void)m_configureCollectionViewLayout {

    CGFloat l_interTileSpace = [self.p_gridViewDataSource m_interTileSpace];

    UICollectionViewFlowLayout *l_layout = (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
    l_layout.minimumInteritemSpacing = l_interTileSpace;
    l_layout.minimumLineSpacing = l_interTileSpace;
    l_layout.scrollDirection = [self.p_gridViewDataSource m_scrollDirection];

    if ([self.p_gridViewDataSource respondsToSelector:@selector(m_contentInset)]) {
        self.collectionView.contentInset = [self.p_gridViewDataSource m_contentInset];
    }

    if ([self.p_gridViewDelegate respondsToSelector:@selector(m_didUpdateCollectionViewFlowLayout:)]) {
        [self.p_gridViewDelegate m_didUpdateCollectionViewFlowLayout:l_layout];
    }

}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(m_onApplicationWillChangeStatusBarFrameNotification:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self m_doFirstLoadConfiguration];
    [self m_updateGridLayoutInCaseDeviceOrientationChangedWhileViewWasNotVisible];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.p_interfaceIsRotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView m_updateContentOffsetForPagination];
    // Need to reload data here because the item order might change if orientation changes
    [self.collectionView reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.p_interfaceIsRotating = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification
                                                  object:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self m_calculateCollectionItemSizeForIndexPath:indexPath];
}

@end