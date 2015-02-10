//
//  KNSemiModalViewController.m
//  KNSemiModalViewController
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "UIViewController+IFA_KNSemiModal.h"
#import "GustyLibCoreUI.h"

static char c_presentingSemiModalKey;
static char c_presentedAsSemiModalKey;
static char c_semiModalViewControllerDelegateKey;

@interface UIViewController (KNSemiModalInternal)

@property (nonatomic) BOOL presentingSemiModal;
@property (nonatomic) BOOL presentedAsSemiModal;

@end

@implementation UIViewController (IFA_KNSemiModal)

#pragma mark - Private

-(void)setPresentingSemiModal:(BOOL)a_presentingSemiModal{
    objc_setAssociatedObject(self, &c_presentingSemiModalKey, @(a_presentingSemiModal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setPresentedAsSemiModal:(BOOL)a_presentedAsSemiModal{
    objc_setAssociatedObject(self, &c_presentedAsSemiModalKey, @(a_presentedAsSemiModal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView*)parentTarget {
    // To make it work with UINav & UITabbar as well
    UIViewController * target = self;
    while (target.parentViewController != nil) {
        target = target.parentViewController;
    }
    return target.view;
}

/*
-(CAAnimationGroup*)animationGroupForward:(BOOL)_forward {
    // Create animation keys, forwards and backwards
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = (CGFloat) (1.0/-900);
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, (CGFloat) (15.0f*M_PI/180.0f), 1, 0, 0);
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = t1.m34;
    t2 = CATransform3DTranslate(t2, 0, (CGFloat) ([self parentTarget].frame.size.height*-0.08), 0);
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:t1];
    animation.duration = kSemiModalAnimationDuration/2;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.toValue = [NSValue valueWithCATransform3D:(_forward?t2:CATransform3DIdentity)];
    animation2.beginTime = animation.duration;
    animation2.duration = animation.duration;
    animation2.fillMode = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:animation.duration*2];
    [group setAnimations:@[animation,animation2]];
    return group;
}
*/

- (UIView *)semiModalView {
    UIView * target = [self parentTarget];
    return (target.subviews)[target.subviews.count - 1];
}

-(void)onTapOutsideSemiModalView {
    BOOL l_shouldDismiss = YES;
    if ([self.semiModalViewDelegate respondsToSelector:@selector(shouldDismissOnTapOutsideForSemiModalView:)]) {
        l_shouldDismiss = [self.semiModalViewDelegate shouldDismissOnTapOutsideForSemiModalView:self.semiModalView];
    }
    if (l_shouldDismiss) {
        [self dismissSemiModalViewWithCompletionBlock:^{
        }];
    }
}

#pragma mark - Public

-(BOOL)presentingSemiModal {
    return [(NSNumber*)objc_getAssociatedObject(self, &c_presentingSemiModalKey) boolValue];
}

-(BOOL)presentedAsSemiModal {
    return [(NSNumber*)objc_getAssociatedObject(self, &c_presentedAsSemiModalKey) boolValue];
}

-(void)presentSemiModalViewController:(UIViewController*)vc {
//    NSLog(@"presentSemiModalViewController: %@, by: %@", [vc description], [self description]);
    self.presentingSemiModal = YES;
    [IFAApplicationDelegate sharedInstance].semiModalViewController = vc;
    [IFAApplicationDelegate sharedInstance].semiModalViewController.presentedAsSemiModal = YES;
    [self presentSemiModalView:vc.view];
}

-(void)presentSemiModalView:(UIView*)vc {
    
    // Determine target
    UIView * target = [self parentTarget];
    
    if (![target.subviews containsObject:vc]) {

        // Calulate all frames
        CGRect sf = vc.frame;
//        NSLog(@"sf: %@", NSStringFromCGRect(sf));
        CGRect vf = target.bounds;
//        NSLog(@"vf: %@", NSStringFromCGRect(vf));
//        NSLog(@"target.bounds: %@", NSStringFromCGRect(target.bounds));
        CGRect f  = CGRectMake(0, vf.size.height-sf.size.height, vf.size.width, sf.size.height);
//        CGRect of = CGRectMake(0, 0, vf.size.width, vf.size.height-sf.size.height);
        
        // Add semi overlay
        UIView * overlay = [[UIView alloc] initWithFrame:target.bounds];
        overlay.autoresizingMask = [IFAUIUtils fullAutoresizingMask];
        overlay.backgroundColor = [UIColor blackColor];
        overlay.alpha = 0;
        
        // Take screenshot and scale
//        UIGraphicsBeginImageContext(target.bounds.size);
//        [target.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        UIImageView * ss = [[UIImageView alloc] initWithImage:image];
//        ss.autoresizingMask = [IFAUIUtils fullAutoresizingMask];
//        [overlay addSubview:ss];
        [target addSubview:overlay];
        [IFAApplicationDelegate sharedInstance].semiModalInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        // Dismiss button
        // Don't use UITapGestureRecognizer to avoid complex handling
        UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissButton addTarget:self action:@selector(onTapOutsideSemiModalView)
                forControlEvents:UIControlEventTouchUpInside];
        dismissButton.backgroundColor = [UIColor clearColor];
        dismissButton.frame = vf;
        dismissButton.autoresizingMask = [IFAUIUtils fullAutoresizingMask];
        [overlay addSubview:dismissButton];

        // Begin overlay animation
//        [ss.layer addAnimation:[self animationGroupForward:YES] forKey:@"pushedBackAnimation"];
//        [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
//            ss.alpha = 0.5;
//        }];
        
        // Present view animated
        vc.frame = CGRectMake(0, vf.size.height, vf.size.width, sf.size.height);
//        NSLog(@"initial frame: %@", NSStringFromCGRect(vc.frame));
        [target addSubview:vc];
//        vc.layer.shadowColor = [[UIColor blackColor] CGColor];
//        vc.layer.shadowOffset = CGSizeMake(0, -2);
//        vc.layer.shadowRadius = 5.0;
//        vc.layer.shadowOpacity = 0.8;
        [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
            overlay.alpha = 0.5;
            vc.frame = f;
//            NSLog(@"final frame: %@", NSStringFromCGRect(vc.frame));
        }];
        
//        NSLog(@"overlay.frame: %@", NSStringFromCGRect(overlay.frame));
//        NSLog(@"ss.frame: %@", NSStringFromCGRect(ss.frame));
//        NSLog(@"dismissButton.frame: %@", NSStringFromCGRect(dismissButton.frame));
//        NSLog(@"target.frame: %@", NSStringFromCGRect(target.frame));
//        NSLog(@"vc.frame: %@", NSStringFromCGRect(vc.frame));

    }
    
}

- (void)dismissSemiModalViewWithCompletionBlock:(void (^)())a_completionBlock {
    UIView * modal = self.semiModalView;
    UIView * target = [self parentTarget];
    UIView * overlay = (target.subviews)[target.subviews.count - 2];
    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
        overlay.alpha = 0;
        modal.frame = CGRectMake(0, target.frame.size.height, modal.frame.size.width, modal.frame.size.height);
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        [modal removeFromSuperview];
        self.presentingSemiModal = NO;
        [IFAApplicationDelegate sharedInstance].semiModalViewController.presentedAsSemiModal = NO;
        [IFAApplicationDelegate sharedInstance].semiModalViewController = nil;
        [UIViewController attemptRotationToDeviceOrientation];  // We may have missed an interface orientation change when the semi modal view was being displayed, so this is the opportunity to catch up
        a_completionBlock();
    }];
    
    // Begin overlay animation
//    UIImageView * ss = (UIImageView*)[overlay.subviews objectAtIndex:0];
//    [ss.layer addAnimation:[self animationGroupForward:NO] forKey:@"bringForwardAnimation"];
//    [UIView animateWithDuration:kSemiModalAnimationDuration animations:^{
//        ss.alpha = 1;
//    }];
}

//-(void)handleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
//    UIView * target = [self parentTarget];
//    UIView * overlay = [target.subviews objectAtIndex:target.subviews.count-2];
//    UIView * ss = [overlay.subviews objectAtIndex:0];
//    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)==UIInterfaceOrientationIsLandscape(self.p_screenshotOrientation)) {
//        ss.hidden = NO;
//        overlay.alpha = 1.0;
//    }else{
//        ss.hidden = YES;
//        overlay.alpha = 0.5;
//    }
//}

-(void)setSemiModalViewDelegate:(id<IFASemiModalViewDelegate>)a_semiModalViewControllerDelegate{
    objc_setAssociatedObject(self, &c_semiModalViewControllerDelegateKey, a_semiModalViewControllerDelegate, OBJC_ASSOCIATION_ASSIGN);
}

-(id<IFASemiModalViewDelegate>)semiModalViewDelegate {
    return objc_getAssociatedObject(self, &c_semiModalViewControllerDelegateKey);
}

@end
