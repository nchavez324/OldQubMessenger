//
//  RIPMessagesCell.h
//  qub
//
//  Created by Nick on 8/21/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIPConvosCell : UITableViewCell

@property (weak, nonatomic) UILabel *usernameLabel;
@property (weak, nonatomic) UIImageView *profileImageView;
@property (weak, nonatomic) UILabel *previewLabel;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UILabel *dateLabel;
@property (weak, nonatomic) UILabel *statusLabel;
@property (weak, nonatomic) UIView *separatorLineView;
@property (strong, nonatomic) NSString *statusCode;
@end
