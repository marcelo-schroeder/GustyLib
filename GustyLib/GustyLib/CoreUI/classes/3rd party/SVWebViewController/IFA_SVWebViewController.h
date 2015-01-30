//
//  IFA_SVWebViewController.h
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/IFA_SVWebViewController

#import "IFAViewController.h"
#import "IFA_SVModalWebViewController.h"
#import "MessageUI/MessageUI.h"

@interface IFA_SVWebViewController : IFAViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) BOOL iphoneUiForAllIdioms;
@property (nonatomic, strong) UIWebView *mainWebView;
@property (nonatomic, readwrite) SVWebViewControllerAvailableActions availableActions;

@property(nonatomic) NSUInteger urlLoadCount;

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
