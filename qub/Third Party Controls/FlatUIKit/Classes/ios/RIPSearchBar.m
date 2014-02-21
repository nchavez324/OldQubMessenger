//
//  RIPSearchBar.m
//  qub
//
//  Created by Nick on 8/20/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPSearchBar.h"
#import "UIColor+FlatUI.h"
#import "UIImage+FlatUI.h"
#import "FUIButton.h"
#import "UIFont+FlatUI.h"
#import <QuartzCore/QuartzCore.h>

@implementation RIPSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
}

- (void)layoutSubviews{
    if(NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1){
        UITextField *searchField = nil;
        UIButton *cancelButton = nil;
        NSUInteger numViews = [self.subviews count];
        for(NSInteger i = 0; i < numViews; i++){
            if([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]){
                searchField = [self.subviews objectAtIndex:i];
            }else if([[self.subviews objectAtIndex:i] isKindOfClass:[UIButton class]]){
                cancelButton = [self.subviews objectAtIndex:i];
            }
        }
        if(searchField != nil){
            searchField.backgroundColor = [UIColor clearColor];
            searchField.font = [UIFont boldFlatFontOfSize:17.0];
            searchField.textColor = [UIColor midnightBlueColor];
        }
        if(cancelButton != nil){
            [cancelButton setBackgroundImage:[UIImage imageWithColor:[UIColor skyBlueColor] cornerRadius:5.0] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[UIImage imageWithColor:[UIColor wetAsphaltColor] cornerRadius:5.0]  forState:UIControlStateHighlighted];
            [cancelButton.titleLabel setFont:[UIFont boldFlatFontOfSize:14.0]];
            [cancelButton.titleLabel setShadowColor:[UIColor clearColor]];
            [cancelButton.titleLabel setShadowOffset:CGSizeMake(0, 0)];
        }
        [self setBackgroundImage:[UIImage imageWithColor:[UIColor softMetalColor]]];
    }
	[super layoutSubviews];
}

@end
