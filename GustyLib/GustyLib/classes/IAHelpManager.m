//
//  IAHelpManager.m
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

#import "IAHelpManager.h"

@interface IAUIBarButtonItemSavedState : NSObject

@property (nonatomic) BOOL p_enabled;
@property (nonatomic) id p_target;
@property (nonatomic) SEL p_action;

@end

@implementation IAUIBarButtonItemSavedState


@end

@interface IAUIViewSavedState : NSObject

@property (nonatomic) BOOL p_userInteractionEnabled;

@end

@implementation IAUIViewSavedState


@end

@interface IAUITableViewCellSavedState : IAUIViewSavedState

@property (nonatomic) BOOL p_selectionStyle;

@end

@implementation IAUITableViewCellSavedState


@end

@interface IAHelpManager ()

@property (nonatomic, readonly, strong) IAUIHelpModeOverlayView *p_helpModeOverlayView;
@property (nonatomic, readonly, strong) UIView *p_userInteractionBlockingView;
@property (nonatomic, readonly, strong) UITapGestureRecognizer *p_mainViewCatchAllGestureRecogniser;
@property (nonatomic, readonly, strong) UITapGestureRecognizer *p_navigationBarCatchAllGestureRecogniser;
@property (nonatomic, readonly, strong) UITapGestureRecognizer *p_toolbarCatchAllGestureRecogniser;

@property (nonatomic, strong) NSMutableArray *p_helpTargets;
@property (nonatomic, strong) NSMutableArray *p_helpTargetSavedStates;
@property (nonatomic, strong) NSMutableArray *p_tabBarItemProxyViews;
@property (nonatomic, strong) NSMutableArray *p_helpTargetSelectionGestureRecognisers;
@property (nonatomic, strong) IAUIHelpPopTipView *p_activePopTipView;
@property (nonatomic, strong) UIView *p_helpTargetProxyView;
@property (nonatomic, strong) UIButton *p_helpButton;
@property (nonatomic, strong) UIButton *p_cancelButton;
@property (nonatomic, strong) UIView *p_screenHelpButtonProxyView;  // Used to point the help pop tip at
@property (nonatomic, strong) UIButton *p_screenHelpButton;
@property (nonatomic, strong) IA_MBProgressHUD *p_helpModeInstructionsHud;
@property (nonatomic, strong) NSTimer *p_helpModeInstructionsTimer;
@property (nonatomic, strong) NSString *p_savedTitle;
@property (nonatomic, strong) UITapGestureRecognizer *p_simpleHelpBackgroundGestureRecogniser;

@property (nonatomic) BOOL p_helpMode;
@property (nonatomic) BOOL p_savedHidesBackButton;

@end

@implementation IAHelpManager{
    @private
    UIView *v_helpModeOverlayView;
    UIView *v_userInteractionBlockingView;
    UITapGestureRecognizer *v_mainViewCatchAllGestureRecogniser;
    UITapGestureRecognizer *v_navigationBarCatchAllGestureRecogniser;
    UITapGestureRecognizer *v_toolbarCatchAllGestureRecogniser;
}


#pragma mark - Private

-(void)m_scheduleHelpModeInstructions{
    self.p_helpModeInstructionsTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(m_onHelpModeInstructionsTimerEvent:) userInfo:nil repeats:NO];
//    NSLog(@"Help mode instructions scheduled to show");
}

-(void)m_cancelHelpModeInstructions{
    [self.p_helpModeInstructionsTimer invalidate];
//    NSLog(@"Help mode instructions scheduling CANCELLED");
}

-(UIView *)p_helpModeOverlayView{
    if (!v_helpModeOverlayView) {
        v_helpModeOverlayView = [IAUIHelpModeOverlayView new];
    }
    return v_helpModeOverlayView;
}

-(UIView *)p_userInteractionBlockingView{
    if (!v_userInteractionBlockingView) {
        v_userInteractionBlockingView = [UIView new];
//        v_userInteractionBlockingView.backgroundColor = [UIColor redColor];
    }
    return v_userInteractionBlockingView;
}

/*
 Update the cancel button frame based on the help button frame
 */
-(void)m_updateCancelButtonFrame{
    UIView *l_view = [self.p_observedHelpTargetContainer m_view];
    CGRect l_helpButtonFrame = self.p_helpButton.frame;
    CGRect l_convertedHelpButtonFrame = [self.p_helpButton.superview convertRect:l_helpButtonFrame toView:l_view];
    self.p_cancelButton.frame = l_convertedHelpButtonFrame;
}

/*
 Update the screen help button frame based on the navigation bar frame
 */
-(void)m_updateScreenHelpButtonFrame{
    UIViewController *l_observedViewController = (UIViewController*)self.p_observedHelpTargetContainer;
    self.p_screenHelpButton.frame = CGRectMake(0, 0, IA_MINIMUM_TAP_AREA_DIMENSION, l_observedViewController.navigationController.navigationBar.frame.size.height);
    self.p_screenHelpButton.center = l_observedViewController.navigationController.navigationBar.center;
    self.p_screenHelpButtonProxyView.center = self.p_screenHelpButton.center;
}

