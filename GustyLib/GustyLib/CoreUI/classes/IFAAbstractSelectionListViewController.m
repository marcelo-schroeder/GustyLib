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

#import "GustyLibCoreUI.h"

@interface IFAAbstractSelectionListViewController ()
@property(nonatomic, weak) NSManagedObject *managedObject;
@property(nonatomic, strong) NSString *propertyName;
@property(nonatomic, weak) IFAFormViewController *formViewController;
@end

@implementation IFAAbstractSelectionListViewController

#pragma mark -
#pragma mark Public

- (id)initWithManagedObject:(NSManagedObject *)a_managedObject propertyName:(NSString *)a_propertyName
         formViewController:(IFAFormViewController *)a_formViewController {
	
    if ((self = [super initWithEntityName:[[IFAPersistenceManager sharedInstance].entityConfig entityNameForProperty:a_propertyName
                                                                                                            inObject:a_managedObject]])) {
		
		self.managedObject = a_managedObject;
		self.propertyName = a_propertyName;
        self.formViewController = a_formViewController;

        self.fetchingStrategy = IFAListViewControllerFetchingStrategyFindEntities;
		
//        if (![IFAUIUtils isIPad]) {
//            UIBarButtonItem *l_barButtonItem = [[self ifa_appearanceTheme] doneBarButtonItemWithTarget:self
//                                                                                              action:@selector(onDoneButtonTap:)
//                                                                                      viewController:self];
//            [self ifa_addLeftBarButtonItem:l_barButtonItem];
//        }

		self.selectNoneButtonItem = [IFAUIUtils barButtonItemForType:IFABarButtonItemTypeSelectNone target:self
                                                              action:@selector(onSelectNoneButtonTap:)];
		
        NSString *l_propertyLabel = [[IFAPersistenceManager sharedInstance].entityConfig labelForProperty:self.propertyName
                                                                                                inObject:self.managedObject];
        if (l_propertyLabel) {
            self.title = l_propertyLabel;
        }
		
    }
	
	return self;
	
}

/* To be overriden by subclasses */

- (void)onSelectNoneButtonTap:(id)sender {
}

//- (void)onDoneButtonTap:(id)sender{
//    [self done];
//}

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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    BOOL l_hasBeenPoppedByNavigationController = self.isMovingFromParentViewController;
    if (l_hasBeenPoppedByNavigationController) {
        [self done];
    }
}

-(void)willRefreshAndReloadData {

    [super willRefreshAndReloadData];

    if (self.asynchronousFetch) {
        // Disable user interaction while data is being refreshed asynchronously
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.selectNoneButtonItem.enabled = NO;
    }


}

-(void)didRefreshAndReloadData {

    [super didRefreshAndReloadData];
    
    // Restore user interaction now that data has been refreshed asynchronously
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self updateUiState];

    [self.tableView flashScrollIndicators];
    
}

- (BOOL)contextSwitchRequestRequired {
    return self.formViewController!=nil;
}

- (void)onContextSwitchRequestNotification:(NSNotification *)aNotification {
    [self.formViewController onContextSwitchRequestNotification:aNotification];
}

#pragma mark - UIPopoverControllerDelegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [self done];
}

@end
