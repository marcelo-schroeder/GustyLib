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

#import "GustyLibHelp.h"

@interface IFABarButtonItemSavedState : NSObject

@property (nonatomic) BOOL IFA_enabled;
@property (nonatomic) id IFA_target;
@property (nonatomic) SEL IFA_action;

@end

@implementation IFABarButtonItemSavedState


@end

@interface IFAViewSavedState : NSObject

@property (nonatomic) BOOL IFA_userInteractionEnabled;

@end

@implementation IFAViewSavedState


@end

@interface IFATableViewCellSavedState : IFAViewSavedState

@property (nonatomic) UITableViewCellSelectionStyle IFA_selectionStyle;

@end

@implementation IFATableViewCellSavedState


@end

@interface IFAHelpManager ()

@property (nonatomic, strong) NSMutableArray *IFA_helpTargets;
@property (nonatomic, strong) NSMutableArray *IFA_helpTargetSavedStates;
@property (nonatomic, strong) NSMutableArray *IFA_tabBarItemProxyViews;
@property (nonatomic, strong) NSMutableArray *IFA_helpTargetSelectionGestureRecognisers;
@property (nonatomic, strong) IFAHelpPopTipView *IFA_activePopTipView;
@property (nonatomic, strong) UIView *IFA_helpTargetProxyView;
@property (nonatomic, strong) UIButton *IFA_helpButton;
@property (nonatomic, strong) UIButton *IFA_cancelButton;
@property (nonatomic, strong) UIView *IFA_screenHelpButtonProxyView;  // Used to point the help pop tip at
@property (nonatomic, strong) UIButton *IFA_screenHelpButton;
@property (nonatomic, strong) IFA_MBProgressHUD *IFA_helpModeInstructionsHud;
@property (nonatomic, strong) NSTimer *IFA_helpModeInstructionsTimer;
@property (nonatomic, strong) NSString *IFA_savedTitle;
@property (nonatomic, strong) UITapGestureRecognizer *IFA_simpleHelpBackgroundGestureRecogniser;

@property (nonatomic) BOOL helpMode;
@property (nonatomic) BOOL IFA_savedHidesBackButton;

@property(nonatomic, strong) IFAHelpModeOverlayView *IFA_helpModeOverlayView;
@property(nonatomic, strong) UIView *IFA_userInteractionBlockingView;
@property(nonatomic, strong) UITapGestureRecognizer *IFA_mainViewCatchAllGestureRecogniser;
@property(nonatomic, strong) UITapGestureRecognizer *IFA_navigationBarCatchAllGestureRecogniser;
@property(nonatomic, strong) UITapGestureRecognizer *IFA_toolbarCatchAllGestureRecogniser;
@end

@implementation IFAHelpManager


#pragma mark - Private

-(void)IFA_scheduleHelpModeInstructions {
    self.IFA_helpModeInstructionsTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self
                                                                      selector:@selector(IFA_onHelpModeInstructionsTimerEvent:)
                                                                      userInfo:nil repeats:NO];
//    NSLog(@"Help mode instructions scheduled to show");
}

-(void)IFA_cancelHelpModeInstructions {
    [self.IFA_helpModeInstructionsTimer invalidate];
//    NSLog(@"Help mode instructions scheduling CANCELLED");
}

-(IFAHelpModeOverlayView *)IFA_helpModeOverlayView {
    if (!_IFA_helpModeOverlayView) {
        _IFA_helpModeOverlayView = [IFAHelpModeOverlayView new];
    }
    return _IFA_helpModeOverlayView;
}

-(UIView *)IFA_userInteractionBlockingView {
    if (!_IFA_userInteractionBlockingView) {
        _IFA_userInteractionBlockingView = [UIView new];
//        v_userInteractionBlockingView.backgroundColor = [UIColor redColor];
    }
    return _IFA_userInteractionBlockingView;
}

/*
 Update the cancel button frame based on the help button frame
 */
-(void)IFA_updateCancelButtonFrame {
    UIView *l_view = [self.observedHelpTargetContainer targetView];
    CGRect l_helpButtonFrame = self.IFA_helpButton.frame;
    CGRect l_convertedHelpButtonFrame = [self.IFA_helpButton.superview convertRect:l_helpButtonFrame toView:l_view];
    self.IFA_cancelButton.frame = l_convertedHelpButtonFrame;
}

/*
 Update the screen help button frame based on the navigation bar frame
 */
-(void)IFA_updateScreenHelpButtonFrame {
    UIViewController *l_observedViewController = (UIViewController*)self.observedHelpTargetContainer;
    self.IFA_screenHelpButton.frame = CGRectMake(0, 0, IFAMinimumTapAreaDimension, l_observedViewController.navigationController.navigationBar.frame.size.height);
    self.IFA_screenHelpButton.center = l_observedViewController.navigationController.navigationBar.center;
    self.IFA_screenHelpButtonProxyView.center = self.IFA_screenHelpButton.center;
}

