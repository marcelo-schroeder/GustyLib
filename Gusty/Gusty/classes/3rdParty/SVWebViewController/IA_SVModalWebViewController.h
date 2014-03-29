//
//  SVModalWebViewController.h
//
//  Created by Oliver Letterer on 13.08.11.
//  Copyright 2011 Home. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import <UIKit/UIKit.h>

enum {
    IA_SVWebViewControllerAvailableActionsNone = 0,
    IA_SVWebViewControllerAvailableActionsOpenInSafari = 1 << 0,
    IA_SVWebViewControllerAvailableActionsMailLink = 1 << 1,
    IA_SVWebViewControllerAvailableActionsCopyLink = 1 << 2
};

typedef NSUInteger IA_SVWebViewControllerAvailableActions;


@class IA_SVWebViewController;

@interface IA_SVModalWebViewController : UINavigationController

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)url;
- (id)initWithURL:(NSURL*)url completionBlock:(void(^)(void))a_completionBlock;

@property (nonatomic, strong) UIColor *barsTintColor;
@property (nonatomic, readwrite) IA_SVWebViewControllerAvailableActions availableActions;
@property (nonatomic, strong, readonly) IA_SVWebViewController *webViewController;

@end
