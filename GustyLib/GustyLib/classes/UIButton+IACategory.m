//
// Created by Marcelo Schroeder on 6/06/13.
// Copyright (c) 2013 InfoAccent Pty Limited. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "IACommon.h"


@implementation UIButton (IACategory)

+ (id)m_buttonWithType:(UIButtonType)a_buttonType appearanceId:(NSString *)a_appearanceId {
    UIButton *a_button = [self buttonWithType:a_buttonType];
    a_button.p_appearanceId = a_appearanceId;
    [a_button m_init];
    return a_button;
}

@end