-(void)m_showHelpModeInstructions{
    self.p_helpModeInstructionsHud = [IAUIUtils showHudWithText:@"Help mode on.\n\nTap anything you see on the screen for specific help.\n\nTap the '?' icon for generic help with this screen.\n\nTap the 'x' icon to quit Help mode."];
}

-(void)m_hideHelpModeInstructions{
    [IAUIUtils hideHud:self.p_helpModeInstructionsHud animated:NO];
}

-(void)m_transitionUiForHelpMode:(BOOL)a_helpMode{

    if (![self.p_observedHelpTargetContainer isKindOfClass:[UIViewController class]]) {
        NSAssert(NO, @"Unexpected class kind for p_observedHelpTargetContainer: %@", [self.p_observedHelpTargetContainer class]);
    }

    if (a_helpMode) {
        CGSize l_size = [IAUIUtils screenBoundsSizeForCurrentOrientation];
        self.p_helpModeOverlayView.frame = CGRectMake(0, 0, l_size.width, l_size.height);
    }

    UIView *l_view = [self.p_observedHelpTargetContainer m_view];
    if (a_helpMode) {
        self.p_helpButton = (UIButton*)[l_view viewWithTag:IA_UIVIEW_TAG_HELP_BUTTON];
        [self m_updateScreenHelpButtonFrame];
        [self m_updateCancelButtonFrame];
    }else{
        [self m_hideHelpModeInstructions];
    }
    [UIView transitionWithView:l_view duration:0.75 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        if ([self.p_observedHelpTargetContainer isKindOfClass:[UIViewController class]]) {
            
            UIViewController *l_observedViewController = (UIViewController*)self.p_observedHelpTargetContainer;
            
            if(a_helpMode){
                if (l_observedViewController.navigationItem) {
                    self.p_savedTitle = l_observedViewController.navigationItem.title;
                    l_observedViewController.navigationItem.title = nil;
                    self.p_savedHidesBackButton = l_observedViewController.navigationItem.hidesBackButton;
                    l_observedViewController.navigationItem.hidesBackButton = YES;
                }
                [l_view addSubview:self.p_helpModeOverlayView];
                [l_view addSubview:self.p_cancelButton];
                [l_view addSubview:self.p_screenHelpButtonProxyView];
                [l_view addSubview:self.p_screenHelpButton];
                self.p_helpButton.hidden = YES;
                [l_observedViewController.view addGestureRecognizer:self.p_mainViewCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.navigationBar addGestureRecognizer:self.p_navigationBarCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.toolbar addGestureRecognizer:self.p_toolbarCatchAllGestureRecogniser];
            }else{
                if (l_observedViewController.navigationItem) {
                    l_observedViewController.navigationItem.title = self.p_savedTitle;
                    l_observedViewController.navigationItem.hidesBackButton = self.p_savedHidesBackButton;
                }
                [l_observedViewController.view removeGestureRecognizer:self.p_mainViewCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.navigationBar removeGestureRecognizer:self.p_navigationBarCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.toolbar removeGestureRecognizer:self.p_toolbarCatchAllGestureRecogniser];
                self.p_helpButton.hidden = NO;
                [self.p_screenHelpButton removeFromSuperview];
                [self.p_screenHelpButtonProxyView removeFromSuperview];
                [self.p_cancelButton removeFromSuperview];
                [self.p_helpModeOverlayView removeFromSuperview];
            }
            
            if ([l_observedViewController isKindOfClass:[UITableViewController class]]) {
                UITableViewController *l_tableViewController = (UITableViewController*)l_observedViewController;
                [l_tableViewController.tableView reloadData];
            }

        }else{
            NSAssert(NO, @"Help mode not supported for target: %@", [self.p_observedHelpTargetContainer description]);
        }

    } completion:^(BOOL finished) {
        if (a_helpMode) {
            [self m_showHelpModeInstructions];
        }
        [IAUtils m_dispatchAsyncMainThreadBlock:^{
            if (a_helpMode) {
                [self.p_observedHelpTargetContainer m_didEnterHelpMode];
            }else{
                [self.p_observedHelpTargetContainer m_didExitHelpMode];
            }
        }];
    }];

}

/*
- (void)m_onHelpModeToggle:(id)aSender{
    [self m_toggleHelpMode];
}
 */

-(void)m_onHelpModeInstructionsTimerEvent:(NSTimer*)a_timer{
    [self m_showHelpModeInstructions];
}

