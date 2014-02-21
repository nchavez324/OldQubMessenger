//
//  RIPSettingsViewController.m
//  qub
//
//  Created by Nick on 6/26/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPSettingsViewController.h"
#import "RIPEditProfileViewController.h"
#import "RIPChangePasswordViewController.h"
#import "RIPCoreDataManager.h"

#import "UITableViewCell+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "SevenSwitch.h"

static NSString * kYes      = @"yes";
static NSString * kNo       = @"no";

@interface RIPSettingsViewController ()

@property (strong, nonatomic) NSMutableArray *notificationData;

@end

@implementation RIPSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
	_notificationData = [NSMutableArray arrayWithArray:@[
						 kNo,
						 kYes
						 ]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.tableView.backgroundView = nil;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor colorWithWhite:0.8 alpha:0.5];
	self.title = NSLocalizedString(@"TITLE_SETTINGS", @"Title for Settings page");
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NAVIGATION_BACK", @"Back display for navigation") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view setAlpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 55.0)];

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, -5.0, 300.0, 60.0)];
	label.backgroundColor = [UIColor clearColor];
	label.opaque = NO;
	label.textColor = [UIColor whiteColor];
	label.highlightedTextColor = [UIColor skyBlueColor];
	label.shadowColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentLeft;
	label.numberOfLines = 0;
	label.font = [UIFont boldFlatFontOfSize:18.0];
	label.shadowColor = [UIColor blackColor];
	
	switch (section){
		case 0:
			label.text = NSLocalizedString(@"TABLE_SECTION_GENERAL", @"Title for General Settings table group");
			break;
		case 1:
			label.text = NSLocalizedString(@"TABLE_SECTION_FIND_FRIENDS", @"Title for Find Friends Settings table group");
			break;
		case 2:
			label.text = NSLocalizedString(@"TABLE_SECTION_NOTIFICATIONS", @"Title for Notifications Settings table group");
			break;
		case 3:
			label.text = NSLocalizedString(@"TITLE_QUB_MESSENGER", @"Title of App");
			break;
		default:
			break;
	}
	
	[header addSubview:label];
	
	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 55.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numRows = 0;
	switch (section){
		case 0://kGeneral
			numRows = 4;
			break;
		case 1://kFindFriends
			numRows = 2;
			break;
		case 2://kNotifications
			numRows = 2;
			break;
		case 3://kHelpAbout
			numRows = 1;
		default:
			break;
	}
	return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [UITableViewCell configureFlatCellWithColor:[UIColor colorWithWhite:1.0 alpha:0.87] selectedColor:[UIColor skyBlueColor] style:UITableViewCellStyleDefault reuseIdentifier:@"SettingsCell"];
	cell.cornerRadius = 3.0;
	cell.textLabel.font = [UIFont flatFontOfSize:17];
	cell.separatorHeight = 1.0;
	
	switch (indexPath.section){
		case 0://kGeneral
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = NSLocalizedString(@"TABLE_CELL_EDIT_PROFILE", @"Title for Edit Profile cell");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"TABLE_CELL_BLOCKLIST", @"Title for Blocklist cell");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"TABLE_CELL_HOTKEYS", @"Title for Hotkeys cell");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 3:
					cell.textLabel.text = NSLocalizedString(@"TABLE_CELL_PASSWORD", @"Title for Change Password cell");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				default:
					break;
			}
			break;
		case 1://kFindFriends
			switch (indexPath.row){
				case 0:
					cell.textLabel.text = NSLocalizedString(@"TABLE_CELL_ADD_CONTACTS", @"Title for Add From Contacts cell");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"TABLE_CELL_INVITE", @"Title for Invite Friends cell");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
			}
			break;
		case 2://kNotifications
			
			switch (indexPath.row){
				case 0:{
					cell.textLabel.text = NSLocalizedString(@"TABLE_CELL_ALERT_SOUND", @"Title for Alert Sound cell");
					SevenSwitch *s = (SevenSwitch *)cell.accessoryView;
					if(s == nil){
						s = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, 65, 33)];
						[SevenSwitch styleSwitch:s];
						s.tag = indexPath.row + 10;
						[s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
						cell.accessoryView = s;
					}
					BOOL visible = [_notificationData[indexPath.row] isEqual:kYes];
					if(s.on != visible){
						[s setOn:visible animated:NO callback:NO];
					}
					break;
				}
				case 1:
					cell.textLabel.text = NSLocalizedString(@"TABLE_CELL_MESSAGE_PREVIEW", @"Title for Message Preview cell");
					SevenSwitch *s = (SevenSwitch *)cell.accessoryView;
					if(s == nil){
						s = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, 65, 33)];
						[SevenSwitch styleSwitch:s];
						s.tag = indexPath.row + 10;
						[s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
						cell.accessoryView = s;
					}
					BOOL visible = [_notificationData[indexPath.row] isEqual:kYes];
					if(s.on != visible){
						[s setOn:visible animated:NO callback:NO];
					}
					break;
			}
			break;
		case 3://kHelpAbout
			switch (indexPath.row){
				case 0:
					cell.textLabel.text = NSLocalizedString(@"TABLE_CELL_HELP_ABOUT", @"Title for Help and About cell");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
			}
		default:
			break;
	}
	return cell;
}

- (void)switchChanged:(SevenSwitch *)sender {
	_notificationData[sender.tag - 10] = [_notificationData[sender.tag - 10] isEqual:kYes]?kNo:kYes;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 2)
		return nil;
	else
		return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section){
		case 0://kGeneral
			switch (indexPath.row){
				case 0:{
					UIStoryboard *profileSb = [UIStoryboard storyboardWithName:@"UserProfileStoryboard" bundle:nil];
					RIPEditProfileViewController *editProfile = (RIPEditProfileViewController *)[profileSb instantiateViewControllerWithIdentifier:@"RIPEditProfileViewController"];
					editProfile.userID = [[RIPCoreDataManager shared] currentUserID];
					[self.navigationController pushViewController:editProfile animated:YES];
					break;
				}
				case 1://Blocklist
					break;
				case 2://Hotkeys
					break;
				case 3:{
					RIPChangePasswordViewController *changePass = [[RIPChangePasswordViewController alloc] initWithNibName:@"RIPChangePasswordViewController" bundle:nil];
					[self.navigationController pushViewController:changePass animated:YES];
					break;
				}
			}
			break;
		case 1://kFindFriends
			switch(indexPath.row){
				case 0://Contacts
					break;
				case 1://Invite
					break;
			}
			break;
		case 2://kNotifications
			break;
		case 3://kqub
			switch (indexPath.row){
				case 0://HelpAbout
					break;
			}
			break;
		default:
			break;
	}
	
}

@end
