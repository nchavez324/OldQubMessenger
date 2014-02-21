//
//  RIPContactsViewController.m
//  qub
//
//  Created by Nick on 6/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPContactsViewController.h"
#import "RIPContactsCell.h"
#import "RIPProfileViewController.h"
#import "RIPCoreDataManager.h"

#import "UITableViewCell+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "MMDrawerController.h"
#import "UIViewController+MMDrawerController.h"
#import "RIPPulseLabel.h"
#import "UIImage+FlatUI.h"

#import "User.h"
#import "ContactStatus.h"
#import "ImageCollection.h"

#import "UIImage+StackBlur.h"
#import "RIPErrorCodes.h"

static NSString * const kRowsKey   = @"rows";
static NSString * const kHeaderKey = @"header";

static NSString *upperAlphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";

@interface RIPContactsViewController ()
@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) User *user;

@property (strong, nonatomic) NSMutableArray *filteredContacts;
@property (assign, nonatomic) BOOL searching;
@property (assign, nonatomic) BOOL hidingData;
@property (strong, nonatomic) UIView *errorHeader;
@end

@implementation RIPContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		_searching = NO;
		_hidingData = NO;
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.tabBarItem.title = NSLocalizedString(@"TABBAR_CONTACTS", @"Tab bar title for Contacts page");
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_user = [[RIPCoreDataManager shared] currentUserInContext:[RIPCoreDataManager shared].managedObjectContext];
	_filteredContacts = [[NSMutableArray alloc] init];
    [self setupErrorHeader];
    
    [self.tableView setBackgroundColor:[UIColor softMetalColor]];
    [self.refreshControl addTarget:self action:@selector(refreshControlManually:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:[UIColor skyBlueColor]];
    [self.refreshControl beginRefreshing];
    [self refreshControlManually:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupTableIndexView];
    [self.refreshControl setTintColor:[UIColor skyBlueColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.refreshControl.isRefreshing && _contacts.count == 0)
        [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
}

- (void)setupErrorHeader {
	self.errorHeader = self.tableView.tableHeaderView;
	self.errorHeader.backgroundColor = [UIColor softMetalColor];
    
	RIPPulseLabel *label = (RIPPulseLabel *)[self.errorHeader viewWithTag:1];
	[label setText:NSLocalizedString(@"ERROR_UNAVAILABLE_DATA", @"Error to be displayed in view controllers when data is unavailable.")];
	[label setTextColor:[UIColor skyBlueColor]];
	[label setFont:[UIFont flatFontOfSize:16.0]];
    [label sizeToFit];
    self.tableView.tableHeaderView = nil;
}

- (void)pullData:(void(^)())completion{
	//inspect add and remove contacts
	__block NSManagedObjectID *userObjID = [self.user objectID];
	__block NSInteger numAddedDeleted = 0;
	[RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
		//In bg thread
		User *myUser = (User *)[context objectWithID:userObjID];
		__block NSSet *oldContacts = [self setOfIDsFromObjects:myUser.contacts];
		if(_contacts == nil){
			_contacts = [[NSMutableArray alloc] init];
			[self addContactStatuses:oldContacts inContext:context];
			[self sortContacts:_contacts inContext:context];
			dispatch_async(dispatch_get_main_queue(), ^{
                if(_contacts.count > 0 && self.tableView.contentOffset.y < 0)
                    [self.tableView setContentOffset:CGPointZero animated:YES];
                [self.tableView reloadData];
			});
		}
		//Loaded old contacts
	} completion:^{
		[[RIPCoreDataManager shared] updateContacts:^(NSSet *newContacts, NSSet *toDelete, RIPError errorCode) {
			dispatch_async(dispatch_get_main_queue(), ^{
                if(errorCode != RIPErrorNone){
                    NSLog(@"pullContacts EC: %d", errorCode);
                    _hidingData = [RIPErrorCodes shouldHideData:errorCode];
                    [self displayError];
                    return completion();
                }else{
                    _hidingData = NO;
                    [self hideError];
                }
            });
			[RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
				numAddedDeleted += [self addContactStatuses:newContacts inContext:context];
				numAddedDeleted += [self removeContactStatuses:toDelete inContext:context];
			} completion:^{
				if(numAddedDeleted > 0){
					self.user = [[RIPCoreDataManager shared] currentUserInContext:[RIPCoreDataManager shared].managedObjectContext];
					[RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
						[self sortContacts:_contacts inContext:context];
					} completion:completion];
				}else{
					completion();
				}
			}];
		}];
	}];
}

