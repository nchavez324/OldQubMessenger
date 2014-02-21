//
//  RIPLoginViewController.m
//  qub
//
//  Created by Nick on 6/24/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "RIPLoginViewController.h"
#import "RIPAppDelegate.h"
#import "RIPCoreDataManager.h"
#import "RIPUserProfileViewController.h"
#import "RIPCenterViewController.h"
#import "RIPContactsViewController.h"

#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MGNavigationTransitioningDelegate.h"

#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "UIImage+StackBlur.h"

#import "RIPTextField.h"
#import "RIPAPIRequest.h"
#import "RIPPulseLabel.h"

#import "AFHTTPRequestOperation.h"

#import "RIPConnectionInit.h"
#import "User.h"
#import "ImageCollection.h"

@implementation RIPLoginViewController

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.view.backgroundColor = [UIColor skyBlueColor];
	
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	bgView.image = [[UIImage imageNamed:@"defaultCover0.jpg"] stackBlur: 3];
	bgView.tag = 10;
	bgView.contentMode = UIViewContentModeScaleAspectFill;
	bgView.clipsToBounds = YES;
	[self.view insertSubview:bgView atIndex:0];
	self.view.clipsToBounds = YES;
	[bgView setAlpha:0.4];
    
	[_usernameField style];
	_usernameField.placeholder =  NSLocalizedString(@"LABEL_USERNAME", @"Username label prompt");
	_usernameField.placeholderTextColor = [UIColor colorWithWhite:0.95 alpha:0.85];

	_passwordField.placeholder = NSLocalizedString(@"LABEL_PASSWORD", @"Password label prompt");
	[_passwordField style];
	_passwordField.placeholderTextColor = [UIColor colorWithWhite:0.95 alpha:0.85];
	
	_signUpButton.titleLabel.font = [UIFont boldFlatFontOfSize:18];
	[_signUpButton setTitle:NSLocalizedString(@"BUTTON_SIGNUP", @"Sign Up Button") forState:UIControlStateNormal];
	
	_loginButton.titleLabel.font = [UIFont boldFlatFontOfSize:20];
	[_loginButton setTitle: NSLocalizedString(@"BUTTON_LOGIN", @"Log In Button") forState:UIControlStateNormal];
	
	_forgotButton.backgroundColor = [UIColor clearColor];
	[_forgotButton setTitle:NSLocalizedString(@"BUTTON_FORGOT", @"Forgot Password Button") forState:UIControlStateNormal];
	_forgotButton.titleLabel.font = [UIFont flatFontOfSize:12];
	[_forgotButton setTitleColor:[UIColor softMetalColor] forState:UIControlStateNormal];
	[_forgotButton setTitleColor:[UIColor whiteColor]  forState:UIControlStateHighlighted];
	
	_errorLabel.backgroundColor = [UIColor clearColor];
	[_errorLabel setText:@""];
	_errorLabel.font = [UIFont flatFontOfSize:14];
	[_errorLabel setTextColor:[UIColor whiteColor]];
	
	_titleLabel.textColor =  [UIColor whiteColor];
	_titleLabel.font =  [UIFont boldAltFontOfSize:22];
	_titleLabel.text = NSLocalizedString(@"TITLE_QUB_MESSENGER", @"Title of App");
    
    [self hideUI];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self defaultsLoad];
}

