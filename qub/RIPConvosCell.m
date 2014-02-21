//
//  RIPMessagesCell.m
//  qub
//
//  Created by Nick on 8/21/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPConvosCell.h"
#import "RIPAppDelegate.h"
#import "ImageCollection.h"

#import "UIFont+FlatUI.h"
#import "UIColor+FlatUI.h"

static NSInteger kUsernameLabelTag     = 1;
static NSInteger kProfilePictureTag    = 2;
static NSInteger kPreviewLabelTag      = 3;
static NSInteger kActivityIndicatorTag = 4;
static NSInteger kDateLabelTag         = 5;
static NSInteger kStatusLabelTag       = 6;
static NSInteger kSeparatorLineViewTag = 7;

@implementation RIPConvosCell

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
	_usernameLabel = (UILabel *)[self viewWithTag:kUsernameLabelTag];
	_profileImageView = (UIImageView *)[self viewWithTag:kProfilePictureTag];
	_previewLabel = (UILabel *)[self viewWithTag:kPreviewLabelTag];
	_activityIndicator = (UIActivityIndicatorView *)[self viewWithTag:kActivityIndicatorTag];
	_dateLabel = (UILabel *)[self viewWithTag:kDateLabelTag];
	_statusLabel = (UILabel *)[self viewWithTag:kStatusLabelTag];
	_separatorLineView = (UIView *)[self viewWithTag:kSeparatorLineViewTag];
	
	[_usernameLabel setFont:[UIFont boldFlatFontOfSize:16.0]];
	[_previewLabel setFont:[UIFont altFontOfSize:14.0]];
	[_dateLabel setFont:[UIFont boldFlatFontOfSize:10.0]];
	[_statusLabel setFont:[UIFont boldFlatFontOfSize:12.0]];
	[_profileImageView setBackgroundColor:[UIColor blackColor]];
	[_profileImageView setImage:[ImageCollection noPhoto]];
    if([RIPAppDelegate usingCircularAvatars]){
        _profileImageView.layer.cornerRadius = _profileImageView.frame.size.height/2.0;
        _profileImageView.layer.masksToBounds = YES;
    }
	_statusCode = @"N";
	
	[self setSelectedState:NO];
}

- (void)setSelectedState:(BOOL)selected{
	UIColor *txtColor = selected?[UIColor softMetalColor]:[UIColor skyBlueColor];
	UIColor *detTxtColor = selected?[UIColor softMetalColor]:[UIColor darkGrayColor];
	UIColor *bgColor = selected?[UIColor skyBlueColor]:[UIColor softMetalColor];
	[_usernameLabel setTextColor:txtColor];
	[_previewLabel setTextColor:detTxtColor];
	[_dateLabel setTextColor:detTxtColor];
	[_statusLabel setTextColor:txtColor];
	
	[_separatorLineView setBackgroundColor:selected?[UIColor skyBlueColor]:[UIColor concreteColor]];
    [self.contentView setBackgroundColor:bgColor];
	[self setBackgroundColor:bgColor];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if(animated)
        [UIView beginAnimations:nil context:nil];
    _profileImageView.alpha = editing?0.5:1.0;
    _dateLabel.alpha = editing?0.0:1.0;
    _statusLabel.alpha = editing?0.0:1.0;
    if(animated)
        [UIView commitAnimations];
}

- (void)setStatusCode:(NSString *)statusCode {
	_statusCode = statusCode;
	_statusLabel.text = [RIPConvosCell statusCodeText:statusCode];
}

+ (NSString *)statusCodeText:(NSString *)statusCode {
	if([statusCode isEqual:@"N"]){
		return @"";
	}else if([statusCode isEqual:@"S"]){
		return NSLocalizedString(@"STATUS_SENT", @"Message sent.");
	}else if([statusCode isEqual:@"D"]){
		return NSLocalizedString(@"STATUS_DELIVERED", @"Message delivered.");
	}else if([statusCode isEqual:@"R"]){
		return NSLocalizedString(@"STATUS_READ", @"Message read.");
	}else{
		return @"";
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	[self setSelectedState:selected];
}

@end
