//
//  RIPChangePasswordViewController.m
//  qub
//
//  Created by Nick on 7/12/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPChangePasswordViewController.h"
#import "RIPTextField.h"

#import "FUIButton.h"
#import "UIFont+FlatUI.h"
#import <QuartzCore/QuartzCore.h>

static NSInteger kOrigPass     = 0;
static NSInteger kNewPass      = 1;
static NSInteger kConfirmPass  = 2;

@interface RIPChangePasswordViewController ()

@end

@implementation RIPChangePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	for(RIPTextField *textField in _fields){
		[textField style];
	}
	((RIPTextField *)[self.view viewWithTag:(kOrigPass + 1)]).placeholder    = NSLocalizedString(@"PASSWORD_ORIGINAL", @"Placeholder text for original password field");
	((RIPTextField *)[self.view viewWithTag:(kNewPass + 1)]).placeholder     = NSLocalizedString(@"PASSWORD_NEW", @"Placeholder text for new password field");
	((RIPTextField *)[self.view viewWithTag:(kConfirmPass + 1)]).placeholder = NSLocalizedString(@"PASSWORD_CONFIRM", @"Placeholder text for new password confirm field");
	[_changeButton setTitle:NSLocalizedString(@"TABLE_CELL_PASSWORD", @"Title for Change Password cell") forState:UIControlStateNormal];
	[_changeButton.titleLabel setNumberOfLines:2];
	
	self.title = NSLocalizedString(@"LABEL_PASSWORD", @"Password label prompt");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeButtonPress:(FUIButton *)sender {
}

- (IBAction)didEndOnExit:(RIPTextField *)sender {
	[sender resignFirstResponder];
	if(sender.tag < 3){
		[[self.view viewWithTag:(sender.tag + 1)] becomeFirstResponder];
	}
}
@end
