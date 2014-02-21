#import "RIPMessageViewController.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "UIViewController+MMDrawerController.h"
#import "UIImage+StackBlur.h"
#import "RIPCoreDataManager.h"
#import "RIPProfileViewController.h"
#import "RIPAppDelegate.h"
#import "RIPCoreDataManager.h"

#import "User.h"
#import "ImageCollection.h"
#import "Message.h"

static NSString *kTimestampKey = @"timestamp";
static NSString *kContentKey   = @"content";
static NSString *kUserIDKey    = @"userID";

static const NSInteger kAvatarUserIndex    = 0;
static const NSInteger kAvatarContactIndex = 1;

@interface RIPMessageViewController ()
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) User *contact;
@property (assign, nonatomic) BOOL doneLoading;
@property (strong, nonatomic) NSMutableArray *unaddedMessages;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *avatarImageViews;
@end

@implementation RIPMessageViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    self.delegate = self;
    self.dataSource = self;
    _doneLoading = NO;
    [super viewDidLoad];

    _user = [[RIPCoreDataManager shared] currentUserInContext:[RIPCoreDataManager shared].managedObjectContext];
    
    [self setBackgroundColor:[UIColor softMetalColor]];

	self.view.clipsToBounds = YES;

    UIButton *user = [UIButton buttonWithType:UIButtonTypeCustom];
	[user setFrame:CGRectMake(0, 0, 35.0, 35.0)];
	[user addTarget:self action:@selector(userBtn) forControlEvents:UIControlEventTouchUpInside];
	[user setImage:[UIImage imageNamed:@"profileIcon"] forState:UIControlStateNormal];
    UIBarButtonItem *userBtn = [[UIBarButtonItem alloc] initWithCustomView:user];
    
    UIButton *camera = [UIButton buttonWithType:UIButtonTypeCustom];
	[camera setFrame:CGRectMake(0, 0, 35.0, 35.0)];
	[camera addTarget:self action:@selector(cameraBtn) forControlEvents:UIControlEventTouchUpInside];
	[camera setImage:[UIImage imageNamed:@"cameraIcon"] forState:UIControlStateNormal];
	UIBarButtonItem *cameraBtn = [[UIBarButtonItem alloc] initWithCustomView:camera];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = (NSFoundationVersionNumber>NSFoundationVersionNumber_iOS_6_1)?-14.0:0.0;
    UIBarButtonItem *between = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    between.width = 0.0;
 
    [self.navigationItem setRightBarButtonItems:@[negativeSpacer, userBtn, between, cameraBtn]];
    
    UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    [titleButton setTitle:self.title forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleButton setTitleColor:[UIColor skyBlueColor] forState:UIControlStateHighlighted];
    [titleButton.titleLabel setFont:[UIFont boldAltFontOfSize:20.0]];
    [titleButton.titleLabel.layer setShadowColor:[UIColor whiteColor].CGColor];
    [titleButton.titleLabel.layer setShadowOpacity:0.8];
    [titleButton.titleLabel.layer setShadowRadius:3.0];
    [titleButton.titleLabel.layer setMasksToBounds:NO];
    [titleButton.titleLabel.layer setShadowOffset:CGSizeZero];
    [titleButton addTarget:self action:@selector(contactBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setTitleView:titleButton];
    [self adjustTitleView:[UIApplication sharedApplication].statusBarOrientation];
    
    [[JSBubbleView appearance] setFont:[UIFont flatFontOfSize:16.0f]];
    
    self.messageInputView.textView.placeHolder = NSLocalizedString(@"NEW_MESSAGE", @"Message box placeholder");
    
    _avatarImageViews = [NSMutableArray arrayWithArray:@[
        [JSAvatarImageFactory avatarImage:[ImageCollection noPhoto] croppedToCircle:[RIPAppDelegate usingCircularAvatars]],
        [JSAvatarImageFactory avatarImage:[ImageCollection noPhoto] croppedToCircle:[RIPAppDelegate usingCircularAvatars]]
    ]];
    
    //sample!
    _messages = [NSMutableArray array];
    //[self addTestMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadAvatarImagesForUserID:_user.user_id.integerValue];
    [self loadAvatarImagesForUserID:_contact.user_id.integerValue];
    [self refreshData];
}

