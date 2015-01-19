//
//  UITableView+IFACategory.m
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

#import "GustyLibCoreUI.h"

@implementation UITableView (IFACoreUI)

#pragma mark - Public

-(void)ifa_deleteRowsAtIndexPaths:(NSArray *)indexPaths {
    if (!indexPaths.count) {
        return;
    }
    NSInteger l_section = ((NSIndexPath *) indexPaths[0]).section;  // Assuming only 1 section
    BOOL l_isCellAnimationStopFractionMustBeGreaterThanStartFractionBugScenario = [self.delegate tableView:self
                                                                                    viewForFooterInSection:l_section] && self.contentOffset.y;
    if (l_isCellAnimationStopFractionMustBeGreaterThanStartFractionBugScenario) {
        //todo: has Apple fixed this bug? Once it has been resolved - clean up.
        // My workaround for this issue: http://stackoverflow.com/questions/11664766/cell-animation-stop-fraction-must-be-greater-than-start-fraction
        // In my case I would get the exception in this scenario:
        // - Table view with a section footer
        // - just enough rows to make it scroll when viewing the last row
        // - deleting that row
        // - I would then get the exception as the table view will attempt to scroll to the top so that all rows are now visible
        // The fix is just to reload the whole section (assumption here is that section footer is required - that is what causes the issue).
        [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(BOOL)ifa_isCellFullyVisibleForRowAtIndexPath:(NSIndexPath*)a_indexPath {

//    NSLog(@"ifa_isCellFullyVisibleForRowAtIndexPath: %@", [a_indexPath description]);

    UITableView *l_tableView = self;
    CGRect l_tableViewFrame = l_tableView.frame;
    CGPoint l_tableViewFrameOrigin = l_tableViewFrame.origin;
    CGSize l_tableViewFrameSize = l_tableViewFrame.size;
    UIEdgeInsets l_tableViewContentInset = l_tableView.contentInset;

    // Section header rect
    CGRect l_sectionHeaderRectLocal = [l_tableView rectForHeaderInSection:a_indexPath.section];

    // Section footer rect
    CGRect l_sectionFooterRectLocal = [l_tableView rectForFooterInSection:a_indexPath.section];

    // Table view rect - a given cell must be fully visible within this rect
    CGFloat l_tableViewRectLocalX = l_tableViewFrameOrigin.x + l_tableViewContentInset.left;
    CGFloat l_tableViewRectLocalY = l_tableViewFrameOrigin.y + l_tableViewContentInset.top;
    CGFloat l_tableViewRectLocalWidthOffset = - l_tableViewContentInset.left - l_tableViewContentInset.right;
    CGFloat l_tableViewRectLocalWidth = l_tableViewFrameSize.width + l_tableViewRectLocalWidthOffset;
    CGFloat l_tableViewRectLocalHeightOffset = - l_tableViewContentInset.top - l_tableViewContentInset.bottom;
    if (l_tableView.style==UITableViewStylePlain) {
        CGFloat l_sectionHeaderRectLocalHeight = l_sectionHeaderRectLocal.size.height;
        CGFloat l_sectionFooterRectLocalHeight = l_sectionFooterRectLocal.size.height;
        l_tableViewRectLocalY += l_sectionHeaderRectLocalHeight;
        l_tableViewRectLocalHeightOffset +=  - l_sectionHeaderRectLocalHeight - l_sectionFooterRectLocalHeight;
    }
    CGFloat l_tableViewRectLocalHeight = l_tableViewFrameSize.height + l_tableViewRectLocalHeightOffset;
    CGRect l_tableViewRectLocal = CGRectMake(l_tableViewRectLocalX, l_tableViewRectLocalY, l_tableViewRectLocalWidth, l_tableViewRectLocalHeight);
    CGRect l_tableViewRectGlobal = [l_tableView.superview convertRect:l_tableViewRectLocal toView:nil];

    // Cell rect
    CGRect l_cellViewRectLocal = [l_tableView rectForRowAtIndexPath:a_indexPath];
    CGRect l_cellViewRectGlobal = [l_tableView convertRect:l_cellViewRectLocal toView:nil];

    BOOL l_fullyVisible = CGRectContainsRect(l_tableViewRectGlobal, l_cellViewRectGlobal);

//    NSLog(@"  NSStringFromCGRect(l_tableViewRectLocal) = %@", NSStringFromCGRect(l_tableViewRectLocal));
//    NSLog(@"  NSStringFromCGRect(l_cellViewRectLocal) = %@", NSStringFromCGRect(l_cellViewRectLocal));
//    NSLog(@"  NSStringFromCGRect(l_sectionHeaderRectLocal) = %@", NSStringFromCGRect(l_sectionHeaderRectLocal));
//    NSLog(@"  NSStringFromCGRect(l_sectionFooterRectLocal) = %@", NSStringFromCGRect(l_sectionFooterRectLocal));
//    NSLog(@"  NSStringFromCGRect(l_tableViewRectGlobal) = %@", NSStringFromCGRect(l_tableViewRectGlobal));
//    NSLog(@"  NSStringFromCGRect(l_cellViewRectGlobal) = %@", NSStringFromCGRect(l_cellViewRectGlobal));
//    NSLog(@"  NSStringFromCGPoint(l_tableView.contentOffset) = %@", NSStringFromCGPoint(l_tableView.contentOffset));
//    NSLog(@"  l_fullyVisible: %u", l_fullyVisible);

    return l_fullyVisible;

}

@end
