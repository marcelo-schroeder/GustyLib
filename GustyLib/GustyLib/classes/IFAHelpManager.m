//
//  IFAHelpManager.m
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

#import "IFACommon.h"

@interface IFABarButtonItemSavedState : NSObject

@property (nonatomic) BOOL XYZ_enabled;
@property (nonatomic) id XYZ_target;
@property (nonatomic) SEL XYZ_action;

@end

@implementation IFABarButtonItemSavedState


@end

@interface IFAViewSavedState : NSObject

@property (nonatomic) BOOL XYZ_userInteractionEnabled;

@end

@implementation IFAViewSavedState


@end

@interface IFATableViewCellSavedState : IFAViewSavedState

@property (nonatomic) BOOL XYZ_selectionStyle;

@end

@implementation IFATableViewCellSavedState


@end

@interface IFAHelpManager ()

@property (nonatomic, readonly, strong) IFAHelpModeOverlayView *XYZ_helpModeOverlayView;
@property (nonatomic, readonly, strong) UIView *XYZ_userInteractionBlockingView;
@property (nonatomic, readonly, strong) UITapGestureRecognizer *XYZ_mainViewCatchAllGestureRecogniser;
@property (nonatomic, readonly, strong) UITapGestureRecognizer *XYZ_navigationBarCatchAllGestureRecogniser;
@property (nonatomic, readonly, strong) UITapGestureRecognizer *XYZ_toolbarCatchAllGestureRecogniser;

@property (nonatomic, strong) NSMutableArray *XYZ_helpTargets;
@property (nonatomic, strong) NSMutableArray *XYZ_helpTargetSavedStates;
@property (nonatomic, strong) NSMutableArray *XYZ_tabBarItemProxyViews;
@property (nonatomic, strong) NSMutableArray *XYZ_helpTargetSelectionGestureRecognisers;
@property (nonatomic, strong) IFAHelpPopTipView *XYZ_activePopTipView;
@property (nonatomic, strong) UIView *XYZ_helpTargetProxyView;
@property (nonatomic, strong) UIButton *XYZ_helpButton;
@property (nonatomic, strong) UIButton *XYZ_cancelButton;
@property (nonatomic, strong) UIView *XYZ_screenHelpButtonProxyView;  // Used to point the help pop tip at
@property (nonatomic, strong) UIButton *XYZ_screenHelpButton;
@property (nonatomic, strong) IFA_MBProgressHUD *XYZ_helpModeInstructionsHud;
@property (nonatomic, strong) NSTimer *XYZ_helpModeInstructionsTimer;
@property (nonatomic, strong) NSString *XYZ_savedTitle;
@property (nonatomic, strong) UITapGestureRecognizer *XYZ_simpleHelpBackgroundGestureRecogniser;

@property (nonatomic) BOOL helpMode;
@property (nonatomic) BOOL XYZ_savedHidesBackButton;

@end

@implementation IFAHelpManager {
    @private
    UIView *v_helpModeOverlayView;
    UIView *v_userInteractionBlockingView;
    UITapGestureRecognizer *v_mainViewCatchAllGestureRecogniser;
    UITapGestureRecognizer *v_navigationBarCatchAllGestureRecogniser;
    UITapGestureRecognizer *v_toolbarCatchAllGestureRecogniser;
}


#pragma mark - Private

-(void)XYZ_scheduleHelpModeInstructions {
    self.XYZ_helpModeInstructionsTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self
                                                                      selector:@selector(XYZ_onHelpModeInstructionsTimerEvent:)
                                                                      userInfo:nil repeats:NO];
//    NSLog(@"Help mode instructions scheduled to show");
}

-(void)XYZ_cancelHelpModeInstructions {
    [self.XYZ_helpModeInstructionsTimer invalidate];
//    NSLog(@"Help mode instructions scheduling CANCELLED");
}

-(UIView *)XYZ_helpModeOverlayView {
    if (!v_helpModeOverlayView) {
        v_helpModeOverlayView = [IFAHelpModeOverlayView new];
    }
    return v_helpModeOverlayView;
}

-(UIView *)XYZ_userInteractionBlockingView {
    if (!v_userInteractionBlockingView) {
        v_userInteractionBlockingView = [UIView new];
//        v_userInteractionBlockingView.backgroundColor = [UIColor redColor];
    }
    return v_userInteractionBlockingView;
}

/*
 Update the cancel button frame based on the help button frame
 */
-(void)XYZ_updateCancelButtonFrame {
    UIView *l_view = [self.observedHelpTargetContainer targetView];
    CGRect l_helpButtonFrame = self.XYZ_helpButton.frame;
    CGRect l_convertedHelpButtonFrame = [self.XYZ_helpButton.superview convertRect:l_helpButtonFrame toView:l_view];
    self.XYZ_cancelButton.frame = l_convertedHelpButtonFrame;
}

/*
 Update the screen help button frame based on the navigation bar frame
 */
-(void)XYZ_updateScreenHelpButtonFrame {
    UIViewController *l_observedViewController = (UIViewController*)self.observedHelpTargetContainer;
    self.XYZ_screenHelpButton.frame = CGRectMake(0, 0, IFAMinimumTapAreaDimension, l_observedViewController.navigationController.navigationBar.frame.size.height);
    self.XYZ_screenHelpButton.center = l_observedViewController.navigationController.navigationBar.center;
    self.XYZ_screenHelpButtonProxyView.center = self.XYZ_screenHelpButton.center;
}