-(void)IFA_showHelpModeInstructions {
    self.IFA_helpModeInstructionsHud = [IFAUIUtils showHudWithText:@"Help mode on.\n\nTap anything you see on the screen for specific help.\n\nTap the '?' icon for generic help with this screen.\n\nTap the 'x' icon to quit Help mode."];
}

-(void)IFA_hideHelpModeInstructions {
    [IFAUIUtils hideHud:self.IFA_helpModeInstructionsHud animated:NO];
}

-(void)IFA_transitionUiForHelpMode:(BOOL)a_helpMode{

    if (![self.observedHelpTargetContainer isKindOfClass:[UIViewController class]]) {
        NSAssert(NO, @"Unexpected class kind for observedHelpTargetContainer: %@", [self.observedHelpTargetContainer class]);
    }

    if (a_helpMode) {
        CGSize l_size = [IFAUIUtils screenBoundsSizeForCurrentOrientation];
        self.IFA_helpModeOverlayView.frame = CGRectMake(0, 0, l_size.width, l_size.height);
    }

    UIView *l_view = [self.observedHelpTargetContainer targetView];
    if (a_helpMode) {
        self.IFA_helpButton = (UIButton*) [l_view viewWithTag:IFAViewTagHelpButton];
        [self IFA_updateScreenHelpButtonFrame];
        [self IFA_updateCancelButtonFrame];
    }else{
        [self IFA_hideHelpModeInstructions];
    }
    __weak __typeof(self) l_weakSelf = self;
    [UIView transitionWithView:l_view duration:0.75 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        if ([self.observedHelpTargetContainer isKindOfClass:[UIViewController class]]) {
            
            UIViewController *l_observedViewController = (UIViewController*)self.observedHelpTargetContainer;
            
            if(a_helpMode){
                if (l_observedViewController.navigationItem) {
                    self.IFA_savedTitle = l_observedViewController.navigationItem.title;
                    l_observedViewController.navigationItem.title = nil;
                    self.IFA_savedHidesBackButton = l_observedViewController.navigationItem.hidesBackButton;
                    l_observedViewController.navigationItem.hidesBackButton = YES;
                }
                [l_view addSubview:self.IFA_helpModeOverlayView];
                [l_view addSubview:self.IFA_cancelButton];
                [l_view addSubview:self.IFA_screenHelpButtonProxyView];
                [l_view addSubview:self.IFA_screenHelpButton];
                self.IFA_helpButton.hidden = YES;
                [l_observedViewController.view addGestureRecognizer:self.IFA_mainViewCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.navigationBar addGestureRecognizer:self.IFA_navigationBarCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.toolbar addGestureRecognizer:self.IFA_toolbarCatchAllGestureRecogniser];
            }else{
                if (l_observedViewController.navigationItem) {
                    l_observedViewController.navigationItem.title = self.IFA_savedTitle;
                    l_observedViewController.navigationItem.hidesBackButton = self.IFA_savedHidesBackButton;
                }
                [l_observedViewController.view removeGestureRecognizer:self.IFA_mainViewCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.navigationBar removeGestureRecognizer:self.IFA_navigationBarCatchAllGestureRecogniser];
                [l_observedViewController.navigationController.toolbar removeGestureRecognizer:self.IFA_toolbarCatchAllGestureRecogniser];
                self.IFA_helpButton.hidden = NO;
                [self.IFA_screenHelpButton removeFromSuperview];
                [self.IFA_screenHelpButtonProxyView removeFromSuperview];
                [self.IFA_cancelButton removeFromSuperview];
                [self.IFA_helpModeOverlayView removeFromSuperview];
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
            [l_weakSelf IFA_showHelpModeInstructions];
        }
        [IFAUtils dispatchAsyncMainThreadBlock:^{
            if (a_helpMode) {
                [l_weakSelf.observedHelpTargetContainer didEnterHelpMode];
            } else {
                [l_weakSelf.observedHelpTargetContainer didExitHelpMode];
            }
        }];
    }];

}

-(void)IFA_onHelpModeInstructionsTimerEvent:(NSTimer*)a_timer{
    [self IFA_showHelpModeInstructions];
}

-(void)IFA_removeHelpTargetSelectionWithAnimation:(BOOL)a_animate dismissPopTipView:(BOOL)a_dismissPopTipView
                       animatePopTipViewDismissal:(BOOL)a_animatePopTipViewDismissal{
    
    // Remove spotlight
    [self.IFA_helpModeOverlayView removeSpotlightWithAnimation:a_animate];
    
    // Remove help target proxy view
    [self.IFA_helpTargetProxyView removeFromSuperview];

    // Remove pop tip
    if (a_dismissPopTipView) {
        [self.IFA_activePopTipView dismissAnimated:a_animatePopTipViewDismissal];
    }else{  // Pop tip has already been dismissed by the user
        if (self.helpMode) {
            [self IFA_scheduleHelpModeInstructions];
        }else{
            [self IFA_removeSimpleHelpBackground];
        }
    }
    self.IFA_activePopTipView = nil;
    
    // Get help overlay ticker going again
//    [IFAUtils dispatchAsyncMainThreadBlock:^{
//        [self.IFA_helpModeOverlayView m_showTicker];
//    }];
//    [IFAUtils dispatchAsyncMainThreadBlock:^{
//        [self.IFA_helpModeOverlayView m_showTicker];
//    } afterDelay:0.5];
//    [self.IFA_helpModeOverlayView m_showTicker];

}

