//
//  RIPPulseLabel.m
//  qub
//
//  Created by Nick on 9/2/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPPulseLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface RIPPulseLabel ()
@property (strong, nonatomic) NSTimer *fadeTimer;
@property (strong, nonatomic) UIColor *pulseColor;
@end

static CGFloat const kStep = 0.1;

@implementation RIPPulseLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)pulse:(UIColor *)color{
	_pulseColor = color;
	self.layer.shadowColor = _pulseColor.CGColor;
	self.layer.shadowOffset = CGSizeMake(0.0, 0.0);
	self.layer.shadowOpacity = 1.0;
	self.layer.shadowRadius = 4.0;
	if(_fadeTimer != nil) [_fadeTimer invalidate];
	_fadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(updateLabel:) userInfo:nil repeats:YES];
}
- (void)updateLabel:(NSTimer *)timer {
	UIColor *c = [UIColor colorWithCGColor:self.layer.shadowColor];
	CGFloat r,g,b,a;
	if(![c getRed:&r green:&g blue:&b alpha:&a]){
		[c getWhite:&r alpha:&a];
		g = a; b = a;
	}
	if(a <= kStep){
		self.layer.shadowColor = [UIColor colorWithRed:r green:g blue:b alpha:0].CGColor;
		[timer invalidate];
		_fadeTimer = nil;
	}else{
		self.layer.shadowColor = [UIColor colorWithRed:r green:g blue:b alpha:a-kStep].CGColor;
	}
}

@end
