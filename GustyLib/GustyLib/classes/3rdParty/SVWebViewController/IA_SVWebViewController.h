//
//  SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "IAUIViewController.h"
#import "IA_SVModalWebViewController.h"

@interface IA_SVWebViewController : IAUIViewController <UIWebViewDelegate>

@property (nonatomic) BOOL iphoneUiForAllIdioms;
@property (nonatomic, strong) UIWebView *mainWebView;
@property (nonatomic, readwrite) IA_SVWebViewControllerAvailableActions availableActions;

@property(nonatomic) NSUInteger p_urlLoadCount;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)url;
- (id)initWithURL:(NSURL*)url completionBlock:(void(^)(void))a_completionBlock;

- (void)doneButtonClicked:(id)sender;

- (void)updateToolbarItems;

- (void)goBackClicked:(UIBarButtonItem *)sender;
- (void)goForwardClicked:(UIBarButtonItem *)sender;
- (void)reloadClicked:(UIBarButtonItem *)sender;
- (void)stopClicked:(UIBarButtonItem *)sender;

@end
