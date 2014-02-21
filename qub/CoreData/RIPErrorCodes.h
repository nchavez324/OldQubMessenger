//
//  RIPErrorCodes.h
//  qub
//
//  Created by Nick on 9/1/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSURLRequest;

@interface RIPErrorCodes : NSObject

typedef enum RIPErrorTag {
    RIPErrorUnknown = 0,
    RIPErrorNone,
    RIPErrorTimeout,
    RIPErrorBadRequest,
    RIPErrorUnauthorized,
    RIPErrorNotFound,
    RIPErrorServer,
    RIPErrorUnavailable,
    RIPErrorContext
} RIPError;

+ (RIPError)errorCodeWithError:(NSError *)error httpStatusCode:(NSInteger)httpCode request:(NSURLRequest *)request;
+ (BOOL)shouldHideData:(RIPError)errorCode;
@end