-(void)m_removeHelpTargetSelectionWithAnimation:(BOOL)a_animate dismissPopTipView:(BOOL)a_dismissPopTipView animatePopTipViewDismissal:(BOOL)a_animatePopTipViewDismissal{
    
    // Remove spotlight
    [self.p_helpModeOverlayView m_removeSpotlightWithAnimation:a_animate];
    
    // Remove help target proxy view
    [self.p_helpTargetProxyView removeFromSuperview];

    // Remove pop tip
    if (a_dismissPopTipView) {
        [self.p_activePopTipView dismissAnimated:a_animatePopTipViewDismissal];
    }else{  // Pop tip has already been dismissed by the user
        if (self.p_helpMode) {
            [self m_scheduleHelpModeInstructions];
        }else{
            [self m_removeSimpleHelpBackground];
        }
    }
    self.p_activePopTipView = nil;
    
    // Get help overlay ticker going again
//    [IAUtils m_dispatchAsyncMainThreadBlock:^{
//        [self.p_helpModeOverlayView m_showTicker];
//    }];
//    [IAUtils m_dispatchAsyncMainThreadBlock:^{
//        [self.p_helpModeOverlayView m_showTicker];
//    } afterDelay:0.5];
//    [self.p_helpModeOverlayView m_showTicker];

}

-(void)m_removeHelpTargetSelectionWithAnimation:(BOOL)a_animate dismissPopTipView:(BOOL)a_dismissPopTipView{
    [self m_removeHelpTargetSelectionWithAnimation:a_animate dismissPopTipView:a_dismissPopTipView animatePopTipViewDismissal:NO];
}

-(void)m_presentPopTipViewWithTitle:(NSString*)a_title description:(NSString*)a_description pointingAtView:(UIView*)a_view{
    
    [self m_cancelHelpModeInstructions];
    
    // Remove HUD display if present
    [self m_hideHelpModeInstructions];

    // Remove previous selection from UI
    [self m_removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];
    
    // Hide help overlay ticker
//    [IAUtils m_dispatchAsyncMainThreadBlock:^{
//        [self.p_helpModeOverlayView m_hideTicker];
//    }];
//    [IAUtils m_dispatchAsyncMainThreadBlock:^{
//        [self.p_helpModeOverlayView m_hideTicker];
//    } afterDelay:0.5];
//    [self.p_helpModeOverlayView m_hideTicker];
    
    UIView *l_pointingAtView = nil;
    if (a_view==self.p_screenHelpButton || a_view.tag==IA_UIVIEW_TAG_HELP_BUTTON) {

        self.p_helpTargetProxyView = nil;
        l_pointingAtView = a_view==self.p_screenHelpButton ? self.p_screenHelpButtonProxyView : a_view;

    }else{
        
        // Create help target proxy view (this will define the spotlight area and where what exactly the pop tip bubble should connect to)
        static NSUInteger const k_hPadding = 20;
        static NSUInteger const k_vPadding = 10;
        CGFloat l_x = a_view.frame.origin.x - (k_hPadding / 2);
        CGFloat l_y =  a_view.frame.origin.y - (k_vPadding / 2);
        CGFloat l_width = a_view.frame.size.width + k_hPadding;
        CGFloat l_height = a_view.frame.size.height + k_vPadding;
        CGRect l_helpTargetProxyViewFrame = CGRectMake(l_x, l_y, l_width, l_height);
        l_helpTargetProxyViewFrame = [self.p_helpModeOverlayView convertRect:l_helpTargetProxyViewFrame fromView:a_view.superview];
        self.p_helpTargetProxyView = [[UIView alloc] initWithFrame:l_helpTargetProxyViewFrame];
        [self.p_helpModeOverlayView addSubview:self.p_helpTargetProxyView];
        
        // Spotlight selection
        [self.p_helpModeOverlayView m_spotlightAtRect:self.p_helpTargetProxyView.frame];
        
        l_pointingAtView = self.p_helpTargetProxyView;
        
    }

    // Present the help pop tip
    self.p_activePopTipView = [IAUIHelpPopTipView new];
    self.p_activePopTipView.p_maximised = a_view==self.p_screenHelpButton;
    UIView *l_containerView = [self.p_observedHelpTargetContainer m_view];
    [self.p_activePopTipView m_presentWithTitle:a_title description:a_description pointingAtView:l_pointingAtView inView:l_containerView completionBlock:^{
        // Remove user interaction blocker
        [self.p_userInteractionBlockingView removeFromSuperview];
    }];

    // Block user interaction while the help pop tip is loading its contents
    self.p_userInteractionBlockingView.frame = self.p_helpMode ? self.p_helpModeOverlayView.frame : CGRectMake(0, 0, l_containerView.frame.size.width, l_containerView.frame.size.height);
    [l_containerView addSubview:self.p_userInteractionBlockingView];

}

-(NSString*)m_helpStringForKeyPath:(NSString*)a_keyPath{
    NSString *l_string = [[NSBundle mainBundle] localizedStringForKey:a_keyPath value:nil table:@"Help"];
    return [l_string isEqualToString:a_keyPath] ? nil : l_string;
}

-(NSString*)m_helpLabelForKeyPath:(NSString*)a_keyPath{
    return [self m_helpStringForKeyPath:[NSString stringWithFormat:@"%@.label", a_keyPath]];
}

