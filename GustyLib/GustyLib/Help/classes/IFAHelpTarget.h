//
// Created by Marcelo Schroeder on 29/09/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* This protocol declares an object as having help.
* Help text is obtained from Help.strings.
*/
@protocol IFAHelpTarget <NSObject>

@required

/**
* @return ID linking this object to an entry in Help.strings.
* The entry in Help.strings will have this key format:
*   <helpTargetId>.description
*/
- (NSString *)helpTargetId;

@end