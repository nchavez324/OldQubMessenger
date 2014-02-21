//
//  RIPProfileViewController.m
//  qub
//
//  Created by Nick on 8/18/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPProfileViewController.h"
#import "MMDrawerController.h"
#import "RIPCenterViewController.h"
#import "RIPContactsViewController.h"
#import "RIPAppDelegate.h"

#import <QuartzCore/QuartzCore.h>
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

#import "User.h"
#import "ImageCollection.h"
#import "RIPCoreDataManager.h"
#import "RIPErrorCodes.h"

NSString * const kIconName = @"iconName";
NSString * const kTitle    = @"title";
NSString * const kMale     = @"M";
NSString * const kFemale   = @"F";
NSString * const kOther    = @"O";

NSInteger const kImageTag         = 100;
NSInteger const kImageViewTagBase = 1;


@interface RIPProfileViewController ()
@property (assign, nonatomic) BOOL isContact;
@end

@implementation RIPProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _userID = -1;
		_isContact = NO;
		_doneLoading = NO;
    }
    return self;
}

- (void)awakeFromNib {
	
	_profileStrings =
	@[
   @{
	   kIconName:@"usernameIcon",
	kTitle:NSLocalizedString(@"PROFILE_USERNAME", @"Username field description")
	},@{
	   kIconName:@"nameIcon",
	kTitle:NSLocalizedString(@"PROFILE_NAME", @"Name field description")
	},@{
	   kIconName:@"ageIcon",
	kTitle:NSLocalizedString(@"PROFILE_AGE", @"Age field description")
	},@{
	   kIconName:@"genderIcon",
	kTitle:NSLocalizedString(@"PROFILE_SEX", @"Sex field description")
	},@{
	   kIconName:@"seekingIcon",
	kTitle:NSLocalizedString(@"PROFILE_SEEKING", @"Seeking field description")
	},@{
	   kIconName:@"locationIcon",
	kTitle:NSLocalizedString(@"PROFILE_LOCATION", @"Location field description")
	}];
}

- (void)viewDidLoad
{
	_profileImageView.contentMode = UIViewContentModeScaleAspectFill;
	_profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
	_profileImageView.layer.borderWidth = 2.0;
    if([RIPAppDelegate usingCircularAvatars]){
        _profileImageView.layer.cornerRadius = _profileImageView.frame.size.height/2.0;
        _profileImageView.layer.masksToBounds = YES;
    }
	[_profileImageView setNeedsDisplay];
	_profileImageView.image = [ImageCollection noPhoto];
	_profileImageView.hidden = YES;
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NAVIGATION_BACK", @"Back display for navigation") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	_user = [[RIPCoreDataManager shared] userWithId:self.userID inContext:[RIPCoreDataManager shared].managedObjectContext];
	__block ImageCollection *imageCollection = (_user.imageCollection==nil)?[[RIPCoreDataManager shared] addImageCollection:_user inContext:[RIPCoreDataManager shared].managedObjectContext]:_user.imageCollection;
	if(imageCollection != nil)
		imageCollection.user = _user;
	[[RIPCoreDataManager shared] pullUser:self.userID completion:^(NSManagedObjectID *userObjID, RIPError errorCode){
		dispatch_async(dispatch_get_main_queue(), ^{
            if(errorCode != RIPErrorNone){
                if([RIPErrorCodes shouldHideData:errorCode]){
                    
                }
            }else{
                _user = (User *)[[RIPCoreDataManager shared].managedObjectContext objectWithID:userObjID];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[RIPCoreDataManager shared] saveContext:[RIPCoreDataManager shared].managedObjectContext];
                });
                [self.profileDataTable reloadData];
            }
        });
	}];
	
	UIApplication *app = [UIApplication sharedApplication];
	UIInterfaceOrientation cur = app.statusBarOrientation;
	[self doLayoutForOrientation:cur];
	_isContact = [[[RIPCoreDataManager shared] currentUserInContext:[RIPCoreDataManager shared].managedObjectContext] isContact:_user];
	if([_user.user_id integerValue] == [[RIPCoreDataManager shared] currentUserID] || [_user.username_visible boolValue] || _isContact)
		self.title = _user.username;
	else
		self.title = NSLocalizedString(@"PROFILE_ANONYMOUS", @"Anonymous username");
	
	[self.profileDataTable reloadData];
	
	if([self.user.selected_image integerValue] != 0){
		NSNumber *n = _user.selected_image;
		if(imageCollection != nil && [imageCollection profilePic:[_user.selected_image integerValue]] == nil)
			[_profileActivityIndicator startAnimating];
		[imageCollection pullProfilePic:[n integerValue] WithQuality:kQualityFull completion:^(NSInteger userID, RIPError errorCode){
			[_profileActivityIndicator stopAnimating];
			UIImage *im = [imageCollection profilePic:[n integerValue]];
			if(errorCode != RIPErrorNone){
				if(im == nil)
					_profileImageView.image = [ImageCollection noPhoto];
				else
					_profileImageView.image = im;
			}else if([_user.user_id integerValue] == userID){//Because of controller reuse!!
				_profileImageView.image = im;
			}
			_profileImageView.hidden = NO;
		}];
		if([_user.selected_image integerValue] != 0 && imageCollection != nil && [imageCollection profilePic:[_user.selected_image integerValue]] != nil){
			_profileImageView.image = [imageCollection profilePic:[_user.selected_image integerValue]];
			_profileImageView.hidden = NO;
		}
	}else{
		_profileImageView.image = [ImageCollection noPhoto];
		_profileImageView.hidden = NO;
	}
	_doneLoading = YES;
}

