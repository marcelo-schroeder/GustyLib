//
// Created by Marcelo Schroeder on 17/03/2014.
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

#import "GustyLibCoreUI.h"

@interface IFAGridViewController ()
@property(nonatomic) BOOL IFA_firstLoadDone;
@property(nonatomic) BOOL IFA_interfaceIsRotating;
@property(nonatomic) NSUInteger IFA_savedHorizontalPageIndex;
@property(nonatomic) NSUInteger IFA_savedVerticalPageIndex;
@end

@implementation IFAGridViewController {

}

#pragma mark - Private

- (void)IFA_updateGridLayoutInCaseDeviceOrientationChangedWhileViewWasNotVisible {
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];
    [self.collectionView reloadData];
}

- (void)IFA_updateContentOffsetInCaseDeviceOrientationChangedWhileViewWasNotVisible {
    if (self.collectionView.pagingEnabled && self.shouldSupportPaging) {
        CGFloat l_contentXOffset = self.IFA_savedHorizontalPageIndex * self.view.frame.size.width;
        CGFloat l_contentYOffset = self.IFA_savedVerticalPageIndex * self.view.frame.size.height;
        if (self.collectionView.contentOffset.x != l_contentXOffset || self.collectionView.contentOffset.y != l_contentYOffset) {
            __weak __typeof(self) l_weakSelf = self;
            [UIView animateWithDuration:0.3 animations:^{
                l_weakSelf.collectionView.contentOffset = CGPointMake(l_contentXOffset, l_contentYOffset);
            }];
        }
    }
}

- (void)IFA_doFirstLoadConfiguration {
    if (!self.IFA_firstLoadDone) {
        [self IFA_updateCollectionViewLayout];
        self.IFA_firstLoadDone = YES;
    }
}

