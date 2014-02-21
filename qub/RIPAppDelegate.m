//
//  RIPAppDelegate.m
//  qub
//
//  Created by Nick on 6/24/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPAppDelegate.h"
#import "RIPTextField.h"
#import "RIPLoginViewController.h"
#import "UITextField+FlatUI.h"
#import "SevenSwitch.h"
#import "RIPCoreDataManager.h"

@implementation RIPAppDelegate

+ (RIPAppDelegate *)sharedAppDelegate {
	return (RIPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
    self.contextManager = [[RIPCoreDataManager alloc] init];
	[self.contextManager loadDataFile];
	
	UIStoryboard *mainSb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
	_login = [mainSb instantiateViewControllerWithIdentifier:@"RIPLoginViewController"];
	self.window.rootViewController = _login;
    [self setUpAppearance];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[self.contextManager saveDataFile];
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self.contextManager terminate];
}

- (void)setUpAppearance {
	
    if(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1){
        [[UINavigationBar appearance] configureFlatNavigationBarWithColor:[UIColor skyBlueColor]];
        [[UITabBar appearance] configureFlatTabBarWithBGColor:[UIColor wetAsphaltColor]
                                               selectionColor:[UIColor skyBlueColor]
                                              deselectedColor:[UIColor whiteColor]];
        [UIBarButtonItem configureFlatButtonsWithColor:[UIColor wetAsphaltColor] highlightedColor:[UIColor sunsetBlueColor] cornerRadius:5.0];
    }else{
        [[UINavigationBar appearance] setBarTintColor:[UIColor skyBlueColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                               NSFontAttributeName : [UIFont boldAltFontOfSize:20.0],
                                                               NSForegroundColorAttributeName : [UIColor whiteColor]
                                                               }];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UITabBarItem appearance]
         setTitleTextAttributes:@{NSFontAttributeName:[UIFont flatFontOfSize:10.0], NSForegroundColorAttributeName:[UIColor softMetalColor]} forState:UIControlStateNormal];
        [[UITabBarItem appearance]
         setTitleTextAttributes:@{NSFontAttributeName:[UIFont flatFontOfSize:10.0],NSForegroundColorAttributeName:[UIColor skyBlueColor]} forState:UIControlStateSelected];
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont altFontOfSize:16.0]} forState:UIControlStateNormal];
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont altFontOfSize:16.0]} forState:UIControlStateSelected];
        [[UITabBar appearance] setBarTintColor:[UIColor wetAsphaltColor]];
    }
    
	
    
    //[[FUIButton appearance] setButtonColor:[UIColor softMetalColor]];
	//[[FUIButton appearance] setShadowColor:[UIColor tinColor]];
	[[FUIButton appearance] setButtonColor:[UIColor clearColor]];
	[[FUIButton appearance] setShadowColor:[UIColor clearColor]];
    //[[FUIButton appearance] setShadowHeight:3.0];
	//[[FUIButton appearance] setCornerRadius:6.0];
    [[FUIButton appearance] setShadowHeight:0.0];
	[[FUIButton appearance] setCornerRadius:0.0];
	//[[FUIButton appearance] setTitleColor:[UIColor skyBlueColor] forState:UIControlStateNormal];
	//[[FUIButton appearance] setTitleColor:[UIColor skyBlueColor] forState:UIControlStateHighlighted];
    [[FUIButton appearance] setTitleColor:[UIColor softMetalColor] forState:UIControlStateNormal];
	[[FUIButton appearance] setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	
	[[RIPTextField appearance] setBackgroundColor:[UIColor whiteColor]];
	[[RIPTextField appearance] setCornerRadius:3.0];
	[[RIPTextField appearance] setFont:[UIFont flatFontOfSize:16.0]];
	
	[[FUISwitch appearance] setOnColor:[UIColor skyBlueColor]];
	[[FUISwitch appearance] setOffColor:[UIColor softMetalColor]];
	[[FUISwitch appearance] setOnBackgroundColor:[UIColor wetAsphaltColor]];
	[[FUISwitch appearance] setOffBackgroundColor:[UIColor tinColor]];
	[[FUISwitch appearance] setHighlightedColor:[UIColor sunsetBlueColor]];
	
	///* Apperance does not work... :_(
	[[SevenSwitch appearance] setKnobColor:[UIColor whiteColor]];
	[[SevenSwitch appearance] setActiveColor:[UIColor softMetalColor]];
	[[SevenSwitch appearance] setInactiveColor:[UIColor tinColor]];
	[[SevenSwitch appearance] setOnColor:[UIColor skyBlueColor]];
	[[SevenSwitch appearance] performSelector:@selector(setBorderColor:) withObject:[UIColor softMetalColor]];
	[[SevenSwitch appearance] setShadowColor:[UIColor wetAsphaltColor]];
	[[SevenSwitch appearance] setOnImage:[UIImage imageNamed:@"checkIcon"]];
	[[SevenSwitch appearance] setOffImage:[UIImage imageNamed:@"crossIcon"]];
	//[[SevenSwitch appearance] setIsRounded:NO];
	// 
	[[FUIAlertView appearance] setDefaultButtonColor:[UIColor softMetalColor]];
	[[FUIAlertView appearance] setDefaultButtonShadowColor:[UIColor tinColor]];
	[[FUIAlertView appearance] setDefaultButtonFont:[UIFont boldFlatFontOfSize:16.0]];
	
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

+ (BOOL)usingCircularAvatars {
    return YES;
}

@end
