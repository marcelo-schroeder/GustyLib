//
//  IAUICollectionViewFetchedResultsControllerDelegate.h
//  Gusty
//
//  Created by Marcelo Schroeder on 15/03/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAUICollectionViewFetchedResultsControllerDelegate : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UICollectionView *p_collectionView;

-(id)initWithCollectionView:(UICollectionView*)a_collectionView;

@end
