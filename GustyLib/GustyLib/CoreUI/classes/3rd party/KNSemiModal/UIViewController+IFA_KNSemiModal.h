//
//  KNSemiModalViewController.h
//  KNSemiModalViewController
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

@protocol IFASemiModalViewDelegate;
#define kSemiModalAnimationDuration   0.3

@interface UIViewController (IFA_KNSemiModal)

@property (nonatomic, readonly) BOOL presentingSemiModal;
@property (nonatomic, readonly) BOOL presentedAsSemiModal;
@property (nonatomic, weak) id<IFASemiModalViewDelegate> semiModalViewDelegate;

-(void)presentSemiModalViewController:(UIViewController*)vc;
-(void)presentSemiModalView:(UIView*)vc;
- (void)dismissSemiModalViewWithCompletionBlock:(void (^)())a_completionBlock;
//-(void)handleWillAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end

@protocol IFASemiModalViewDelegate <NSObject>
@optional
- (BOOL)shouldDismissOnTapOutsideForSemiModalView:(UIView *)a_semiModalView;
@end