-(NSString*)m_helpTitleForKeyPath:(NSString*)a_keyPath{
    return [self m_helpStringForKeyPath:[NSString stringWithFormat:@"%@.title", a_keyPath]];
}

-(NSString*)m_helpDescriptionForKeyPath:(NSString*)a_keyPath{
    return [self m_helpStringForKeyPath:[NSString stringWithFormat:@"%@.description", a_keyPath]];
}

- (void)m_onHelpTargetSelectionForBarButtonItem:(UIBarButtonItem*)a_barButtonItem event:(UIEvent*)a_event{
    
    if (self.p_activePopTipView.p_presentationRequestInProgress) {
        return;
    }
    
    NSLog(@"m_onHelpTargetSelectionForBarButtonItem: %@", a_barButtonItem.p_helpTargetId);
//    NSLog(@"accessibilityLabel: %@, accessibilityHint: %@, accessibilityValue: %@", a_barButtonItem.accessibilityLabel, a_barButtonItem.accessibilityHint, a_barButtonItem.accessibilityValue);

//    NSDictionary *l_helpDictionary = [IAUtils getPlistAsDictionary:@"Help"];
//    NSLog(@"   HELP VALUE: %@", [l_helpDictionary valueForKeyPath:a_barButtonItem.p_helpTargetId]);

    NSAssert([[a_event allTouches] count]==1, @"Unexpected touch set count: %u", [[a_event allTouches] count]);
    UIView *l_view = ((UITouch*)[[a_event allTouches] anyObject]).view;
    NSString *l_title = [self m_helpTitleForKeyPath:a_barButtonItem.p_helpTargetId];
    if (!l_title) {
        l_title = a_barButtonItem.accessibilityLabel ? a_barButtonItem.accessibilityLabel : a_barButtonItem.title;
    }
    [self m_presentPopTipViewWithTitle:l_title description:[self m_helpDescriptionForKeyPath:a_barButtonItem.p_helpTargetId] pointingAtView:l_view];
    
}

- (void)m_onHelpTargetSelectionForTapGestureRecogniser:(UITapGestureRecognizer*)a_tapGestureRecogniser{
    
    if (self.p_activePopTipView.p_presentationRequestInProgress) {
        return;
    }
    
    NSLog(@"m_onHelpTargetSelectionForTapGestureRecogniser - view: %@, helpTargetId: %@", a_tapGestureRecogniser.view, a_tapGestureRecogniser.view.p_helpTargetId);
//    NSLog(@"m_onHelpTargetSelectionForTapGestureRecogniser: %@, helpTargetId: %@", [a_tapGestureRecogniser description], a_tapGestureRecogniser.view.p_helpTargetId);
    
//    NSDictionary *l_helpDictionary = [IAUtils getPlistAsDictionary:@"Help"];
//    NSLog(@"   HELP VALUE: %@", [l_helpDictionary valueForKeyPath:a_tapGestureRecogniser.view.p_helpTargetId]);

    UIViewController *l_viewController = (UIViewController*)self.p_observedHelpTargetContainer;
    UIView *l_view = a_tapGestureRecogniser.view;
    NSString *l_helpTargetId = l_view.p_helpTargetId;
    
    NSString *l_title = [self m_helpTitleForKeyPath:l_helpTargetId];
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
    [self m_presentPopTipViewWithTitle:l_title description:[self m_helpDescriptionForKeyPath:l_helpTargetId] pointingAtView:l_view];
    
}

-(void)m_onCatchAllGestureRecogniserTap:(UITapGestureRecognizer*)a_tapGestureRecognizer{
    if (a_tapGestureRecognizer==self.p_navigationBarCatchAllGestureRecogniser || a_tapGestureRecognizer==self.p_toolbarCatchAllGestureRecogniser) {
        UIView *l_view = [a_tapGestureRecognizer.view hitTest:[a_tapGestureRecognizer locationInView:a_tapGestureRecognizer.view] withEvent:nil];
//        NSLog(@"view tapped on toolbar: %@", l_view);
        if (![l_view isKindOfClass:[UINavigationBar class]] && ![l_view isKindOfClass:[UIToolbar class]]) {
            // If the view tapped is not a toolbar (e.g. a bar button item), then it should have been handled somewhere else, so nothing to do here
            return;
        }
    }
    [self m_resetUi];
    [IAUIUtils showAndHideUserActionConfirmationHudWithText:@"No help available for selection"];
}

-(UITapGestureRecognizer *)p_mainViewCatchAllGestureRecogniser{
    if (!v_mainViewCatchAllGestureRecogniser) {
        v_mainViewCatchAllGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m_onCatchAllGestureRecogniserTap:)];
        v_mainViewCatchAllGestureRecogniser.cancelsTouchesInView = NO;
    }
    return v_mainViewCatchAllGestureRecogniser;
}