-(void)XYZ_showHelpModeInstructions {
    self.XYZ_helpModeInstructionsHud = [IFAUIUtils showHudWithText:@"Help mode on.\n\nTap anything you see on the screen for specific help.\n\nTap the '?' icon for generic help with this screen.\n\nTap the 'x' icon to quit Help mode."];
}

-(void)XYZ_hideHelpModeInstructions {
    [IFAUIUtils hideHud:self.XYZ_helpModeInstructionsHud animated:NO];
}

-(void)XYZ_transitionUiForHelpMode:(BOOL)a_helpMode{

    if (![self.observedHelpTargetContainer isKindOfClass:[UIViewController class]]) {
        NSAssert(NO, @"Unexpected class kind for observedHelpTargetContainer: %@", [self.observedHelpTargetContainer class]);
    }

    if (a_helpMode) {
        CGSize l_size = [IFAUIUtils screenBoundsSizeForCurrentOrientation];
        self.XYZ_helpModeOverlayView.frame = CGRectMake(0, 0, l_size.width, l_size.height);
    }

    UIView *l_view = [self.observedHelpTargetContainer targetView];
    if (a_helpMode) {
        self.XYZ_helpButton = (UIButton*) [l_view viewWithTag:IFAViewTagHelpButton];
        [self XYZ_updateScreenHelpButtonFrame];
        [self XYZ_updateCancelButtonFrame];
    }else{
        [self XYZ_hideHelpModeInstructions];
    }
    [UIView transitionWithView:l_view duration:0.75 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        if ([self.observedHelpTargetContainer isKindOfClass:[UIViewController class]]) {
            
            UIViewController *l_observedViewController = (UIViewController*)self.observedHelpTargetContainer;
            
            if(a_helpMode){
                if (l_observedViewController.navigationItem) {
                    self.XYZ_savedTitle = l_observedViewController.navigationItem.title;
                    l_observedViewController.navigationItem.title = nil;
                    self.XYZ_savedHidesBackButton = l_observedViewController.navigationItem.hidesBackButton;
                    l_observedViewController.navigationItem.hidesBackButton = YES;
                }
                [l_view addSubview:self.XYZ_helpModeOverlayView];
                [l_view addSubview:self.XYZ_cancelButton];
                [l_view addSubview:self.XYZ_screenHelpButtonProxyView];
                [l_view addSubview:self.XYZ_screenHelpButton];
                self.XYZ_helpButton.hidden = YES;
                [l_observedViewController.view addGestureRecognizer:self.XYZ_mainViewCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.navigationBar addGestureRecognizer:self.XYZ_navigationBarCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.toolbar addGestureRecognizer:self.XYZ_toolbarCatchAllGestureRecogniser];
            }else{
                if (l_observedViewController.navigationItem) {
                    l_observedViewController.navigationItem.title = self.XYZ_savedTitle;
                    l_observedViewController.navigationItem.hidesBackButton = self.XYZ_savedHidesBackButton;
                }
                [l_observedViewController.view removeGestureRecognizer:self.XYZ_mainViewCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.navigationBar removeGestureRecognizer:self.XYZ_navigationBarCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.toolbar removeGestureRecognizer:self.XYZ_toolbarCatchAllGestureRecogniser];
                self.XYZ_helpButton.hidden = NO;
                [self.XYZ_screenHelpButton removeFromSuperview];
                [self.XYZ_screenHelpButtonProxyView removeFromSuperview];
                [self.XYZ_cancelButton removeFromSuperview];
                [self.XYZ_helpModeOverlayView removeFromSuperview];
            }
            
            if ([l_observedViewController isKindOfClass:[UITableViewController class]]) {
                UITableViewController *l_tableViewController = (UITableViewController*)l_observedViewController;
                [l_tableViewController.tableView reloadData];
            }

        }else{
            NSAssert(NO, @"Help mode not supported for target: %@", [self.observedHelpTargetContainer description]);
        }

    } completion:^(BOOL finished) {
        if (a_helpMode) {
            [self XYZ_showHelpModeInstructions];
        }
        [IFAUtils dispatchAsyncMainThreadBlock:^{
            if (a_helpMode) {
                [self.observedHelpTargetContainer didEnterHelpMode];
            } else {
                [self.observedHelpTargetContainer didExitHelpMode];
            }
        }];
    }];

}

-(void)XYZ_onHelpModeInstructionsTimerEvent:(NSTimer*)a_timer{
    [self XYZ_showHelpModeInstructions];
}