-(void)removeHelpTargetSelectionWithAnimation:(BOOL)a_animate dismissPopTipView:(BOOL)a_dismissPopTipView{
    [self IFA_removeHelpTargetSelectionWithAnimation:a_animate dismissPopTipView:a_dismissPopTipView
                          animatePopTipViewDismissal:NO];
}

-(void)IFA_presentPopTipViewWithTitle:(NSString *)a_title description:(NSString *)a_description pointingAtView:(UIView*)a_view{

    [self IFA_cancelHelpModeInstructions];
    
    // Remove HUD display if present
    [self IFA_hideHelpModeInstructions];

    // Remove previous selection from UI
    [self removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];
    
    // Hide help overlay ticker
//    [IFAUtils dispatchAsyncMainThreadBlock:^{
//        [self.IFA_helpModeOverlayView m_hideTicker];
//    }];
//    [IFAUtils dispatchAsyncMainThreadBlock:^{
//        [self.IFA_helpModeOverlayView m_hideTicker];
//    } afterDelay:0.5];
//    [self.IFA_helpModeOverlayView m_hideTicker];
    
    UIView *l_pointingAtView = nil;
    if (a_view==self.IFA_screenHelpButton || a_view.tag== IFAViewTagHelpButton) {

        self.IFA_helpTargetProxyView = nil;
        l_pointingAtView = a_view==self.IFA_screenHelpButton ? self.IFA_screenHelpButtonProxyView : a_view;

    }else{
        
        // Create help target proxy view (this will define the spotlight area and where what exactly the pop tip bubble should connect to)
        static NSUInteger const k_hPadding = 20;
        static NSUInteger const k_vPadding = 10;
        CGFloat l_x = a_view.frame.origin.x - (k_hPadding / 2);
        CGFloat l_y =  a_view.frame.origin.y - (k_vPadding / 2);
        CGFloat l_width = a_view.frame.size.width + k_hPadding;
        CGFloat l_height = a_view.frame.size.height + k_vPadding;
        CGRect l_helpTargetProxyViewFrame = CGRectMake(l_x, l_y, l_width, l_height);
        l_helpTargetProxyViewFrame = [self.IFA_helpModeOverlayView convertRect:l_helpTargetProxyViewFrame
                                                                      fromView:a_view.superview];
        self.IFA_helpTargetProxyView = [[UIView alloc] initWithFrame:l_helpTargetProxyViewFrame];
        [self.IFA_helpModeOverlayView addSubview:self.IFA_helpTargetProxyView];
        
        // Spotlight selection
        [self.IFA_helpModeOverlayView spotlightAtRect:self.IFA_helpTargetProxyView.frame];
        
        l_pointingAtView = self.IFA_helpTargetProxyView;
        
    }

    // Present the help pop tip
    self.IFA_activePopTipView = [IFAHelpPopTipView new];
    self.IFA_activePopTipView.maximised = a_view==self.IFA_screenHelpButton;
    UIView *l_containerView = [self.observedHelpTargetContainer targetView];
    __weak __typeof(self) l_weakSelf = self;
    [self.IFA_activePopTipView presentWithTitle:a_title description:a_description pointingAtView:l_pointingAtView
                                         inView:l_containerView completionBlock:^{
        // Remove user interaction blocker
        [l_weakSelf.IFA_userInteractionBlockingView removeFromSuperview];
    }];

    // Block user interaction while the help pop tip is loading its contents
    self.IFA_userInteractionBlockingView.frame = self.helpMode ? self.IFA_helpModeOverlayView.frame : CGRectMake(0, 0, l_containerView.frame.size.width, l_containerView.frame.size.height);
    [l_containerView addSubview:self.IFA_userInteractionBlockingView];

}

-(NSString*)IFA_helpStringForKeyPath:(NSString*)a_keyPath{
    NSString *l_string = [[NSBundle mainBundle] localizedStringForKey:a_keyPath value:nil table:@"Help"];
//    NSLog(@"IFA_helpStringForKeyPath");
//    NSLog(@"  a_keyPath = %@", a_keyPath);
//    NSLog(@"  l_string = %@", l_string);
    return [l_string isEqualToString:a_keyPath] ? nil : l_string;
}

-(NSString*)IFA_helpLabelForKeyPath:(NSString*)a_keyPath{
    return [self IFA_helpStringForKeyPath:[NSString stringWithFormat:@"%@.label", a_keyPath]];
}

-(NSString*)IFA_helpTitleForKeyPath:(NSString*)a_keyPath{
    return [self IFA_helpStringForKeyPath:[NSString stringWithFormat:@"%@.title", a_keyPath]];
}

