//
//  IAUIAbstractSelectionViewController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 10/01/11.
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

#import "IACommon.h"

@interface IAUIAbstractSelectionListViewController ()
@property(nonatomic, strong, readwrite) NSManagedObject *p_managedObject;
@property(nonatomic, strong, readwrite) NSString *p_propertyName;
@end

@implementation IAUIAbstractSelectionListViewController

#pragma mark -
#pragma mark Public

- (id) initWithManagedObject:(NSManagedObject *)aManagedObject propertyName:(NSString *)aPropertyName{
	
    if ((self = [super initWithEntityName:[[IAPersistenceManager sharedInstance].entityConfig entityNameForProperty:aPropertyName inObject:aManagedObject]])) {
		
		self.p_managedObject = aManagedObject;
		self.p_propertyName = aPropertyName;
		
        if (![IAUIUtils isIPad]) {
            UIBarButtonItem *l_barButtonItem = [[self IFA_appearanceTheme] doneBarButtonItemWithTarget:self
                                                                                              action:@selector(onDoneButtonTap:)
                                                                                      viewController:self];
            [self IFA_addLeftBarButtonItem:l_barButtonItem];
        }
		
		self.p_selectNoneButtonItem = [IAUIUtils barButtonItemForType:IA_UIBAR_BUTTON_ITEM_SELECT_NONE target:self action:@selector(onSelectNoneButtonTap:)];
		
        NSString *l_propertyLabel = [[IAPersistenceManager sharedInstance].entityConfig labelForProperty:self.p_propertyName
                                                                                          inObject:self.p_managedObject];
        if (l_propertyLabel) {
            self.title = [NSString stringWithFormat:@"%@ Selection", l_propertyLabel];
        }
		
    }
	
	return self;
	
}

/* To be overriden by subclasses */

- (void)onSelectNoneButtonTap:(id)sender {
}

- (void)onDoneButtonTap:(id)sender{
    [self done];
}

- (void)done{
}

- (void) updateUiState{
}

#pragma mark -
#pragma mark Overrides

- (NSArray*)IFA_nonEditModeToolbarItems {
    if ([[IAPersistenceManager sharedInstance].entityConfig shouldShowSelectNoneButtonInSelectionForEntity:self.IFA_entityName]) {
        return @[self.p_selectNoneButtonItem];
    }else{
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self updateUiState];
}

-(void)willRefreshAndReloadDataAsync {

    [super willRefreshAndReloadDataAsync];
    
    // Disable user interaction while data is being refreshed asynchronously
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.p_selectNoneButtonItem.enabled = NO;

}

-(void)didRefreshAndReloadDataAsync {

    [super didRefreshAndReloadDataAsync];
    
    // Restore user interaction now that data has been refreshed asynchronously
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self updateUiState];

    [self.tableView flashScrollIndicators];
    
}

#pragma mark - UIPopoverControllerDelegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [self done];
}

@end
