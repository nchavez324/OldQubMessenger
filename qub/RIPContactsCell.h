//
//  RIPContactsCell.h
//  qub
//
//  Created by Nick on 8/14/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIPContactsCell : UITableViewCell
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImageView *profileImageView;

@end