- (void)defaultsLoad {
    [_largeActivityIndicator startAnimating];
    [RIPConnectionInit setUpModelWithUsername:[[NSUserDefaults standardUserDefaults] stringForKey:kDefaultsUsernameKey] passwordHash:[[NSUserDefaults standardUserDefaults] stringForKey:kDefaultsPasswordHashKey] isFromDefaults:YES completion:^(UserLoginSuccess success, id JSON) {
        [self handleUserLoginSuccess:success withJSON:JSON passwordHash:[[NSUserDefaults standardUserDefaults] stringForKey:kDefaultsPasswordHashKey] completion:^{
			[_largeActivityIndicator stopAnimating];
		}];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
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

- (IBAction)didEndOnExit:(RIPTextField *)sender {
	if(sender == _usernameField){
		[_passwordField becomeFirstResponder];
	}else{
		[_passwordField resignFirstResponder];
	}
}

- (IBAction)backgroundTap:(id)sender {
	[_usernameField resignFirstResponder];
	[_passwordField resignFirstResponder];
}

- (IBAction)signUpButtonPress:(UIButton *)sender {
	
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
	NSString *username = [_usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [_passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[_passwordField resignFirstResponder];
	[_usernameField resignFirstResponder];
    if(password.length > 0 && username.length > 0){
        NSString *passwordHash = [RIPAPIRequest encryptString:password];
        [_smallActivityIndicator startAnimating];
        [RIPConnectionInit setUpModelWithUsername:username passwordHash:passwordHash isFromDefaults:NO completion:^(UserLoginSuccess success, id JSON) {
            [self handleUserLoginSuccess:success withJSON:JSON passwordHash:passwordHash completion:^{
				[_smallActivityIndicator stopAnimating];
			}];
        }];
    }else{
        [self handleUserLoginSuccess:kNothingEntered withJSON:nil passwordHash:nil completion:nil];
    }
}

- (IBAction)forgotPasswordButton:(UIButton *)sender {
	
}

/****** Custom Methods ******
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

- (void)unhideUI {
    _forgotButton.hidden = NO;
    _usernameField.hidden = NO;
    _passwordField.hidden = NO;
    _loginButton.hidden = NO;
    _signUpButton.hidden = NO;
	_errorLabel.hidden = NO;
}

- (void)hideUI {
    _forgotButton.hidden = YES;
    _usernameField.hidden = YES;
    _passwordField.hidden = YES;
    _loginButton.hidden = YES;
    _signUpButton.hidden = YES;
	_errorLabel.hidden = YES;
}

- (void)handleUserLoginSuccess:(UserLoginSuccess)success withJSON:JSON passwordHash:(NSString *)passwordHash completion:(void(^)())completion{
   	//do shit from delegate like alert in here nigga
	//main queue!
	if(success == kSuccess){
		[self setupUser:JSON passwordHash:passwordHash completion:^(NSManagedObjectID *userObjID) {
			dispatch_async(dispatch_get_main_queue(), ^{
                if(userObjID == nil){
                    return [self handleUserLoginSuccess:kContextError withJSON:nil passwordHash:nil completion:completion];
                }
                MMDrawerController *vc = [RIPLoginViewController setupMainScreen];
                [self presentViewController:vc animated:YES completion:nil];
                if(completion != nil)
                    completion();
            });
		}];
	}else if(success == kIncorrectLogin){
        [self unhideUI];
		NSString *msg = NSLocalizedString(@"ERROR_INCORRECT", @"Error message for incorrect credentials");
		_errorLabel.text = msg;
		[_errorLabel pulse:[UIColor whiteColor]];
		if(completion != nil)
			completion();
	}else if(success == kNoLoginFound){
		/* Do nothing, stay on this screen! Unhide everything tho*/
        [self unhideUI];
		if(completion != nil)
			completion();
	}else if(success == kNothingEntered){
        [self unhideUI];
		NSString *msg = NSLocalizedString(@"ERROR_NOTHING", @"Error message for no credentials entered");
		_errorLabel.text = msg;
		[_errorLabel pulse:[UIColor whiteColor]];
		if(completion != nil)
			completion();
	}else if(success == kServerError){
        [self unhideUI];
		NSString *msg = NSLocalizedString(@"ERROR_SERVER", @"Error message for server error");
		_errorLabel.text = msg;
		[_errorLabel pulse:[UIColor whiteColor]];
		if(completion != nil)
			completion();
	}else if(success == kContextError){
		[self unhideUI];
		NSString *msg = NSLocalizedString(@"ERROR_SERVER", @"Error message for server error");
		_errorLabel.text = msg;
		[_errorLabel pulse:[UIColor whiteColor]];
		if(completion != nil)
			completion();
	}else if(success == kNoInternetConnection || success == kTimeout){
		[self setupUser:nil passwordHash:passwordHash completion:^(NSManagedObjectID *userObjID) {
			dispatch_async(dispatch_get_main_queue(), ^{
                if(userObjID == nil){
                    return [self handleUserLoginSuccess:kNotAvailable withJSON:nil passwordHash:nil completion:completion];
                }
                MMDrawerController *vc = [RIPLoginViewController setupMainScreen];
                [self presentViewController:vc animated:YES completion:nil];
                if(completion != nil)
                    completion();
            });
		}];
	}else if(success == kNotAvailable){
		[self unhideUI];
		NSString *msg = NSLocalizedString(@"ERROR_NOT_AVAILABLE", @"Error message for unavailable service.");
		_errorLabel.text = msg;
		[_errorLabel pulse:[UIColor whiteColor]];
		if(completion != nil)
			completion();
	}
}


- (void)setupUser:JSON passwordHash:(NSString *)passwordHash completion:(void(^)(NSManagedObjectID *userObjID))completion{
	__block NSManagedObjectID *objID;
	//get username!
	if(JSON == nil){
		//offline!
		NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsUsernameKey];
        if(username != nil){
			[RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
				NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"username=[c]%@",username]];
				[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:NO]]];
                NSError *error = nil;
				NSArray *arr = [context executeFetchRequest:fetchRequest error:&error];
				if(error != nil){
					NSLog(@"Context Error: %@ Code %d", error.localizedDescription, error.code);
					objID = nil;
					return;
				}
				if(arr == nil || arr.count < 1){
                    objID = nil;
					return;
				}
				User *user = (User *)arr[0];
				[[RIPCoreDataManager shared] setCurrentUserID:user.user_id.integerValue];
				objID = user.objectID;
			} completion:^{
				completion(objID);
			}];
		}else
			completion(nil);
	}else{
		[RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
			User *user = [[RIPCoreDataManager shared] addUserWithJSON:JSON isMin:NO inContext:context];
			if(user == nil){
				objID = nil;
				return;
			}
			[[RIPCoreDataManager shared] setCurrentUserID:[user.user_id integerValue]];
			user.password_hash = passwordHash;
			objID = user.objectID;
			[[RIPCoreDataManager shared] saveContext:context];
		} completion:^{
			completion(objID);
		}];
	}
}