- (void)setContactID:(NSInteger)contactID {
    _contactID = contactID;
    _messages = nil;
    _unaddedMessages = nil;
    _contact = [[RIPCoreDataManager shared] userWithId:_contactID inContext:[RIPCoreDataManager shared].managedObjectContext];
}

- (void)pullData:(void (^)(NSArray *))completion {
    _doneLoading = NO;
	void (^fetchBlock)(BOOL, RIPError) = ^(BOOL completeOnEmpty, RIPError errorCode){
		dispatch_async(dispatch_get_main_queue(), ^{
            if(errorCode != RIPErrorNone){
                NSLog(@"pullMessages EC: %d", errorCode);
                /*_hidingData = [RIPErrorCodes shouldHideData:errorCode];
                [self displayError];*/
                _doneLoading = YES;
                return completion(nil);
            }else{
                /*_hidingData = NO;
                [self hideError];*/
            }
        });
        _unaddedMessages = [NSMutableArray array];
		[RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
			NSArray *fetchedMessages = [[RIPCoreDataManager shared] messagesBetween:_user.user_id.integerValue and:_contactID count:-1 offset:-1 inContext:[RIPCoreDataManager shared].managedObjectContext];
			if(fetchedMessages == nil || fetchedMessages.count == 0){
                if(completeOnEmpty){
                    _doneLoading = YES;
                    return completion(nil);
                }else
                    return;
			}
            int lastCheckedIndex = -1;
            for (NSInteger i = 0; i < fetchedMessages.count; i++) {
                Message *message = fetchedMessages[i];
                NSInteger fromID = message.fromUserID.integerValue;
                float timestamp = message.timestamp.floatValue;
				NSMutableDictionary *msgEntry = nil;
                BOOL present = NO;
                for(NSInteger j = lastCheckedIndex+1; j < _messages.count; j++){
                    NSMutableDictionary *d = _messages[j];
                    if([(NSNumber *)d[kUserIDKey] integerValue] == fromID &&
                       [(NSNumber *)d[kTimestampKey] floatValue] == timestamp){
                        //already loaded
                        present = YES;
                        lastCheckedIndex = j;
                        break;
                    }
                }
                if(!present)
                    msgEntry = [NSMutableDictionary dictionary];
                msgEntry[kTimestampKey] = [NSNumber numberWithFloat:timestamp];
                msgEntry[kContentKey] = message.content;
                msgEntry[kUserIDKey] = [NSNumber numberWithInteger:fromID];
                if(!present){
                    [_unaddedMessages addObject:msgEntry];
                    lastCheckedIndex = _messages.count - 1;
                }
			}
		} completion:^{
            completion(_unaddedMessages);
        }];
	};
	if(_messages == nil)
		fetchBlock(NO, RIPErrorNone);
    NSLog(@"Here..");
	[[RIPCoreDataManager shared] updateMessages:fetchBlock];
}

- (void)refreshData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self pullData:^(NSArray *newMessages){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(YES){
                    for (NSMutableDictionary *msgEntry in newMessages) {
                        [self didSendMessage:msgEntry];
                    }
                    _unaddedMessages = nil;
                    [self reloadMessageRows:_user.user_id.integerValue];
                    [self reloadMessageRows:_contactID];
                    
                }
            });
       }];
    });
}

