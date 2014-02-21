//
//  ContactStatus.m
//  qub
//
//  Created by Nick on 8/14/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "ContactStatus.h"
#import "User.h"

NSString * const kConfirmed        = @"CONF";
NSString * const kUserRequested    = @"1REQ";
NSString * const kContactRequested = @"2REQ";

@implementation ContactStatus

@dynamic status;
@dynamic username;
@dynamic user_id;
@dynamic owner;

- (void)fillWithUser:(User *)contact status:(NSString *)status {
	self.status = status;
	self.username = contact.username;
	self.user_id = contact.user_id;
	//self.owner assigned externally
}

- (NSString *)description{
	return [NSString stringWithFormat:@"{ID:%d, UN:%@, ST:%@, OWID?:%@}", [self.user_id integerValue], self.username, self.status, self.owner==nil?@"NO":[NSString stringWithFormat:@"%d",self.owner.user_id.integerValue]];
}

@end
