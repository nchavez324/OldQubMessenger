//
//  RIPTextField.h
//  qub
//
//  Created by Nick on 7/12/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIPTextField : UITextField

@property (strong, nonatomic) UIColor *placeholderTextColor;
@property (strong, nonatomic) UIFont *placeholderFont;
@property (assign, nonatomic) NSInteger rowNum;

- (void)style;

@end
