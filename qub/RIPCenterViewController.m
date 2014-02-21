//
//  RIPCenterViewController.m
//  qub
//
//  Created by Nick on 6/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPCenterViewController.h"
#import "RIPContactsViewController.h"
#import "RIPConvosViewController.h"

#import "MMDrawerBarButtonItem.h"

#import "UIViewController+MMDrawerController.h"
#import "UINavigationBar+FlatUI.h"
#import "UITabBar+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"

@implementation RIPCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (RIPContactsViewController *)contactsVc {
	return self.viewControllers[0];
}

- (RIPConvosViewController *)convosVc {
	return self.viewControllers[1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	UIButton *user = [UIButton buttonWithType:UIButtonTypeCustom];
	[user setFrame:CGRectMake(0, 0, 35.0, 35.0)];
	[user addTarget:self action:@selector(userBtn) forControlEvents:UIControlEventTouchUpInside];
	[user setImage:[UIImage imageNamed:@"profileIcon"] forState:UIControlStateNormal];
	UIBarButtonItem *userBtn = [[UIBarButtonItem alloc] initWithCustomView:user];
    
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
	[add setFrame:CGRectMake(0, 0, 30.0, 30.0)];
	[add addTarget:self action:@selector(addBtn) forControlEvents:UIControlEventTouchUpInside];
	[add setImage:[UIImage imageNamed:@"addIcon"] forState:UIControlStateNormal];
	UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithCustomView:add];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = (NSFoundationVersionNumber>NSFoundationVersionNumber_iOS_6_1)?-14.0:0.0;
    UIBarButtonItem *between = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    between.width = 0.0;
    
	[self.navigationItem setRightBarButtonItems:@[negativeSpacer, userBtn, between, addBtn]];
	
    negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = (NSFoundationVersionNumber>NSFoundationVersionNumber_iOS_6_1)?-12.0:0.0;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn setFrame:CGRectMake(0, 0, 55.0, 35.0)];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor softMetalColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(editList) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, editBtn] animated:NO];
	[self updateEditButton:NO];
    
    [[self.tabBar.items objectAtIndex:0]
	 setFinishedSelectedImage:[UIImage imageNamed:@"contactsSelectedIcon"]
	 withFinishedUnselectedImage:[UIImage imageNamed:@"contactsUnselectedIcon"]];
	
	[[self.tabBar.items objectAtIndex:1]
	 setFinishedSelectedImage:[UIImage imageNamed:@"convosSelectedIcon"]
	 withFinishedUnselectedImage:[UIImage imageNamed:@"convosUnselectedIcon"]];
	
	self.title = NSLocalizedString(@"TITLE_QUB_MESSENGER", @"Title of App");
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NAVIGATION_BACK", @"Back display for navigation") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
}

- (void)editList {
    UITableViewController *tvc = (UITableViewController *)self.selectedViewController;
    [tvc setEditing:!tvc.editing animated:YES];
    [self updateEditButton:tvc.editing];
}

- (void)updateEditButton:(BOOL)editing {
    UIBarButtonItem *button = self.navigationItem.leftBarButtonItems[1];
    
    UIFont *font = editing?
        [UIFont boldFlatFontOfSize:18.0]:
        [UIFont flatFontOfSize:18.0];
    [[(UIButton *)button.customView titleLabel] setFont:font];
    
    NSString *title = editing?
        NSLocalizedString(@"DONE", @"Done tab bar title"):
        NSLocalizedString(@"EDIT", @"Edit tab bar title");
    [(UIButton *)button.customView setTitle:title forState:UIControlStateNormal];
    NSArray *rightBtns = self.navigationItem.rightBarButtonItems;
    [UIView beginAnimations:nil context:nil];
    for (UIBarButtonItem *b in rightBtns) {
        b.customView.alpha = editing?0.0:1.0;
    }
    [UIView commitAnimations];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    int index = self.selectedIndex==0?1:0;
    UITableViewController *tvc = [self.viewControllers objectAtIndex:index];
    [self.selectedViewController setEditing:NO animated:NO];
    [tvc setEditing:NO animated:NO];
    [self updateEditButton:NO];
}

- (void)addBtn {
    [self.selectedViewController performSelector:@selector(addBtn)];
}

- (void)userBtn {
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}
- (void)leftBtn {
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
@end
