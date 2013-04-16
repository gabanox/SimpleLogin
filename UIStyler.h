//
//  UIStyler.h
//  SimpleLogin
//
//  Created by Gabriel Ramirez on 4/7/13.
//  Copyright (c) 2013 badge.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIStyler : NSObject

+ (UILabel *) styleLabel:(UILabel *) aLabel withColor:(UIColor *) aColor;

+ (UITextField *)styleTextFieldForLoginTableWithTableCell: (UITableViewCell *)aCell textIndicator: (NSString *)aLabel;
@end