-(UITapGestureRecognizer *)p_navigationBarCatchAllGestureRecogniser{
    if (!v_navigationBarCatchAllGestureRecogniser) {
        v_navigationBarCatchAllGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m_onCatchAllGestureRecogniserTap:)];
        v_navigationBarCatchAllGestureRecogniser.cancelsTouchesInView = NO;
    }
    return v_navigationBarCatchAllGestureRecogniser;
}

-(UITapGestureRecognizer *)p_toolbarCatchAllGestureRecogniser{
    if (!v_toolbarCatchAllGestureRecogniser) {
        v_toolbarCatchAllGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m_onCatchAllGestureRecogniserTap:)];
        v_toolbarCatchAllGestureRecogniser.cancelsTouchesInView = NO;
    }
    return v_toolbarCatchAllGestureRecogniser;
}

-(void)m_addHelpTargets{
    
    NSArray *l_helpTargets = [self.p_observedHelpTargetContainer m_helpTargets];
    //        NSLog(@"l_helpTargets: %@", [l_helpTargets description]);
    for (id<IAHelpTarget> l_helpTarget in l_helpTargets) {
        [self m_addHelpTarget:l_helpTarget];
    }
    
    [IAUIUtils m_traverseHierarchyForView:[self.p_observedHelpTargetContainer m_view] withBlock:^(UIView *a_view) {
        [self m_addHelpTarget:a_view];
        if ([a_view conformsToProtocol:@protocol(IAHelpTargetContainer)]) {
            id<IAHelpTargetContainer> l_helpTargetContainer = (id<IAHelpTargetContainer>)a_view;
            for (UIView *l_view in [l_helpTargetContainer m_helpTargets]) {
                [self m_addHelpTarget:l_view];
            }
        }
    }];
    
}

-(void)m_removeHelpTargets{
    
    // Remove the tab bar item proxy views first
    for (UIView* l_view in self.p_tabBarItemProxyViews) {
        [l_view removeFromSuperview];
    }
    [self.p_tabBarItemProxyViews removeAllObjects];
    
    // Now remove the remaining help targets
    for (id<IAHelpTarget> l_helpTarget in [self.p_helpTargets copy]) {
        [self m_removeHelpTarget:l_helpTarget];
    }
    
}

-(void)m_removeSimpleHelpBackground{
    IAUIAbstractFieldEditorViewController *l_fieldEditorViewController = (IAUIAbstractFieldEditorViewController*)self.p_observedHelpTargetContainer;
    NSAssert(l_fieldEditorViewController, @"l_fieldEditorViewController is nil");
    [[l_fieldEditorViewController.navigationController.view viewWithTag:IA_UIVIEW_TAG_HELP_BACKGROUND] removeFromSuperview];
}

-(void)m_onSimpleHelpGestureRecogniserAction:(id)sender{
    [self.p_activePopTipView dismissAnimated:YES];
    self.p_activePopTipView = nil;
    [self m_removeSimpleHelpBackground];
}

-(void)m_onHelpButtonTap:(UIButton*)a_button{

    if ([self.p_observedHelpTargetContainer isKindOfClass:[IAUIAbstractFieldEditorViewController class]]) { // Simple Help
        
        IAUIAbstractFieldEditorViewController *l_fieldEditorViewController = (IAUIAbstractFieldEditorViewController*)self.p_observedHelpTargetContainer;
//        NSLog(@"l_fieldEditorViewController.p_helpTargetId: %@", l_fieldEditorViewController.p_helpTargetId);
//        NSLog(@"  l_fieldEditorViewController.view.frame: %@", NSStringFromCGRect(l_fieldEditorViewController.view.frame));
//        NSLog(@"  l_fieldEditorViewController.navigationController.view.frame: %@", NSStringFromCGRect(l_fieldEditorViewController.navigationController.view.frame));
//        NSLog(@"  a_button.frame: %@", NSStringFromCGRect(a_button.frame));

        NSAssert(self.p_activePopTipView==nil, @"self.p_activePopTipView no nil: %@", [self.p_activePopTipView description]);

        // Configure tap gesture recogniser
        self.p_simpleHelpBackgroundGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m_onSimpleHelpGestureRecogniserAction:)];
        
        // Configure background view
        CGRect l_frame = l_fieldEditorViewController.navigationController.view.frame;
        UIView *l_backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, l_frame.size.width, l_frame.size.height)];
        l_backgroundView.tag = IA_UIVIEW_TAG_HELP_BACKGROUND;
        l_backgroundView.backgroundColor = [UIColor clearColor];
        [l_backgroundView addGestureRecognizer:self.p_simpleHelpBackgroundGestureRecogniser];
        [l_fieldEditorViewController.navigationController.view addSubview:l_backgroundView];
        
        // Present pop tip view
        NSString *l_description = [self m_helpDescriptionForKeyPath:l_fieldEditorViewController.p_helpTargetId];
        [self m_presentPopTipViewWithTitle:nil description:l_description pointingAtView:a_button];

    }else{  // Help Mode
        [self m_toggleHelpMode];
    }
}

