//
//  IFAApplicationLogViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 6/05/11.
//  Copyright 2011 InfoAccent Pty Limited. All rights reserved.
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


@interface IFAApplicationLogViewController ()
@property(nonatomic, strong) UIBarButtonItem *IFA_deleteAllButton;
@property(nonatomic, strong) UIBarButtonItem *IFA_refreshButton;
@end

@implementation IFAApplicationLogViewController

#pragma mark -
#pragma mark Private

- (void)onAction:(id)a_sender{
    if (a_sender== self.IFA_deleteAllButton) {
        [[IFAPersistenceManager sharedInstance] deleteAllForEntityAndSave:self.entityName validationAlertPresenter:self];
    }
    [self refreshAndReloadData];
}

#pragma mark -
#pragma mark Overrides

-(id)init{
    return [super initWithEntityName:@"IFAApplicationLog"];
}

- (UITableViewCellStyle)tableViewCellStyle {
	return UITableViewCellStyleSubtitle;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *l_cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [[self ifa_appearanceTheme] setAppearanceForView:l_cell.detailTextLabel];
    IFAApplicationLog *l_logEntry = (IFAApplicationLog *) [self objectForIndexPath:indexPath];
    l_cell.detailTextLabel.text = l_logEntry.message;
    return l_cell;
}

- (NSArray*)ifa_nonEditModeToolbarItems {
    
    if (!self.IFA_deleteAllButton) {
        self.IFA_deleteAllButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onAction:)];
    }
    
    if (!self.IFA_refreshButton) {
        self.IFA_refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(onAction:)];
    }
	
	// Separator
	UIBarButtonItem *spaceBarButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeFlexibleSpace
                                                                    target:nil action:nil];
	
	return @[self.IFA_deleteAllButton, 
			spaceBarButtonItem,
            self.IFA_refreshButton];
	
}


@end
