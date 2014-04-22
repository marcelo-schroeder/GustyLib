//
// Created by Marcelo Schroeder on 29/01/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import "IAUIPassthroughView.h"
#import "NSObject+IACategory.h"

@interface IAUIPassthroughView ()

@property(nonatomic) BOOL p_excludeMyself;
@end

@implementation IAUIPassthroughView {

}

#pragma mark - Private

- (UIView *)hitTestChildrenOfView:(UIView *)a_parentView point:(CGPoint)a_point withEvent:(UIEvent *)a_event {
    self.p_excludeMyself = YES;
    UIView *l_view = nil;
    for (UIView *l_subView in a_parentView.subviews) {
        CGPoint l_point = [l_subView convertPoint:a_point fromView:self];
        l_view = [l_subView hitTest:l_point withEvent:a_event];
        if (l_view) {
            break;
        }
    }
    self.p_excludeMyself = NO;
    return l_view;
}

#pragma mark - Overrides

- (void)m_commonInit {
    [super m_commonInit];
    self.backgroundColor = [UIColor clearColor];
}

- (id)init {
    self = [super init];
    if (self) {
        [self m_commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self m_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self m_commonInit];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.p_excludeMyself) {
        return nil;
    }
    UIView *l_topLevelView = self.window;
    UIView *l_view = [self hitTestChildrenOfView:l_topLevelView point:point withEvent:event];
    if (self.p_shouldDismissKeyboardOnNonTextInputInteractions) {
        BOOL l_viewIsATextInput = [l_view conformsToProtocol:@protocol(UITextInput)];
        BOOL l_viewIsAButtonInsideATextInput = [l_view isKindOfClass:[UIButton class]] && [l_view.superview conformsToProtocol:@protocol(UITextInput)]; //e.g. the clear button in a text field
        if (!l_viewIsATextInput && !l_viewIsAButtonInsideATextInput) {
            [self.window endEditing:YES];
        }
    }
    if (self.p_hitTestBlock) {
        self.p_hitTestBlock(point, event, l_view);
    }
    return l_view;
}

@end