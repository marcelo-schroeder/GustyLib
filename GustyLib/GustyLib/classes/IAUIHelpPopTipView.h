//
//  IAUIHelpPopTipView.h
//  Gusty
//
//  Created by Marcelo Schroeder on 17/04/12.
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

#import "IA_CMPopTipView.h"

@interface IAUIHelpPopTipView : IA_CMPopTipView <IA_CMPopTipViewDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate>

@property (atomic) BOOL p_presentationRequestInProgress;
@property (atomic) BOOL p_maximised;
@property (atomic) BOOL p_isTitlePositionFixed;

-(void)m_presentWithTitle:(NSString*)a_title description:(NSString*)a_description pointingAtView:(UIView *)a_viewPointedAt inView:(UIView *)a_viewPresentedIn completionBlock:(void (^)(void))a_completionBlock;

@end
