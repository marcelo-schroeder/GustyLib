//
// Created by Marcelo Schroeder on 10/04/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAUIViewController.h"

@protocol IASlidingFrostedGlassViewControllerDelegate;

typedef enum{
    IASlidingFrostedGlassViewControllerBlurEffectLight,
    IASlidingFrostedGlassViewControllerBlurEffectExtraLight,
    IASlidingFrostedGlassViewControllerBlurEffectDark,
}IASlidingFrostedGlassViewControllerBlurEffect;

typedef UIImage *(^IASlidingFrostedGlassViewControllerSnapshotEffectBlock)(UIImage *);

@interface IASlidingFrostedGlassViewController : IAUIViewController <UIViewControllerTransitioningDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, weak) id<IASlidingFrostedGlassViewControllerDelegate> p_delegate;
@property(nonatomic, strong, readonly) UIImageView *p_frostedGlassImageView;

/**
* Defines the type of blur effect to be applied on the frosted glass.
* Default: IASlidingFrostedGlassViewControllerBlurEffectLight.
* It is overridden by setting the p_blurEffectTintColor property or the p_snapshotEffectBlock property.
*/
@property (nonatomic) IASlidingFrostedGlassViewControllerBlurEffect p_blurEffect;

/**
* Defines the tint colour of the blur effect to be applied on the frosted glass.
* Default: nil.
* If set, it takes precedence over the p_blurEffect property.
* It is overridden by setting the p_snapshotEffectBlock property.
*/
@property (nonatomic, strong) UIColor *p_blurEffectTintColor;

/**
* Allows a custom effect to be applied on the snapshot image used by the frosted glass.
* Default: nil.
* If set, it takes precedence over the p_blurEffect and p_blurEffectTintColor properties.
* The block receives UIImage instance as an argument (the snapshot image) and returns a UIImage instance, allowing for the manipulation of the snapshot.
*/
@property (nonatomic, strong) IASlidingFrostedGlassViewControllerSnapshotEffectBlock p_snapshotEffectBlock;

- (id)initWithChildViewController:(UIViewController *)a_childViewController
         slidingAnimationDuration:(NSTimeInterval)a_slidingAnimationDuration;

- (UIImage *)m_newBlurredSnapshotImageFrom:(UIView *)a_viewToSnapshot;
@end

@protocol IASlidingFrostedGlassViewControllerDelegate <NSObject>

@optional
- (CGFloat)m_frostedGlassViewHeight;

@end