- (void)refreshBtn {
	MMDrawerController *drawer = (MMDrawerController *)self.parentViewController.parentViewController;
	RIPCenterViewController *center = (RIPCenterViewController *)drawer.centerViewController.childViewControllers[0];
	RIPContactsViewController *contactsVc = center.contactsVc;
	[contactsVc pullData:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			[[RIPCoreDataManager shared] pullUser:self.userID completion:^(NSManagedObjectID *userObjID, RIPError errorCode){
				dispatch_async(dispatch_get_main_queue(), ^{
                    //on main queue!
                    if(errorCode != RIPErrorNone){
                        //TODO
                        if([RIPErrorCodes shouldHideData:errorCode]){
                            
                        }
                    }else{
                        [RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
                            _user = (User *)[[RIPCoreDataManager shared].managedObjectContext objectWithID:userObjID];
                            _isContact = [[[RIPCoreDataManager shared] currentUserInContext:[RIPCoreDataManager shared].managedObjectContext] isContact:_user];
                            [[RIPCoreDataManager shared] saveContext:context];
                        } completion:^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.profileDataTable reloadData];
                                __block ImageCollection *imageCollection = _user.imageCollection;
                                if(imageCollection != nil){
                                    if([self.user.selected_image integerValue] != 0){
                                        NSNumber *n = _user.selected_image;
                                        [imageCollection pullProfilePic:[n integerValue] WithQuality:kQualityFull completion:^(NSInteger userID, RIPError errorCode){
                                            [_profileActivityIndicator stopAnimating];
                                            UIImage *im = [imageCollection profilePic:[n integerValue]];
                                            if(errorCode != RIPErrorNone){
                                                if(im == nil)
                                                    _profileImageView.image = [ImageCollection noPhoto];
                                                else
                                                    _profileImageView.image = im;
                                            }else if([_user.user_id integerValue] == userID){
                                                _profileImageView.image = im;
                                            }
                                            _profileImageView.hidden = NO;
                                        }];
                                        if([_user.selected_image integerValue] != 0 && [imageCollection profilePic:[_user.selected_image integerValue]] != nil){
                                            _profileImageView.image = [imageCollection profilePic:[_user.selected_image integerValue]];
                                            _profileImageView.hidden = NO;
                                        }
                                    }else{
                                        _profileImageView.image = [ImageCollection noPhoto];
                                        _profileImageView.hidden = NO;
                                    }
                                }else{
                                    _profileImageView.image = [ImageCollection noPhoto];
                                    _profileImageView.hidden = NO;
                                }
                            });
                        }];
                    }
                });
			}];
		});
	}];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self doLayoutForOrientation:toInterfaceOrientation];
}

- (void)doLayoutForOrientation:(UIInterfaceOrientation)orientation {
	CGFloat profileImageSize = 116;
	_profileImageView.frame = CGRectMake(self.view.center.x - profileImageSize/2.0, 20.0, profileImageSize, profileImageSize);
	_profileActivityIndicator.frame = CGRectMake(_profileImageView.center.x - _profileActivityIndicator.frame.size.width/2, _profileImageView.center.y - _profileActivityIndicator.frame.size.height/2, _profileActivityIndicator.frame.size.width, _profileActivityIndicator.frame.size.height);
	_profileDataTable.frame = CGRectMake(self.view.frame.origin.x, _profileImageView.frame.origin.y + _profileImageView.frame.size.height + 8.0, self.view.frame.size.width, _profileDataTable.rowHeight * kNumRows);
	UIScrollView *scroll = (UIScrollView *)self.view;
	scroll.contentSize = CGSizeMake(_profileDataTable.frame.size.width, _profileDataTable.frame.origin.y + _profileDataTable.frame.size.height);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(_isContact || !_doneLoading){
		return kNumRows;
	}else{
		NSArray *propertyList = [User propertyList];
		NSInteger ans = 0;
		for (NSString *property in propertyList) {
			NSNumber *b = [self.user valueForKey:[property stringByAppendingString:@"_visible"]];
			if([b boolValue])
				ans++;
		}
    	return ans;
	}
}

