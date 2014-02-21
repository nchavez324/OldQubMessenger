//
//  RIPContactsCell.m
//  qub
//
//  Created by Nick on 8/14/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPContactsCell.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "UIImage+FlatUI.h"
#import "RIPAppDelegate.h"

typedef enum RIPContactCellViewTag {
    RIPContactCellUsernameLabel = 1,
    RIPContactCellNameLabel,
    RIPContactCellSeparatorView,
    RIPContactCellProfileImageView,
    RIPContactCellActivityIndicator
} RIPContactCellView;

@interface RIPContactsCell ()
@property (strong, nonatomic) UIView *separatorLineView;
@end

@implementation RIPContactsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
		[self customInit];
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if(self)
		[self customInit];
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self)
		[self customInit];
	return self;
}

- (id)init {
	self = [super init];
	if(self)
        [self customInit];
	return self;
}


- (void)customInit {
    
    _usernameLabel = (UILabel *)[self viewWithTag:RIPContactCellUsernameLabel];
    _nameLabel = (UILabel *)[self viewWithTag:RIPContactCellNameLabel];
    _separatorLineView = [self viewWithTag:RIPContactCellSeparatorView];
    _profileImageView = (UIImageView *)[self viewWithTag:RIPContactCellProfileImageView];
    _activityIndicator = (UIActivityIndicatorView *)[self viewWithTag:RIPContactCellActivityIndicator];
    
	[_usernameLabel setFont:[UIFont boldFlatFontOfSize:20.0]];
	[_nameLabel setFont:[UIFont flatFontOfSize:14.0]];
	[_profileImageView setBackgroundColor:[UIColor blackColor]];
	_profileImageView.hidden = YES;
    if([RIPAppDelegate usingCircularAvatars]){
        _profileImageView.layer.cornerRadius = _profileImageView.frame.size.height/2.0;
        _profileImageView.layer.masksToBounds = YES;
    }

    [self setSelectedState:NO];
}

- (void)setSelectedState:(BOOL)selected{
	UIColor *txtColor = selected?[UIColor softMetalColor]:[UIColor skyBlueColor];
	UIColor *bgColor = selected?[UIColor skyBlueColor]:[UIColor softMetalColor];
	[_usernameLabel setTextColor:txtColor];
	[_nameLabel setTextColor:txtColor];
	// We need to set the contentView's background colour, otherwise the sides are clear on the swipe and animations
	[self.contentView setBackgroundColor:bgColor];
	[self setBackgroundColor:bgColor];
		
	[_separatorLineView setBackgroundColor:selected?[UIColor skyBlueColor]:[UIColor concreteColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	[self setSelectedState:selected];
}

@end
