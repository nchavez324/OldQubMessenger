//
//  RIPChangePasswordViewController.h
//  qub
//
//  Created by Nick on 7/12/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FUIButton;
@class RIPTextField;

@interface RIPChangePasswordViewController : UIViewController
@property (strong, nonatomic) IBOutletCollection(RIPTextField) NSArray *fields;
@property (weak, nonatomic) IBOutlet FUIButton *changeButton;

- (IBAction)changeButtonPress:(FUIButton *)sender;
- (IBAction)didEndOnExit:(RIPTextField *)sender;
@end
