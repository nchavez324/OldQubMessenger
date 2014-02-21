//
//  ContactStatus.h
//  qub
//
//  Created by Nick on 8/14/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

extern NSString * const kConfirmed;
extern NSString * const kUserRequested;
extern NSString * const kContactRequested;

@interface ContactStatus : NSManagedObject

@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) User *owner;

- (void)fillWithUser:(User *)contact status:(NSString *)status;

@end