-(void)XYZ_removeHelpTargetSelectionWithAnimation:(BOOL)a_animate dismissPopTipView:(BOOL)a_dismissPopTipView
                       animatePopTipViewDismissal:(BOOL)a_animatePopTipViewDismissal{
    
    // Remove spotlight
    [self.XYZ_helpModeOverlayView removeSpotlightWithAnimation:a_animate];
    
    // Remove help target proxy view
    [self.XYZ_helpTargetProxyView removeFromSuperview];

    // Remove pop tip
    if (a_dismissPopTipView) {
        [self.XYZ_activePopTipView dismissAnimated:a_animatePopTipViewDismissal];
    }else{  // Pop tip has already been dismissed by the user
        if (self.helpMode) {
            [self XYZ_scheduleHelpModeInstructions];
        }else{
            [self XYZ_removeSimpleHelpBackground];
        }
    }
    self.XYZ_activePopTipView = nil;
    
    // Get help overlay ticker going again
//    [IFAUtils dispatchAsyncMainThreadBlock:^{
//        [self.XYZ_helpModeOverlayView m_showTicker];
//    }];
//    [IFAUtils dispatchAsyncMainThreadBlock:^{
//        [self.XYZ_helpModeOverlayView m_showTicker];
//    } afterDelay:0.5];
//    [self.XYZ_helpModeOverlayView m_showTicker];

}

-(void)removeHelpTargetSelectionWithAnimation:(BOOL)a_animate dismissPopTipView:(BOOL)a_dismissPopTipView{
    [self XYZ_removeHelpTargetSelectionWithAnimation:a_animate dismissPopTipView:a_dismissPopTipView
                          animatePopTipViewDismissal:NO];
}

-(void)XYZ_presentPopTipViewWithTitle:(NSString *)a_title description:(NSString *)a_description pointingAtView:(UIView*)a_view{

    [self XYZ_cancelHelpModeInstructions];
    
    // Remove HUD display if present
    [self XYZ_hideHelpModeInstructions];

    // Remove previous selection from UI
    [self removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];
    
    // Hide help overlay ticker
//    [IFAUtils dispatchAsyncMainThreadBlock:^{
//        [self.XYZ_helpModeOverlayView m_hideTicker];
//    }];
//    [IFAUtils dispatchAsyncMainThreadBlock:^{
//        [self.XYZ_helpModeOverlayView m_hideTicker];
//    } afterDelay:0.5];
//    [self.XYZ_helpModeOverlayView m_hideTicker];
    
    UIView *l_pointingAtView = nil;
    if (a_view==self.XYZ_screenHelpButton || a_view.tag== IFAViewTagHelpButton) {

        self.XYZ_helpTargetProxyView = nil;
        l_pointingAtView = a_view==self.XYZ_screenHelpButton ? self.XYZ_screenHelpButtonProxyView : a_view;

    }else{
        
        // Create help target proxy view (this will define the spotlight area and where what exactly the pop tip bubble should connect to)
        static NSUInteger const k_hPadding = 20;
        static NSUInteger const k_vPadding = 10;
        CGFloat l_x = a_view.frame.origin.x - (k_hPadding / 2);
        CGFloat l_y =  a_view.frame.origin.y - (k_vPadding / 2);
        CGFloat l_width = a_view.frame.size.width + k_hPadding;
        CGFloat l_height = a_view.frame.size.height + k_vPadding;
        CGRect l_helpTargetProxyViewFrame = CGRectMake(l_x, l_y, l_width, l_height);
        l_helpTargetProxyViewFrame = [self.XYZ_helpModeOverlayView convertRect:l_helpTargetProxyViewFrame
                                                                      fromView:a_view.superview];
        self.XYZ_helpTargetProxyView = [[UIView alloc] initWithFrame:l_helpTargetProxyViewFrame];
        [self.XYZ_helpModeOverlayView addSubview:self.XYZ_helpTargetProxyView];
        
        // Spotlight selection
        [self.XYZ_helpModeOverlayView spotlightAtRect:self.XYZ_helpTargetProxyView.frame];
        
        l_pointingAtView = self.XYZ_helpTargetProxyView;
        
    }

    // Present the help pop tip
    self.XYZ_activePopTipView = [IFAHelpPopTipView new];
    self.XYZ_activePopTipView.maximised = a_view==self.XYZ_screenHelpButton;
    UIView *l_containerView = [self.observedHelpTargetContainer targetView];
    [self.XYZ_activePopTipView presentWithTitle:a_title description:a_description pointingAtView:l_pointingAtView
                                         inView:l_containerView completionBlock:^{
        // Remove user interaction blocker
        [self.XYZ_userInteractionBlockingView removeFromSuperview];
    }];

    // Block user interaction while the help pop tip is loading its contents
    self.XYZ_userInteractionBlockingView.frame = self.helpMode ? self.XYZ_helpModeOverlayView.frame : CGRectMake(0, 0, l_containerView.frame.size.width, l_containerView.frame.size.height);
    [l_containerView addSubview:self.XYZ_userInteractionBlockingView];

}

-(NSString*)XYZ_helpStringForKeyPath:(NSString*)a_keyPath{
    NSString *l_string = [[NSBundle mainBundle] localizedStringForKey:a_keyPath value:nil table:@"Help"];
    return [l_string isEqualToString:a_keyPath] ? nil : l_string;
}

-(NSString*)XYZ_helpLabelForKeyPath:(NSString*)a_keyPath{
    return [self XYZ_helpStringForKeyPath:[NSString stringWithFormat:@"%@.label", a_keyPath]];
}

-(NSString*)XYZ_helpTitleForKeyPath:(NSString*)a_keyPath{
    return [self XYZ_helpStringForKeyPath:[NSString stringWithFormat:@"%@.title", a_keyPath]];
}

