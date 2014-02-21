//
//  RIPLoginViewController.h
//  qub
//
//  Created by Nick on 6/24/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlatUIKit.h"
#import "RIPConnectionInit.h"

@class RIPTextField;
@class RIPPulseLabel;
@class MMDrawerController;

@interface RIPLoginViewController : UIViewController

@property (nonatomic, weak) IBOutlet RIPTextField * usernameField;
@property (nonatomic, weak) IBOutlet RIPTextField * passwordField;
@property (weak, nonatomic) IBOutlet FUIButton *loginButton;
@property (nonatomic, weak) IBOutlet FUIButton *signUpButton;
@property (nonatomic, weak) IBOutlet UIButton * forgotButton;
@property (nonatomic, weak) IBOutlet UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet RIPPulseLabel *errorLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *largeActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *smallActivityIndicator;

- (void)handleUserLoginSuccess:(UserLoginSuccess)success withJSON:JSON passwordHash:(NSString *)passwordHash completion:(void(^)())completion;
- (IBAction)didEndOnExit:(RIPTextField *)sender;
- (IBAction)signUpButtonPress:(UIButton *)sender;
- (IBAction)loginButtonPressed:(UIButton *)sender;
- (IBAction)forgotPasswordButton:(UIButton *)sender;
- (IBAction)backgroundTap:(id)sender;

+ (MMDrawerController *)setupMainScreen;

@end
