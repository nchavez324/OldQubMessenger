//
//  RIPConnectionInit.h
//  qub
//
//  Created by Nick on 6/11/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	kSuccess,
	kIncorrectLogin,
	kNothingEntered,
	kNoLoginFound,
	kServerError,
	kContextError,
	kNoInternetConnection,
	kTimeout,
	kNotAvailable,
    kUnknownError
} UserLoginSuccess;

extern NSString * const kDefaultsUsernameKey;
extern NSString * const kDefaultsPasswordHashKey;

@interface RIPConnectionInit : NSObject

+ (void)setUpModelWithUsername:(NSString *)username passwordHash:(NSString *)passwordHash isFromDefaults:(BOOL)defaults completion:(void(^)(UserLoginSuccess success, id JSON))completion;

@end
