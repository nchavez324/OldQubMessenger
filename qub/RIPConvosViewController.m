//
//  RIPConvosViewController.m
//  qub
//
//  Created by Nick on 6/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPConvosViewController.h"

#import "RIPCoreDataManager.h"
#import "UIColor+FlatUI.h"
#import "RIPConvosCell.h"
#import "RIPErrorCodes.h"
#import "RIPPulseLabel.h"
#import "UIFont+FlatUI.h"
#import "RIPMessageViewController.h"

#import "User.h"
#import "Message.h"
#import "ImageCollection.h"

static NSString * const kRowsKey   = @"rows";
static NSString * const kHeaderKey = @"header";

@interface RIPConvosViewController ()
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSMutableArray *convos;
@property (assign, nonatomic) BOOL hidingData;
@property (assign, nonatomic) BOOL doneLoading;
@property (strong, nonatomic) UIView *errorHeader;
@end

@implementation RIPConvosViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		_hidingData = NO;
        _doneLoading = NO;
    }
    return self;
}

- (void)awakeFromNib {
	self.tabBarItem.title = NSLocalizedString(@"TABBAR_CONVOS", @"Tab bar title for Convos page");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
	
	_user = [[RIPCoreDataManager shared] currentUserInContext:[RIPCoreDataManager shared].managedObjectContext];
	[self setupErrorHeader];
    
    [self.tableView setBackgroundColor:[UIColor softMetalColor]];
    [self.refreshControl addTarget:self action:@selector(refreshControlManually:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:[UIColor skyBlueColor]];
    [self.refreshControl beginRefreshing];
    [self refreshControlManually:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.refreshControl setTintColor:[UIColor skyBlueColor]];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.refreshControl.isRefreshing)
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

- (void)pullData:(void (^)())completion {
	
    _doneLoading = NO;
	void (^fetchBlock)(BOOL, RIPError) = ^(BOOL completeOnEmpty, RIPError errorCode){
		dispatch_async(dispatch_get_main_queue(), ^{
            //get messages that are relevant to list -- newest for each convo
            if(errorCode != RIPErrorNone){
                NSLog(@"pullMessages EC: %d", errorCode);
                _hidingData = [RIPErrorCodes shouldHideData:errorCode];
                [self displayError];
                _doneLoading = YES;
                return completion();
            }else{
                _hidingData = NO;
                [self hideError];
            }
        });
		[RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
			NSMutableArray *fetchedContacts = [[NSMutableArray alloc] init];
			NSSortDescriptor *byTimestamp = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
			[fetchRequest setSortDescriptors:@[byTimestamp]];
			NSError *error = nil;
			//NSLog(@"About to fetch");
			//thread blocking here!!!!!!!!!! Use of managed objects
			NSArray *messages = [context executeFetchRequest:fetchRequest error:&error];
			//NSLog(@"Fetched!");
			if(error != nil){
				NSLog(@"Context error: %@", [error localizedDescription]);
			}
			//messages are sorted by timestamp, so if you find one and it has not been picked up, you can ignore the rest.
			_convos = [[NSMutableArray alloc] init];
			if(messages.count == 0){
                if(completeOnEmpty){
                    _doneLoading = YES;
                    return completion();
                }else
                    return;
			}
            BOOL allContactsExist = YES;
			for (NSInteger i = 0; i < messages.count; i++) {
				Message *message = messages[i];
				NSInteger contactID = message.fromUserID.integerValue==self.user.user_id.integerValue?message.toUserID.integerValue:message.fromUserID.integerValue;
				if([fetchedContacts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
					NSNumber *ID = obj;
					if(ID.integerValue == contactID){
						*stop = YES;
						return YES;
					}
					return NO;
				}] == NSNotFound){
					//you have found the newest message for a given contact
					[_convos addObject:message.objectID];
                    NSInteger contactID = (message.toUserID.integerValue == _user.user_id.integerValue)?message.fromUserID.integerValue:message.toUserID.integerValue;
                    User *contact = [[RIPCoreDataManager shared] userWithId:contactID inContext:[RIPCoreDataManager shared].managedObjectContext];
                    if(contact == nil){
                        allContactsExist = NO;
                    }
					[fetchedContacts addObject:[NSNumber numberWithInteger:contactID]];
				}
			}
            //check if you have contacts locally -- if not load em
            if(allContactsExist){
                _doneLoading = YES;
            }else{
                NSLog(@"PROBLEMS?");
                [[RIPCoreDataManager shared] updateContacts:^(NSSet *newContacts, NSSet *toDelete, RIPError errorCode) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(errorCode != RIPErrorNone){
                            NSLog(@"pullContacts EC: %d", errorCode);
                            _hidingData = [RIPErrorCodes shouldHideData:errorCode];
                            [self displayError];
                        }else{
                            _hidingData = NO;
                            [self hideError];
                        }
                    });
                    _doneLoading = YES;
                    completion();
                }];
            }
		} completion:completion];
	};
	if(_convos == nil)
		fetchBlock(NO, RIPErrorNone);
	[[RIPCoreDataManager shared] updateMessages:fetchBlock];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if(_hidingData) return 0;
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_convos == nil || _hidingData) return 0;
	return _convos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(_hidingData)
		return nil;
    static NSString *CellIdentifier = @"ConvosCell";
    RIPConvosCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Message *msg = (Message *)[[RIPCoreDataManager shared].managedObjectContext objectWithID:_convos[indexPath.row]];
	[self configureCell:cell message:msg];
    
    return cell;
}

