//
//  UIFont+FlatUI.m
//  FlatUI
//
//  Created by Jack Flintermann on 5/7/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "UIFont+FlatUI.h"
#import <CoreText/CoreText.h>

@implementation UIFont (FlatUI)

+ (UIFont *)flatFontOfSize:(CGFloat)size {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL * url = [[NSBundle mainBundle] URLForResource:@"Lato-Regular" withExtension:@"ttf"];
		CFErrorRef error;
        CTFontManagerRegisterFontsForURL((__bridge CFURLRef)url, kCTFontManagerScopeNone, &error);
        error = nil;
    });
    return [UIFont fontWithName:@"Lato-Regular" size:size];
}

+ (UIFont *)boldFlatFontOfSize:(CGFloat)size {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL * url = [[NSBundle mainBundle] URLForResource:@"Lato-Bold" withExtension:@"ttf"];
		CFErrorRef error;
        CTFontManagerRegisterFontsForURL((__bridge CFURLRef)url, kCTFontManagerScopeNone, &error);
        error = nil;
    });
    return [UIFont fontWithName:@"Lato-Bold" size:size];
}

+ (UIFont *)altFontOfSize:(CGFloat)size {
	return [UIFont fontWithName:@"Avenir" size:size];
}

+ (UIFont *)boldAltFontOfSize:(CGFloat)size {
	return [UIFont fontWithName:@"Avenir-Black" size:size];
}

+ (UIFont *)italicAltFontOfSize:(CGFloat)size {
	return [UIFont fontWithName:@"Avenir-BlackOblique" size:size];
}

+ (UIFont *)italicFlatFontOfSize:(CGFloat)size {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL * url = [[NSBundle mainBundle] URLForResource:@"Lato-Italic" withExtension:@"ttf"];
		CFErrorRef error;
        CTFontManagerRegisterFontsForURL((__bridge CFURLRef)url, kCTFontManagerScopeNone, &error);
        error = nil;
    });
    return [UIFont fontWithName:@"Lato-Italic" size:size];
}

@end
