//
//  IFAAppearanceThemeManager.h
//  Gusty
//
//  Created by Marcelo Schroeder on 1/08/12.
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

@protocol IFAAppearanceTheme;

@class IFAColorScheme;

@interface IFAAppearanceThemeManager : NSObject

@property (nonatomic, strong, readonly) id<IFAAppearanceTheme> loadedAppearanceTheme;
@property (nonatomic, strong, readonly) IFAColorScheme *loadedColorScheme;

- (void)reloadUiWithNoTransitionAnimation;

- (void)reloadUiWithAnimationOptions:(UIViewAnimationOptions)a_animationOptions;
- (void)reloadUiWithAnimationDuration:(NSTimeInterval)a_animationDuration
                     animationOptions:(UIViewAnimationOptions)a_animationOptions
                      completionBlock:(void (^)(BOOL finished))a_completionBlock;

//-(void)reloadUiWithTransitionAnimation:(SMUiReloadTransitionAnimation)a_transitionAnimation;
//-(void)reloadUiWithTransitionAnimation:(SMUiReloadTransitionAnimation)a_transitionAnimation completionBlock:(void (^)(BOOL finished))a_completionBlock;

// This returns the loaded appearance theme (i.e. loaded by this manager) if it has been loaded,
//  otherwise it returns the appearance theme set by the delegate (i.e. in the case this manager is not used)
-(id<IFAAppearanceTheme>)activeAppearanceTheme;

- (void)applyAppearanceTheme;

+ (IFAAppearanceThemeManager *)sharedInstance;
+(NSBundle*)bundleForThemeNamed:(NSString*)a_themeName;

@end
