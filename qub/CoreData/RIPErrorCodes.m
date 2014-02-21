//
//  RIPErrorCodes.m
//  qub
//
//  Created by Nick on 9/1/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPErrorCodes.h"

@implementation RIPErrorCodes

+ (RIPError)errorCodeWithError:(NSError *)error httpStatusCode:(NSInteger)httpCode request:(NSURLRequest *)request {
	//NSLog(@"Error: %@ Code %d", [error localizedDescription], error.code);
    RIPError err = RIPErrorUnknown;
	if(httpCode > 0){
		switch (httpCode) {
			case 400:
				err = RIPErrorBadRequest;
				break;
			case 401:
				err = RIPErrorUnauthorized;
				break;
			case 404:
				err = RIPErrorNotFound;
				break;
			case 500:
				err = RIPErrorServer;
				break;
			default:
				break;
		}
	}
	switch (error.code) {
		case -1001:
			err = RIPErrorTimeout;
			break;
		case -1009:
			err = RIPErrorUnavailable;
			break;
		default:
			break;
	}
	if(err == RIPErrorUnknown)
        NSLog(@"Unknown error: %@, code %d (http %d) <%@>", [error localizedDescription], [error code], httpCode, (request == nil)?@"NONE":request.URL);
	return err;
}

+ (BOOL)shouldHideData:(RIPError)errorCode {
	return NO;
    //return (errorCode == RIPErrorBadRequest || errorCode == RIPErrorContext || errorCode == RIPErrorUnknown || errorCode == RIPErrorUnauthorized || errorCode == RIPErrorNotFound);
}

@end