-(NSString*)IFA_helpDescriptionForKeyPath:(NSString*)a_keyPath{
    return [self IFA_helpStringForKeyPath:[NSString stringWithFormat:@"%@.description", a_keyPath]];
}

- (void)IFA_onHelpTargetSelectionForBarButtonItem:(UIBarButtonItem *)a_barButtonItem event:(UIEvent*)a_event{
    
    if (self.IFA_activePopTipView.presentationRequestInProgress) {
        return;
    }
    
    NSLog(@"m_onHelpTargetSelectionForBarButtonItem: %@", a_barButtonItem.helpTargetId);
//    NSLog(@"accessibilityLabel: %@, accessibilityHint: %@, accessibilityValue: %@", a_barButtonItem.accessibilityLabel, a_barButtonItem.accessibilityHint, a_barButtonItem.accessibilityValue);

//    NSDictionary *l_helpDictionary = [IFAUtils getPlistAsDictionary:@"Help"];
//    NSLog(@"   HELP VALUE: %@", [l_helpDictionary valueForKeyPath:a_barButtonItem.helpTargetId]);

    NSAssert([[a_event allTouches] count]==1, @"Unexpected touch set count: %lu", (unsigned long)[[a_event allTouches] count]);
    UIView *l_view = ((UITouch*)[[a_event allTouches] anyObject]).view;
    NSString *l_title = [self IFA_helpTitleForKeyPath:a_barButtonItem.helpTargetId];
    if (!l_title) {
        l_title = a_barButtonItem.accessibilityLabel ? a_barButtonItem.accessibilityLabel : a_barButtonItem.title;
    }
    [self IFA_presentPopTipViewWithTitle:l_title
                             description:[self IFA_helpDescriptionForKeyPath:a_barButtonItem.helpTargetId]
                          pointingAtView:l_view];
    
}

- (void)IFA_onHelpTargetSelectionForTapGestureRecogniser:(UITapGestureRecognizer*)a_tapGestureRecogniser{
    
    if (self.IFA_activePopTipView.presentationRequestInProgress) {
        return;
    }
    
    NSLog(@"m_onHelpTargetSelectionForTapGestureRecogniser - view: %@, helpTargetId: %@", a_tapGestureRecogniser.view, a_tapGestureRecogniser.view.helpTargetId);
//    NSLog(@"IFA_onHelpTargetSelectionForTapGestureRecogniser: %@, helpTargetId: %@", [a_tapGestureRecogniser description], a_tapGestureRecogniser.view.helpTargetId);
    
//    NSDictionary *l_helpDictionary = [IFAUtils getPlistAsDictionary:@"Help"];
//    NSLog(@"   HELP VALUE: %@", [l_helpDictionary valueForKeyPath:a_tapGestureRecogniser.view.helpTargetId]);

    UIViewController *l_viewController = (UIViewController*)self.observedHelpTargetContainer;
    UIView *l_view = a_tapGestureRecogniser.view;
    NSString *l_helpTargetId = l_view.helpTargetId;
    
    NSString *l_title = [self IFA_helpTitleForKeyPath:l_helpTargetId];
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
    [self IFA_presentPopTipViewWithTitle:l_title description:[self IFA_helpDescriptionForKeyPath:l_helpTargetId]
                          pointingAtView:l_view];
    
}

-(void)IFA_onCatchAllGestureRecogniserTap:(UITapGestureRecognizer*)a_tapGestureRecognizer{
    if (a_tapGestureRecognizer==self.IFA_navigationBarCatchAllGestureRecogniser || a_tapGestureRecognizer==self.IFA_toolbarCatchAllGestureRecogniser) {
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

-(UITapGestureRecognizer *)IFA_mainViewCatchAllGestureRecogniser {
    if (!_IFA_mainViewCatchAllGestureRecogniser) {
        _IFA_mainViewCatchAllGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(IFA_onCatchAllGestureRecogniserTap:)];
        _IFA_mainViewCatchAllGestureRecogniser.cancelsTouchesInView = NO;
    }
    return _IFA_mainViewCatchAllGestureRecogniser;
}

-(UITapGestureRecognizer *)IFA_navigationBarCatchAllGestureRecogniser {
    if (!_IFA_navigationBarCatchAllGestureRecogniser) {
        _IFA_navigationBarCatchAllGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(IFA_onCatchAllGestureRecogniserTap:)];
        _IFA_navigationBarCatchAllGestureRecogniser.cancelsTouchesInView = NO;
    }
    return _IFA_navigationBarCatchAllGestureRecogniser;
}

-(UITapGestureRecognizer *)IFA_toolbarCatchAllGestureRecogniser {
    if (!_IFA_toolbarCatchAllGestureRecogniser) {
        _IFA_toolbarCatchAllGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(IFA_onCatchAllGestureRecogniserTap:)];
        _IFA_toolbarCatchAllGestureRecogniser.cancelsTouchesInView = NO;
    }
    return _IFA_toolbarCatchAllGestureRecogniser;
}

