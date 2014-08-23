//
// Created by Marcelo Schroeder on 20/06/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import <objc/runtime.h>
#import "UIViewController+IFAHelp.h"
#import "IFAAbstractPagingContainerViewController.h"
#import "IFADynamicPagingContainerViewController.h"
#import "IFAUIUtils.h"
#import "UIViewController+IFACategory.h"
#import "UIBarItem+IFAHelp.h"

static char c_helpTargetIdKey;
static char c_helpBarButtonItemKey;

@implementation UIViewController (IFAHelp)

#pragma mark - Public

-(UIBarButtonItem*)IFA_helpBarButtonItem {
    return objc_getAssociatedObject(self, &c_helpBarButtonItemKey);
}

-(void)setIFA_helpBarButtonItem:(UIBarButtonItem*)a_helpBarButtonItem{
    objc_setAssociatedObject(self, &c_helpBarButtonItemKey, a_helpBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)ifa_helpTargetIdForName:(NSString*)a_name{
    return [NSString stringWithFormat:@"controllers.%@.%@", [[self class] description], a_name];
}

//-(void)m_updateEditButtonItemAccessibilityLabel{
//    [self IFA_editBarButtonItem].accessibilityLabel = self.editing ? @"Done Button" : @"Edit Button";
//}

-(BOOL)ifa_helpMode {
    return [IFAHelpManager sharedInstance].helpMode;
}

-(void)ifa_registerForHelp {
    if (![self.parentViewController isKindOfClass:[IFAAbstractPagingContainerViewController class]]) {
        UIViewController *l_helpTargetViewController = [[IFAHelpManager sharedInstance] isHelpEnabledForViewController:self] ? self : nil;
        [[IFAHelpManager sharedInstance] observeHelpTargetContainer:l_helpTargetViewController];
    }
}

-(NSString*)ifa_editBarButtonItemHelpTargetId {
    NSString *l_helpTargetId = nil;
    if (self.editing) {
        BOOL l_doneButtonSaves = self.ifa_doneButtonSaves;
        if ([self isKindOfClass:[IFADynamicPagingContainerViewController class]]) {
            IFADynamicPagingContainerViewController *l_pagingContainerViewController = (IFADynamicPagingContainerViewController *)self;
            l_doneButtonSaves = [l_pagingContainerViewController visibleChildViewController].ifa_doneButtonSaves;
        }
        if (l_doneButtonSaves) {
            l_helpTargetId = [IFAUIUtils helpTargetIdForName:@"saveButton"];
        }else{
            l_helpTargetId = [IFAUIUtils helpTargetIdForName:@"doneButton"];
        }
    }else{
        l_helpTargetId = [IFAUIUtils helpTargetIdForName:@"editButton"];
    }
    return l_helpTargetId;
}

-(NSString*)ifa_accessibilityLabelForKeyPath:(NSString*)a_keyPath{
    return [[IFAHelpManager sharedInstance] accessibilityLabelForKeyPath:a_keyPath];
}

-(NSString*)ifa_accessibilityLabelForName:(NSString*)a_name{
    return [self ifa_accessibilityLabelForKeyPath:[self ifa_helpTargetIdForName:a_name]];
}

#pragma mark - IFAHelpTarget protocol

-(NSString*)helpTargetId {
    return objc_getAssociatedObject(self, &c_helpTargetIdKey);
}

-(void)setHelpTargetId:(NSString*)a_helpTargetId{
    objc_setAssociatedObject(self, &c_helpTargetIdKey, a_helpTargetId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - IFAHelpTargetContainer

-(NSArray*)helpTargets {

    NSMutableArray *l_helpTargets = [NSMutableArray new];

    // Navigation bar
    if (self.navigationController.navigationBar) {
//        NSLog(@"navigationBar: %@", [l_helpTarget description]);
        [l_helpTargets addObject:self.navigationController.navigationBar];
    }
//    NSLog(@"Processing left bar button items in %@...", [self description]);
    for (UIBarButtonItem *l_barButtonItem in self.navigationItem.leftBarButtonItems) {
//        NSLog(@"l_barButtonItem: %@, helpTargetId: %@, title: %@", [l_barButtonItem description], l_barButtonItem.helpTargetId, l_barButtonItem.title);
        [l_helpTargets addObject:l_barButtonItem];
    }
//    NSLog(@"Processing right bar button items in %@...", [self description]);
    for (UIBarButtonItem *l_barButtonItem in self.navigationItem.rightBarButtonItems) {
//        NSLog(@" l_barButtonItem: %@", [l_barButtonItem description]);
        if (l_barButtonItem.tag== IFABarItemTagHelpButton) {
//            NSLog(@" help button ignored");
            continue;
        }
//        NSLog(@" IFA_editBarButtonItem: %@", [[self m_editBarButtonItem] description]);
        if (l_barButtonItem== [self IFA_editBarButtonItem]) {
            l_barButtonItem.helpTargetId = [self ifa_editBarButtonItemHelpTargetId];
        }
        [l_helpTargets addObject:l_barButtonItem];
    }

    // Tool bar
    for (UIBarButtonItem *l_barButtonItem in self.navigationController.toolbar.items) {
        [l_helpTargets addObject:l_barButtonItem];
    }

    // Tab bar
    if (self.tabBarController.tabBar) {
        [l_helpTargets addObject:self.tabBarController.tabBar];
    }

    return l_helpTargets;

}

-(UIView *)helpModeToggleView {
    return self.navigationController.navigationBar;
}

-(UIView*)targetView {
    return [self ifa_mainViewController].view;
}

-(void)willEnterHelpMode {
    // does nothing
}

-(void)didEnterHelpMode {
    // does nothing
}

-(void)willExitHelpMode {
    // does nothing
}

-(void)didExitHelpMode {
    // does nothing
}

#pragma mark - Private

-(UIBarButtonItem*)IFA_editBarButtonItem {
    if ([self isKindOfClass:[IFADynamicPagingContainerViewController class]]) {
        IFADynamicPagingContainerViewController *l_containerViewController = (IFADynamicPagingContainerViewController *)self;
        return [l_containerViewController visibleChildViewController].editButtonItem;
    }else{
        return self.editButtonItem;
    }
}

@end