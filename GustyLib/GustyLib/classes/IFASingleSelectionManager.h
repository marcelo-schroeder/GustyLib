//
//  IFASingleSelectionManager.h
//  Gusty
//
//  Created by Marcelo Schroeder on 18/10/10.
//  Copyright 2010 InfoAccent Pty Limited. All rights reserved.
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

@interface IFASingleSelectionManager : IFASelectionManager {

}

@property (nonatomic, strong) id selectedObject;
@property (nonatomic, readonly) NSIndexPath *selectedIndexPath;

- (id)initWithSelectionManagerDelegate:(id<IFASelectionManagerDelegate>)aDelegate selectedObject:(id)aSelectedObject;
- (id)initWithSelectionManagerDelegate:(id<IFASelectionManagerDelegate>)aDelegate;

@end