-(void)IFA_addHelpTargets {
    
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

-(void)IFA_removeHelpTargets {
    
    // Remove the tab bar item proxy views first
    for (UIView* l_view in self.IFA_tabBarItemProxyViews) {
        [l_view removeFromSuperview];
    }
    [self.IFA_tabBarItemProxyViews removeAllObjects];
    
    // Now remove the remaining help targets
    for (id<IFAHelpTarget> l_helpTarget in [self.IFA_helpTargets copy]) {
        [self removeHelpTarget:l_helpTarget];
    }
    
}

-(void)IFA_removeSimpleHelpBackground {
    IFAAbstractFieldEditorViewController *l_fieldEditorViewController = (IFAAbstractFieldEditorViewController *)self.observedHelpTargetContainer;
    NSAssert(l_fieldEditorViewController, @"l_fieldEditorViewController is nil");
    [[l_fieldEditorViewController.navigationController.view viewWithTag:IFAViewTagHelpBackground] removeFromSuperview];
}

-(void)IFA_onSimpleHelpGestureRecogniserAction:(id)sender{
    [self.IFA_activePopTipView dismissAnimated:YES];
    self.IFA_activePopTipView = nil;
    [self IFA_removeSimpleHelpBackground];
}

-(void)IFA_onHelpButtonTap:(UIButton*)a_button{

    //wip: clean up the help mode stuff
//    if ([self.observedHelpTargetContainer isKindOfClass:[IFAAbstractFieldEditorViewController class]]) { // Simple Help
        
        IFAAbstractFieldEditorViewController *l_fieldEditorViewController = (IFAAbstractFieldEditorViewController *)self.observedHelpTargetContainer;
//        NSLog(@"l_fieldEditorViewController.helpTargetId: %@", l_fieldEditorViewController.helpTargetId);
//        NSLog(@"  l_fieldEditorViewController.view.frame: %@", NSStringFromCGRect(l_fieldEditorViewController.view.frame));
//        NSLog(@"  l_fieldEditorViewController.navigationController.view.frame: %@", NSStringFromCGRect(l_fieldEditorViewController.navigationController.view.frame));
//        NSLog(@"  a_button.frame: %@", NSStringFromCGRect(a_button.frame));

        NSAssert(self.IFA_activePopTipView ==nil, @"self.IFA_activePopTipView no nil: %@", [self.IFA_activePopTipView description]);

        // Configure tap gesture recogniser
        self.IFA_simpleHelpBackgroundGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(IFA_onSimpleHelpGestureRecogniserAction:)];
        
        // Configure background view
        CGRect l_frame = l_fieldEditorViewController.navigationController.view.frame;
        UIView *l_backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, l_frame.size.width, l_frame.size.height)];
        l_backgroundView.tag = IFAViewTagHelpBackground;
        l_backgroundView.backgroundColor = [UIColor clearColor];
        [l_backgroundView addGestureRecognizer:self.IFA_simpleHelpBackgroundGestureRecogniser];
        [l_fieldEditorViewController.navigationController.view addSubview:l_backgroundView];
        
        // Present pop tip view
//    NSString *keyPath = l_fieldEditorViewController.helpTargetId; //wip: review
    NSString *keyPath = @"controllers.NowViewController.screen";
    NSString *l_description = [self IFA_helpDescriptionForKeyPath:keyPath];
        [self IFA_presentPopTipViewWithTitle:nil description:l_description pointingAtView:a_button];

//    }else{  // Help Mode
//        [self toggleHelpMode];
//    }
}

-(void)IFA_onCancelButtonTap:(UIButton*)a_button{
    [self toggleHelpMode];
}

-(void)IFA_onScreenHelpButtonTap:(UIButton*)a_button{
    UIViewController *l_observedViewController = (UIViewController*)self.observedHelpTargetContainer;
    NSString *l_helpTargetId = l_observedViewController.helpTargetId;
    if (!l_helpTargetId) {
        l_helpTargetId = [l_observedViewController ifa_helpTargetIdForName:@"screen"];
    }
    NSLog(@"m_onScreenHelpButtonTap for helpTargetId: %@", l_helpTargetId);
    NSString *l_title = [self IFA_helpTitleForKeyPath:l_helpTargetId];
    if (!l_title) {
        l_title = self.IFA_savedTitle;
    }
    NSString *l_description = [self IFA_helpDescriptionForKeyPath:l_helpTargetId];
    [self IFA_presentPopTipViewWithTitle:l_title description:l_description pointingAtView:a_button];
}

-(IFAHelpTargetView *)IFA_insertHelpTargetViewForView:(UIView *)a_view title:(NSString*)a_title{
//    NSLog(@"m_insertHelpTargetViewForView: %@", a_view);
    IFAHelpTargetView *l_helpTargetView = [[IFAHelpTargetView alloc] initWithFrame:a_view.frame];
//    l_helpTargetView.backgroundColor = [UIColor redColor];
    l_helpTargetView.helpTargetId = a_view.helpTargetId;
    if (a_title) {
        l_helpTargetView.accessibilityLabel = a_title;
    }
    [a_view.superview insertSubview:l_helpTargetView aboveSubview:a_view];
    return l_helpTargetView;
}