- (void)IFA_onApplicationWillChangeStatusBarFrameNotification:(NSNotification *)a_notification {
    if (!self.IFA_interfaceIsRotating) {  // If interface is rotating then layout will be taken care of somewhere else
        // Force collection views re-layout
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

- (CGFloat)IFA_calculateHorizontalSpaceAvailable {

    UICollectionViewFlowLayout *l_layout = self.layout;
    CGFloat l_numberOfColumns = [self.gridViewDataSource numberOfGridColumns];
    UIEdgeInsets l_reservedEdgeSpace = UIEdgeInsetsZero;
    if ([self.gridViewDataSource respondsToSelector:@selector(reservedEdgeSpace)]) {
        l_reservedEdgeSpace = [self.gridViewDataSource reservedEdgeSpace];
    }

    CGFloat l_horizontalSpace = self.view.frame.size.width;
    CGFloat l_horizontalSpaceUnavailable = (l_layout.minimumInteritemSpacing * (l_numberOfColumns - 1)) + l_reservedEdgeSpace.left + l_reservedEdgeSpace.right;
    CGFloat l_horizontalSpaceAvailable = l_horizontalSpace - l_horizontalSpaceUnavailable;

//    NSLog(@"  l_horizontalSpace: %f", l_horizontalSpace);
//    NSLog(@"  l_horizontalSpaceUnavailable: %f", l_horizontalSpaceUnavailable);
//    NSLog(@"  l_horizontalSpaceAvailable: %f", l_horizontalSpaceAvailable);
    
    return l_horizontalSpaceAvailable;

}

- (CGFloat)IFA_calculateCollectionItemWidthForIndexPath:(NSIndexPath *)a_indexPath{

    if ([self.gridViewDataSource respondsToSelector:@selector(itemHeightMultiplierForItemWidth)]) {
        CGFloat l_multiplier = [self.gridViewDataSource itemHeightMultiplierForItemWidth];
        if (l_multiplier) {
            // Item width is based on the item height
            return [self IFA_calculateCollectionItemHeightForIndexPath:a_indexPath] * l_multiplier;
        }
    }

    CGFloat l_numberOfColumns = [self.gridViewDataSource numberOfGridColumns];
    CGFloat l_horizontalSpaceAvailable = [self IFA_calculateHorizontalSpaceAvailable];
    CGFloat l_itemWidth = (CGFloat) floor(l_horizontalSpaceAvailable / l_numberOfColumns);

    if (a_indexPath) {

        CGFloat l_lastColumnTileWidthAdjustment = 0;
        BOOL l_shouldAdjustLastColumnWidth = NO;
        if ([self.gridViewDataSource respondsToSelector:@selector(shouldAdjustLastColumnWidth)]) {
            l_shouldAdjustLastColumnWidth = [self.gridViewDataSource shouldAdjustLastColumnWidth];
        }
        if (l_shouldAdjustLastColumnWidth) {
            if ([self isOnLastColumnForItemAtIndexPath:a_indexPath]) {
                l_lastColumnTileWidthAdjustment = l_horizontalSpaceAvailable - l_itemWidth * l_numberOfColumns;
            }
            l_itemWidth += l_lastColumnTileWidthAdjustment;
//            NSLog(@"    l_isLastColumn: %u", l_isLastColumn);
        }
//        NSLog(@"    l_lastColumnTileWidthAdjustment: %f", l_lastColumnTileWidthAdjustment);

    }
    
    return l_itemWidth;

}

- (CGFloat)IFA_calculateVerticalSpaceAvailable {

    UICollectionViewFlowLayout *l_layout = self.layout;
    CGFloat l_numberOfRows = [self.gridViewDataSource numberOfGridRows];
    UIEdgeInsets l_reservedEdgeSpace = UIEdgeInsetsZero;
    if ([self.gridViewDataSource respondsToSelector:@selector(reservedEdgeSpace)]) {
        l_reservedEdgeSpace = [self.gridViewDataSource reservedEdgeSpace];
    }

    CGFloat l_verticalSpace = self.view.frame.size.height;
    CGFloat l_verticalSpaceUnavailable = (l_layout.minimumLineSpacing * (l_numberOfRows - 1)) + l_reservedEdgeSpace.top + l_reservedEdgeSpace.bottom;
    CGFloat l_verticalSpaceAvailable = l_verticalSpace - l_verticalSpaceUnavailable;

//    NSLog(@"  l_verticalSpace: %f", l_verticalSpace);
//    NSLog(@"  l_verticalSpaceUnavailable: %f", l_verticalSpaceUnavailable);
//    NSLog(@"  l_verticalSpaceAvailable: %f", l_verticalSpaceAvailable);
    
    return l_verticalSpaceAvailable;
    
}

- (CGFloat)IFA_calculateCollectionItemHeightForIndexPath:(NSIndexPath *)a_indexPath{

    if ([self.gridViewDataSource respondsToSelector:@selector(itemWidthMultiplierForItemHeight)]) {
        CGFloat l_multiplier = [self.gridViewDataSource itemWidthMultiplierForItemHeight];
        if (l_multiplier) {
            // Item height is based on the item width
            return [self IFA_calculateCollectionItemWidthForIndexPath:a_indexPath] * l_multiplier;
        }
    }

    CGFloat l_numberOfRows = [self.gridViewDataSource numberOfGridRows];
    CGFloat l_verticalSpaceAvailable = [self IFA_calculateVerticalSpaceAvailable];
    CGFloat l_itemHeight = (CGFloat) floor(l_verticalSpaceAvailable / l_numberOfRows);

    if (a_indexPath) {

        CGFloat l_lastRowTileHeightAdjustment = 0;
        BOOL l_shouldAdjustLastRowHeight = NO;
        if ([self.gridViewDataSource respondsToSelector:@selector(shouldAdjustLastRowHeight)]) {
            l_shouldAdjustLastRowHeight = [self.gridViewDataSource shouldAdjustLastRowHeight];
        }
        if (l_shouldAdjustLastRowHeight) {
            if ([self isOnLastRowForItemAtIndex:a_indexPath]) {
                l_lastRowTileHeightAdjustment = l_verticalSpaceAvailable - l_itemHeight * l_numberOfRows;
            }
            l_itemHeight += l_lastRowTileHeightAdjustment;
//            NSLog(@"    l_isLastRow: %u", l_isLastRow);
        }
//        NSLog(@"    l_lastRowTileHeightAdjustment: %f", l_lastRowTileHeightAdjustment);

    }

    return l_itemHeight;
    
}

- (CGSize)IFA_calculateCollectionItemSizeForIndexPath:(NSIndexPath *)a_indexPath{
//    NSLog(@"IFA_calculateCollectionItemSizeForIndexPath: %@", [a_indexPath description]);
    CGFloat l_itemWidth = [self IFA_calculateCollectionItemWidthForIndexPath:a_indexPath];
    CGFloat l_itemHeight = [self IFA_calculateCollectionItemHeightForIndexPath:a_indexPath];
    CGSize l_collectionItemSize = CGSizeMake(l_itemWidth, l_itemHeight);
//    NSLog(@"  l_collectionItemSize: %@", NSStringFromCGSize(l_collectionItemSize));
    return l_collectionItemSize;
}

- (void)IFA_updateCollectionViewLayout {

    CGFloat l_interTileSpace = [self.gridViewDataSource interTileSpace];

    UICollectionViewFlowLayout *l_layout = self.layout;
    l_layout.minimumInteritemSpacing = l_interTileSpace;
    l_layout.minimumLineSpacing = l_interTileSpace;
    l_layout.scrollDirection = [self.gridViewDataSource scrollDirection];

    if ([self.gridViewDataSource respondsToSelector:@selector(sectionInset)]) {
        l_layout.sectionInset = [self.gridViewDataSource sectionInset];
    }

    if ([self.gridViewDataSource respondsToSelector:@selector(contentInset)]) {
        self.collectionView.contentInset = [self.gridViewDataSource contentInset];
    }

    if ([self.gridViewDelegate respondsToSelector:@selector(didUpdateCollectionViewFlowLayout:)]) {
        [self.gridViewDelegate didUpdateCollectionViewFlowLayout:l_layout];
    }

}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(IFA_onApplicationWillChangeStatusBarFrameNotification:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self IFA_doFirstLoadConfiguration];
    [self IFA_updateGridLayoutInCaseDeviceOrientationChangedWhileViewWasNotVisible];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self IFA_updateContentOffsetInCaseDeviceOrientationChangedWhileViewWasNotVisible];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.IFA_savedHorizontalPageIndex = [self.collectionView ifa_horizontalPageIndex];
    self.IFA_savedVerticalPageIndex = [self.collectionView ifa_verticalPageIndex];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.IFA_interfaceIsRotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (self.collectionView.pagingEnabled && self.shouldSupportPaging) {
        [self.collectionView ifa_updateContentOffsetForPagination];
    }
    [self IFA_updateCollectionViewLayout];
    // Need to reload data here because the item order might change if orientation changes
    [self.collectionView reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.IFA_interfaceIsRotating = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification
                                                  object:nil];
}