- (void)reloadMessageRows:(NSInteger)userID {
    NSMutableArray *rows = [NSMutableArray array];
    for (NSInteger i = 0; i < _messages.count; i++) {
        NSDictionary *msg = _messages[i];
        if([(NSNumber *)msg[kUserIDKey] integerValue] == userID)
            [rows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
}

- (void)loadAvatarImagesForUserID:(NSInteger)userID {
    User *user = (userID == _user.user_id.integerValue)?_user:_contact;
    NSInteger index =
        (user.user_id.integerValue == _user.user_id.integerValue)?kAvatarUserIndex:kAvatarContactIndex;
    if(user != nil && user.selected_image.integerValue != 0){
        if(user.imageCollection == nil){
            __block ImageCollection *imageCollection = [[RIPCoreDataManager shared] addImageCollection:user inContext:[RIPCoreDataManager shared].managedObjectContext];
            if(imageCollection != nil)
                imageCollection.user = user;
            user.imageCollection = imageCollection;
        }
		if([user.imageCollection profilePic:[user.selected_image integerValue]] == nil){
			[user.imageCollection pullProfilePic:[user.selected_image integerValue] WithQuality:kQualityThumb completion:^(NSInteger userID, RIPError errorCode){
				dispatch_async(dispatch_get_main_queue(), ^{
                    if(errorCode != RIPErrorNone){
                        //error pulling profile pic!
                        _avatarImageViews[index] =
                        [JSAvatarImageFactory
                         avatarImage:[ImageCollection noPhoto]
                         croppedToCircle:[RIPAppDelegate usingCircularAvatars]];
                    }else{
                        _avatarImageViews[index] =
                        [JSAvatarImageFactory
                         avatarImage:[user.imageCollection
                                      profilePic:[user.selected_image integerValue]]
                         croppedToCircle:[RIPAppDelegate usingCircularAvatars]];
                    }
                });
			}];
			_avatarImageViews[index] =
            [JSAvatarImageFactory
             avatarImage:[ImageCollection noPhoto]
             croppedToCircle:[RIPAppDelegate usingCircularAvatars]];
		}else{
            _avatarImageViews[index] =
                [JSAvatarImageFactory
                avatarImage:[user.imageCollection
                profilePic:[user.selected_image integerValue]]
                croppedToCircle:[RIPAppDelegate usingCircularAvatars]];
		}
	}else{
		_avatarImageViews[index] =
        [JSAvatarImageFactory
         avatarImage:[ImageCollection noPhoto]
         croppedToCircle:[RIPAppDelegate usingCircularAvatars]];
	}
    [self reloadMessageRows:user.user_id.integerValue];
}

- (void)addTestMessages {
    NSMutableDictionary *m1 = [NSMutableDictionary dictionaryWithDictionary:@{
        kTimestampKey: [NSNumber numberWithFloat:1389996469],
        kContentKey: @"Yo dude",
        kUserIDKey: @1
    }];
    NSMutableDictionary *m2 = [NSMutableDictionary dictionaryWithDictionary:@{
        kTimestampKey: [NSNumber numberWithFloat:1389996868],
        kContentKey: @"Yoo HAlo later come thru",
        kUserIDKey: @2
    }];
    NSMutableDictionary *m3 = [NSMutableDictionary dictionaryWithDictionary:@{
        kTimestampKey: [NSNumber numberWithFloat:1389996890],
        kContentKey: @"Ask your mom",
        kUserIDKey: @2
    }];
    NSMutableDictionary *m4 = [NSMutableDictionary dictionaryWithDictionary:@{
        kTimestampKey: [NSNumber numberWithFloat:1389996992],
        kContentKey: @"Aiight I think I'll be there soon",
        kUserIDKey: @1
    }];
    NSMutableDictionary *m5 = [NSMutableDictionary dictionaryWithDictionary:@{
        kTimestampKey: [NSNumber numberWithFloat:1389997540],
        kContentKey: @"omw!",
        kUserIDKey: @1
    }];
    [_messages addObjectsFromArray:@[m1, m2, m3, m4, m5]];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text {
    NSDate *d = [NSDate date];
    NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithDictionary:@{
        kTimestampKey: [NSNumber numberWithFloat:d.timeIntervalSince1970],
        kContentKey: text,
        kUserIDKey: [NSNumber numberWithInteger:_user.user_id.integerValue]
    }];
    [self didSendMessage:msg];
}

- (void)didSendMessage:(NSMutableDictionary *)entry {
    [_messages addObject:entry];
    [self finishSend];
    [self scrollToBottomAnimated:YES];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_messages == nil || _messages.count - 1 < indexPath.row){
        NSLog(@"FML");
        return JSBubbleMessageTypeOutgoing;
    }
    NSMutableDictionary *msg = _messages[indexPath.row];
    NSInteger userID = [(NSNumber *)msg[kUserIDKey] integerValue];
    if(userID == _user.user_id.integerValue)
        return JSBubbleMessageTypeOutgoing;
    else
        return JSBubbleMessageTypeIncoming;
}

#pragma mark - Messages view delegate: OPTIONAL

- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if([cell messageType] == JSBubbleMessageTypeOutgoing)
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    else
        cell.bubbleView.textView.textColor = [UIColor wetAsphaltColor];
    
    if([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
        NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
        [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
        cell.bubbleView.textView.linkTextAttributes = attrs;
    }
    if(cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor grayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
        cell.timestampLabel.font = [UIFont flatFontOfSize:cell.timestampLabel.font.pointSize];
    }
    if(cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor grayColor];
        cell.subtitleLabel.font = [UIFont flatFontOfSize:cell.timestampLabel.font.pointSize];
    }
}

//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//  - (UIButton *)sendButtonForInputView
//  *** Implement to prevent auto-scrolling when message is added
#pragma mark - Messages view data source: REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_messages == nil || _messages.count - 1 < indexPath.row)
        return @"<>";
    NSMutableDictionary *msg = _messages[indexPath.row];
    NSString *content = (NSString *)msg[kContentKey];
    return content;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_messages == nil || _messages.count - 1 < indexPath.row){
        return [NSDate distantPast];
    }
    NSMutableDictionary *msg = _messages[indexPath.row];
    float ts = [(NSNumber *)msg[kTimestampKey] floatValue];
    return [NSDate dateWithTimeIntervalSince1970:ts];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_messages == nil || _messages.count - 1 < indexPath.row)
        return nil;
    UIImageView *imV = nil;
    NSMutableDictionary *msg = _messages[indexPath.row];
    NSInteger userID = [(NSNumber *)msg[kUserIDKey] integerValue];
    UIImage *im = _avatarImageViews[((userID == _user.user_id.integerValue)?
                             kAvatarUserIndex:
                             kAvatarContactIndex)];
    imV = [[UIImageView alloc] initWithImage:im];
    return imV;
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"";
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return NO;
}

