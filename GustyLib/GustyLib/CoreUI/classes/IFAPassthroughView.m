//
// Created by Marcelo Schroeder on 29/01/2014.
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

#import "GustyLibCoreUI.h"

@interface IFAPassthroughView ()

@property(nonatomic) BOOL IFA_excludeMyself;
@end

@implementation IFAPassthroughView {

}

#pragma mark - Private

- (UIView *)hitTestChildrenOfView:(UIView *)a_parentView point:(CGPoint)a_point withEvent:(UIEvent *)a_event {
    self.IFA_excludeMyself = YES;
    UIView *l_view = nil;
    for (UIView *l_subView in a_parentView.subviews.reverseObjectEnumerator) {
        CGPoint l_point = [l_subView convertPoint:a_point fromView:self];
        l_view = [l_subView hitTest:l_point withEvent:a_event];
        if (l_view) {
            break;
        }
    }
    self.IFA_excludeMyself = NO;
    return l_view;
}

#pragma mark - Overrides

- (void)ifa_commonInit {
    [super ifa_commonInit];
    self.backgroundColor = [UIColor clearColor];
}

- (id)init {
    self = [super init];
    if (self) {
        [self ifa_commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ifa_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self ifa_commonInit];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    if (self.IFA_excludeMyself) {   // It is attempting to predict which view will be hit ignoring self, so bail out immediately returning nil
        return nil;
    } else {
        CGRect keyboardFrame = [IFAApplicationDelegate sharedInstance].keyboardFrame;
        CGPoint pointInGlobalCoordinateSystem = [self convertPoint:point toView:nil];
        if (CGRectContainsPoint(keyboardFrame, pointInGlobalCoordinateSystem)) {
            return [super hitTest:point withEvent:event];
        }
    }

    // Attempt to predict which view will be hit ignoring self
    UIView *l_topLevelView = self.window;
    UIView *l_predictedView = [self hitTestChildrenOfView:l_topLevelView point:point withEvent:event];

    if (self.shouldDismissKeyboardOnNonTextInputInteractions) {
        BOOL l_viewIsATextInput = [l_predictedView conformsToProtocol:@protocol(UITextInput)];
        BOOL l_viewIsAButtonInsideATextInput = [l_predictedView isKindOfClass:[UIButton class]] && [l_predictedView.superview conformsToProtocol:@protocol(UITextInput)]; //e.g. the clear button in a text field
        if (!l_viewIsATextInput && !l_viewIsAButtonInsideATextInput) {
            [self.window endEditing:YES];
        }
    }

    if (self.hitTestBlock) {
        return self.hitTestBlock(point, event, l_predictedView);
    } else {
        return nil;
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
//    NSLog(@"touchesBegan");
//    NSLog(@"  touches = %@", [touches description]);
//    NSLog(@"  event = %@", [event description]);
//    UITouch *touch = [[event allTouches] anyObject];
//    NSLog(@"  touch.view = %@", touch.view);
    if (self.touchesEndedBlock) {
        self.touchesEndedBlock(touches, event);
    }
}

@end