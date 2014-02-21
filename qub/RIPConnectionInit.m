//
//  RIPConnectionInit.m
//  qub
//
//  Created by Nick on 6/11/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPConnectionInit.h"
#import "AFHTTPRequestOperation.h"
#import "RIPAPIRequest.h"

#define DEBUG_online YES

NSString * const kDefaultsUsernameKey     = @"Username";
NSString * const kDefaultsPasswordHashKey = @"PasswordHash";

@implementation RIPConnectionInit

+ (void)setUpModelWithUsername:(NSString *)username passwordHash:(NSString *)passwordHash isFromDefaults:(BOOL)defaults completion:(void(^)(UserLoginSuccess success, id JSON))completion{
	if(DEBUG_online){
		if(username.length > 0 && passwordHash.length > 0){
			[RIPConnectionInit makeBasicConnectionWithUsername:username passwordHash:passwordHash completion:^(UserLoginSuccess success, id JSON) {
					dispatch_async(dispatch_get_main_queue(), ^{
						completion(success, JSON);
					});
			}];
		}else{
			completion(defaults?kNoLoginFound:kNothingEntered, nil);
		}
	}else{
		completion(kNoInternetConnection, nil);
	}
}

+ (void)makeBasicConnectionWithUsername:(NSString *)username passwordHash:(NSString *)passwordHash completion:(void(^)(UserLoginSuccess success, id JSON))completion{
	AFHTTPRequestOperation *basicInfoRequest = [RIPAPIRequest JSONRequestFromURLString:[NSString stringWithFormat:@"profiles/%@", username] relativeToBaseURL:[RIPAPIRequest baseApiURL] withParameters:nil username:username passwordHash:passwordHash method:@"GET" success:^(AFHTTPRequestOperation *operation, id responseObject) {
		//write to defaults!
		[[NSUserDefaults standardUserDefaults] setObject:username forKey:kDefaultsUsernameKey];
		[[NSUserDefaults standardUserDefaults] setObject:passwordHash forKey:kDefaultsPasswordHashKey];
		completion(kSuccess, responseObject);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UserLoginSuccess success = kUnknownError;
        switch ([operation.response statusCode]){
			case 401:
				success = kIncorrectLogin;
				break;
			case 500:
			case 400:
				success = kServerError;
				break;
		}
		switch (error.code) {
			case -1009:
				success = kNoInternetConnection;
				break;
			case -1001:
				success = kTimeout;
				break;
		}
		if(success == kUnknownError)
			success = kServerError;
		completion(success, nil);
	}];
	[basicInfoRequest start];
}

@end
