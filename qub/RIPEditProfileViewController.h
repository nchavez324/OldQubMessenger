//
//  RIPEditProfileViewController.h
//  qub
//
//  Created by Nick on 7/6/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPUserProfileViewController.h"
#import "FUIButton.h"

@interface RIPEditProfileViewController : RIPUserProfileViewController
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
- (IBAction)addPhotoPress:(UIButton *)sender;

@end
