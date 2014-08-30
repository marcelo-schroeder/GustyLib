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

#import "GustyLibCore.h"

@implementation UITableView (IFACategory)

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

    BOOL l_fullyVisible = NO;

    UITableViewCell *l_cell;
    if ((l_cell = [self cellForRowAtIndexPath:a_indexPath])) {

        // Convert local coordinates to global coordinates
        CGRect l_cellViewRect = CGRectOffset(l_cell.frame, -self.contentOffset.x, -self.contentOffset.y);
        IFAApplicationDelegate *l_appDelegate = (IFAApplicationDelegate *) [UIApplication sharedApplication].delegate;
        CGFloat l_heightOffset = l_appDelegate.keyboardVisible ? -self.contentInset.bottom : 0;
        CGRect l_tableViewVisibleRect = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height + l_heightOffset);
//        NSLog(@"          l_cellViewRect: %@", NSStringFromCGRect(l_cellViewRect));
//        NSLog(@"             self.bounds: %@", NSStringFromCGRect(self.bounds));
//        NSLog(@"       self.contentInset: %@", NSStringFromUIEdgeInsets(self.contentInset));
//        NSLog(@"          l_heightOffset: %f", l_heightOffset);
//        NSLog(@"  l_tableViewVisibleRect: %@", NSStringFromCGRect(l_tableViewVisibleRect));

        // Check if it's fully visible
        if ((l_fullyVisible = CGRectContainsRect(l_tableViewVisibleRect, l_cellViewRect))) {
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
//    NSLog(@"  l_fullyVisible: %u", l_fullyVisible);

    return l_fullyVisible;

}

@end