- (NSString *)helpDescriptionFor:(NSString *)a_entityName formName:(NSString *)a_formName
                     sectionName:(NSString *)a_sectionName helpTypePath:(NSString *)a_helpTypePath
                                                             createMode:(BOOL)a_createMode {
    NSObject *mode = a_createMode ? @"create" : @"any";
    NSString *keyPath = [NSString stringWithFormat:@"entities.%@.forms.%@.sections.%@.%@.modes.%@", a_entityName,
                                                   a_formName, a_sectionName, a_helpTypePath, mode];
    return [self IFA_helpDescriptionForKeyPath:keyPath];
}

#pragma mark - Public

-(void)observeHelpTargetContainer:(id<IFAHelpTargetContainer>)a_helpTargetContainer{
    
    // Store view controller to be observed
    self.observedHelpTargetContainer = a_helpTargetContainer;
    
    // Reset any pop tip views left over
    self.IFA_activePopTipView = nil;
    
//    NSLog(@"Registered as target view controller for help: %@", [a_helpTargetContainer description]);

}

- (void)helpRequestedForTabBarItemIndex:(NSUInteger)a_index helpTargetId:(NSString *)a_helpTargetId title:(NSString*)a_title{
    NSLog(@"m_helpRequestedForTabBarItemIndex: %@", a_helpTargetId);
    [self IFA_presentPopTipViewWithTitle:a_title description:[self IFA_helpDescriptionForKeyPath:a_helpTargetId]
                          pointingAtView:(self.IFA_tabBarItemProxyViews)[a_index]];
}

-(void)addHelpTarget:(id<IFAHelpTarget>)a_helpTarget{
    
//    NSLog(@"addHelpTarget: %@", [a_helpTarget description]);
    
    // Get a special case out of the way first: UITabBar
    if([a_helpTarget isKindOfClass:[UITabBar class]]){
        
        UITabBar *l_tabBar = (UITabBar*)a_helpTarget;
        NSUInteger l_tabBarItemWidth = (NSUInteger) (l_tabBar.frame.size.width / l_tabBar.items.count);
        for (int i=0; i<l_tabBar.items.count; i++) {
            @autoreleasepool {
                CGRect l_frame = CGRectMake(i*l_tabBarItemWidth, 0, l_tabBarItemWidth, l_tabBar.frame.size.height);
                UIView *l_view = [[UIView alloc] initWithFrame:l_frame];
                l_view.userInteractionEnabled = NO;
                [l_tabBar addSubview:l_view];
                [self.IFA_tabBarItemProxyViews addObject:l_view];
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
            l_barButtonItemSavedState.IFA_enabled = l_barButtonItem.enabled;
            l_barButtonItemSavedState.IFA_target = l_barButtonItem.target;
            l_barButtonItemSavedState.IFA_action = l_barButtonItem.action;
            
            l_barButtonItem.enabled = YES;
            l_barButtonItem.target = self;
            l_barButtonItem.action = @selector(IFA_onHelpTargetSelectionForBarButtonItem:event:);
            
            [self.IFA_helpTargets addObject:l_barButtonItem];
            [self.IFA_helpTargetSavedStates addObject:l_barButtonItemSavedState];
            [self.IFA_helpTargetSelectionGestureRecognisers addObject:[NSNull null]];
            
        }
        
    }else if([a_helpTarget isKindOfClass:[UIView class]]){
        
        UIView *l_view = nil;
        IFAViewSavedState *l_viewSavedState = nil;

        if ([a_helpTarget isKindOfClass:[UIControl class]]) {
            
            UIControl *l_control = (UIControl*)a_helpTarget;
            l_view = [self IFA_insertHelpTargetViewForView:l_control title:nil];

        }else{

            l_view = (UIView*)a_helpTarget;
            
            if ([l_view isKindOfClass:[UITableViewCell class]]) {
                
                UITableViewCell *l_tableViewCell = (UITableViewCell*)a_helpTarget;
                if ([l_view isKindOfClass:[IFAFormTableViewCell class]]) {
                    
                    l_view = [self IFA_insertHelpTargetViewForView:l_view title:l_tableViewCell.textLabel.text];

                }else{
                    
                    IFATableViewCellSavedState *l_tableViewCellSavedState = [IFATableViewCellSavedState new];
                    l_tableViewCellSavedState.IFA_selectionStyle = l_tableViewCell.selectionStyle;
                    l_tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    l_viewSavedState = l_tableViewCellSavedState;
                    
                }
                
            }else{
                
                l_viewSavedState = [IFAViewSavedState new];
                
            }
            
            l_viewSavedState.IFA_userInteractionEnabled = l_view.userInteractionEnabled;
            
            l_view.userInteractionEnabled = YES;

        }
        
        UITapGestureRecognizer *l_tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(IFA_onHelpTargetSelectionForTapGestureRecogniser:)];
        [l_view addGestureRecognizer:l_tapGestureRecogniser];
        
        [self.IFA_helpTargets addObject:l_view];
        [self.IFA_helpTargetSavedStates addObject:l_viewSavedState ? l_viewSavedState : [NSNull null]];
        [self.IFA_helpTargetSelectionGestureRecognisers addObject:l_tapGestureRecogniser];
        
    }else{
        NSAssert(NO, @"Unexpected help target: %@", [a_helpTarget description]);
    }
    
}

