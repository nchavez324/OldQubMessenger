//
//  RIPProfileViewController.h
//  qub
//
//  Created by Nick on 6/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "RIPProfileViewController.h"

@class User;

@interface RIPUserProfileViewController : RIPProfileViewController
<iCarouselDelegate, iCarouselDataSource>

extern NSString * const kEmptyVal;
extern NSInteger const kActivityIndicatorTag;

/***
 Set of table views and icons that represent layout.
 ***/

/*** Toggling actions. ***/
@property (weak, nonatomic) IBOutlet iCarousel *profileCarousel;
@property (strong, nonatomic) NSMutableArray *pictureData;

@end