- (void)displayError {
    UIView *errHeader;
    if (self.tableView.tableHeaderView != nil) {
        errHeader = self.tableView.tableHeaderView;
    }else{
        errHeader = self.errorHeader;
        
        [UIView beginAnimations:@"RIPExpandHeader" context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [self.tableView setTableHeaderView:errHeader];
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
        [UIView commitAnimations];
    }
    RIPPulseLabel *pulseLabel = (RIPPulseLabel *)errHeader.subviews[0];
    [pulseLabel pulse:[UIColor skyBlueColor]];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
}

- (void)hideError {
    if(self.tableView.tableHeaderView != nil){
        UIView *errHeader = self.tableView.tableHeaderView;
        
        [UIView beginAnimations:@"RIPShrinkHeader" context:nil];
        [UIView setAnimationDuration:[CATransaction animationDuration]];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [errHeader removeFromSuperview];
        [self.tableView setTableHeaderView:nil];
        //self.tableView.tableHeaderView.frame = CGRectMake(r.origin.x, r.origin.y, r.size.width, self.searchDisplayController.searchBar.frame.size.height);
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
        [UIView commitAnimations];
        
    }
}

- (NSSet *)setOfIDsFromObjects:(NSSet *)contacts{
	//needs to be properly handled by background context!!
	NSMutableSet *ans = [[NSMutableSet alloc] init];
	for (ContactStatus *cs in contacts)
		[ans addObject:cs.objectID];
	return ans;
}

- (void)sortContacts:(NSMutableArray *)contacts inContext:(NSManagedObjectContext *)context{
	//main queue
	[contacts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSString *letter1 = (NSString *)((NSDictionary *)obj1)[kHeaderKey];
		NSString *letter2 = (NSString *)((NSDictionary *)obj2)[kHeaderKey];
		return [letter1 compare:letter2];
	}];
	for(NSDictionary *section in contacts){
		NSMutableArray *rows = section[kRowsKey];
		[rows sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			ContactStatus *cs1 = (ContactStatus *)[context objectWithID:(NSManagedObjectID *)obj1];
			ContactStatus *cs2 = (ContactStatus *)[context objectWithID:(NSManagedObjectID *)obj2];
			return [cs1.username compare:cs2.username];
		}];
	}
}

