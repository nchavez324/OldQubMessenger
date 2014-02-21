//
//  UITextField+FlatUI.m
//  qub
//
//  Created by Nick on 6/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UITextField+FlatUI.h"

@implementation UITextField (FlatUI)

- (CGFloat)cornerRadius {
	return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
	self.layer.cornerRadius = cornerRadius;
}

@end
