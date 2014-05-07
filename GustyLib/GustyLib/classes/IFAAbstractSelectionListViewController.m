//
//  IFAAbstractSelectionListViewController.m
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

#import "IFACommon.h"

@interface IFAAbstractSelectionListViewController ()
@property(nonatomic, strong, readwrite) NSManagedObject *managedObject;
@property(nonatomic, strong, readwrite) NSString *propertyName;
@end

@implementation IFAAbstractSelectionListViewController

#pragma mark -
#pragma mark Public

- (id) initWithManagedObject:(NSManagedObject *)aManagedObject propertyName:(NSString *)aPropertyName{
	
    if ((self = [super initWithEntityName:[[IFAPersistenceManager sharedInstance].entityConfig entityNameForProperty:aPropertyName inObject:aManagedObject]])) {
		
		self.managedObject = aManagedObject;
		self.propertyName = aPropertyName;
		
        if (![IFAUIUtils isIPad]) {
            UIBarButtonItem *l_barButtonItem = [[self ifa_appearanceTheme] doneBarButtonItemWithTarget:self
                                                                                              action:@selector(onDoneButtonTap:)
                                                                                      viewController:self];
            [self ifa_addLeftBarButtonItem:l_barButtonItem];
        }
		
		self.selectNoneButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemSelectNone target:self
                                                              action:@selector(onSelectNoneButtonTap:)];
		
        NSString *l_propertyLabel = [[IFAPersistenceManager sharedInstance].entityConfig labelForProperty:self.propertyName
                                                                                                inObject:self.managedObject];
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

- (NSArray*)ifa_nonEditModeToolbarItems {
    if ([[IFAPersistenceManager sharedInstance].entityConfig shouldShowSelectNoneButtonInSelectionForEntity:self.entityName]) {
        return @[self.selectNoneButtonItem];
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
    self.selectNoneButtonItem.enabled = NO;

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