-(void)removeHelpTarget:(id<IFAHelpTarget>)a_helpTarget{
    
    NSUInteger l_index = [self.IFA_helpTargets indexOfObject:a_helpTarget];

    if ([a_helpTarget isKindOfClass:[UIBarButtonItem class]]) {
        
        UIBarButtonItem *l_barButtonItem = (UIBarButtonItem*)a_helpTarget;
        IFABarButtonItemSavedState *l_barButtonItemSavedState = (self.IFA_helpTargetSavedStates)[l_index];
        l_barButtonItem.enabled = l_barButtonItemSavedState.IFA_enabled;
        l_barButtonItem.target = l_barButtonItemSavedState.IFA_target;
        l_barButtonItem.action = l_barButtonItemSavedState.IFA_action;
        
    }else if([a_helpTarget isKindOfClass:[UIView class]]){
        
        UIView *l_view = (UIView*)a_helpTarget;
        if ([l_view isKindOfClass:[IFAHelpTargetView class]]) {
            [l_view removeFromSuperview];
        }
        
        id l_obj = (self.IFA_helpTargetSavedStates)[l_index];
        if ([l_obj isKindOfClass:[IFAViewSavedState class]]) { // Safeguard against the cases where the object is a [NSNull null]
            IFAViewSavedState *l_viewSavedState = l_obj;
            l_view.userInteractionEnabled = l_viewSavedState.IFA_userInteractionEnabled;
            if ([a_helpTarget isKindOfClass:[UITableViewCell class]]) {
                IFATableViewCellSavedState *l_tableViewCellSavedState = (IFATableViewCellSavedState *)l_viewSavedState;
                ((UITableViewCell*)l_view).selectionStyle = l_tableViewCellSavedState.IFA_selectionStyle;
            }
        }

        [l_view removeGestureRecognizer:(self.IFA_helpTargetSelectionGestureRecognisers)[l_index]];
        
    }else{
        NSAssert(NO, @"Unexpected help target: %@", [a_helpTarget description]);
    }
    
    [self.IFA_helpTargets removeObjectAtIndex:l_index];
    [self.IFA_helpTargetSavedStates removeObjectAtIndex:l_index];
    [self.IFA_helpTargetSelectionGestureRecognisers removeObjectAtIndex:l_index];

}

-(void)refreshHelpTargets {
    [self IFA_removeHelpTargets];
    [self IFA_addHelpTargets];
}

-(void)IFA_removeHelpTargetSelection {
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

        [self IFA_transitionUiForHelpMode:self.helpMode];

        [self IFA_addHelpTargets];

    }else{

        [self IFA_cancelHelpModeInstructions];

        [self removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];

        [self IFA_removeHelpTargets];

        [self IFA_transitionUiForHelpMode:self.helpMode];
        
    }
    
}

-(UIBarButtonItem*)newHelpBarButtonItem {
    
    // Configure image
    UIImage *l_helpButtonImage = [UIImage imageNamed:@"IFA_Icon_Help"];

    // Configure button
    UIButton *l_helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    l_helpButton.tag = IFAViewTagHelpButton;
    l_helpButton.frame = CGRectMake(0, 0, l_helpButtonImage.size.width, 44);
    l_helpButton.accessibilityLabel = [self accessibilityLabelForKeyPath:[IFAUIUtils helpTargetIdForName:@"helpButton"]];
//    l_helpButton.backgroundColor = [UIColor redColor];
    [l_helpButton setImage:l_helpButtonImage forState:UIControlStateNormal];
    [l_helpButton addTarget:self action:@selector(IFA_onHelpButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    // Configure bar button item
    UIBarButtonItem *l_helpBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:l_helpButton];
    l_helpBarButtonItem.tag = IFABarItemTagHelpButton;
    
    return l_helpBarButtonItem;
    
}

-(BOOL)isHelpEnabledForViewController:(UIViewController*)a_viewController{
    NSArray *l_helpEnabledViewControllerClassNames = [IFAUtils infoPList][@"IFAHelpEnabledViewControllers"];
    return [l_helpEnabledViewControllerClassNames containsObject:[a_viewController.class description]];
}

-(void)resetUi {
    [self removeHelpTargetSelectionWithAnimation:NO dismissPopTipView:YES];
    [self IFA_hideHelpModeInstructions];
    [self IFA_cancelHelpModeInstructions];
    [self IFA_scheduleHelpModeInstructions];
}

-(void)observedViewControllerDidRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self IFA_updateScreenHelpButtonFrame];
    [self IFA_updateCancelButtonFrame];
    [self refreshHelpTargets];
}

-(void)observedViewControllerWillRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self IFA_removeHelpTargetSelection];
}

