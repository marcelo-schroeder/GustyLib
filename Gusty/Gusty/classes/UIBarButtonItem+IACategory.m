//
//  UIBarButtonItem+IACategory.m
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

static char c_buttonKey;

@interface UIBarButtonItem (IACategory_Private)

@property (nonatomic, strong) UIButton *p_button;

@end

@implementation UIBarButtonItem (IACategory)

#pragma mark - Private

-(void)setP_button:(UIColor*)a_button{
    objc_setAssociatedObject(self, &c_buttonKey, a_button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)m_onButtonAction{
    objc_msgSend(self.target, self.action, self);
}

#pragma mark - Public

-(UIColor*)p_button{
    return objc_getAssociatedObject(self, &c_buttonKey);
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
    self.p_button = [UIButton m_buttonWithType:UIButtonTypeCustom appearanceId:a_appearanceId];
    [self.p_button addTarget:self action:@selector(m_onButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.p_button.p_appearanceId = a_appearanceId;
    [self.p_button setImage:l_buttonImage forState:UIControlStateNormal];
    [self.p_button sizeToFit];
    self.p_button.adjustsImageWhenHighlighted = YES;

    // Create the bar button item
    if (self=[self initWithCustomView:self.p_button]) {
        self.target = a_target;
        self.action = a_action;
        // Style it
        [[[IAUIAppearanceThemeManager m_instance] m_activeAppearanceTheme] m_setAppearanceForBarButtonItem:self viewController:a_viewController important:NO];
    }

    return self;

}

@end
