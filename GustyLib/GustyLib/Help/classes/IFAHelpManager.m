//
//  IFAHelpManager.m
//  Gusty
//
//  Created by Marcelo Schroeder on 22/03/12.
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

//wip: review help button - it should be a simple bar button item if possible
//wip: clean up
#import "GustyLibHelp.h"

@interface IFAHelpManager ()

@property (nonatomic) BOOL helpMode;
@property(nonatomic, strong) UIViewController *helpTargetViewController;
@end

@implementation IFAHelpManager

#pragma mark - Public

-(void)toggleHelpModeForViewController:(UIViewController *)a_viewController {

    self.helpMode =!self.helpMode;

    if (self.helpMode) {
        self.helpTargetViewController = a_viewController;
        IFAHelpNavigationController *helpNavigationController = [[IFAHelpNavigationController alloc] initWithTargetViewController:a_viewController];
        helpNavigationController.ifa_presenter = self;
        [a_viewController presentViewController:helpNavigationController
                                             animated:YES completion:nil];
    }else{
        __weak __typeof(self) l_weakSelf = self;
        [a_viewController dismissViewControllerAnimated:YES completion:^{
            [l_weakSelf IFA_quitHelpMode];
        }];
    }

}

-(UIBarButtonItem*)newHelpBarButtonItemForViewController:(UIViewController *)a_viewController {
    
    // Configure image
    UIImage *l_helpButtonImage = [UIImage imageNamed:@"IFA_Icon_Help"];

    // Configure button
    UIButton *l_helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    l_helpButton.ifa_helpTargetViewController = a_viewController;
    l_helpButton.tag = IFAViewTagHelpButton;
    l_helpButton.frame = CGRectMake(0, 0, l_helpButtonImage.size.width, 44);
    [l_helpButton setImage:l_helpButtonImage forState:UIControlStateNormal];
    [l_helpButton addTarget:self action:@selector(IFA_onHelpButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    // Configure bar button item
    UIBarButtonItem *l_helpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:l_helpButton];
    l_helpBarButtonItem.tag = IFABarItemTagHelpButton;
    
    return l_helpBarButtonItem;
    
}

-(BOOL)isHelpEnabledForViewController:(UIViewController*)a_viewController{
    NSArray *l_helpEnabledViewControllerClassNames = [IFAUtils infoPList][@"IFAHelpEnabledViewControllers"];
    return [l_helpEnabledViewControllerClassNames containsObject:[a_viewController.class description]];
}

- (NSString *)formSectionHelpForType:(IFAFormSectionHelpType)a_helpType entityName:(NSString *)a_entityName
                            formName:(NSString *)a_formName sectionName:(NSString *)a_sectionName
                          createMode:(BOOL)a_createMode {
    NSString *helpTypePath;
    switch (a_helpType) {
        case IFAFormSectionHelpTypeHeader:
            helpTypePath = @"header";
            break;
        case IFAFormSectionHelpTypeFooter:
            helpTypePath = @"footer";
            break;
    }
    NSString *help = nil;
    if (a_createMode) {
        help = [self helpDescriptionFor:a_entityName formName:a_formName sectionName:a_sectionName
                           helpTypePath:helpTypePath
                             createMode:YES];
    }
    if (!help) {
        help = [self helpDescriptionFor:a_entityName formName:a_formName sectionName:a_sectionName
                           helpTypePath:helpTypePath
                             createMode:NO];
    }
    return help;
}

- (NSString *)helpForPropertyName:(NSString *)a_propertyName inEntityName:(NSString *)a_entityName {
    NSString *keyPath = [NSString stringWithFormat:@"entities.%@.properties.%@", a_entityName, a_propertyName];
    return [self IFA_helpDescriptionForKeyPath:keyPath];
}

- (NSString *)emptyListHelpForEntityName:(NSString *)a_entityName {
    NSString *keyPath = [NSString stringWithFormat:@"entities.%@.list.placeholder", a_entityName];
    return [self IFA_helpDescriptionForKeyPath:keyPath];
}


- (NSString *)formHelpForType:(IFAFormHelpType)a_helpType entityName:(NSString *)a_entityName
                     formName:(NSString *)a_formName {
    NSString *helpTypePath;
    switch (a_helpType){
        case IFAFormHelpTypeHeader:
            helpTypePath = @"header";
            break;
        case IFAFormHelpTypeFooter:
            helpTypePath = @"footer";
            break;
    }
    NSString *keyPath = [NSString stringWithFormat:@"entities.%@.forms.%@.%@", a_entityName,
                                                   a_formName, helpTypePath];
    return [self IFA_helpDescriptionForKeyPath:keyPath];
}

- (NSString *)helpForViewController:(UIViewController *)a_viewController {
    NSString *entityName = nil;
    if ([a_viewController isKindOfClass:[IFAListViewController class]]) {
        entityName = ((IFAListViewController *) a_viewController).entityName;
    }else if ([a_viewController isKindOfClass:[IFAFormViewController class]]) {
        entityName = ((IFAFormViewController *) a_viewController).object.ifa_entityName;
    }
    NSString *keyPath = [NSString stringWithFormat:@"entities.%@", entityName];
    return [self IFA_helpDescriptionForKeyPath:keyPath];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static id c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

#pragma mark -

- (void)sessionDidCompleteForViewController:(UIViewController *)a_viewController changesMade:(BOOL)a_changesMade
                                       data:(id)a_data shouldAnimateDismissal:(BOOL)a_shouldAnimateDismissal {
    [self IFA_quitHelpMode];
}

#pragma mark - Private

-(NSString*)IFA_helpStringForKeyPath:(NSString*)a_keyPath{
    NSString *l_string = [[NSBundle mainBundle] localizedStringForKey:a_keyPath value:nil table:@"Help"];
//    NSLog(@"IFA_helpStringForKeyPath");
//    NSLog(@"  a_keyPath = %@", a_keyPath);
//    NSLog(@"  l_string = %@", l_string);
    return [l_string isEqualToString:a_keyPath] ? nil : l_string;
}

-(NSString*)IFA_helpLabelForKeyPath:(NSString*)a_keyPath{
    return [self IFA_helpStringForKeyPath:[NSString stringWithFormat:@"%@.label", a_keyPath]];
}

-(NSString*)IFA_helpTitleForKeyPath:(NSString*)a_keyPath{
    return [self IFA_helpStringForKeyPath:[NSString stringWithFormat:@"%@.title", a_keyPath]];
}

-(NSString*)IFA_helpDescriptionForKeyPath:(NSString*)a_keyPath{
    return [self IFA_helpStringForKeyPath:[NSString stringWithFormat:@"%@.description", a_keyPath]];
}

//wip: clean up code below big time
- (void)IFA_onHelpButtonTap:(UIButton *)a_button {
    [self toggleHelpModeForViewController:a_button.ifa_helpTargetViewController];
}

- (NSString *)helpDescriptionFor:(NSString *)a_entityName formName:(NSString *)a_formName
                     sectionName:(NSString *)a_sectionName helpTypePath:(NSString *)a_helpTypePath
                      createMode:(BOOL)a_createMode {
    NSObject *mode = a_createMode ? @"create" : @"any";
    NSString *keyPath = [NSString stringWithFormat:@"entities.%@.forms.%@.sections.%@.%@.modes.%@", a_entityName,
                                                   a_formName, a_sectionName, a_helpTypePath, mode];
    return [self IFA_helpDescriptionForKeyPath:keyPath];
}

- (void)IFA_quitHelpMode {
    [self.helpTargetViewController dismissViewControllerAnimated:YES completion:^{
        self.helpMode = NO;
        self.helpTargetViewController = nil;
    }];
}

@end