-(NSString*)XYZ_helpDescriptionForKeyPath:(NSString*)a_keyPath{
    return [self XYZ_helpStringForKeyPath:[NSString stringWithFormat:@"%@.description", a_keyPath]];
}

- (void)XYZ_onHelpTargetSelectionForBarButtonItem:(UIBarButtonItem *)a_barButtonItem event:(UIEvent*)a_event{
    
    if (self.XYZ_activePopTipView.presentationRequestInProgress) {
        return;
    }
    
    NSLog(@"m_onHelpTargetSelectionForBarButtonItem: %@", a_barButtonItem.helpTargetId);
//    NSLog(@"accessibilityLabel: %@, accessibilityHint: %@, accessibilityValue: %@", a_barButtonItem.accessibilityLabel, a_barButtonItem.accessibilityHint, a_barButtonItem.accessibilityValue);

//    NSDictionary *l_helpDictionary = [IFAUtils getPlistAsDictionary:@"Help"];
//    NSLog(@"   HELP VALUE: %@", [l_helpDictionary valueForKeyPath:a_barButtonItem.helpTargetId]);

    NSAssert([[a_event allTouches] count]==1, @"Unexpected touch set count: %u", [[a_event allTouches] count]);
    UIView *l_view = ((UITouch*)[[a_event allTouches] anyObject]).view;
    NSString *l_title = [self XYZ_helpTitleForKeyPath:a_barButtonItem.helpTargetId];
    if (!l_title) {
        l_title = a_barButtonItem.accessibilityLabel ? a_barButtonItem.accessibilityLabel : a_barButtonItem.title;
    }
    [self XYZ_presentPopTipViewWithTitle:l_title
                             description:[self XYZ_helpDescriptionForKeyPath:a_barButtonItem.helpTargetId]
                          pointingAtView:l_view];
    
}

- (void)XYZ_onHelpTargetSelectionForTapGestureRecogniser:(UITapGestureRecognizer*)a_tapGestureRecogniser{
    
    if (self.XYZ_activePopTipView.presentationRequestInProgress) {
        return;
    }
    
    NSLog(@"m_onHelpTargetSelectionForTapGestureRecogniser - view: %@, helpTargetId: %@", a_tapGestureRecogniser.view, a_tapGestureRecogniser.view.ifa_helpTargetId);
//    NSLog(@"XYZ_onHelpTargetSelectionForTapGestureRecogniser: %@, helpTargetId: %@", [a_tapGestureRecogniser description], a_tapGestureRecogniser.view.helpTargetId);
    
//    NSDictionary *l_helpDictionary = [IFAUtils getPlistAsDictionary:@"Help"];
//    NSLog(@"   HELP VALUE: %@", [l_helpDictionary valueForKeyPath:a_tapGestureRecogniser.view.helpTargetId]);

    UIViewController *l_viewController = (UIViewController*)self.observedHelpTargetContainer;
    UIView *l_view = a_tapGestureRecogniser.view;
    NSString *l_helpTargetId = l_view.ifa_helpTargetId;
    
    NSString *l_title = [self XYZ_helpTitleForKeyPath:l_helpTargetId];
    if (!l_title) {
        l_title = l_view.accessibilityLabel;
        if (!l_title) {
            if ([l_view isKindOfClass:[UINavigationBar class]]) {
                l_title = l_viewController.navigationItem.title;
            }else if ([l_view isKindOfClass:[UITableViewCell class]]) {
                UITableViewCell *l_cell = (UITableViewCell*)l_view;
                l_title = l_cell.textLabel.text;
            }
        }
    }
    [self XYZ_presentPopTipViewWithTitle:l_title description:[self XYZ_helpDescriptionForKeyPath:l_helpTargetId]
                          pointingAtView:l_view];
    
}

-(void)XYZ_onCatchAllGestureRecogniserTap:(UITapGestureRecognizer*)a_tapGestureRecognizer{
    if (a_tapGestureRecognizer==self.XYZ_navigationBarCatchAllGestureRecogniser || a_tapGestureRecognizer==self.XYZ_toolbarCatchAllGestureRecogniser) {
        UIView *l_view = [a_tapGestureRecognizer.view hitTest:[a_tapGestureRecognizer locationInView:a_tapGestureRecognizer.view] withEvent:nil];
//        NSLog(@"view tapped on toolbar: %@", l_view);
        if (![l_view isKindOfClass:[UINavigationBar class]] && ![l_view isKindOfClass:[UIToolbar class]]) {
            // If the view tapped is not a toolbar (e.g. a bar button item), then it should have been handled somewhere else, so nothing to do here
            return;
        }
    }
    [self resetUi];
    [IFAUIUtils showAndHideUserActionConfirmationHudWithText:@"No help available for selection"];
}

-(UITapGestureRecognizer *)XYZ_mainViewCatchAllGestureRecogniser {
    if (!v_mainViewCatchAllGestureRecogniser) {
        v_mainViewCatchAllGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(XYZ_onCatchAllGestureRecogniserTap:)];
        v_mainViewCatchAllGestureRecogniser.cancelsTouchesInView = NO;
    }
    return v_mainViewCatchAllGestureRecogniser;
}

