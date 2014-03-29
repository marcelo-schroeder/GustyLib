//
//  SVModalWebViewController.m
//
//  Created by Oliver Letterer on 13.08.11.
//  Copyright 2011 Home. All rights reserved.
//
//  https://github.com/samvermette/SVWebViewController

#import "IA_SVModalWebViewController.h"
#import "IA_SVWebViewController.h"

@interface IA_SVModalWebViewController ()

@property (nonatomic, strong) IA_SVWebViewController *webViewController;

@end


@implementation IA_SVModalWebViewController

@synthesize barsTintColor, availableActions, webViewController;

#pragma mark - Initialization


- (id)initWithAddress:(NSString*)urlString {
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL*)url {
    return [self initWithURL:url completionBlock:NULL];
}

- (id)initWithURL:(NSURL*)url completionBlock:(void(^)(void))a_completionBlock {
    self.webViewController = [[IA_SVWebViewController alloc] initWithURL:url completionBlock:a_completionBlock];
    if (self = [super initWithRootViewController:self.webViewController]) {
        // Made the change below to allow the button to be styled via the appearance proxy
        //        self.webViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:webViewController action:@selector(doneButtonClicked:)];
        self.webViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:webViewController action:@selector(doneButtonClicked:)];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    
    if (self.barsTintColor) {
        self.navigationBar.tintColor = self.toolbar.tintColor = self.barsTintColor;
    }
}

- (void)setAvailableActions:(IA_SVWebViewControllerAvailableActions)newAvailableActions {
    self.webViewController.availableActions = newAvailableActions;
}

@end