- (void)configureCell:(UITableViewCell *)cell {
	UIImageView *iconView = (UIImageView *)[cell viewWithTag:1];
	UILabel *valLabel = (UILabel *)[cell viewWithTag:2];
	UILabel *titleLabel = (UILabel *)[cell viewWithTag:3];
	UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:4];
	if(activityIndicator == nil){
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		activityIndicator.frame = CGRectMake(valLabel.frame.origin.x, 5, 28, 28);
		[activityIndicator setHidesWhenStopped:YES];
		[activityIndicator stopAnimating];
		activityIndicator.tag = 4;
		[cell addSubview:activityIndicator];
	}
	
	iconView.layer.shadowColor = [UIColor blackColor].CGColor;
	valLabel.font = [UIFont boldFlatFontOfSize:17.0];
	valLabel.textColor = [UIColor whiteColor];
	valLabel.shadowColor = [UIColor blackColor];
	titleLabel.font = [UIFont flatFontOfSize:12.0];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.shadowColor = [UIColor darkGrayColor];
	titleLabel.clipsToBounds = NO;
	cell.clipsToBounds = NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
	[self configureCell:cell];
	
	
	UIImageView *iconView = (UIImageView *)[cell viewWithTag:1];
	UILabel *valLabel = (UILabel *)[cell viewWithTag:2];
	UILabel *titleLabel = (UILabel *)[cell viewWithTag:3];
	UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:4];
	NSInteger i = 1;

	
	if(_isContact || !_doneLoading){
		i = indexPath.row;
	}else{
		NSArray *propertyList = [User propertyList];
        NSMutableArray *visibleList = [NSMutableArray array];
		int j = 0;
        for (NSString *property in propertyList) {
            NSString *k = [property stringByAppendingString:@"_visible"];
			NSNumber *b = [self.user valueForKey:k];
			if([b boolValue])
                [visibleList addObject:[NSNumber numberWithInt:j+1]];
            j++;
		}
        i = [(NSNumber *)visibleList[indexPath.row] intValue];
	}

	[self visibleAndAssignView:valLabel dataWithIndex:i];
	iconView.image = [UIImage imageNamed:_profileStrings[i][kIconName]];
	titleLabel.text = _profileStrings[i][kTitle];
	if(valLabel.text.length == 0 && !activityIndicator.isAnimating)
		[activityIndicator startAnimating];
	else if(valLabel.text.length > 0 && activityIndicator.isAnimating)
		[activityIndicator stopAnimating];

	return cell;
}

- (BOOL)visibleAndAssignView:view dataWithIndex:(NSInteger)index {
	if(!_doneLoading){
		return YES;
	}
	NSString *text = @"";
	BOOL visible   = NO;
	NSInteger dataCompletion = [_user.dataCompletion integerValue];
	if([view respondsToSelector:@selector(setText:)]){
		switch (index) {
			case kUsername:
				if(dataCompletion >= kMin)
                    text = _user.username;
                if(dataCompletion >= kFull)
                    visible = [_user.username_visible boolValue];
				break;
			case kName:
                if(dataCompletion >= kMin)
                    text = _user.name;
                if(dataCompletion >= kFull)
                    visible = [_user.name_visible boolValue];
				break;
			case kAge:
                if(dataCompletion >= kFull){
                    text = [NSString stringWithFormat:@"%@%d%@", NSLocalizedString(@"PROFILE_AGE_VALUE_PREFIX", @"Language prefix for age value"), [_user.age integerValue], NSLocalizedString(@"PROFILE_AGE_VALUE_SUFFIX", @"Language suffix for age value")];
                    visible = [_user.age_visible boolValue];
                }
				break;
			case kSex:
                if(dataCompletion >= kFull){
                    if([_user.sex isEqual:kMale]){
                        text = NSLocalizedString(@"PROFILE_SEX_MALE", @"Male sex category");
                    }else if([_user.sex  isEqual:kFemale]){
                        text = NSLocalizedString(@"PROFILE_SEX_FEMALE", @"Female sex category");
                    }else if([_user.sex isEqual:kOther]){
                        text = NSLocalizedString(@"PROFILE_SEX_OTHER", @"Other sex category");
                    }
                    visible = [_user.sex_visible boolValue];
                }
				break;
			case kSeeking:
                if(dataCompletion >= kFull){
                    if([_user.seeking isEqual:kMale]){
                        text = NSLocalizedString(@"PROFILE_SEX_MALE", @"Male sex category");
                    }else if([_user.seeking isEqual:kFemale]){
                        text = NSLocalizedString(@"PROFILE_SEX_FEMALE", @"Female sex category");
                    }else if([_user.seeking isEqual:kOther]){
                        text = NSLocalizedString(@"PROFILE_SEX_OTHER", @"Other sex category");
                    }
                    visible = [_user.seeking_visible boolValue];
                }
				break;
			case kLocation:
                if(dataCompletion >= kFull){
                    text = _user.location;
                    visible = [_user.location_visible boolValue];
                }
				break;
			default:
				break;
		}
		[view performSelector:@selector(setText:) withObject:text];
	}
	return visible;
}


@end
