//
//  IFANavigationController.m
//  Gusty
//
//  Created by Marcelo Schroeder on 18/05/11.
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

@interface IFANavigationController ()
@end

@implementation IFANavigationController {
    
}

#pragma mark - Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ifa_viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self ifa_viewWillAppear];

    // Force iOS to re-calculate positioning of the title label.
    // This seems to be a bug in iOS when using non system fonts in title text attributes.
    if (self.navigationBar.titleTextAttributes || [UINavigationBar appearance].titleTextAttributes) {
        [self.navigationBar setNeedsLayout];
    }

}

-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    [self ifa_viewDidAppear];

}

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    [self ifa_viewWillDisappear];

}

-(void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    [self ifa_viewDidDisappear];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    [self ifa_prepareForSegue:segue sender:sender];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return [self ifa_shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(NSUInteger)supportedInterfaceOrientations{
    return [self ifa_supportedInterfaceOrientations];
}

-(BOOL)disablesAutomaticKeyboardDismissal{
    return self.visibleViewController.disablesAutomaticKeyboardDismissal;
}

-(void)dealloc{
    [self ifa_dealloc];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self ifa_willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self ifa_willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self ifa_didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self ifa_setEditing:editing animated:animated];
}

#pragma mark - IFAContextSwitchTarget

- (BOOL)contextSwitchRequestRequired {
    if ([self.topViewController conformsToProtocol:@protocol(IFAContextSwitchTarget)]) {
        return ((id <IFAContextSwitchTarget>) self.topViewController).contextSwitchRequestRequired;
    }else{
        return NO;
    }
}

@end
