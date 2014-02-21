//
//  RIPAppDelegate.h
//  qub
//
//  Created by Nick on 6/24/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIPConnectionInit.h"
#import "RIPErrorCodes.h"

@class RIPLoginViewController;
@class MGNavigationTransitioningDelegate;
@class RIPCoreDataManager;

@interface RIPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RIPCoreDataManager *contextManager;
@property (strong, nonatomic) MGNavigationTransitioningDelegate *navigationTransitionDelegate;

/** Main View Controllers **/

@property (strong, nonatomic) RIPLoginViewController *login;

+ (BOOL)usingCircularAvatars;
+ (RIPAppDelegate *) sharedAppDelegate;


@end
