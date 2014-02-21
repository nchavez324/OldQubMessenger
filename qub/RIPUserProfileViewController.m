//
//  RIPProfileViewController.m
//  qub
//
//  Created by Nick on 6/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "RIPUserProfileViewController.h"
#import "RIPEditProfileViewController.h"
#import "RIPSettingsViewController.h"
#import "RIPAppDelegate.h"
#import "RIPMessageViewController.h"
#import "UIViewController+MMDrawerController.h"

#import "UIFont+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "UIImage+FlatUI.h"
#import "SevenSwitch.h"

#import "User.h"
#import "ImageCollection.h"
#import "RIPErrorCodes.h"

NSString * const kEmptyVal = @"Empty";
NSInteger const kActivityIndicatorTag = 600;

@implementation RIPUserProfileViewController

/** Auto Generated Methods **
 *                          *
 *                          *
 *                          *
 *                          *
 *                          *
 *                          *
 *                          *
 *                          *
 *                          *
 ****************************/

- (void)viewDidLoad
{
    [super viewDidLoad];
	_profileCarousel.type = iCarouselTypeLinear;
	_profileCarousel.bounceDistance = 0.4;
	_profileCarousel.clipsToBounds = NO;
	_profileCarousel.scrollSpeed = 1.0;
	
	UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
	[b setFrame:CGRectMake(0, 0, 35.0, 35.0)];
	[b addTarget:self action:@selector(settingsBtn) forControlEvents:UIControlEventTouchUpInside];
	[b setImage:[UIImage imageNamed:@"gearIcon"] forState:UIControlStateNormal];
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:b] animated:YES];
    
    //self.title = NSLocalizedString(@"TITLE_PROFILE", @"Title for Profile page");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_pictureData = [NSMutableArray
					arrayWithArray:@[[ImageCollection noPhoto]]];
	if([self.user.num_profile_pics integerValue] == [self.user.imageCollection numPicsFilled]){
		for (NSInteger i = 1; i <= [self.user.num_profile_pics integerValue]; i++)
			[_pictureData addObject:[self.user.imageCollection profilePic:i]];
	}else{//if num profile pics is unupdated
		for (NSInteger i = 0; i < [self.user.num_profile_pics integerValue]; i++)
			[_pictureData addObject:kEmptyVal];
	}
	
	__block ImageCollection *imageCollection = self.user.imageCollection;
	if([self.user.selected_image integerValue] != 0 && imageCollection.dataCompletion < kFull){
		[imageCollection pullAllProfilePicsWithQuality:kQualityFull completion:^(NSInteger userID, NSInteger indexCompleted, RIPError errorCode) {
			//NSLog(@"Error Code: %d", errorCode);
			UIImage *im = [imageCollection profilePic:indexCompleted];
			if(errorCode != RIPErrorNone){
				if(im == nil)
					[_pictureData replaceObjectAtIndex:indexCompleted withObject:[ImageCollection noPhoto]];
				else
					[_pictureData replaceObjectAtIndex:indexCompleted withObject:im];
				if(indexCompleted == [self.user.selected_image integerValue])
					[self updateProfilePicture];
				[self.profileCarousel reloadItemAtIndex:indexCompleted animated:YES];
			}else if(userID == self.userID){
				[_pictureData replaceObjectAtIndex:indexCompleted withObject:im];
				if(indexCompleted == [self.user.selected_image integerValue])
					[self updateProfilePicture];
				[self.profileCarousel reloadItemAtIndex:indexCompleted animated:YES];
			}
		}];
	}
	
	self.navigationItem.leftBarButtonItem = nil;
	
	[self.profileDataTable reloadData];
	[self updateProfilePicture];
	[self.profileCarousel reloadData];
	
	self.doneLoading = YES;
}

