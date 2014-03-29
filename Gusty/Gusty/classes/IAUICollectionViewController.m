//
//  IAUICollectionViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 20/12/12.
//  Copyright (c) 2012 InfoAccent Pty Limited. All rights reserved.
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

#import "IAUICollectionViewController.h"

@interface IAUICollectionViewController ()

@end

@implementation IAUICollectionViewController{
    
}

#pragma mark - Public

-(void)m_updateCollectionView:(UICollectionView*)a_collectionView oldDataArrayCount:(NSUInteger)a_oldDataArrayCount newDataArrayCount:(NSUInteger)a_newDataArrayCount{
    [self m_updateCollectionView:a_collectionView oldDataArrayCount:a_oldDataArrayCount newDataArrayCount:a_newDataArrayCount completionBlock:nil];
};

-(void)m_updateCollectionView:(UICollectionView*)a_collectionView oldDataArrayCount:(NSUInteger)a_oldDataArrayCount newDataArrayCount:(NSUInteger)a_newDataArrayCount completionBlock:(void (^)(BOOL finished))a_completionBlock{

    [self.collectionView performBatchUpdates:^{

        NSUInteger l_greatestCount = a_oldDataArrayCount > a_newDataArrayCount ? a_oldDataArrayCount : a_newDataArrayCount;
        for (int i=0; i<l_greatestCount; i++) {
            BOOL l_hasOld = i+1<=a_oldDataArrayCount;
            BOOL l_hasNew = i+1<=a_newDataArrayCount;
            if (l_hasOld && !l_hasNew) {
                [a_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            }else if (!l_hasOld && l_hasNew) {
                [a_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            }else if (l_hasOld && l_hasNew) {
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            }
        }

    } completion:a_completionBlock];

}

#pragma mark - Overrides

-(void)dealloc{
    [self m_dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return [self m_shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return [self m_supportedInterfaceOrientations];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self m_viewWillAppear];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self m_viewDidAppear];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self m_viewWillDisappear];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [self m_viewDidDisappear];
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self m_viewDidLoad];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    [self m_prepareForSegue:segue sender:sender];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self m_willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self m_willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self m_didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end
