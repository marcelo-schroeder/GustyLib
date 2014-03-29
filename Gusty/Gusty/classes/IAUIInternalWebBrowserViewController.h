//
// Created by Marcelo Schroeder on 27/03/2014.
// Copyright (c) 2014 InfoAccent Pty Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVWebViewController.h"

@protocol IAUIInternalWebBrowserViewControllerDelegate <NSObject>

- (UIBarButtonItem *)m_newActionBarButtonItem;
- (UIBarButtonItem *)m_newPreviousBarButtonItem;
- (UIBarButtonItem *)m_newNextBarButtonItem;
- (UIBarButtonItem *)m_newStopBarButtonItem;
- (UIBarButtonItem *)m_newRefreshBarButtonItem;

@end
@interface IAUIInternalWebBrowserViewController : SVWebViewController <IAUIInternalWebBrowserViewControllerDelegate>
@property(nonatomic, weak) id<IAUIInternalWebBrowserViewControllerDelegate> p_delegate;
@end
