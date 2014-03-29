//
//  UITableView+IACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 20/01/12.
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

#import "UITableView+IACategory.h"

@implementation UITableView (IACategory)

#pragma mark - Public

-(void)m_deleteRowsAtIndexPaths:(NSArray *)indexPaths{
    [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
}

-(BOOL)m_isCellFullyVisibleForRowAtIndexPath:(NSIndexPath*)a_indexPath{

    BOOL l_fullyVisible = NO;

    UITableViewCell *l_cell;
    if ((l_cell=[self cellForRowAtIndexPath:a_indexPath])) {

        // Convert local coordinates to global coordinates
        CGRect l_cellViewRect = CGRectOffset(l_cell.frame, -self.contentOffset.x, -self.contentOffset.y);
        CGRect l_tableViewRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
//        NSLog(@"l_cellViewRect: %@", NSStringFromCGRect(l_cellViewRect));
//        NSLog(@"l_tableViewRect: %@", NSStringFromCGRect(l_tableViewRect));

        // Check if it's fully visible
        if ((l_fullyVisible = CGRectContainsRect(l_tableViewRect, l_cellViewRect))) {
            if ([self.delegate tableView:self viewForHeaderInSection:a_indexPath.section]) {
                CGRect l_sectionHeaderRect = [self rectForHeaderInSection:a_indexPath.section];
//                NSLog(@"  l_sectionHeaderRect: %@", NSStringFromCGRect(l_sectionHeaderRect));
                if ((l_fullyVisible = !CGRectIntersectsRect(l_cellViewRect, l_sectionHeaderRect))) {
                    if ([self.delegate tableView:self viewForFooterInSection:a_indexPath.section]) {
                        CGRect l_sectionFooterRect = [self rectForFooterInSection:a_indexPath.section];
//                        NSLog(@"  l_sectionFooterRect: %@", NSStringFromCGRect(l_sectionFooterRect));
                        l_fullyVisible = !CGRectIntersectsRect(l_cellViewRect, l_sectionFooterRect);
                    }
                }
            }
        }

    }
//    NSLog(@"l_fullyVisible: %u", l_fullyVisible);

    return l_fullyVisible;

}

@end
