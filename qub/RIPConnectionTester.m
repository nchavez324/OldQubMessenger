//
//  RIPConnectionTester.m
//  qub
//
//  Created by Nick on 7/29/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPConnectionTester.h"

#import "AFJSONRequestOperation.h"

#import "JFBCrypt.h"

static NSString *_blowfishSalt = @"$2y$07$zbST1Hc51Vu1DBnoeraUYS";
static NSString *_blowfishSaltDeprecated = @"$2a$07$zbST1Hc51Vu1DBnoeraUYS";
static NSString *_privateApiKeyHash = @"O7YzNa5WvByep8qrFcIC.aYBiuZ20KWO";

@implementation RIPConnectionTester

+ (NSString *)encryptString:(NSString *)string{
	NSString *hash = [JFBCrypt hashPassword:string withSalt:_blowfishSaltDeprecated];
	hash = [hash stringByReplacingCharactersInRange:NSMakeRange(0, _blowfishSaltDeprecated.length-1) withString:@""];
	return hash;
}

+ (NSString *)encryptArray:(NSArray *)array {
	return [RIPConnectionTester encryptString:[RIPConnectionTester collapseArray:array]];
}

+ (NSString *)collapseArray:(NSArray *)array {
	NSString *ans = @"";
	for(int i = 0; i < [array count]; i++){
		if(i % 2 == 0)
			ans = [NSString stringWithFormat:@"%@%@:", ans, array[i]];
		else
			ans = [NSString stringWithFormat:@"%@%@,", ans, array[i]];
	}
	return ans;
}

+ (NSURLRequest *)requestFromURLString:(NSString *)path relativeToBaseURL:(NSURL *)baseURL withPrivateAPIKeyHash:(NSString *)privateAPIKeyHash passwordHash:(NSString *)passwordHash method:(NSString *)method {
	NSURL *url = [NSURL URLWithString:path relativeToURL:baseURL];
	NSMutableURLRequest *request = [NSURLRequest requestWithURL:url];
	NSString *hash = [RIPConnectionTester encryptArray:[RIPConnectionTester arraySignatureFromURL:request privateKeyHash:privateAPIKeyHash passwordHash:passwordHash]];
	path = [NSString stringWithFormat:@"%@&hash=%@", path, hash];
	url = [NSURL URLWithString:path relativeToURL:baseURL];
	request = [NSURLRequest requestWithURL:url];
	return request;
}

+ (void)loadImageWithSuccess:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure {
	
	NSURLRequest *image1Request = [RIPConnectionTester
								   requestFromURLString:@"profiles/1/images/1?username=nick95xD&public_api_key=primary_app&timestamp=1374859875"
								   relativeToBaseURL:[NSURL URLWithString:@"https://10.0.2.2/qub_messenger/api/"]
								   withPrivateAPIKeyHash:_privateApiKeyHash
								   passwordHash:@"O/itZY/SdkeL1F/I0IuK9DO1Op1f3jza" method:@"GET"];
	
	AFHTTPRequestOperation *httpOp = [[AFHTTPRequestOperation alloc] initWithRequest:image1Request];
	[httpOp setCompletionBlockWithSuccess:success failure:failure];
	httpOp.allowsInvalidSSLCertificate = YES;
	
	NSSet *mimeTypes = [NSSet setWithArray:@[@"image/png"]];
	[AFHTTPRequestOperation addAcceptableContentTypes:mimeTypes];
	NSLog(@"Requested at: %@",[NSDate date]);
	[httpOp start];
}

+ (void)loadJSONWithSuccess:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure {
	
	
	NSURLRequest *messagesRequest = [RIPConnectionTester
								   requestFromURLString:@"profiles/1/messages/3?max_count=2&start_at=2&username=nick95xD&public_api_key=primary_app&timestamp=1374859875"
								   relativeToBaseURL:[NSURL URLWithString:@"https://10.0.2.2/qub_messenger/api/"]
								   withPrivateAPIKeyHash:_privateApiKeyHash
									 passwordHash:@"O/itZY/SdkeL1F/I0IuK9DO1Op1f3jza" method:@"GET"];
	AFJSONRequestOperation *jsonOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:messagesRequest success:success failure:failure];
	//Only on localhost!!!
	jsonOp.allowsInvalidSSLCertificate = YES;
	[jsonOp start];
}

+ (NSArray *)arraySignatureFromURL:(NSURLRequest *)urlRequest privateKeyHash:(NSString *)privateKeyHash passwordHash:(NSString *)passwordHash{
	NSMutableArray *ans = [NSMutableArray arrayWithArray:@[@"HTTP_method"]];
	[ans addObject:[urlRequest HTTPMethod]];
	NSURL *url = [urlRequest URL];
	
	NSArray *parameters = [[url query]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
	ans = [NSMutableArray arrayWithArray:[ans arrayByAddingObjectsFromArray:parameters]];
	
	NSArray *pathComponents = [url pathComponents];
	NSInteger i = [pathComponents indexOfObject:@"api"]+1;
	
	for(NSInteger j = 0; j+i <[pathComponents count]; j++){
		[ans addObject:[NSString stringWithFormat:@"%d", j]];
		[ans addObject:pathComponents[j+i]];
	}
	
	[ans addObject:@"private_key_hash"];
	[ans addObject:privateKeyHash];
	[ans addObject:@"password_hash"];
	[ans addObject:passwordHash];
	
	return ans;
}

@end
