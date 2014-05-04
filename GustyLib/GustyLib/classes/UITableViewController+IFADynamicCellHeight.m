//
// Created by Marcelo Schroeder on 6/04/2014.
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

#import "IFACommon.h"
#import "UITableViewController+IFADynamicCellHeight.h"

@interface UITableViewController (IADynamicCellHeight_Priate)
@property (nonatomic, strong) NSMutableDictionary *IFA_cachedCellHeights;
@end

@implementation UITableViewController (IFADynamicCellHeight)

static char c_dynamicCellHeightDelegateKey;
static char c_cachedHeightsKey;

#pragma mark - Public

-(void)setIFA_dynamicCellHeightDelegate:(id<IFATableViewControllerDynamicCellHeightDelegate>)a_dynamicCellHeightDelegate{
    objc_setAssociatedObject(self, &c_dynamicCellHeightDelegateKey, a_dynamicCellHeightDelegate, OBJC_ASSOCIATION_ASSIGN);
}

-(id<IFATableViewControllerDynamicCellHeightDelegate>)IFA_dynamicCellHeightDelegate {
    return objc_getAssociatedObject(self, &c_dynamicCellHeightDelegateKey);
}

-(NSMutableDictionary*)IFA_cachedCellHeights {
    NSMutableDictionary *l_obj = objc_getAssociatedObject(self, &c_cachedHeightsKey);
    if (!l_obj) {
        l_obj = [@{} mutableCopy];
        self.IFA_cachedCellHeights = l_obj;
    }
    return l_obj;
}

-(void)setIFA_cachedCellHeights:(NSMutableDictionary*)a_cachedHeights{
    objc_setAssociatedObject(self, &c_cachedHeightsKey, a_cachedHeights, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)IFA_heightForCellAtIndexPath:(NSIndexPath *)a_indexPath tableView:(UITableView *)a_tableView {

    if (!self.IFA_dynamicCellHeightDelegate) {
        return 0;
    }

    // Obtain prototype cell from delegate
    UITableViewCell *l_cell = [self.IFA_dynamicCellHeightDelegate IFA_prototypeCellForIndexPath:a_indexPath
                                                                                      tableView:a_tableView];

    // Ask delegate to populate prototype cell
    [self.IFA_dynamicCellHeightDelegate IFA_populateCell:l_cell atIndexPath:a_indexPath
                                               tableView:a_tableView];

    // Configure cell's content view for auto layout
    UIView *l_contentView = l_cell.contentView;
    l_contentView.translatesAutoresizingMaskIntoConstraints = NO;

    // Constraint the content view width for correct height calculation
    NSLayoutConstraint *l_contentViewWidthConstraint = nil;
    if ([self.IFA_dynamicCellHeightDelegate respondsToSelector:@selector(IFA_cellContentViewWidthForPrototypeCell:)]) {
        CGFloat l_contentViewWidthConstraintConstant = [self.IFA_dynamicCellHeightDelegate IFA_cellContentViewWidthForPrototypeCell:l_cell];
        l_contentViewWidthConstraint = [NSLayoutConstraint constraintWithItem:l_contentView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:(NSLayoutAttribute) nil
                                                                   multiplier:1
                                                                     constant:l_contentViewWidthConstraintConstant];
        [l_contentView addConstraint:l_contentViewWidthConstraint];
    }

    // Force layout to apply constraints - assume cell has already been populated with content
    [l_contentView setNeedsLayout];
    [l_contentView layoutIfNeeded];

    // Set preferred max layout width for multi-line labels
    [self IFA_setPreferredMaxLayoutWidthForMultiLineLabelsInCell:l_cell
                                            basedOnPrototypeCell:l_cell];

    // Calculate size
    CGSize l_size = [l_contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];

    // Calculate height
    CGFloat l_height = l_size.height + 1;   // Adds separator height

    // Clean up
    [l_contentView removeConstraint:l_contentViewWidthConstraint];

    // Cache height
    self.IFA_cachedCellHeights[a_indexPath] = @(l_height);

    return l_height;

}

- (void)IFA_setPreferredMaxLayoutWidthForMultiLineLabelsInCell:(UITableViewCell *)a_cell
                                          basedOnPrototypeCell:(UITableViewCell *)a_prototypeCell {
    if ([self.IFA_dynamicCellHeightDelegate respondsToSelector:@selector(IFA_multiLineLabelKeyPathsForCellWithReuseIdentifier:)]) {
        NSArray *l_multiLineLabelKeyPaths = [self.IFA_dynamicCellHeightDelegate IFA_multiLineLabelKeyPathsForCellWithReuseIdentifier:a_prototypeCell.reuseIdentifier];
        for (NSString *l_keyPath in l_multiLineLabelKeyPaths) {
            UILabel *l_label = [a_cell valueForKeyPath:l_keyPath];
            if ([l_label isKindOfClass:[UILabel class]]) {
                if (l_label.numberOfLines != 1) {
                    UILabel *l_prototypeLabel = [a_prototypeCell valueForKeyPath:l_keyPath];
                    l_label.preferredMaxLayoutWidth = l_prototypeLabel.frame.size.width;
                }
            }
        }
    }
}

@end