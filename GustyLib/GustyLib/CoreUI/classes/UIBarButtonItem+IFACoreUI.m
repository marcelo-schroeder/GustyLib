//
//  UIBarButtonItem+IFACategory.m
//  Gusty
//
//  Created by Marcelo Schroeder on 28/01/13.
//  Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
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

static char c_buttonKey;
static char c_typeKey;

@interface UIBarButtonItem (IFACategory_Private)

@property (nonatomic, strong) UIButton *ifa_button;

@end

@implementation UIBarButtonItem (IFACoreUI)

#pragma mark - Private

-(void)setIfa_button:(UIButton*)a_button{
    objc_setAssociatedObject(self, &c_buttonKey, a_button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setIfa_type:(IFABarButtonItemType)a_type{
    objc_setAssociatedObject(self, &c_typeKey, @(a_type), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)IFA_onButtonAction {
    objc_msgSend(self.target, self.action, self);
}

#pragma mark - Public

-(UIButton*)ifa_button {
    return objc_getAssociatedObject(self, &c_buttonKey);
}

-(IFABarButtonItemType)ifa_type {
    return (IFABarButtonItemType) ((NSNumber *) objc_getAssociatedObject(self, &c_typeKey)).unsignedIntegerValue;
}

-(id)initWithImageName:(NSString*)a_imageName target:(id)a_target action:(SEL)a_action{
    return [self initWithImageName:a_imageName target:a_target action:a_action appearanceId:nil viewController:nil];
}

- (id)initWithImageName:(NSString *)a_imageName
                 target:(id)a_target
                 action:(SEL)a_action
           appearanceId:(NSString *)a_appearanceId
         viewController:(UIViewController *)a_viewController {

    // Create the underlying button
    UIImage *l_buttonImage = [UIImage imageNamed:a_imageName];
    self.ifa_button = [UIButton ifa_buttonWithType:UIButtonTypeCustom appearanceId:a_appearanceId];
    [self.ifa_button addTarget:self action:@selector(IFA_onButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.ifa_button.ifa_appearanceId = a_appearanceId;
    [self.ifa_button setImage:l_buttonImage forState:UIControlStateNormal];
    [self.ifa_button sizeToFit];
    self.ifa_button.adjustsImageWhenHighlighted = YES;

    // Create the bar button item
    if (self= [self initWithCustomView:self.ifa_button]) {
        self.target = a_target;
        self.action = a_action;
        // Style it
        [[[IFAAppearanceThemeManager sharedInstance] activeAppearanceTheme] setAppearanceForBarButtonItem:self
                                                                                          viewController:a_viewController
                                                                                               important:NO];
    }

    return self;

}

@end
