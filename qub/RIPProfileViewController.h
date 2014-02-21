//
//  RIPProfileViewController.h
//  qub
//
//  Created by Nick on 8/18/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface RIPProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

extern NSString * const kIconName;
extern NSString * const kTitle;
extern NSString * const kMale;
extern NSString * const kFemale;
extern NSString * const kOther;

typedef enum userData {
	kUsername = 0,
	kName     = 1,
	kAge      = 2,
	kSex      = 3,
	kSeeking  = 4,
	kLocation = 5,
	kNumRows  = 6
} UserData;

extern NSInteger const kImageTag;
extern NSInteger const kImageViewTagBase;


@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITableView * profileDataTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *profileActivityIndicator;
@property (strong, nonatomic) NSArray *profileStrings;
@property (strong, nonatomic) User *user;
@property (assign, nonatomic) NSInteger userID;
@property (assign, nonatomic) BOOL doneLoading;

- (void)configureCell:(UITableViewCell *)cell;
- (void)doLayoutForOrientation:(UIInterfaceOrientation)orientation;
- (BOOL)visibleAndAssignView:view dataWithIndex:(NSInteger)index;

@end
