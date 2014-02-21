//
//  UITabBar+FlatUI.m
//  qub
//
//  Created by Nick on 6/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "UITabBar+FlatUI.h"

#import "UIFont+FlatUI.h"

@implementation UITabBar (FlatUI)

- (void) configureFlatTabBarWithBGColor:(UIColor *)bgColor selectionColor:(UIColor *)selColor deselectedColor:(UIColor *)desColor{
	
	CGRect rect = CGRectMake(0, 0, 1, 1);
	
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, bgColor.CGColor);
	CGContextFillRect(context, rect);
	UIImage *tabImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIGraphicsBeginImageContext(rect.size);
	context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
	CGContextFillRect(context, rect);
	UIImage *selImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	for(UITabBarItem *item in self.items){
		[item
		 setTitleTextAttributes:@{
		 UITextAttributeFont:[UIFont flatFontOfSize:11],
		 UITextAttributeTextColor:desColor
		 }
		 forState:UIControlStateNormal];
		[item
		 setTitleTextAttributes:@{
		 UITextAttributeFont:[UIFont flatFontOfSize:11],
		 UITextAttributeTextColor:selColor
		 }
		 forState:UIControlStateSelected];
	}
	
	self.backgroundImage = tabImage;
	self.selectionIndicatorImage = selImage;
}

@end
