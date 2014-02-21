//
//  RIPConvosViewController.h
//  qub
//
//  Created by Nick on 6/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIPConvosViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIView *errorView;

- (void)addBtn;
- (void)pullData:(void(^)())completion;

@end
