//
// Created by Marcelo Schroeder on 18/08/2014.
// Copyright (c) 2014 InfoAccent Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFAView.h"

@class IFAFormTableViewCell;


@interface IFAFormTableViewCellContentView : IFAView {
    
}
@property (weak, nonatomic) IBOutlet IFAFormTableViewCell *formTableViewCell;
@end