-(UITapGestureRecognizer *)XYZ_navigationBarCatchAllGestureRecogniser {
    if (!v_navigationBarCatchAllGestureRecogniser) {
        v_navigationBarCatchAllGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(XYZ_onCatchAllGestureRecogniserTap:)];
        v_navigationBarCatchAllGestureRecogniser.cancelsTouchesInView = NO;
    }
    return v_navigationBarCatchAllGestureRecogniser;
}

-(UITapGestureRecognizer *)XYZ_toolbarCatchAllGestureRecogniser {
    if (!v_toolbarCatchAllGestureRecogniser) {
        v_toolbarCatchAllGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(XYZ_onCatchAllGestureRecogniserTap:)];
        v_toolbarCatchAllGestureRecogniser.cancelsTouchesInView = NO;
    }
    return v_toolbarCatchAllGestureRecogniser;
}

-(void)XYZ_addHelpTargets {
    
    NSArray *l_helpTargets = [self.observedHelpTargetContainer helpTargets];
    //        NSLog(@"l_helpTargets: %@", [l_helpTargets description]);
    for (id<IFAHelpTarget> l_helpTarget in l_helpTargets) {
        [self addHelpTarget:l_helpTarget];
    }

    [IFAUIUtils traverseHierarchyForView:[self.observedHelpTargetContainer targetView] withBlock:^(UIView *a_view) {
        [self addHelpTarget:a_view];
        if ([a_view conformsToProtocol:@protocol(IFAHelpTargetContainer)]) {
            id <IFAHelpTargetContainer> l_helpTargetContainer = (id <IFAHelpTargetContainer>) a_view;
            for (UIView *l_view in [l_helpTargetContainer helpTargets]) {
                [self addHelpTarget:l_view];
            }
        }
    }];
    
}

-(void)XYZ_removeHelpTargets {
    
    // Remove the tab bar item proxy views first
    for (UIView* l_view in self.XYZ_tabBarItemProxyViews) {
        [l_view removeFromSuperview];
    }
    [self.XYZ_tabBarItemProxyViews removeAllObjects];
    
    // Now remove the remaining help targets
    for (id<IFAHelpTarget> l_helpTarget in [self.XYZ_helpTargets copy]) {
        [self removeHelpTarget:l_helpTarget];
    }
    
}

-(void)XYZ_removeSimpleHelpBackground {
    IFAAbstractFieldEditorViewController *l_fieldEditorViewController = (IFAAbstractFieldEditorViewController *)self.observedHelpTargetContainer;
    NSAssert(l_fieldEditorViewController, @"l_fieldEditorViewController is nil");
    [[l_fieldEditorViewController.navigationController.view viewWithTag:IFAViewTagHelpBackground] removeFromSuperview];
}

-(void)XYZ_onSimpleHelpGestureRecogniserAction:(id)sender{
    [self.XYZ_activePopTipView dismissAnimated:YES];
    self.XYZ_activePopTipView = nil;
    [self XYZ_removeSimpleHelpBackground];
}

-(void)XYZ_onHelpButtonTap:(UIButton*)a_button{

    if ([self.observedHelpTargetContainer isKindOfClass:[IFAAbstractFieldEditorViewController class]]) { // Simple Help
        
        IFAAbstractFieldEditorViewController *l_fieldEditorViewController = (IFAAbstractFieldEditorViewController *)self.observedHelpTargetContainer;
//        NSLog(@"l_fieldEditorViewController.helpTargetId: %@", l_fieldEditorViewController.helpTargetId);
//        NSLog(@"  l_fieldEditorViewController.view.frame: %@", NSStringFromCGRect(l_fieldEditorViewController.view.frame));
//        NSLog(@"  l_fieldEditorViewController.navigationController.view.frame: %@", NSStringFromCGRect(l_fieldEditorViewController.navigationController.view.frame));
//        NSLog(@"  a_button.frame: %@", NSStringFromCGRect(a_button.frame));

        NSAssert(self.XYZ_activePopTipView ==nil, @"self.XYZ_activePopTipView no nil: %@", [self.XYZ_activePopTipView description]);

        // Configure tap gesture recogniser
        self.XYZ_simpleHelpBackgroundGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(XYZ_onSimpleHelpGestureRecogniserAction:)];
        
        // Configure background view
        CGRect l_frame = l_fieldEditorViewController.navigationController.view.frame;
        UIView *l_backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, l_frame.size.width, l_frame.size.height)];
        l_backgroundView.tag = IFAViewTagHelpBackground;
        l_backgroundView.backgroundColor = [UIColor clearColor];
        [l_backgroundView addGestureRecognizer:self.XYZ_simpleHelpBackgroundGestureRecogniser];
        [l_fieldEditorViewController.navigationController.view addSubview:l_backgroundView];
        
        // Present pop tip view
        NSString *l_description = [self XYZ_helpDescriptionForKeyPath:l_fieldEditorViewController.ifa_helpTargetId];
        [self XYZ_presentPopTipViewWithTitle:nil description:l_description pointingAtView:a_button];

    }else{  // Help Mode
        [self toggleHelpMode];
    }
}

-(void)XYZ_onCancelButtonTap:(UIButton*)a_button{
    [self toggleHelpMode];
}

