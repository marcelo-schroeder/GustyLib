//
//  IFAOperation.h
//  Gusty
//
//  Created by Marcelo Schroeder on 2/09/11.
//  Copyright 2011 InfoAccent Pty Limited. All rights reserved.
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

@class IFAWorkInProgressModalViewManager;

/**
* This is an NSOperation with added UI progress tracking using <IFAWorkInProgressModalViewManager>.
*/
@interface IFAOperation : NSOperation

/**
* Work in progress modal view manager used to track progress between the operation and the UI.
*/
@property(nonatomic, weak) IFAWorkInProgressModalViewManager *workInProgressModalViewManager;

/**
* Indicates whether the progress to be tracked will determinate (YES) or not (NO).
* If set to YES, then use the <determinateProgressPercentage> property to indicate how much of the operation's work has been completed.
* The default is NO.
*/
@property (nonatomic) BOOL determinateProgress;

/**
* Progress percentage completed with a range between 0 and 1.
* This property is only relevant when the <determinateProgress> property is set to YES.
*/
@property (nonatomic) float determinateProgressPercentage;

/**
* Progress message to be displayed on the UI.
*/
@property (nonatomic, strong) NSString *progressMessage;

/**
* Indicates whether user cancellation is allowed (YES) or not (NO).
* The default is YES.
*/
@property (nonatomic) BOOL allowsCancellation;

@end
