//
//  IFAHelpManager.h
//  GustyLib
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

typedef enum {
    IFAFormHelpTypeHeader,
    IFAFormHelpTypeFooter,
}IFAFormHelpType;

typedef enum {
    IFAFormSectionHelpTypeHeader,
    IFAFormSectionHelpTypeFooter,
}IFAFormSectionHelpType;

@protocol IFAHelpTargetContainer <NSObject>

-(NSArray*)helpTargets;
-(UIView *)helpModeToggleView;
-(UIView*)targetView;
@optional
-(void)willEnterHelpMode;
-(void)didEnterHelpMode;
-(void)willExitHelpMode;
-(void)didExitHelpMode;

@end

@protocol IFAHelpTarget <NSObject>

@property (nonatomic, strong) NSString *helpTargetId;

@end

@interface IFAHelpManager : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic) BOOL helpEnabled;
@property (nonatomic, readonly) BOOL helpMode;
@property (nonatomic, weak) id<IFAHelpTargetContainer> observedHelpTargetContainer;

-(void)observeHelpTargetContainer:(id<IFAHelpTargetContainer>)a_helpTargetContainer;
- (void)helpRequestedForTabBarItemIndex:(NSUInteger)a_index helpTargetId:(NSString *)a_helpTargetId title:(NSString*)a_title;

-(void)addHelpTarget:(id<IFAHelpTarget>)a_helpTarget;
-(void)removeHelpTarget:(id<IFAHelpTarget>)a_helpTarget;

-(void)refreshHelpTargets;

-(void)removeHelpTargetSelectionWithAnimation:(BOOL)a_animate dismissPopTipView:(BOOL)a_dismissPopTipView;
-(void)resetUi;

-(void)toggleHelpMode;

-(UIBarButtonItem*)newHelpBarButtonItem;
-(BOOL)isHelpEnabledForViewController:(UIViewController*)a_viewController;

-(void)observedViewControllerDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
-(void)observedViewControllerWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

-(NSString*)accessibilityLabelForKeyPath:(NSString*)a_keyPath;

/**
* @returns Form section help text.
*/
- (NSString *)formSectionHelpForType:(IFAFormSectionHelpType)a_helpType
                          entityName:(NSString *)a_entityName
                            formName:(NSString *)a_formName
                         sectionName:(NSString *)a_sectionName;

//wip: do I still need this? Have I encountered any cases of help at the form level?
- (NSString *)formHelpForType:(IFAFormHelpType)a_helpType
                   entityName:(NSString *)a_entityName
                     formName:(NSString *)a_formName;

+ (IFAHelpManager *)sharedInstance;
+ (NSString*)helpTargetIdForPropertyName:(NSString *)a_propertyName inObject:(NSObject*)a_object;

@end