- (void)doLayoutForOrientation:(UIInterfaceOrientation)orientation {
	CGFloat profileImageSize = 116;
	self.profileImageView.frame = CGRectMake(self.view.center.x - profileImageSize/2.0, 20.0, profileImageSize, profileImageSize);
	self.profileActivityIndicator.frame = CGRectMake(self.profileImageView.center.x - self.profileActivityIndicator.frame.size.width/2, self.profileImageView.center.y - self.profileActivityIndicator.frame.size.height/2, self.profileActivityIndicator.frame.size.width, self.profileActivityIndicator.frame.size.height);
	_profileCarousel.frame = CGRectMake(self.view.frame.origin.x, self.profileImageView.frame.origin.y + self.profileImageView.frame.size.height + 8.0, self.view.frame.size.width, 60.0);
	self.profileDataTable.frame = CGRectMake(self.view.frame.origin.x, _profileCarousel.frame.origin.y + _profileCarousel.frame.size.height + 8.0, self.view.frame.size.width, self.profileDataTable.rowHeight * kNumRows);
	UIScrollView *scroll = (UIScrollView *)self.view;
	scroll.contentSize = CGSizeMake(self.profileDataTable.frame.size.width, self.profileDataTable.frame.origin.y + self.profileDataTable.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/****** Action Methods ******
 *                          *
 *                          *
 *                          *
 *                          *
 *                          *
 *                          *
 *                          *
 *                          *
 *                          *
 ****************************/

- (void)settingsBtn {
	UIStoryboard *secondarySb = [UIStoryboard storyboardWithName:@"SecondaryStoryboard" bundle:nil];
    RIPSettingsViewController *settings = (RIPSettingsViewController *)[secondarySb instantiateViewControllerWithIdentifier:@"RIPSettingsViewController"];
    [self.navigationController pushViewController:settings animated:YES];
}

/******** Delegate Methods *******
 *                               *
 *                               *
 *                               *
 *                               *
 *                               *
 *                               *
 *                               *
 *                               *
 *                               *
 *********************************/

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
	switch (option){
		case iCarouselOptionSpacing:{
			return 1.1;
        }
		case iCarouselOptionOffsetMultiplier:{
			return 1.0;
		}
		default:{
			return value;
		}
	}
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
	NSNumber *new = [NSNumber numberWithInteger:index];
	NSNumber *old = self.user.selected_image;
	if(new != old){
		self.user.selected_image = new;
		UIView *oldView = [carousel viewWithTag:old.integerValue+kImageViewTagBase];
		UIView *newView = [carousel viewWithTag:new.integerValue+kImageViewTagBase];
		if(oldView != nil){
			[self updateProfileView:oldView atIndex:old.integerValue];
			//[self.profileCarousel reloadItemAtIndex:old.integerValue animated:YES];
			[oldView setNeedsDisplay];
		}
		[self updateProfileView:newView atIndex:new.integerValue];
		//[self.profileCarousel reloadItemAtIndex:new.integerValue animated:YES];
		[newView setNeedsDisplay];
		[self updateProfilePicture];
        
        if(![self.class isSubclassOfClass:RIPEditProfileViewController.class]){
            UINavigationController *centerNav = (UINavigationController *)self.mm_drawerController.centerViewController;
            if(centerNav.visibleViewController.class == [RIPMessageViewController class]){
                RIPMessageViewController *msgVc = (RIPMessageViewController *)centerNav.visibleViewController;
                [msgVc loadAvatarImagesForUserID:self.userID];
            }
        }
	}
}

/******** Data Source Methods *******
 *                                  *
 *                                  *
 *                                  *
 *                                  *
 *                                  *
 *                                  *
 *                                  *
 *                                  *
 *                                  *
 ************************************/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return kNumRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
	[self configureCell:cell];
	SevenSwitch *s = (SevenSwitch *)[cell accessoryView];
	
	if(s == nil){
		s = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, 65, 33)];
		[SevenSwitch styleSwitch:s];
		[s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		[cell setAccessoryView:s];
		s.tag = indexPath.row + 10;
	}
	UIImageView *iconView = (UIImageView *)[cell viewWithTag:1];
	UILabel *valLabel = (UILabel *)[cell viewWithTag:2];
	UILabel *titleLabel = (UILabel *)[cell viewWithTag:3];
	iconView.image = [UIImage imageNamed:self.profileStrings[indexPath.row][kIconName]];
	BOOL visible = [self visibleAndAssignView:valLabel dataWithIndex:indexPath.row];
	titleLabel.text = self.profileStrings[indexPath.row][kTitle];

	if(s.on != visible){
		[s setOn:visible animated:NO callback:NO];
	}
	return cell;
}