- (void)configureCell:(RIPConvosCell *)cell message:(Message *)message {
	NSInteger contactID = message.fromUserID.integerValue==self.user.user_id.integerValue?message.toUserID.integerValue:message.fromUserID.integerValue;
	//INVESTIGATE
	User *contact = [[RIPCoreDataManager shared] userWithId:contactID inContext:[RIPCoreDataManager shared].managedObjectContext];
    //message preview, date, status
	cell.previewLabel.text = message.content;
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.timestamp.floatValue];
	cell.dateLabel.text = [self formattedDate:date];
	cell.statusCode = message.status;
	if(contact == nil){
        cell.usernameLabel.text = @"...";
		return;
	}
	cell.usernameLabel.text = contact.username;
	__block UIImageView *profileImageView = cell.profileImageView;
	if([contact.selected_image integerValue] != 0 && contact.imageCollection != nil){
		if([contact.imageCollection profilePic:[contact.selected_image integerValue]] == nil){
			[cell.activityIndicator startAnimating];
			[contact.imageCollection pullProfilePic:[contact.selected_image integerValue] WithQuality:kQualityThumb completion:^(NSInteger userID, RIPError errorCode){
				dispatch_async(dispatch_get_main_queue(), ^{
                    if(errorCode != RIPErrorNone){
                        [profileImageView setImage:[ImageCollection noPhoto]];
                    }else{
                        [profileImageView setImage:[contact.imageCollection profilePic:[contact.selected_image integerValue]]];
                    }
                    [cell.activityIndicator stopAnimating];
                    profileImageView.hidden = NO;
                });
			}];
			[profileImageView setImage:[ImageCollection noPhoto]];
		}else{
			[profileImageView setImage:[contact.imageCollection profilePic:[contact.selected_image integerValue]]];
			profileImageView.hidden = NO;
		}
	}else{
		[profileImageView setImage:[ImageCollection noPhoto]];
		profileImageView.hidden = NO;
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(_hidingData){
		RIPPulseLabel *label = (RIPPulseLabel *)[cell viewWithTag:1];
		[label pulse:[UIColor skyBlueColor]];
	}
}

- (NSString *)formattedDate:(NSDate *)date {
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	[cal setTimeZone:[NSTimeZone systemTimeZone]];
	NSDateComponents *comp = [cal components:NSIntegerMax fromDate:[NSDate date]];
	[comp setHour:0];
	[comp setMinute:0];
	[comp setSecond:0];
	NSDate *lastMidnight = [cal dateFromComponents:comp];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:[cal timeZone]];
	if([date laterDate:lastMidnight] == lastMidnight){
		comp = [cal components:NSIntegerMax fromDate:[NSDate date]];
		[comp setDay:[comp day] - ([comp weekday] - 1)];
		[comp setHour:0];
		[comp setMinute:0];
		[comp setSecond:0];
		NSDate *beginningOfWeek = [cal dateFromComponents:comp];
		if([date laterDate:beginningOfWeek] == beginningOfWeek){
			//return month/year: 12/31
			[dateFormatter setDateFormat:@"M/d"];
			return [dateFormatter stringFromDate:date];
		}else{
			//return day of week abbreviated: Mon
			[dateFormatter setDateFormat:@"eee"];
			return [dateFormatter stringFromDate:date];
		}
	}else{
		//return like format: 3:01p
		[dateFormatter setDateFormat:@"hh:mma"];
		return [dateFormatter stringFromDate:date];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(!_hidingData){
		Message *msg = (Message *)[[RIPCoreDataManager shared].managedObjectContext objectWithID:_convos[indexPath.row]];
		[self selectedMessage:msg];
	}
}

- (void)selectedMessage:(Message *)message {
    RIPMessageViewController *dvc = [[RIPMessageViewController alloc] init];
    NSInteger contactID = (self.user.user_id.integerValue == message.toUserID.integerValue)?
        message.fromUserID.integerValue:
        message.toUserID.integerValue;
    User *contact = [[RIPCoreDataManager shared] userWithId:contactID inContext:[RIPCoreDataManager shared].managedObjectContext];
    if(contact != nil && [_user isContactWithID:contactID] && contact.username != nil)
        dvc.title = contact.username;
    else
        dvc.title = NSLocalizedString(@"TITLE_CONVO", @"Default title for convo");
    dvc.contactID = contactID;
    
    [self.navigationController pushViewController:dvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 48;
}

- (void)addBtn {
    NSLog(@"Here!");
}

- (void)refreshControlManually:(UIRefreshControl *) refCtl{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self pullData:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_doneLoading){
                    [self.tableView reloadData];
                    [refCtl endRefreshing];
                }
            });
        }];
    });
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return !_hidingData;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(editingStyle == UITableViewCellEditingStyleDelete){
		UITableViewRowAnimation anim = UITableViewRowAnimationAutomatic;
        [_convos removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:anim];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.editing){
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;
}


@end