-(void)m_onCancelButtonTap:(UIButton*)a_button{
    [self m_toggleHelpMode];
}

-(void)m_onScreenHelpButtonTap:(UIButton*)a_button{
    UIViewController *l_observedViewController = (UIViewController*)self.p_observedHelpTargetContainer;
    NSString *l_helpTargetId = l_observedViewController.p_helpTargetId;
    if (!l_helpTargetId) {
        l_helpTargetId = [l_observedViewController m_helpTargetIdForName:@"screen"];
    }
    NSLog(@"m_onScreenHelpButtonTap for helpTargetId: %@", l_helpTargetId);
    NSString *l_title = [self m_helpTitleForKeyPath:l_helpTargetId];
    if (!l_title) {
        l_title = self.p_savedTitle;
    }
    NSString *l_description = [self m_helpDescriptionForKeyPath:l_helpTargetId];
    [self m_presentPopTipViewWithTitle:l_title description:l_description pointingAtView:a_button];
}

-(IAUIHelpTargetView*)m_insertHelpTargetViewForView:(UIView*)a_view title:(NSString*)a_title{
//    NSLog(@"m_insertHelpTargetViewForView: %@", a_view);
    IAUIHelpTargetView *l_helpTargetView = [[IAUIHelpTargetView alloc] initWithFrame:a_view.frame];
//    l_helpTargetView.backgroundColor = [UIColor redColor];
    l_helpTargetView.p_helpTargetId = a_view.p_helpTargetId;
    if (a_title) {
        l_helpTargetView.accessibilityLabel = a_title;
    }
    [a_view.superview insertSubview:l_helpTargetView aboveSubview:a_view];
    return l_helpTargetView;
}

#pragma mark - Public

-(void)m_observeHelpTargetContainer:(id<IAHelpTargetContainer>)a_helpTargetContainer{
    
    // Store view controller to be observed
    self.p_observedHelpTargetContainer = a_helpTargetContainer;
    
    // Reset any pop tip views left over
    self.p_activePopTipView = nil;
    
//    NSLog(@"Registered as target view controller for help: %@", [a_helpTargetContainer description]);

}

- (void)m_helpRequestedForTabBarItemIndex:(NSUInteger)a_index helpTargetId:(NSString*)a_helpTargetId title:(NSString*)a_title{
    NSLog(@"m_helpRequestedForTabBarItemIndex: %@", a_helpTargetId);
    [self m_presentPopTipViewWithTitle:a_title description:[self m_helpDescriptionForKeyPath:a_helpTargetId] pointingAtView:[self.p_tabBarItemProxyViews objectAtIndex:a_index]];
}

-(void)m_addHelpTarget:(id<IAHelpTarget>)a_helpTarget{
    
//    NSLog(@"m_addHelpTarget: %@", [a_helpTarget description]);
    
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
                [self.p_tabBarItemProxyViews addObject:l_view];
            }
        }
        
        return;
        
    }
    
    // From this point onwards a help target ID is required (except for a navigation bar)
    if (!a_helpTarget.p_helpTargetId) {
        return;
    }
    
//    NSLog(@"  a_helpTarget.p_helpTargetId: %@", a_helpTarget.p_helpTargetId);
    
    if ([a_helpTarget isKindOfClass:[UIBarButtonItem class]]) {
        
        UIBarButtonItem *l_barButtonItem = (UIBarButtonItem*)a_helpTarget;
        
        if (l_barButtonItem.action) {
            
//            NSLog(@"l_barButtonItem: %@, title: %@, target: %@, action: %@", [l_barButtonItem description], l_barButtonItem.title, [l_barButtonItem.target description], NSStringFromSelector(l_barButtonItem.action));
            
            IAUIBarButtonItemSavedState *l_barButtonItemSavedState = [IAUIBarButtonItemSavedState new];
            l_barButtonItemSavedState.p_enabled = l_barButtonItem.enabled;
            l_barButtonItemSavedState.p_target = l_barButtonItem.target;
            l_barButtonItemSavedState.p_action = l_barButtonItem.action;
            
            l_barButtonItem.enabled = YES;
            l_barButtonItem.target = self;
            l_barButtonItem.action = @selector(m_onHelpTargetSelectionForBarButtonItem:event:);
            
            [self.p_helpTargets addObject:l_barButtonItem];
            [self.p_helpTargetSavedStates addObject:l_barButtonItemSavedState];
            [self.p_helpTargetSelectionGestureRecognisers addObject:[NSNull null]];
            
        }
        
    }else if([a_helpTarget isKindOfClass:[UIView class]]){
        
        UIView *l_view = nil;
        IAUIViewSavedState *l_viewSavedState = nil;

        if ([a_helpTarget isKindOfClass:[UIControl class]]) {
            
            UIControl *l_control = (UIControl*)a_helpTarget;
            l_view = [self m_insertHelpTargetViewForView:l_control title:nil];

        }else{

            l_view = (UIView*)a_helpTarget;
            
            if ([l_view isKindOfClass:[UITableViewCell class]]) {
                
                UITableViewCell *l_tableViewCell = (UITableViewCell*)a_helpTarget;
                if ([l_view isKindOfClass:[IAUIFormTableViewCell class]]) {
                    
                    l_view = [self m_insertHelpTargetViewForView:l_view title:l_tableViewCell.textLabel.text];

                }else{
                    
                    IAUITableViewCellSavedState *l_tableViewCellSavedState = [IAUITableViewCellSavedState new];
                    l_tableViewCellSavedState.p_selectionStyle = l_tableViewCell.selectionStyle;
                    l_tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    l_viewSavedState = l_tableViewCellSavedState;
                    
                }
                
            }else{
                
                l_viewSavedState = [IAUIViewSavedState new];
                
            }
            
            l_viewSavedState.p_userInteractionEnabled = l_view.userInteractionEnabled;
            
            l_view.userInteractionEnabled = YES;

        }
        
        UITapGestureRecognizer *l_tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(m_onHelpTargetSelectionForTapGestureRecogniser:)];
        [l_view addGestureRecognizer:l_tapGestureRecogniser];
        
        [self.p_helpTargets addObject:l_view];
        [self.p_helpTargetSavedStates addObject:l_viewSavedState?l_viewSavedState:[NSNull null]];
        [self.p_helpTargetSelectionGestureRecognisers addObject:l_tapGestureRecogniser];
        
    }else{
        NSAssert(NO, @"Unexpected help target: %@", [a_helpTarget description]);
    }
    
}