#pragma mark - Public

- (UICollectionViewFlowLayout *)layout {
    return (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
}
- (BOOL)isOnLastRowForItemAtIndex:(NSIndexPath *)a_indexPath {
    UICollectionViewFlowLayout *l_layout = self.layout;
    CGFloat l_numberOfColumns = [self.gridViewDataSource numberOfGridColumns];
    CGFloat l_numberOfRows = [self.gridViewDataSource numberOfGridRows];
    CGFloat l_numberOfTiles = l_numberOfColumns * l_numberOfRows;
    BOOL l_isLastRow;
    if (l_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        l_isLastRow = (((NSUInteger) a_indexPath.item + 1) % (NSUInteger) l_numberOfRows) == 0;
    } else {
        l_isLastRow = a_indexPath.item >= l_numberOfTiles - l_numberOfColumns;
    }
    return l_isLastRow;
}

- (BOOL)isOnLastColumnForItemAtIndexPath:(NSIndexPath *)a_indexPath {
    UICollectionViewFlowLayout *l_layout = self.layout;
    CGFloat l_numberOfColumns = [self.gridViewDataSource numberOfGridColumns];
    CGFloat l_numberOfRows = [self.gridViewDataSource numberOfGridRows];
    CGFloat l_numberOfTiles = l_numberOfColumns * l_numberOfRows;
    BOOL l_isLastColumn;
    if (l_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        l_isLastColumn = a_indexPath.item >= l_numberOfTiles - l_numberOfRows;
    } else {
        l_isLastColumn = (((NSUInteger) a_indexPath.item + 1) % (NSUInteger) l_numberOfColumns) == 0;
    }
    return l_isLastColumn;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self IFA_calculateCollectionItemSizeForIndexPath:indexPath];
}

@end