- (NSInteger)removeContactStatuses:(NSSet *)toDelete inContext:(NSManagedObjectContext *)context {
	NSInteger numDeleted = 0;
	if(toDelete.count == 0)
		return numDeleted;
	NSArray *toDeleteArray = [toDelete allObjects];
	NSMutableArray *sectionsToDelete = [[NSMutableArray alloc] init];
	for (NSInteger i = 0; i < toDeleteArray.count; i++) {
		NSManagedObjectID *currentObjID = toDeleteArray[i];
		ContactStatus *contactStatus = (ContactStatus *)[context objectWithID:currentObjID];
		NSString *username = contactStatus.username;
		NSString *firstLetter = [[username substringToIndex:1] uppercaseStringWithLocale:[NSLocale currentLocale]];
		if([upperAlphabet rangeOfString:firstLetter].location == NSNotFound) firstLetter = @"#";
		NSInteger sectionIndex = -1;
		for (NSInteger i = 0; i < _contacts.count; i++) {
			NSMutableDictionary *section = _contacts[i];
			if([section [kHeaderKey] isEqual:firstLetter]){
				sectionIndex = i;
				break;
			}
		}
		if(sectionIndex == -1){
			continue;
		}
		NSMutableArray *rows = _contacts[sectionIndex][kRowsKey];
		NSInteger pos = -1;
		for (NSInteger i = 0; i < rows.count; i++) {
			ContactStatus *cs = (ContactStatus *)[context objectWithID:(NSManagedObjectID *)rows[i]];
			if(cs.user_id.integerValue == contactStatus.user_id.integerValue){
				pos = i;
				break;
			}
		}
		if(pos == -1){
			continue;
		}else{
			NSManagedObjectID *objID = [rows objectAtIndex:pos];
			ContactStatus *c = (ContactStatus *)[context objectWithID:objID];
			c.owner = nil;
			[rows removeObjectAtIndex:pos];
			User *currentUser = [[RIPCoreDataManager shared] currentUserInContext:context];
			[currentUser removeContactsObject:c];
			numDeleted++;
			if(rows.count == 0){
				//delete this section!
				[sectionsToDelete addObject:_contacts[sectionIndex][kHeaderKey]];
			}
		}
	}
	for (NSString *letter in sectionsToDelete) {
		NSInteger n = [_contacts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary *d = obj;
			if([d[kHeaderKey] isEqual:letter]){
				*stop = YES;
				return YES;
			}
			return NO;
		}];
		[_contacts removeObjectAtIndex:n];
	}
	return numDeleted;
}

- (NSInteger)addContactStatuses:(NSSet *)contacts inContext:(NSManagedObjectContext *)context{
	NSInteger numAdded = 0;
	if(contacts.count == 0)
		return numAdded;
	NSArray *contactsArray = [contacts allObjects];
	for (NSInteger i = 0; i < contactsArray.count; i++) {
		NSManagedObjectID *currentObjID = contactsArray[i];
		ContactStatus *contactStatus = (ContactStatus *)[context objectWithID:currentObjID];
		NSString *username = contactStatus.username;
		NSString *firstLetter = [[username substringToIndex:1] uppercaseStringWithLocale:[NSLocale currentLocale]];
		if([upperAlphabet rangeOfString:firstLetter].location == NSNotFound) firstLetter = @"#";
		
		NSInteger sectionIndex = -1;
		for (NSInteger i = 0; i < _contacts.count; i++) {
			NSMutableDictionary *section = _contacts[i];
			if([section [kHeaderKey] isEqual:firstLetter]){
				sectionIndex = i;
				break;
			}
		}
		if(sectionIndex == -1){
			NSMutableDictionary *section = [[NSMutableDictionary alloc] init];
			section[kHeaderKey] = firstLetter;
			section[kRowsKey] = [[NSMutableArray alloc] init];
			[_contacts addObject:section]; //need to sort because of this
			sectionIndex = _contacts.count-1;
		}
		NSMutableArray *rows = _contacts[sectionIndex][kRowsKey];
		ContactStatus *prev = nil;
		NSInteger pos = -1;
		for (NSInteger i = 0; i < rows.count; i++) {
			ContactStatus *cs = (ContactStatus *)[context objectWithID:(NSManagedObjectID *)rows[i]];
			if([cs.user_id isEqualToNumber:contactStatus.user_id]){
				prev = cs;
				pos = i;
				break;
			}
		}
		User *currentUser = [[RIPCoreDataManager shared] currentUserInContext:context];
		if(prev == nil){
			[rows addObject:currentObjID];//need to sort as well.
			[currentUser addContactsObject:contactStatus];
			numAdded++;
		}else{
			[currentUser removeContactsObject:prev];
			[currentUser addContactsObject:contactStatus];
			[rows replaceObjectAtIndex:pos withObject:currentObjID];
		}
		contactStatus.owner = currentUser;
	}
	return numAdded;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if(_hidingData)
		return 0;
	if(tableView.tag != 1)
		return 1;
    if(_contacts == nil || _contacts.count == 0) return 0;
	return _contacts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(_hidingData)
		return 0;
	if(tableView.tag != 1)
		return [_filteredContacts count];
	if(_contacts == nil || _contacts.count == 0) return 0;
    NSMutableArray *rows = _contacts[section][kRowsKey];
	return rows.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if(tableView.tag != 1 || _hidingData)
		return nil;
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 17.0)];
	[header setBackgroundColor:[UIColor softMetalColor]];

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 17.0)];
	label.backgroundColor = [UIColor clearColor];
	label.opaque = NO;
	label.textColor = [UIColor skyBlueColor];
	label.highlightedTextColor = [UIColor skyBlueColor];
	label.shadowColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentLeft;
	label.numberOfLines = 0;
	label.font = [UIFont boldFlatFontOfSize:15.0];
	
	label.text = _contacts[section][kHeaderKey];
    
	[header addSubview:label];

	return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if(tableView.tag == 1 && !_hidingData)
		return 17.0;
	else
		return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_hidingData)
		return nil;
    static NSString *CellIdentifier = @"ContactsCell";
    RIPContactsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	ContactStatus *contactStatus = nil;
	if(tableView.tag == 1){
		contactStatus = (ContactStatus *)[[RIPCoreDataManager shared].managedObjectContext objectWithID:_contacts[indexPath.section][kRowsKey][indexPath.row]];
	}else{
		contactStatus = (ContactStatus *)[[RIPCoreDataManager shared].managedObjectContext objectWithID:_filteredContacts[indexPath.row]];
	}
	[self configureCell:cell contactStatus:contactStatus];
	
    return cell;
}