-(void)m_removeHelpTarget:(id<IAHelpTarget>)a_helpTarget{
    
    NSUInteger l_index = [self.p_helpTargets indexOfObject:a_helpTarget];

    if ([a_helpTarget isKindOfClass:[UIBarButtonItem class]]) {
        
        UIBarButtonItem *l_barButtonItem = (UIBarButtonItem*)a_helpTarget;
        IAUIBarButtonItemSavedState *l_barButtonItemSavedState = [self.p_helpTargetSavedStates objectAtIndex:l_index];
        l_barButtonItem.enabled = l_barButtonItemSavedState.p_enabled;
        l_barButtonItem.target = l_barButtonItemSavedState.p_target;
        l_barButtonItem.action = l_barButtonItemSavedState.p_action;
        
    }else if([a_helpTarget isKindOfClass:[UIView class]]){
        
        UIView *l_view = (UIView*)a_helpTarget;
        if ([l_view isKindOfClass:[IAUIHelpTargetView class]]) {
            [l_view removeFromSuperview];
        }
        
        id l_obj = [self.p_helpTargetSavedStates objectAtIndex:l_index];
        if ([l_obj isKindOfClass:[IAUIViewSavedState class]]) { // Safeguard against the cases where the object is a [NSNull null]
            IAUIViewSavedState *l_viewSavedState = l_obj;
            l_view.userInteractionEnabled = l_viewSavedState.p_userInteractionEnabled;
            if ([a_helpTarget isKindOfClass:[UITableViewCell class]]) {
                IAUITableViewCellSavedState *l_tableViewCellSavedState = (IAUITableViewCellSavedState*)l_viewSavedState;
                ((UITableViewCell*)l_view).selectionStyle = l_tableViewCellSavedState.p_selectionStyle;
            }
        }
        
        [l_view removeGestureRecognizer:[self.p_helpTargetSelectionGestureRecognisers objectAtIndex:l_index]];
        
    }else{
        NSAssert(NO, @"Unexpected help target: %@", [a_helpTarget description]);
    }
    
    [self.p_helpTargets removeObjectAtIndex:l_index];
    [self.p_helpTargetSavedStates removeObjectAtIndex:l_index];
    [self.p_helpTargetSelectionGestureRecognisers removeObjectAtIndex:l_index];

}

-(void)m_refreshHelpTargets{
    [self m_removeHelpTargets];
    [self m_addHelpTargets];
}

-(void)m_removeHelpTargetSelection{
    [self m_removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];
}

-(void)m_toggleHelpMode{
    
    if (self.p_helpMode) {
        [self.p_observedHelpTargetContainer m_willExitHelpMode];
    }else{
        [self.p_observedHelpTargetContainer m_willEnterHelpMode];
    }
    
    self.p_helpMode=!self.p_helpMode;
    
    if (self.p_helpMode) {
        
        [self m_transitionUiForHelpMode:self.p_helpMode];
        
        [self m_addHelpTargets];
        
        [IAAnalyticsUtils m_logEntryForScreenName:@"Help"];
        
    }else{
        
        [self m_cancelHelpModeInstructions];
        
        [self m_removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];
        
        [self m_removeHelpTargets];
        
        [self m_transitionUiForHelpMode:self.p_helpMode];
        
    }
    
}

