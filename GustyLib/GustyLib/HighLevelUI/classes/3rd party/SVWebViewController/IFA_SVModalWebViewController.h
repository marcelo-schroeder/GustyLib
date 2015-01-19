//
//  IFA_SVModalWebViewController.h
//
//  Created by Oliver Letterer on 13.08.11.
//  Copyright 2011 Home. All rights reserved.
//
//  https://github.com/samvermette/IFA_SVWebViewController

#import <UIKit/UIKit.h>

enum {
    SVWebViewControllerAvailableActionsNone             = 0,
    SVWebViewControllerAvailableActionsOpenInSafari     = 1 << 0,
    SVWebViewControllerAvailableActionsMailLink         = 1 << 1,
    SVWebViewControllerAvailableActionsCopyLink         = 1 << 2
};

typedef NSUInteger SVWebViewControllerAvailableActions;


@class IFA_SVWebViewController;

@interface IFA_SVModalWebViewController : UINavigationController

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)url;
- (id)initWithURL:(NSURL*)url completionBlock:(void(^)(void))a_completionBlock;

@property (nonatomic, strong) UIColor *barsTintColor;
@property (nonatomic, readwrite) SVWebViewControllerAvailableActions availableActions;
@property (nonatomic, strong, readonly) IFA_SVWebViewController *webViewController;

@end