- (void)configureCell:(RIPContactsCell *)cell contactStatus:(ContactStatus *)contactStatus {
	//INVESTIGATE
	User *user = [[RIPCoreDataManager shared] userWithId:[contactStatus.user_id integerValue] inContext:[RIPCoreDataManager shared].managedObjectContext];
	cell.usernameLabel.text = user.username;
	cell.nameLabel.text = user.name;
    __block UIImageView *profileImageView = cell.profileImageView;
	if([user.selected_image integerValue] != 0 && user.imageCollection != nil){
		if([user.imageCollection profilePic:[user.selected_image integerValue]] == nil){
			[cell.activityIndicator startAnimating];
			[user.imageCollection pullProfilePic:[user.selected_image integerValue] WithQuality:kQualityThumb completion:^(NSInteger userID, RIPError errorCode){
				dispatch_async(dispatch_get_main_queue(), ^{
                    if(errorCode != RIPErrorNone){
                        //error pulling profile pic!
                        [profileImageView setImage:[ImageCollection noPhoto]];
                    }else{
                        [profileImageView setImage:[user.imageCollection profilePic:[user.selected_image integerValue]]];
                    }
                    [cell.activityIndicator stopAnimating];
                    profileImageView.hidden = NO;
                });
			}];
			[profileImageView setImage:[ImageCollection noPhoto]];
		}else{
			[profileImageView setImage:[user.imageCollection profilePic:[user.selected_image integerValue]]];
			profileImageView.hidden = NO;
		}
	}else{
		[profileImageView setImage:[ImageCollection noPhoto]];
		profileImageView.hidden = NO;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(_hidingData) return;
	ContactStatus *contactStatus = nil;
	if(tableView.tag == 1){
		contactStatus = (ContactStatus *)[[RIPCoreDataManager shared].managedObjectContext objectWithID:_contacts[indexPath.section][kRowsKey][indexPath.row]];
	}else{
		contactStatus = contactStatus = (ContactStatus *)[[RIPCoreDataManager shared].managedObjectContext objectWithID:_filteredContacts[indexPath.row]];
		[self.searchDisplayController.searchBar resignFirstResponder];
	}
	[self selectedContactStatus:contactStatus atIndexPath:indexPath];
}

- (void)selectedContactStatus:(ContactStatus *)contactStatus atIndexPath:(NSIndexPath *)indexPath{
	NSInteger userID = [contactStatus.user_id integerValue];
	MMDrawerController *drawer = (MMDrawerController *)self.parentViewController.parentViewController.parentViewController;
	RIPProfileViewController *contactProfile;
	if(drawer.leftDrawerViewController == nil){
		UIStoryboard *profileSb = [UIStoryboard storyboardWithName:@"UserProfileStoryboard" bundle:nil];
		contactProfile = (RIPProfileViewController *)[profileSb instantiateViewControllerWithIdentifier:@"RIPProfileViewController"];
		UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:contactProfile];
		
		UIImageView *bgView = [[UIImageView alloc] initWithFrame:nav.view.frame];
		bgView.image = [[UIImage imageNamed:@"cancun.jpg"] stackBlur: 3];
		bgView.contentMode = UIViewContentModeScaleAspectFill;
		bgView.clipsToBounds = YES;
		[nav.view insertSubview:bgView atIndex:0];
		nav.view.clipsToBounds = YES;
		//CoverPhoto!!
		drawer.leftDrawerViewController = nav;
	}else{
		contactProfile = (RIPProfileViewController *)drawer.leftDrawerViewController.childViewControllers[0];
	}
	contactProfile.userID = userID;
	[drawer openDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
        [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 48;
}

- (void) refreshControlManually:(UIRefreshControl *)refCtl {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self pullData:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [refCtl endRefreshing];
            });
        }];
    });
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *arr = [NSMutableArray array];
    char letter = 'A';
    while (letter <= 'Z') {
        [arr addObject:[NSString stringWithFormat:@"%c", letter]];
        letter++;
    }
    [arr addObject:@"#"];
    return arr;
}