-(UIBarButtonItem*)m_newHelpBarButtonItem{
    
    // Configure image
    UIImage *l_helpButtonImage = [UIImage imageNamed:@"248-QuestionCircleAlt"];

    // Configure button
    UIButton *l_helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    l_helpButton.tag = IA_UIVIEW_TAG_HELP_BUTTON;
    l_helpButton.frame = CGRectMake(0, 0, 20, 44);
    l_helpButton.accessibilityLabel = [self m_accessibilityLabelForKeyPath:[IAUIUtils m_helpTargetIdForName:@"helpButton"]];
//    l_helpButton.backgroundColor = [UIColor redColor];
    [l_helpButton setImage:l_helpButtonImage forState:UIControlStateNormal];
    [l_helpButton addTarget:self action:@selector(m_onHelpButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    // Configure bar button item
    UIBarButtonItem *l_helpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:l_helpButton];
    l_helpBarButtonItem.tag = IA_UIBAR_ITEM_TAG_HELP_BUTTON;
    
    return l_helpBarButtonItem;
    
}

-(BOOL)m_isHelpEnabledForViewController:(UIViewController*)a_viewController{
    NSArray *l_helpEnabledViewControllerClassNames = [[IAUtils infoPList] objectForKey:@"IAHelpEnabledViewControllers"];
    return [l_helpEnabledViewControllerClassNames containsObject:[a_viewController.class description]];
}

-(void)m_resetUi{
    [self m_removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];
    [self m_hideHelpModeInstructions];
    [self m_cancelHelpModeInstructions];
    [self m_scheduleHelpModeInstructions];
}

-(void)m_observedViewControllerDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self m_updateScreenHelpButtonFrame];
    [self m_updateCancelButtonFrame];
    [self m_refreshHelpTargets];
}

-(void)m_observedViewControllerWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self m_removeHelpTargetSelection];
}

-(NSString *)m_accessibilityLabelForKeyPath:(NSString *)a_keyPath{
    NSString *l_accessibilityLabel = [self m_helpLabelForKeyPath:a_keyPath];
    if (!l_accessibilityLabel) {
        l_accessibilityLabel = [self m_helpTitleForKeyPath:a_keyPath];
    }
    return l_accessibilityLabel;
}

+ (IAHelpManager*)m_instance {
    static dispatch_once_t c_dispatchOncePredicate;
    static IAHelpManager *c_instance = nil;
    dispatch_once(&c_dispatchOncePredicate, ^{
        c_instance = [self new];
    });
    return c_instance;
}

+ (NSString*)m_helpTargetIdForPropertyName:(NSString*)a_propertyName inObject:(NSObject*)a_object{
    return [NSString stringWithFormat:@"entities.%@.%@", [a_object entityName], a_propertyName];
}

#pragma mark - Overrides

-(id)init{

    if (self=[super init]) {

        self.p_helpTargets = [NSMutableArray new];
        self.p_helpTargetSavedStates = [NSMutableArray new];
        self.p_tabBarItemProxyViews = [NSMutableArray new];
        self.p_helpTargetSelectionGestureRecognisers = [NSMutableArray new];
        
        // Configure the cancel button
        UIImage *l_cancelButtonImage = [UIImage imageNamed:@"277-MultiplyCircle-white"];
        self.p_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.p_cancelButton.frame = CGRectZero;
        self.p_cancelButton.accessibilityLabel = [self m_accessibilityLabelForKeyPath:[IAUIUtils m_helpTargetIdForName:@"closeHelpButton"]];
        [self.p_cancelButton setImage:l_cancelButtonImage forState:UIControlStateNormal];
        [self.p_cancelButton addTarget:self action:@selector(m_onCancelButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        
        // Configure the screen help button
        UIImage *l_screenHelpButtonImage = [UIImage imageNamed:@"248-QuestionCircleAlt"];
        self.p_screenHelpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.p_screenHelpButton.frame = CGRectZero;
        self.p_screenHelpButton.accessibilityLabel = [self m_accessibilityLabelForKeyPath:[IAUIUtils m_helpTargetIdForName:@"screenHelpButton"]];
        [self.p_screenHelpButton setImage:l_screenHelpButtonImage forState:UIControlStateNormal];
        [self.p_screenHelpButton addTarget:self action:@selector(m_onScreenHelpButtonTap:) forControlEvents:UIControlEventTouchUpInside];
//        self.p_screenHelpButton.backgroundColor = [UIColor redColor];
        
        // Configure the screen help button proxy
        static NSUInteger const k_screenHelpButtonProxyViewPadding = 4;
        self.p_screenHelpButtonProxyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, l_screenHelpButtonImage.size.width+k_screenHelpButtonProxyViewPadding, l_screenHelpButtonImage.size.height+k_screenHelpButtonProxyViewPadding)];
//        self.p_screenHelpButtonProxyView.backgroundColor = [UIColor blueColor];

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
