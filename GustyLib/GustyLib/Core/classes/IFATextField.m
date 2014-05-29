//
//  IFATextField.m
//  Gusty
//
//  Created by Marcelo Schroeder on 22/05/12.
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

#import "IFATextField.h"

@implementation IFATextField


#pragma mark - Overrides

//-(CGRect)textRectForBounds:(CGRect)bounds{
//    if (self.textPaddingEnabled) {
//        return CGRectMake(bounds.origin.x + self.leftTextPadding, bounds.origin.y + self.topTextPadding, bounds.size.width - self.rightTextPadding, bounds.size.height - self.bottomTextPadding);
//    }else{
//        return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
//    }
//}
//
//-(CGRect)editingRectForBounds:(CGRect)bounds{
//    if (self.editingPaddingEnabled) {
//        return CGRectMake(bounds.origin.x + self.leftEditingPadding, bounds.origin.y + self.topEditingPadding, bounds.size.width - self.rightEditingPadding, bounds.size.height - self.bottomEditingPadding);
//    }else{
//        return CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
//    }
//}

@end
