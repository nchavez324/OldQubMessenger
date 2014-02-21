//
//  RIPConnectionTester.h
//  qub
//
//  Created by Nick on 7/29/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"

@interface RIPConnectionTester : NSObject

+ (NSURLRequest *)requestFromURLString:(NSString *)path relativeToBaseURL:(NSURL *)baseURL withPrivateAPIKeyHash:(NSString *)privateAPIKeyHash passwordHash:(NSString *)passwordHash method:(NSString *)method;

@end
