//
//  RIPCenterViewController.h
//  qub
//
//  Created by Nick on 6/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RIPConnectionInit.h"

@class RIPContactsViewController;
@class RIPConvosViewController;

@interface RIPCenterViewController : UITabBarController <UITabBarControllerDelegate>

@property (assign, nonatomic) UserLoginSuccess success;

@property (nonatomic, weak, readonly)RIPContactsViewController *contactsVc;
@property (nonatomic, weak, readonly)RIPConvosViewController *convosVc;

@end
