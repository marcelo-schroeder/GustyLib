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
    UIImage *helpButtonImage = [[IFAUIUtils class] ifa_classBundleImageNamed:helpButtonImageName];

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

-(BOOL)shouldEnableHelpForViewController:(UIViewController*)a_viewController {
    if ([a_viewController isKindOfClass:[IFAAbstractSelectionListViewController class]]) {
        return NO;
    }else{
        return [self helpForViewController:a_viewController] != nil;
    }
}

- (NSString *)helpForSectionNamed:(NSString *)a_sectionName inFormNamed:(NSString *)a_formName
                       createMode:(BOOL)a_createMode entityNamed:(NSString *)a_entityName {
    NSString *help = nil;
    if (a_createMode) {
        help = [self helpDescriptionFor:a_entityName formName:a_formName sectionName:a_sectionName createMode:YES];
    }
    if (!help) {
        help = [self helpDescriptionFor:a_entityName formName:a_formName sectionName:a_sectionName createMode:NO];
    }
    return help;
}

- (NSString *)helpForPropertyName:(NSString *)a_propertyName inEntityName:(NSString *)a_entityName
                            value:(NSString *)a_value {
    NSMutableString *helpTargetId = [NSMutableString stringWithFormat:@"entities.%@.properties.%@", a_entityName, a_propertyName];
    if (a_value) {
        [helpTargetId appendFormat:@".values.%@", a_value];
    }
    return [self IFA_helpDescriptionForHelpTargetId:helpTargetId];
}

- (NSString *)emptyListHelpForEntityName:(NSString *)a_entityName {
    NSString *helpTargetId = [NSString stringWithFormat:@"entities.%@.list.placeholder", a_entityName];
    return [self IFA_helpDescriptionForHelpTargetId:helpTargetId];
}

- (NSString *)helpForViewController:(UIViewController *)a_viewController {
    if ([a_viewController conformsToProtocol:@protocol(IFAHelpTarget)]) {
        id<IFAHelpTarget> helpTarget = (id <IFAHelpTarget>) a_viewController;
        return [self IFA_helpDescriptionForHelpTargetId:helpTarget.helpTargetId];
    }else{
        return nil;
    }
}

- (NSString *)helpTargetIdForEntityNamed:(NSString *)a_entityName {
    return [NSString stringWithFormat:@"entities.%@", a_entityName];
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
    NSString *l_string = NSLocalizedStringFromTable(a_keyPath, @"GustyLibHelpLocalizable", nil);
    return [l_string isEqualToString:a_keyPath] ? nil : l_string;
}

-(NSString*)IFA_helpDescriptionForHelpTargetId:(NSString*)a_helpTargetId {
    return [self IFA_helpStringForKeyPath:[NSString stringWithFormat:@"%@.description", a_helpTargetId]];
}

- (void)IFA_onHelpButtonTap:(UIButton *)a_button {
    [self toggleHelpModeForViewController:a_button.ifa_helpTargetViewController];
}

- (NSString *)helpDescriptionFor:(NSString *)a_entityName formName:(NSString *)a_formName
                     sectionName:(NSString *)a_sectionName createMode:(BOOL)a_createMode {
    NSObject *mode = a_createMode ? @"create" : @"any";
    NSString *helpTargetId = [NSString stringWithFormat:@"entities.%@.forms.%@.sections.%@.modes.%@", a_entityName,
                                                   a_formName, a_sectionName, mode];
    return [self IFA_helpDescriptionForHelpTargetId:helpTargetId];
}

@end
