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

#import "IFAGridViewController.h"
#import "UICollectionView+IFACategory.h"

@interface IFAGridViewController ()
@property(nonatomic) BOOL XYZ_firstLoadDone;
@property(nonatomic) BOOL XYZ_interfaceIsRotating;
@end

@implementation IFAGridViewController {

}

#pragma mark - Private

- (void)XYZ_updateGridLayoutInCaseDeviceOrientationChangedWhileViewWasNotVisible {
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];
    [self.collectionView reloadData];
}

- (void)XYZ_doFirstLoadConfiguration {
    if (!self.XYZ_firstLoadDone) {
        [self XYZ_updateCollectionViewLayout];
        self.XYZ_firstLoadDone = YES;
    }
}

- (void)XYZ_onApplicationWillChangeStatusBarFrameNotification:(NSNotification *)a_notification {
    if (!self.XYZ_interfaceIsRotating) {  // If interface is rotating then layout will be taken care of somewhere else
        // Force collection views re-layout
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

- (CGFloat)XYZ_calculateHorizontalSpaceAvailable {

    UICollectionViewFlowLayout *l_layout = self.layout;
    CGFloat l_numberOfColumns = [self.gridViewDataSource numberOfColumns];
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

- (CGFloat)XYZ_calculateCollectionItemWidthForIndexPath:(NSIndexPath *)a_indexPath{

    if ([self.gridViewDataSource respondsToSelector:@selector(itemHeightMultiplierForItemWidth)]) {
        CGFloat l_multiplier = [self.gridViewDataSource itemHeightMultiplierForItemWidth];
        if (l_multiplier) {
            // Item width is based on the item height
            return [self XYZ_calculateCollectionItemHeightForIndexPath:a_indexPath] * l_multiplier;
        }
    }

    UICollectionViewFlowLayout *l_layout = self.layout;
    CGFloat l_numberOfColumns = [self.gridViewDataSource numberOfColumns];
    CGFloat l_numberOfRows = [self.gridViewDataSource numberOfRows];
    CGFloat l_numberOfTiles = l_numberOfColumns * l_numberOfRows;
    CGFloat l_horizontalSpaceAvailable = [self XYZ_calculateHorizontalSpaceAvailable];
    CGFloat l_itemWidth = (CGFloat) floor(l_horizontalSpaceAvailable / l_numberOfColumns);

    if (a_indexPath) {

        CGFloat l_lastColumnTileWidthAdjustment = 0;
        BOOL l_shouldAdjustLastColumnWidth = NO;
        if ([self.gridViewDataSource respondsToSelector:@selector(shouldAdjustLastColumnWidth)]) {
            l_shouldAdjustLastColumnWidth = [self.gridViewDataSource shouldAdjustLastColumnWidth];
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
//            NSLog(@"    l_isLastColumn: %u", l_isLastColumn);
        }
//        NSLog(@"    l_lastColumnTileWidthAdjustment: %f", l_lastColumnTileWidthAdjustment);

    }
    
    return l_itemWidth;

}

- (CGFloat)XYZ_calculateVerticalSpaceAvailable {

    UICollectionViewFlowLayout *l_layout = self.layout;
    CGFloat l_numberOfRows = [self.gridViewDataSource numberOfRows];
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

- (CGFloat)XYZ_calculateCollectionItemHeightForIndexPath:(NSIndexPath *)a_indexPath{

    if ([self.gridViewDataSource respondsToSelector:@selector(itemWidthMultiplierForItemHeight)]) {
        CGFloat l_multiplier = [self.gridViewDataSource itemWidthMultiplierForItemHeight];
        if (l_multiplier) {
            // Item height is based on the item width
            return [self XYZ_calculateCollectionItemWidthForIndexPath:a_indexPath] * l_multiplier;
        }
    }

    UICollectionViewFlowLayout *l_layout = self.layout;
    CGFloat l_numberOfColumns = [self.gridViewDataSource numberOfColumns];
    CGFloat l_numberOfRows = [self.gridViewDataSource numberOfRows];
    CGFloat l_numberOfTiles = l_numberOfColumns * l_numberOfRows;
    CGFloat l_verticalSpaceAvailable = [self XYZ_calculateVerticalSpaceAvailable];
    CGFloat l_itemHeight = (CGFloat) floor(l_verticalSpaceAvailable / l_numberOfRows);

    if (a_indexPath) {

        CGFloat l_lastRowTileHeightAdjustment = 0;
        BOOL l_shouldAdjustLastRowHeight = NO;
        if ([self.gridViewDataSource respondsToSelector:@selector(shouldAdjustLastRowHeight)]) {
            l_shouldAdjustLastRowHeight = [self.gridViewDataSource shouldAdjustLastRowHeight];
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
//            NSLog(@"    l_isLastRow: %u", l_isLastRow);
        }
//        NSLog(@"    l_lastRowTileHeightAdjustment: %f", l_lastRowTileHeightAdjustment);

    }

    return l_itemHeight;
    
}

- (CGSize)XYZ_calculateCollectionItemSizeForIndexPath:(NSIndexPath *)a_indexPath{
//    NSLog(@"XYZ_calculateCollectionItemSizeForIndexPath: %@", [a_indexPath description]);
    CGFloat l_itemWidth = [self XYZ_calculateCollectionItemWidthForIndexPath:a_indexPath];
    CGFloat l_itemHeight = [self XYZ_calculateCollectionItemHeightForIndexPath:a_indexPath];
    CGSize l_collectionItemSize = CGSizeMake(l_itemWidth, l_itemHeight);
//    NSLog(@"  l_collectionItemSize: %@", NSStringFromCGSize(l_collectionItemSize));
    return l_collectionItemSize;
}

- (void)XYZ_updateCollectionViewLayout {

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
                                             selector:@selector(XYZ_onApplicationWillChangeStatusBarFrameNotification:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self XYZ_doFirstLoadConfiguration];
    [self XYZ_updateGridLayoutInCaseDeviceOrientationChangedWhileViewWasNotVisible];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.XYZ_interfaceIsRotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView ifa_updateContentOffsetForPagination];
    [self XYZ_updateCollectionViewLayout];
    // Need to reload data here because the item order might change if orientation changes
    [self.collectionView reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.XYZ_interfaceIsRotating = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification
                                                  object:nil];
}

#pragma mark - Public

- (UICollectionViewFlowLayout *)layout {
    return (UICollectionViewFlowLayout *) self.collectionView.collectionViewLayout;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self XYZ_calculateCollectionItemSizeForIndexPath:indexPath];
}

@end