-(void)XYZ_onScreenHelpButtonTap:(UIButton*)a_button{
    UIViewController *l_observedViewController = (UIViewController*)self.observedHelpTargetContainer;
    NSString *l_helpTargetId = l_observedViewController.ifa_helpTargetId;
    if (!l_helpTargetId) {
        l_helpTargetId = [l_observedViewController ifa_helpTargetIdForName:@"screen"];
    }
    NSLog(@"m_onScreenHelpButtonTap for helpTargetId: %@", l_helpTargetId);
    NSString *l_title = [self XYZ_helpTitleForKeyPath:l_helpTargetId];
    if (!l_title) {
        l_title = self.XYZ_savedTitle;
    }
    NSString *l_description = [self XYZ_helpDescriptionForKeyPath:l_helpTargetId];
    [self XYZ_presentPopTipViewWithTitle:l_title description:l_description pointingAtView:a_button];
}

-(IFAHelpTargetView *)XYZ_insertHelpTargetViewForView:(UIView *)a_view title:(NSString*)a_title{
//    NSLog(@"m_insertHelpTargetViewForView: %@", a_view);
    IFAHelpTargetView *l_helpTargetView = [[IFAHelpTargetView alloc] initWithFrame:a_view.frame];
//    l_helpTargetView.backgroundColor = [UIColor redColor];
    l_helpTargetView.ifa_helpTargetId = a_view.ifa_helpTargetId;
    if (a_title) {
        l_helpTargetView.accessibilityLabel = a_title;
    }
    [a_view.superview insertSubview:l_helpTargetView aboveSubview:a_view];
    return l_helpTargetView;
}

#pragma mark - Public

-(void)observeHelpTargetContainer:(id<IFAHelpTargetContainer>)a_helpTargetContainer{
    
    // Store view controller to be observed
    self.observedHelpTargetContainer = a_helpTargetContainer;
    
    // Reset any pop tip views left over
    self.XYZ_activePopTipView = nil;
    
//    NSLog(@"Registered as target view controller for help: %@", [a_helpTargetContainer description]);

}

- (void)helpRequestedForTabBarItemIndex:(NSUInteger)a_index helpTargetId:(NSString *)a_helpTargetId title:(NSString*)a_title{
    NSLog(@"m_helpRequestedForTabBarItemIndex: %@", a_helpTargetId);
    [self XYZ_presentPopTipViewWithTitle:a_title description:[self XYZ_helpDescriptionForKeyPath:a_helpTargetId]
                          pointingAtView:[self.XYZ_tabBarItemProxyViews objectAtIndex:a_index]];
}

-(void)addHelpTarget:(id<IFAHelpTarget>)a_helpTarget{
    
//    NSLog(@"addHelpTarget: %@", [a_helpTarget description]);
    
    // Get a special case out of the way first: UITabBar
    if([a_helpTarget isKindOfClass:[UITabBar class]]){
        
        UITabBar *l_tabBar = (UITabBar*)a_helpTarget;
        NSUInteger l_tabBarItemWidth = l_tabBar.frame.size.width / l_tabBar.items.count;
        for (int i=0; i<l_tabBar.items.count; i++) {
            @autoreleasepool {
                CGRect l_frame = CGRectMake(i*l_tabBarItemWidth, 0, l_tabBarItemWidth, l_tabBar.frame.size.height);
                UIView *l_view = [[UIView alloc] initWithFrame:l_frame];
                l_view.userInteractionEnabled = NO;
                [l_tabBar addSubview:l_view];
                [self.XYZ_tabBarItemProxyViews addObject:l_view];
            }
        }
        
        return;
        
    }
    
    // From this point onwards a help target ID is required (except for a navigation bar)
    if (!a_helpTarget.helpTargetId) {
        return;
    }
    
//    NSLog(@"  a_helpTarget.helpTargetId: %@", a_helpTarget.helpTargetId);
    
    if ([a_helpTarget isKindOfClass:[UIBarButtonItem class]]) {
        
        UIBarButtonItem *l_barButtonItem = (UIBarButtonItem*)a_helpTarget;
        
        if (l_barButtonItem.action) {
            
//            NSLog(@"l_barButtonItem: %@, title: %@, target: %@, action: %@", [l_barButtonItem description], l_barButtonItem.title, [l_barButtonItem.target description], NSStringFromSelector(l_barButtonItem.action));
            
            IFABarButtonItemSavedState *l_barButtonItemSavedState = [IFABarButtonItemSavedState new];
            l_barButtonItemSavedState.XYZ_enabled = l_barButtonItem.enabled;
            l_barButtonItemSavedState.XYZ_target = l_barButtonItem.target;
            l_barButtonItemSavedState.XYZ_action = l_barButtonItem.action;
            
            l_barButtonItem.enabled = YES;
            l_barButtonItem.target = self;
            l_barButtonItem.action = @selector(XYZ_onHelpTargetSelectionForBarButtonItem:event:);
            
            [self.XYZ_helpTargets addObject:l_barButtonItem];
            [self.XYZ_helpTargetSavedStates addObject:l_barButtonItemSavedState];
            [self.XYZ_helpTargetSelectionGestureRecognisers addObject:[NSNull null]];
            
        }
        
    }else if([a_helpTarget isKindOfClass:[UIView class]]){
        
        UIView *l_view = nil;
        IFAViewSavedState *l_viewSavedState = nil;

        if ([a_helpTarget isKindOfClass:[UIControl class]]) {
            
            UIControl *l_control = (UIControl*)a_helpTarget;
            l_view = [self XYZ_insertHelpTargetViewForView:l_control title:nil];

        }else{

            l_view = (UIView*)a_helpTarget;
            
            if ([l_view isKindOfClass:[UITableViewCell class]]) {
                
                UITableViewCell *l_tableViewCell = (UITableViewCell*)a_helpTarget;
                if ([l_view isKindOfClass:[IFAFormTableViewCell class]]) {
                    
                    l_view = [self XYZ_insertHelpTargetViewForView:l_view title:l_tableViewCell.textLabel.text];

                }else{
                    
                    IFATableViewCellSavedState *l_tableViewCellSavedState = [IFATableViewCellSavedState new];
                    l_tableViewCellSavedState.XYZ_selectionStyle = l_tableViewCell.selectionStyle;
                    l_tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    l_viewSavedState = l_tableViewCellSavedState;
                    
                }
                
            }else{
                
                l_viewSavedState = [IFAViewSavedState new];
                
            }
            
            l_viewSavedState.XYZ_userInteractionEnabled = l_view.userInteractionEnabled;
            
            l_view.userInteractionEnabled = YES;

        }
        
        UITapGestureRecognizer *l_tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(XYZ_onHelpTargetSelectionForTapGestureRecogniser:)];
        [l_view addGestureRecognizer:l_tapGestureRecogniser];
        
        [self.XYZ_helpTargets addObject:l_view];
        [self.XYZ_helpTargetSavedStates addObject:l_viewSavedState ? l_viewSavedState : [NSNull null]];
        [self.XYZ_helpTargetSelectionGestureRecognisers addObject:l_tapGestureRecogniser];
        
    }else{
        NSAssert(NO, @"Unexpected help target: %@", [a_helpTarget description]);
    }
    
}