- (void)setupTableIndexView {
    for(UIView *v in self.tableView.subviews){
        if([v respondsToSelector:@selector(setIndexColor:)]){
            [v performSelector:@selector(setIndexColor:) withObject:[UIColor skyBlueColor]];
            if([v respondsToSelector:@selector(setFont:)]){
                [v performSelector:@selector(setFont:) withObject:[UIFont boldFlatFontOfSize:10.0]];
                [v performSelector:@selector(setBackgroundColor:) withObject:[UIColor clearColor]];
            }
        }
    }
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1){
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        //self.tableView.sectionIndexMinimumDisplayRowCount = 10;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSInteger lastIndex = NSNotFound;
    char letter = [title characterAtIndex:0];
    if(letter == '#')
        letter = 'Z' + 1;
    for (NSInteger i = 0; i < _contacts.count; i++) {
        NSString *header = _contacts[i][kHeaderKey];
        char c = [header characterAtIndex:0];
        if(c == '#')
            c = 'Z' + 1;
        
        if(c == letter){
            lastIndex = i;
            break;
        }else if(c < letter)
            lastIndex = i;
        else
            break;
        
    }
    if(lastIndex == NSNotFound)
        [self.tableView setContentOffset:CGPointZero animated:NO];
    return lastIndex;
}

- (void)addBtn {
    NSLog(@"Wrong again!");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return !_hidingData;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(editingStyle == UITableViewCellEditingStyleDelete){
		UITableViewRowAnimation anim = UITableViewRowAnimationAutomatic;
        NSMutableArray *rows = _contacts[indexPath.section][kRowsKey];
        [rows removeObjectAtIndex:indexPath.row];
        if(rows.count == 0){
            [_contacts removeObjectAtIndex:indexPath.section];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:anim];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.editing){
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;
}

/*
- (IBAction)addMessage:(UIButton *)sender {
	if(![[sender.superview.superview class] isSubclassOfClass:[UITableViewCell class]])
		return;
	UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
	UITableView *tableView = (UITableView *)sender.superview.superview.superview;
	NSIndexPath *ind = [tableView indexPathForCell:cell];
	NSManagedObjectID *contactID = _searching?_filteredContacts[ind.row]:_contacts[ind.section][kRowsKey][ind.row];
	ContactStatus *contactStatus = (ContactStatus *)[[RIPCoreDataManager shared].managedObjectContext objectWithID:contactID];
	NSLog(@"Should message %@!", contactStatus);
}
*/


@end
