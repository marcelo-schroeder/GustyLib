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
        IFAHelpViewController *helpViewController = [[IFAHelpViewController alloc] initWithTargetViewController:a_viewController];
        [a_viewController presentViewController:helpViewController
                                             animated:YES completion:nil];
    }else{
        __weak __typeof(self) l_weakSelf = self;
        [a_viewController dismissViewControllerAnimated:YES completion:^{
            l_weakSelf.helpMode = NO;
            l_weakSelf.helpTargetViewController = nil;
        }];
    }

}

- (UIBarButtonItem *)newHelpBarButtonItemForViewController:(UIViewController *)a_viewController
                                                  selected:(BOOL)a_selected {
    
    // Configure image
    NSString *helpButtonImageName = [NSString stringWithFormat:@"IFA_Icon_Help_%@", a_selected?@"selected":@"normal"];
    UIImage *helpButtonImage = [UIImage imageNamed:helpButtonImageName];

    // Configure button
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    helpButton.ifa_helpTargetViewController = a_viewController;
    helpButton.tag = IFAViewTagHelpButton;
    helpButton.frame = CGRectMake(0, 0, helpButtonImage.size.width, 44);
    [helpButton setImage:helpButtonImage forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(IFA_onHelpButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    // Configure bar button item
    UIBarButtonItem *helpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:helpButton];
    helpBarButtonItem.tag = IFABarItemTagHelpButton;
    
    return helpBarButtonItem;
    
}

-(BOOL)isHelpEnabledForViewController:(UIViewController*)a_viewController{
    return [self helpForViewController:a_viewController]!=nil;
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

@end
