//
//  RIPEditProfileViewController.m
//  qub
//
//  Created by Nick on 7/6/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPEditProfileViewController.h"
#import "RIPCoreDataManager.h"

#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "FUIAlertView.h"
#import "UIStepper+FlatUI.h"
#import "FUISegmentedControl.h"
#import "RIPTextField.h"

#import "User.h"
#import "ImageCollection.h"

@interface UIXButton : UIButton
@property (weak, nonatomic) UIView *parent;
@end
@implementation UIXButton
@end

@interface RIPEditProfileViewController () <FUIAlertViewDelegate>

@property (assign, nonatomic) NSInteger toDelete;
@property (weak, nonatomic) RIPTextField *curField;

@end

@implementation RIPEditProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_toDelete = -1;
		_curField = nil;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.userID = [[RIPCoreDataManager shared] currentUserID];
	self.title = NSLocalizedString(@"TABLE_CELL_EDIT_PROFILE", @"Title for Edit Profile cell");
	UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
	[b setFrame:CGRectMake(0, 0, 35.0, 35.0)];
	[b addTarget:self action:@selector(coverBtn) forControlEvents:UIControlEventTouchUpInside];
	[b setImage:[UIImage imageNamed:@"coverIcon"] forState:UIControlStateNormal];
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:b] animated:YES];
	[_addPhotoButton setImage:[UIImage imageNamed:@"addPhotoIcon"] forState:UIControlStateNormal];
	
	[self.navigationItem setLeftBarButtonItem:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(keyboardWillHide)
	 name:UIKeyboardWillHideNotification
	 object:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	if(_curField != nil){
		[_curField resignFirstResponder];
		_curField = nil;
	}
}

- (void)doLayoutForOrientation:(UIInterfaceOrientation)orientation {
	self.profileCarousel.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 70.0, self.view.frame.size.width, 60.0);
	self.profileDataTable.frame = CGRectMake(self.view.frame.origin.x, self.profileCarousel.frame.origin.y + self.profileCarousel.frame.size.height + 8.0, self.view.frame.size.width, self.profileDataTable.rowHeight * kNumRows);
	
	UIScrollView *scroll = (UIScrollView *)self.view;
		scroll.contentSize = CGSizeMake(self.profileDataTable.frame.size.width, self.profileDataTable.frame.origin.y + self.profileDataTable.frame.size.height);
	CGFloat s = 48.0;
	_addPhotoButton.frame = CGRectMake(self.view.center.x - s/2.0, (self.profileCarousel.frame.origin.y - self.view.frame.origin.y - s)/2.0, s, s);
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
	switch (option){
		case iCarouselOptionSpacing:{
			return 1.15;
        }
		case iCarouselOptionOffsetMultiplier:{
			return 1.0;
		}
		default:{
			return value;
		}
	}
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
	view = [super carousel:carousel viewForItemAtIndex:index reusingView:view];
	if([view viewWithTag:101] == nil && index != 0 && ![self.pictureData[index] isEqual:kEmptyVal]){
		CGFloat s = 24.0;
		UIXButton *delBtn = [[UIXButton alloc] initWithFrame:CGRectMake(55.0-s, 2, s, s)];
		[delBtn setImage:[UIImage imageNamed:@"deleteIcon"] forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(delBtn:) forControlEvents:UIControlEventTouchUpInside];
		delBtn.tag = 101;
		[view addSubview:delBtn];
		delBtn.parent = view;
	}
	return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditCell"];
	
	UIImageView *iconView = (UIImageView *)[cell viewWithTag:1];
	RIPTextField *valField = (RIPTextField *)[cell viewWithTag:2];
	valField.rowNum = indexPath.row;
	
	valField.frame = CGRectMake(valField.frame.origin.x, valField.frame.origin.y, 211.0, 25.0);//184
	[valField style];
	
	UILabel *titleLabel = (UILabel *)[cell viewWithTag:3];
	iconView.layer.shadowColor = [UIColor blackColor].CGColor;
	titleLabel.font = [UIFont flatFontOfSize:12.0];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.shadowColor = [UIColor darkGrayColor];
	titleLabel.clipsToBounds = NO;
	cell.clipsToBounds = NO;
	iconView.image = [UIImage imageNamed:self.profileStrings[indexPath.row][kIconName]];
	
	[self visibleAndAssignView:valField dataWithIndex:indexPath.row];
	
	titleLabel.text = self.profileStrings[indexPath.row][kTitle];

	if(indexPath.row == kUsername || indexPath.row == kAge || indexPath.row == kSex || indexPath.row == kSeeking){
		valField.enabled = NO;
		valField.backgroundColor = [UIColor clearColor];
		valField.leftView = nil;
		if(indexPath.row == kAge){
			
			FUIButton *inc = (FUIButton *)[cell viewWithTag:402];
			if(inc == nil){
				CGFloat s = valField.frame.size.height;
				inc = [[FUIButton alloc] initWithFrame:CGRectMake(valField.frame.origin.x + valField.frame.size.width - s, valField.frame.origin.y, s, s)];
				inc.buttonColor = [UIColor clearColor];
				inc.shadowColor = [UIColor clearColor];
				inc.shadowHeight = 0;
				inc.cornerRadius = s/2.0;
				[inc setImage:[UIImage imageNamed:@"addIcon"] forState:UIControlStateNormal];
				[inc addTarget:self action:@selector(ageInc) forControlEvents:UIControlEventTouchUpInside];
				inc.tag = 402;
				[cell addSubview:inc];
			}
			FUIButton *dec = (FUIButton *)[cell viewWithTag:403];
			if(dec == nil){
				CGFloat s = valField.frame.size.height;
				dec = [[FUIButton alloc] initWithFrame:CGRectMake(inc.frame.origin.x - 8 - s, inc.frame.origin.y, s, s)];
				dec.buttonColor = [UIColor clearColor];
				dec.shadowColor = [UIColor clearColor];
				dec.shadowHeight = 0;
				dec.cornerRadius = s/2.0;
				[dec setImage:[UIImage imageNamed:@"minusIcon"] forState:UIControlStateNormal];
				[dec addTarget:self action:@selector(ageDec) forControlEvents:UIControlEventTouchUpInside];
				dec.tag = 403;
				[cell addSubview:dec];
			}
		}else if(indexPath.row == kSex || indexPath.row == kSeeking){
			FUISegmentedControl *sexer = (FUISegmentedControl *)[cell viewWithTag:401];
			if(sexer == nil){
				valField.hidden = YES;
				sexer = [[FUISegmentedControl alloc] initWithFrame:CGRectMake(valField.frame.origin.x, valField.frame.origin.y, valField.frame.size.width * 1.0, valField.frame.size.height)];
				sexer.tag = 401;
				
				[sexer insertSegmentWithTitle:NSLocalizedString(@"PROFILE_SEX_OTHER", @"Other sex category") atIndex:0 animated:NO];
				[sexer insertSegmentWithTitle:NSLocalizedString(@"PROFILE_SEX_FEMALE", @"Female sex category") atIndex:0 animated:NO];
				[sexer insertSegmentWithTitle:NSLocalizedString(@"PROFILE_SEX_MALE", @"Male sex category") atIndex:0 animated:NO];
				if(indexPath.row == kSex)
					[sexer addTarget:self action:@selector(sexField:) forControlEvents:UIControlEventValueChanged];
				else if(indexPath.row == kSeeking)
					[sexer addTarget:self action:@selector(seekingField:) forControlEvents:UIControlEventValueChanged];
				[sexer style];
				[cell addSubview:sexer];
			}
			NSInteger i = -1;
			NSString *s = indexPath.row == kSex?self.user.sex:self.user.seeking;
			if([s isEqual:kMale]){
				i = 0;
			}else if([s isEqual:kFemale]){
				i = 1;
			}else if([s isEqual:kOther]){
				i = 2;
			}
			[sexer setSelectedSegmentIndex:i];
		}
	}
	return cell;
}

