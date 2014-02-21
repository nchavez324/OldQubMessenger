//
//  RIPTextField.m
//  qub
//
//  Created by Nick on 7/12/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPTextField.h"
#import "UIFont+FlatUI.h"

#import <QuartzCore/QuartzCore.h>

@implementation RIPTextField

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if(self){
		[self customInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self){
		[self customInit];
	}
	return self;
}

- (void)customInit {
	_rowNum = -1;
}

- (void)drawPlaceholderInRect:(CGRect)rect {
	[_placeholderTextColor setFill];
    CGRect r;
    if([[UIDevice currentDevice] systemVersion].floatValue >= 7.0)
        r = CGRectMake(rect.origin.x, (rect.size.height - _placeholderFont.lineHeight)/2.0, rect.size.width, self.font.lineHeight);
    else
        r = rect;

	[[self placeholder] drawInRect:r withFont:_placeholderFont lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
}

- (void) style{
	self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
	UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, self.frame.size.height)];
	leftView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
	self.leftViewMode = UITextFieldViewModeAlways;
	self.leftView = leftView;
	self.font = [UIFont boldFlatFontOfSize:17.0];
	self.textColor = [UIColor whiteColor];
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.placeholderFont = [UIFont flatFontOfSize:16.0];
	self.placeholderTextColor = [UIColor colorWithWhite:0.9 alpha:0.8];
}

@end