-(NSString *)accessibilityLabelForKeyPath:(NSString *)a_keyPath{
    NSString *l_accessibilityLabel = [self IFA_helpLabelForKeyPath:a_keyPath];
    if (!l_accessibilityLabel) {
        l_accessibilityLabel = [self IFA_helpTitleForKeyPath:a_keyPath];
    }
    return l_accessibilityLabel;
}

- (NSString *)formSectionHelpForType:(IFAFormSectionHelpType)a_helpType entityName:(NSString *)a_entityName
                            formName:(NSString *)a_formName sectionName:(NSString *)a_sectionName
                          createMode:(BOOL)a_createMode {
    NSString *helpTypePath;
    switch (a_helpType) {
        case IFAFormSectionHelpTypeHeader:
            helpTypePath = @"header";
            break;
        case IFAFormSectionHelpTypeFooter:
            helpTypePath = @"footer";
            break;
    }
    NSString *help = nil;
    if (a_createMode) {
        help = [self helpDescriptionFor:a_entityName formName:a_formName sectionName:a_sectionName
                           helpTypePath:helpTypePath
                             createMode:YES];
    }
    if (!help) {
        help = [self helpDescriptionFor:a_entityName formName:a_formName sectionName:a_sectionName
                           helpTypePath:helpTypePath
                             createMode:NO];
    }
    return help;
}

- (NSString *)helpForPropertyName:(NSString *)a_propertyName inEntityName:(NSString *)a_entityName {
    NSString *keyPath = [NSString stringWithFormat:@"entities.%@.properties.%@", a_entityName, a_propertyName];
    return [self IFA_helpDescriptionForKeyPath:keyPath];
}

- (NSString *)emptyListHelpForEntityName:(NSString *)a_entityName {
    NSString *keyPath = [NSString stringWithFormat:@"entities.%@.list.placeholder", a_entityName];
    return [self IFA_helpDescriptionForKeyPath:keyPath];
}


- (NSString *)formHelpForType:(IFAFormHelpType)a_helpType entityName:(NSString *)a_entityName
                     formName:(NSString *)a_formName {
    NSString *helpTypePath;
    switch (a_helpType){
        case IFAFormHelpTypeHeader:
            helpTypePath = @"header";
            break;
        case IFAFormHelpTypeFooter:
            helpTypePath = @"footer";
            break;
    }
    NSString *keyPath = [NSString stringWithFormat:@"entities.%@.forms.%@.%@", a_entityName,
                                                   a_formName, helpTypePath];
    return [self IFA_helpDescriptionForKeyPath:keyPath];
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
    return [NSString stringWithFormat:@"entities.%@.properties.%@", [a_object ifa_entityName], a_propertyName];
}

#pragma mark - Overrides

-(id)init{

    if (self=[super init]) {

        self.IFA_helpTargets = [NSMutableArray new];
        self.IFA_helpTargetSavedStates = [NSMutableArray new];
        self.IFA_tabBarItemProxyViews = [NSMutableArray new];
        self.IFA_helpTargetSelectionGestureRecognisers = [NSMutableArray new];
        
        // Configure the cancel button
        UIImage *l_cancelButtonImage = [UIImage imageNamed:@"IFA_Icon_Close"];
        self.IFA_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.IFA_cancelButton.frame = CGRectZero;
        self.IFA_cancelButton.accessibilityLabel = [self accessibilityLabelForKeyPath:[IFAUIUtils helpTargetIdForName:@"closeHelpButton"]];
        [self.IFA_cancelButton setImage:l_cancelButtonImage forState:UIControlStateNormal];
        [self.IFA_cancelButton addTarget:self action:@selector(IFA_onCancelButtonTap:)
                        forControlEvents:UIControlEventTouchUpInside];
        
        // Configure the screen help button
        UIImage *l_screenHelpButtonImage = [UIImage imageNamed:@"IFA_Icon_Help"];
        self.IFA_screenHelpButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.IFA_screenHelpButton.frame = CGRectZero;
        self.IFA_screenHelpButton.accessibilityLabel = [self accessibilityLabelForKeyPath:[IFAUIUtils helpTargetIdForName:@"screenHelpButton"]];
        [self.IFA_screenHelpButton setImage:l_screenHelpButtonImage forState:UIControlStateNormal];
        [self.IFA_screenHelpButton addTarget:self action:@selector(IFA_onScreenHelpButtonTap:)
                            forControlEvents:UIControlEventTouchUpInside];
//        self.IFA_screenHelpButton.backgroundColor = [UIColor redColor];
        
        // Configure the screen help button proxy
        static NSUInteger const k_screenHelpButtonProxyViewPadding = 4;
        self.IFA_screenHelpButtonProxyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, l_screenHelpButtonImage.size.width+k_screenHelpButtonProxyViewPadding, l_screenHelpButtonImage.size.height+k_screenHelpButtonProxyViewPadding)];
//        self.IFA_screenHelpButtonProxyView.backgroundColor = [UIColor blueColor];

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