- (void)ageInc {
	NSNumber *n = self.user.age;
	if([n integerValue] < 120){
		self.user.age = [NSNumber numberWithInteger:([n integerValue] + 1)];
		[self.profileDataTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kAge inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void)ageDec {
	NSNumber *n = self.user.age;
	if([n integerValue] > 13){
		self.user.age = [NSNumber numberWithInteger:([n integerValue] - 1)];
		[self.profileDataTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:kAge inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void) sexField:(FUISegmentedControl *)sender {
	NSInteger i = sender.selectedSegmentIndex;
	switch (i){
		case 0:
			self.user.sex = kMale;
			break;
		case 1:
			self.user.sex = kFemale;
			break;
		case 2:
			self.user.sex = kOther;
			break;
		default:
			break;
	}
}

- (void) seekingField:(FUISegmentedControl *)sender {
	NSInteger i = sender.selectedSegmentIndex;
	switch (i){
		case 0:
			self.user.seeking = kMale;
			break;
		case 1:
			self.user.seeking = kFemale;
			break;
		case 2:
			self.user.seeking = kOther;
			break;
		default:
			break;
	}
}

- (void)coverBtn {
	
}

- (IBAction)addPhotoPress:(UIButton *)sender {
}

- (void)delBtn:(id)sender {
	UIXButton *b = (UIXButton *)sender;
	_toDelete = b.parent.tag-kImageViewTagBase;
	FUIAlertView *confirm = [[FUIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_DELETING_PHOTO", @"Alert title for deleting photo") message:NSLocalizedString(@"ALERT_CONFIRM_DELETE", @"Asks if user is sure he/she wants to delete the photo.") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"Cancel") otherButtonTitles:NSLocalizedString(@"DELETE", @"Delete"), nil];
	[FUIAlertView styleAlertView:confirm];
	confirm.tag = 500;
	[confirm show];
}

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 0 && alertView.tag == 500){
		//edit data as well
		[self.profileCarousel removeItemAtIndex:_toDelete animated:YES];
		[self.pictureData removeObjectAtIndex:_toDelete];
		[self.profileCarousel reloadData];
		//reload carousel
		_toDelete = -1;
	}else if(alertView.tag == 501){
		UITextField *f = (UITextField *)[[self.profileDataTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kName inSection:0]] viewWithTag:2];
		[f setText:self.user.name];
	}else if(alertView.tag == 502){
		UITextField *f = (UITextField *)[[self.profileDataTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kLocation inSection:0]] viewWithTag:2];
		[f setText:self.user.location];
	}
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*** Keyboard Adjustments ***
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

#define kOFFSET_FOR_KEYBOARD 80.0

-(void)keyboardWillHide {
    [self setViewMovement:0.0];
}

- (IBAction)textFieldDidBeginEditing:(RIPTextField *)sender {
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	UIScrollView *scroll = (UIScrollView *)self.view;
	float c =  UIInterfaceOrientationIsPortrait(o)?
	((sender.rowNum == kName)?(0.4):(2.65)):
	((sender.rowNum == kName)?(1.6):(3.8));
	[self setViewMovement:(c*kOFFSET_FOR_KEYBOARD - scroll.contentOffset.y)];
	_curField = sender;
}

- (IBAction)textFieldEditingDidEnd:(RIPTextField *)sender {
	NSString *raw = sender.text;
	NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *trimmed = [raw stringByTrimmingCharactersInSet:ws];
	if([trimmed length] < 2 && sender.rowNum == kName){
		FUIAlertView *alert = [[FUIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_ERROR", @"Error without colon") message:NSLocalizedString(@"ALERT_NAME_INPUT_ERROR", @"Name must exceed two characters in length.") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
		[FUIAlertView styleAlertView:alert];
		alert.tag = 501;
		[alert show];
	}else if([trimmed length] < 2 && sender.rowNum == kLocation){
		FUIAlertView *alert = [[FUIAlertView alloc] initWithTitle:NSLocalizedString(@"ALERT_ERROR", @"Error without colon")  message:NSLocalizedString(@"ALERT_LOCATION_INPUT_ERROR", @"Location name must exceed two characters in length.") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK")otherButtonTitles:nil];
		[FUIAlertView styleAlertView:alert];
		alert.tag = 502;
		[alert show];
	}else{
		[sender resignFirstResponder];
		[sender setText:trimmed];
		switch (sender.rowNum){
			case kName:
				self.user.name = sender.text;
				break;
			case kLocation:
				self.user.location = sender.text;
				break;
			default:
				break;
		}
	}
	_curField = nil;
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovement:(CGFloat)offset{
	CGRect rect = self.view.frame;
	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	rect.origin.y = -offset;
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self
	 name:UIKeyboardWillHideNotification
	 object:nil];
	[self saveAndCheckData];
}

- (void)saveAndCheckData {
	//Save all Data and check for blank fields!!
	//Name
	UITextField *nameField = (UITextField *)[[self.profileDataTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kName inSection:0]] viewWithTag:2];
	NSString *raw = nameField.text;
	NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *trimmed = [raw stringByTrimmingCharactersInSet:ws];
	if([trimmed length] < 2){
		[nameField setText:self.user.name];
	}else{
		self.user.name = trimmed;
	}
	
	//age is being saved consistently
	
	//Sex
	UISegmentedControl *sex = (UISegmentedControl *)[[self.profileDataTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kSex inSection:0]] viewWithTag:401];
	NSInteger i = sex.selectedSegmentIndex;
	switch (i){
		case 0:
			self.user.sex = kMale;
			break;
		case 1:
			self.user.sex = kFemale;
			break;
		case 2:
			self.user.sex = kOther;
			break;
		default:
			break;
	}
	//Seeking
	UISegmentedControl *seeking = (UISegmentedControl *)[[self.profileDataTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kSeeking inSection:0]] viewWithTag:401];
	i = seeking.selectedSegmentIndex;
	switch (i){
		case 0:
			self.user.seeking = kMale;
			break;
		case 1:
			self.user.seeking = kFemale;
			break;
		case 2:
			self.user.seeking = kOther;
			break;
		default:
			break;
	}
	//Location
	UITextField *locField = (UITextField *)[[self.profileDataTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kLocation inSection:0]] viewWithTag:2];
	raw = locField.text;
	trimmed = [raw stringByTrimmingCharactersInSet:ws];
	if([trimmed length] < 2){
		[locField setText:self.user.location];
	}else{
		self.user.location = trimmed;
	}
	
	[[RIPCoreDataManager shared] saveContext:[RIPCoreDataManager shared].managedObjectContext];
	//Async post!!!!!
}

@end