-(void)removeHelpTarget:(id<IFAHelpTarget>)a_helpTarget{
    
    NSUInteger l_index = [self.XYZ_helpTargets indexOfObject:a_helpTarget];

    if ([a_helpTarget isKindOfClass:[UIBarButtonItem class]]) {
        
        UIBarButtonItem *l_barButtonItem = (UIBarButtonItem*)a_helpTarget;
        IFABarButtonItemSavedState *l_barButtonItemSavedState = [self.XYZ_helpTargetSavedStates objectAtIndex:l_index];
        l_barButtonItem.enabled = l_barButtonItemSavedState.XYZ_enabled;
        l_barButtonItem.target = l_barButtonItemSavedState.XYZ_target;
        l_barButtonItem.action = l_barButtonItemSavedState.XYZ_action;
        
    }else if([a_helpTarget isKindOfClass:[UIView class]]){
        
        UIView *l_view = (UIView*)a_helpTarget;
        if ([l_view isKindOfClass:[IFAHelpTargetView class]]) {
            [l_view removeFromSuperview];
        }
        
        id l_obj = [self.XYZ_helpTargetSavedStates objectAtIndex:l_index];
        if ([l_obj isKindOfClass:[IFAViewSavedState class]]) { // Safeguard against the cases where the object is a [NSNull null]
            IFAViewSavedState *l_viewSavedState = l_obj;
            l_view.userInteractionEnabled = l_viewSavedState.XYZ_userInteractionEnabled;
            if ([a_helpTarget isKindOfClass:[UITableViewCell class]]) {
                IFATableViewCellSavedState *l_tableViewCellSavedState = (IFATableViewCellSavedState *)l_viewSavedState;
                ((UITableViewCell*)l_view).selectionStyle = l_tableViewCellSavedState.XYZ_selectionStyle;
            }
        }
        
        [l_view removeGestureRecognizer:[self.XYZ_helpTargetSelectionGestureRecognisers objectAtIndex:l_index]];
        
    }else{
        NSAssert(NO, @"Unexpected help target: %@", [a_helpTarget description]);
    }
    
    [self.XYZ_helpTargets removeObjectAtIndex:l_index];
    [self.XYZ_helpTargetSavedStates removeObjectAtIndex:l_index];
    [self.XYZ_helpTargetSelectionGestureRecognisers removeObjectAtIndex:l_index];

}

-(void)refreshHelpTargets {
    [self XYZ_removeHelpTargets];
    [self XYZ_addHelpTargets];
}

-(void)XYZ_removeHelpTargetSelection {
    [self removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];
}

-(void)toggleHelpMode {
    
    if (self.helpMode) {
        [self.observedHelpTargetContainer willExitHelpMode];
    }else{
        [self.observedHelpTargetContainer willEnterHelpMode];
    }
    
    self.helpMode =!self.helpMode;
    
    if (self.helpMode) {

        [self XYZ_transitionUiForHelpMode:self.helpMode];

        [self XYZ_addHelpTargets];

        [IFAAnalyticsUtils logEntryForScreenName:@"Help"];
        
    }else{

        [self XYZ_cancelHelpModeInstructions];

        [self removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];

        [self XYZ_removeHelpTargets];

        [self XYZ_transitionUiForHelpMode:self.helpMode];
        
    }
    
}