- (void)contactBtn {
	MMDrawerController *drawer = self.mm_drawerController;
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
	contactProfile.userID = _contactID;
	[drawer openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)userBtn {
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)cameraBtn {
    //LOL
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(type == JSBubbleMessageTypeIncoming)
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor concreteColor]];
    else
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor marineBlueColor]];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy {
    return JSMessagesViewTimestampPolicyAll;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy {
    return JSMessagesViewAvatarPolicyAll;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy {
    return JSMessagesViewSubtitlePolicyNone;
}

- (JSMessageInputViewStyle)inputViewStyle {
    return (NSFoundationVersionNumber>NSFoundationVersionNumber_iOS_6_1)?
JSMessageInputViewStyleFlat:
    JSMessageInputViewStyleClassic;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self adjustTitleView:toInterfaceOrientation];
    
}

- (void)adjustTitleView:(UIInterfaceOrientation)orientation {
    UIView *titleView = self.navigationItem.titleView;
    CGRect t = titleView.frame;
    CGSize s = CGSizeMake(UIInterfaceOrientationIsPortrait(orientation)?150:350, UIInterfaceOrientationIsPortrait(orientation)?44:34);
    titleView.frame = CGRectMake(t.origin.x + t.size.width/2.0 - s.width/2.0, t.origin.y + t.size.height/2.0 - s.height/2.0, s.width, s.height);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

@end
