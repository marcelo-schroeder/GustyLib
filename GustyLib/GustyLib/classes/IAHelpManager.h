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

-(NSArray*)m_helpTargets;
-(UINavigationBar*)m_helpModeToggleView;
-(UIView*)m_view;
@optional
-(void)m_willEnterHelpMode;
-(void)m_didEnterHelpMode;
-(void)m_willExitHelpMode;
-(void)m_didExitHelpMode;

@end

@protocol IAHelpTarget <NSObject>

@property (nonatomic, strong) NSString *p_helpTargetId;

@end

@interface IAHelpManager : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL p_helpEnabled;
@property (nonatomic, readonly) BOOL p_helpMode;
@property (nonatomic, weak) id<IAHelpTargetContainer> p_observedHelpTargetContainer;

-(void)m_observeHelpTargetContainer:(id<IAHelpTargetContainer>)a_helpTargetContainer;
- (void)m_helpRequestedForTabBarItemIndex:(NSUInteger)a_index helpTargetId:(NSString*)a_helpTargetId title:(NSString*)a_title;

-(void)m_addHelpTarget:(id<IAHelpTarget>)a_helpTarget;
-(void)m_removeHelpTarget:(id<IAHelpTarget>)a_helpTarget;

-(void)m_refreshHelpTargets;

-(void)m_removeHelpTargetSelectionWithAnimation:(BOOL)a_animate dismissPopTipView:(BOOL)a_dismissPopTipView;
-(void)m_resetUi;

-(void)m_toggleHelpMode;

-(UIBarButtonItem*)m_newHelpBarButtonItem;
-(BOOL)m_isHelpEnabledForViewController:(UIViewController*)a_viewController;

-(void)m_observedViewControllerDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
-(void)m_observedViewControllerWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

-(NSString*)m_accessibilityLabelForKeyPath:(NSString*)a_keyPath;

+ (IAHelpManager*)m_instance;
+ (NSString*)m_helpTargetIdForPropertyName:(NSString*)a_propertyName inObject:(NSObject*)a_object;

@end