+ (MMDrawerController *)setupMainScreen {
	UIStoryboard *mainSb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
	UIStoryboard *profileSb = [UIStoryboard storyboardWithName:@"UserProfileStoryboard" bundle:nil];
	RIPUserProfileViewController *profile = [profileSb instantiateViewControllerWithIdentifier:@"RIPUserProfileViewController"];
	profile.userID = [[RIPCoreDataManager shared] currentUserID];
    [RIPAppDelegate sharedAppDelegate].navigationTransitionDelegate = [[MGNavigationTransitioningDelegate alloc] init];
	UINavigationController *rightNav = [[UINavigationController alloc] initWithRootViewController:profile];
    rightNav.delegate = [RIPAppDelegate sharedAppDelegate].navigationTransitionDelegate;
    
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:rightNav.view.frame];
	bgView.image = [[UIImage imageNamed:@"cancun.jpg"] stackBlur: 3];
	bgView.contentMode = UIViewContentModeScaleAspectFill;
	bgView.clipsToBounds = YES;
	[rightNav.view insertSubview:bgView atIndex:0];
	rightNav.view.clipsToBounds = YES;

	RIPCenterViewController *center = [mainSb instantiateViewControllerWithIdentifier:@"RIPCenterViewController"];
    [center setSelectedIndex:0];
	UINavigationController *centerNav = [[UINavigationController alloc] initWithRootViewController:center];
    centerNav.navigationBar.translucent = NO;
    centerNav.delegate = [RIPAppDelegate sharedAppDelegate].navigationTransitionDelegate;
	
	MMDrawerController *drawer = [[MMDrawerController alloc] initWithCenterViewController:centerNav rightDrawerViewController:rightNav];
	drawer.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
	drawer.closeDrawerGestureModeMask =
	MMCloseDrawerGestureModePanningCenterView |
	MMCloseDrawerGestureModePanningNavigationBar |
	MMCloseDrawerGestureModeTapCenterView |
	MMCloseDrawerGestureModeTapNavigationBar;

	[drawer setDrawerVisualStateBlock:MMDrawerVisualState.slideAndScaleVisualStateBlock];
	return drawer;
}

@end
