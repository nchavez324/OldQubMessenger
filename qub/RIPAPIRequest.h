//
//  RIPConnectionTester.h
//  qub
//
//  Created by Nick on 7/29/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;
@class AFJSONRequestOperation;

@interface RIPAPIRequest : NSObject

+ (NSURL *)baseApiURL;

+ (NSURL *)urlFromURLString:(NSString *)path relativeToBaseURL:(NSURL *)baseURL withParameters:(NSArray *)parameters username:(NSString *)username passwordHash:(NSString *)passwordHash method:(NSString *)method;

+ (AFHTTPRequestOperation *)httpRequestFromURLString:(NSString *)path relativeToBaseURL:(NSURL *)baseURL withParameters:(NSArray *)parameters username:(NSString *)username passwordHash:(NSString *)passwordHash method:(NSString *)method success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (AFHTTPRequestOperation *)JSONRequestFromURLString:(NSString *)path relativeToBaseURL:(NSURL *)baseURL withParameters:(NSArray *)parameters username:(NSString *)username passwordHash:(NSString *)passwordHash method:(NSString *)method success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (NSString *)encryptString:(NSString *)string;
@end
