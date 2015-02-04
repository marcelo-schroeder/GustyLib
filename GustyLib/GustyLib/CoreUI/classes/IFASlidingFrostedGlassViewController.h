//
// Created by Marcelo Schroeder on 10/04/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
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
#import "IFAViewController.h"

@protocol IFASlidingFrostedGlassViewControllerDelegate;

typedef NS_ENUM(NSUInteger, IFASlidingFrostedGlassViewControllerBlurEffect){
    IFASlidingFrostedGlassViewControllerBlurEffectLight,
    IFASlidingFrostedGlassViewControllerBlurEffectExtraLight,
    IFASlidingFrostedGlassViewControllerBlurEffectDark,
};

typedef UIImage *(^IFASlidingFrostedGlassViewControllerSnapshotEffectBlock)(UIImage *);

@interface IFASlidingFrostedGlassViewController : IFAViewController <UIViewControllerTransitioningDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) id<IFASlidingFrostedGlassViewControllerDelegate> delegate;
@property(nonatomic, strong, readonly) UIImageView *frostedGlassImageView;

/**
* Defines the type of blur effect to be applied on the frosted glass.
* Default: IFASlidingFrostedGlassViewControllerBlurEffectLight.
* It is overridden by setting the blurEffectTintColor property or the snapshotEffectBlock property.
*/
@property (nonatomic) IFASlidingFrostedGlassViewControllerBlurEffect blurEffect;

/**
* Defines the tint colour of the blur effect to be applied on the frosted glass.
* Default: nil.
* If set, it takes precedence over the blurEffect property.
* It is overridden by setting the snapshotEffectBlock property.
*/
@property (nonatomic, strong) UIColor *blurEffectTintColor;

/**
* Allows a custom effect to be applied on the snapshot image used by the frosted glass.
* Default: nil.
* If set, it takes precedence over the blurEffect and blurEffectTintColor properties.
* The block receives UIImage instance as an argument (the snapshot image) and returns a UIImage instance, allowing for the manipulation of the snapshot.
*/
@property (nonatomic, strong) IFASlidingFrostedGlassViewControllerSnapshotEffectBlock snapshotEffectBlock;

- (id)initWithChildViewController:(UIViewController *)a_childViewController
         slidingAnimationDuration:(NSTimeInterval)a_slidingAnimationDuration;

- (UIImage *)newBlurredSnapshotImageFrom:(UIView *)a_viewToSnapshot;
@end

@protocol IFASlidingFrostedGlassViewControllerDelegate <NSObject>

@optional

/**
* Request to the delegate to provide the current height for the frosted glass view.
* This will keep layout calculations up to date.
* @param a_viewController Object instance making the call.
* @returns Current height for the frosted glass view.
*/
- (CGFloat)
frostedGlassViewHeightForSlidingFrostedGlassViewController:(IFASlidingFrostedGlassViewController *)a_viewController;

/**
* Notification that the dismissal of the view controller has completed (including any transition animation).
* @param a_viewController Object instance making the call.
*/
- (void)didDismissSlidingFrostedGlassViewController:(IFASlidingFrostedGlassViewController *)a_viewController;

@end