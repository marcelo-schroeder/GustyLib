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

/**
* This class manages the state of single object selection, and it offers optional integration with a table view controller for managing associated view state.
*/
@interface IFASingleSelectionManager : IFASelectionManager {

}

/**
* Currently selected object.
*/
@property (nonatomic, strong) id selectedObject;

/**
* Currently selected index path.
*/
@property (nonatomic, readonly) NSIndexPath *selectedIndexPath;

/**
* Convenience initialiser.
* @param a_dataSource The selection manager's data source (required).
* @param a_selectedObject Any previously selected object (optional).
*/
- (id)initWithSelectionManagerDataSource:(id<IFASelectionManagerDataSource>)a_dataSource selectedObject:(id)a_selectedObject;

@end
