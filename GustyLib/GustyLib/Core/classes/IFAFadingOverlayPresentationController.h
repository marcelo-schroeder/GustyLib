//
// Created by Marcelo Schroeder on 24/09/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
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

#import <Foundation/Foundation.h>

@protocol IFAFadingOverlayPresentationControllerDataSource;

/**
* Presentation controller that presents content on top of a provided overlay view.
* A fading animation is used for transitions. The animation runs alongside the transition coordinator's animation.
*/
@interface IFAFadingOverlayPresentationController : UIPresentationController

/**
* Required presentation controller's data source.
*/
@property (nonatomic, weak) id<IFAFadingOverlayPresentationControllerDataSource> fadingOverlayPresentationControllerDataSource;

@end

/**
* Data source for the presentation controller.
*/
@protocol IFAFadingOverlayPresentationControllerDataSource <NSObject>

@required

/**
* Request for an overlay view.
* @param a_fadingOverlayPresentationController The sender.
* @returns Overlay view to be used as the background view.
*/
- (UIView *)overlayViewForFadingOverlayPresentationController:(IFAFadingOverlayPresentationController *)a_fadingOverlayPresentationController;

@end