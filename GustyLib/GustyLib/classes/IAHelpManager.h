//
//  IAHelpManager.h
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

#import <Foundation/Foundation.h>

@protocol IAHelpTargetContainer <NSObject>

-(NSArray*)helpTargets;
-(UINavigationBar*)helpModeToggleView;
-(UIView*)targetView;
@optional
-(void)willEnterHelpMode;
-(void)didEnterHelpMode;
-(void)willExitHelpMode;
-(void)didExitHelpMode;

@end

@protocol IAHelpTarget <NSObject>

@property (nonatomic, strong) NSString *helpTargetId;

@end

@interface IAHelpManager : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL helpEnabled;
@property (nonatomic, readonly) BOOL helpMode;
@property (nonatomic, weak) id<IAHelpTargetContainer> observedHelpTargetContainer;

-(void)observeHelpTargetContainer:(id<IAHelpTargetContainer>)a_helpTargetContainer;
- (void)helpRequestedForTabBarItemIndex:(NSUInteger)a_index helpTargetId:(NSString *)a_helpTargetId title:(NSString*)a_title;

-(void)addHelpTarget:(id<IAHelpTarget>)a_helpTarget;
-(void)removeHelpTarget:(id<IAHelpTarget>)a_helpTarget;

-(void)refreshHelpTargets;

-(void)removeHelpTargetSelectionWithAnimation:(BOOL)a_animate dismissPopTipView:(BOOL)a_dismissPopTipView;
-(void)resetUi;

-(void)toggleHelpMode;

-(UIBarButtonItem*)newHelpBarButtonItem;
-(BOOL)isHelpEnabledForViewController:(UIViewController*)a_viewController;

-(void)observedViewControllerDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
-(void)observedViewControllerWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

-(NSString*)accessibilityLabelForKeyPath:(NSString*)a_keyPath;

+ (IAHelpManager*)sharedInstance;
+ (NSString*)helpTargetIdForPropertyName:(NSString *)a_propertyName inObject:(NSObject*)a_object;

@end