-(UIBarButtonItem*)newHelpBarButtonItem {
    
    // Configure image
    UIImage *l_helpButtonImage = [UIImage imageNamed:@"248-QuestionCircleAlt"];

    // Configure button
    UIButton *l_helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    l_helpButton.tag = IFAViewTagHelpButton;
    l_helpButton.frame = CGRectMake(0, 0, 20, 44);
    l_helpButton.accessibilityLabel = [self accessibilityLabelForKeyPath:[IFAUIUtils helpTargetIdForName:@"helpButton"]];
//    l_helpButton.backgroundColor = [UIColor redColor];
    [l_helpButton setImage:l_helpButtonImage forState:UIControlStateNormal];
    [l_helpButton addTarget:self action:@selector(XYZ_onHelpButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    // Configure bar button item
    UIBarButtonItem *l_helpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:l_helpButton];
    l_helpBarButtonItem.tag = IFABarItemTagHelpButton;
    
    return l_helpBarButtonItem;
    
}

-(BOOL)isHelpEnabledForViewController:(UIViewController*)a_viewController{
    NSArray *l_helpEnabledViewControllerClassNames = [[IFAUtils infoPList] objectForKey:@"IFAHelpEnabledViewControllers"];
    return [l_helpEnabledViewControllerClassNames containsObject:[a_viewController.class description]];
}

-(void)resetUi {
    [self removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];
    [self XYZ_hideHelpModeInstructions];
    [self XYZ_cancelHelpModeInstructions];
    [self XYZ_scheduleHelpModeInstructions];
}

-(void)observedViewControllerDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self XYZ_updateScreenHelpButtonFrame];
    [self XYZ_updateCancelButtonFrame];
    [self refreshHelpTargets];
}

-(void)observedViewControllerWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self XYZ_removeHelpTargetSelection];
}

-(NSString *)accessibilityLabelForKeyPath:(NSString *)a_keyPath{
    NSString *l_accessibilityLabel = [self XYZ_helpLabelForKeyPath:a_keyPath];
    if (!l_accessibilityLabel) {
        l_accessibilityLabel = [self XYZ_helpTitleForKeyPath:a_keyPath];
    }
    return l_accessibilityLabel;
}

+ (IFAHelpManager *)sharedInstance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IFAHelpManager *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

+ (NSString*)helpTargetIdForPropertyName:(NSString *)a_propertyName inObject:(NSObject*)a_object{
    return [NSString stringWithFormat:@"entities.%@.%@", [a_object ifa_entityName], a_propertyName];
}

#pragma mark - Overrides

-(id)init{

    if (self=[super init]) {

        self.XYZ_helpTargets = [NSMutableArray new];
        self.XYZ_helpTargetSavedStates = [NSMutableArray new];
        self.XYZ_tabBarItemProxyViews = [NSMutableArray new];
        self.XYZ_helpTargetSelectionGestureRecognisers = [NSMutableArray new];
        
        // Configure the cancel button
        UIImage *l_cancelButtonImage = [UIImage imageNamed:@"277-MultiplyCircle-white"];
        self.XYZ_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.XYZ_cancelButton.frame = CGRectZero;
        self.XYZ_cancelButton.accessibilityLabel = [self accessibilityLabelForKeyPath:[IFAUIUtils helpTargetIdForName:@"closeHelpButton"]];
        [self.XYZ_cancelButton setImage:l_cancelButtonImage forState:UIControlStateNormal];
        [self.XYZ_cancelButton addTarget:self action:@selector(XYZ_onCancelButtonTap:)
                        forControlEvents:UIControlEventTouchUpInside];
        
        // Configure the screen help button
        UIImage *l_screenHelpButtonImage = [UIImage imageNamed:@"248-QuestionCircleAlt"];
        self.XYZ_screenHelpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.XYZ_screenHelpButton.frame = CGRectZero;
        self.XYZ_screenHelpButton.accessibilityLabel = [self accessibilityLabelForKeyPath:[IFAUIUtils helpTargetIdForName:@"screenHelpButton"]];
        [self.XYZ_screenHelpButton setImage:l_screenHelpButtonImage forState:UIControlStateNormal];
        [self.XYZ_screenHelpButton addTarget:self action:@selector(XYZ_onScreenHelpButtonTap:)
                            forControlEvents:UIControlEventTouchUpInside];
//        self.XYZ_screenHelpButton.backgroundColor = [UIColor redColor];
        
        // Configure the screen help button proxy
        static NSUInteger const k_screenHelpButtonProxyViewPadding = 4;
        self.XYZ_screenHelpButtonProxyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, l_screenHelpButtonImage.size.width+k_screenHelpButtonProxyViewPadding, l_screenHelpButtonImage.size.height+k_screenHelpButtonProxyViewPadding)];
//        self.XYZ_screenHelpButtonProxyView.backgroundColor = [UIColor blueColor];

    }

    return self;

}

#pragma mark - UIGestureRecognizerDelegate protocol

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    // Hit test: prevents the gesture recogniser from "stealing" touches that should otherwise go to a subview (i.e. bar button items in a navigation bar)
    UIView *l_hitTestView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view] withEvent:nil];
//    NSLog(@"l_hitTestView: %@", [l_hitTestView description]);
    return gestureRecognizer.view==l_hitTestView;
}

@end