- (void)switchChanged:(SevenSwitch *)sender {
	NSInteger i = sender.tag - 10;
	switch (i) {
		case kUsername:
			self.user.username_visible = [NSNumber numberWithBool:![self.user.username_visible boolValue]];
			break;
		case kName:
			self.user.name_visible = [NSNumber numberWithBool:![self.user.name_visible boolValue]];
			break;
		case kAge:
			self.user.age_visible = [NSNumber numberWithBool:![self.user.age_visible boolValue]];
			break;
		case kSex:
			self.user.sex_visible = [NSNumber numberWithBool:![self.user.sex_visible boolValue]];
			break;
		case kSeeking:
			self.user.seeking_visible = [NSNumber numberWithBool:![self.user.seeking_visible boolValue]];
			break;
		case kLocation:
			self.user.location_visible = [NSNumber numberWithBool:![self.user.location_visible boolValue]];
			break;
		default:
			break;
	}
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return [_pictureData count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
	//create new view if no view is available for recycling
	UIImageView *imgView = nil;
	if (view == nil){
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 57.0, 57.0)];
		imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 7, 50.0f, 50.0f)];
		imgView.tag = kImageTag;
        if([RIPAppDelegate usingCircularAvatars]){
            imgView.layer.cornerRadius = imgView.frame.size.height/2.0;
            imgView.layer.masksToBounds = YES;
        }else{
            imgView.layer.cornerRadius = 2.0;
        }
		UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicator.tag = kActivityIndicatorTag;
		[activityIndicator setHidesWhenStopped:YES];
		CGFloat size = 20;
		activityIndicator.frame = CGRectMake(view.center.x - size/2, view.center.y - size/2, size, size);
		[activityIndicator stopAnimating];
		
		[view addSubview:activityIndicator];
		[view addSubview:imgView];
	}else{
		imgView = (UIImageView *)[view viewWithTag:kImageTag];
	}
	view.contentMode = UIViewContentModeScaleAspectFill;
	view.tag = index + kImageViewTagBase;
	imgView.contentMode = UIViewContentModeScaleAspectFill;
	[self updateProfileView:view atIndex:index];
	
	return view;
	
}

- (void)updateProfileView:(UIView *)view atIndex:(NSInteger)index {
	UIImageView *imgView = ((UIImageView *)[view viewWithTag:kImageTag]);
	UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[view viewWithTag:kActivityIndicatorTag];
	if([[_pictureData objectAtIndex:index] isEqual:kEmptyVal]){
		if(!activityIndicator.isAnimating){
			[activityIndicator startAnimating];
		}
		imgView.hidden = YES;
	}else{
		imgView.image = (UIImage *)[_pictureData objectAtIndex:index];
		if(activityIndicator.isAnimating){
			[activityIndicator stopAnimating];
		}
		imgView.hidden = NO;
		if([NSNumber numberWithInteger:index] == self.user.selected_image){
			imgView.layer.borderWidth = 2.0;//1.0;
			imgView.layer.borderColor = [UIColor skyBlueColor].CGColor;
			imgView.alpha = 1.0;
		}else{
			imgView.layer.borderWidth = 2.0;//1.0;
			imgView.layer.borderColor = [UIColor whiteColor].CGColor;
			imgView.alpha = 0.7;
		}
		imgView.clipsToBounds = YES;
		view.clipsToBounds = NO;
	}
	view.tag = index + kImageViewTagBase;
}

- (void)updateProfilePicture {
	if(self.profileImageView != nil){
		NSNumber *n = self.user.selected_image;
		if([_pictureData[n.integerValue] isEqual:kEmptyVal]){
			if(!self.profileActivityIndicator.isAnimating){
				[self.profileActivityIndicator startAnimating];
			}
			self.profileImageView.hidden = YES;
		}else{
			if(self.profileActivityIndicator.isAnimating){
				[self.profileActivityIndicator stopAnimating];
			}
			self.profileImageView.hidden = NO;
			self.profileImageView.image = (UIImage *)_pictureData[n.integerValue];
			self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
			self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
			self.profileImageView.layer.borderWidth = 2.0;
			[self.profileImageView setNeedsDisplay];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	//post up!!
}

@end
