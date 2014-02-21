//
//  RIPConnectionTester.m
//  qub
//
//  Created by Nick on 7/29/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "RIPAPIRequest.h"
#import "AFHTTPRequestOperation.h"
#import "JFBCrypt.h"

static BOOL      _useLocal               = YES;
static NSString *_publicApiKey           = @"primary_app";
static NSString *_privateApiKeyHash      = @"O3tuZVKRhalS/yJbkbiyg/VakAOaI1ri";
static NSString *_blowfishSaltDeprecated = @"$2a$07$zbST1Hc51Vu1DBnoeraUYS";
static NSInteger _kStringSplitFactor     = 50;
static NSString *_timestamp              = @"";
static NSURL *baseApiURL;

@implementation RIPAPIRequest

+ (NSURL *)baseApiURL {
	if(baseApiURL == nil){
        if(TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR)
            _useLocal = NO;
        NSString *path = _useLocal?
            @"http://192.168.58.1/qub_messenger/api/":
            @"http://www.qubmessenger.com/api/";
        baseApiURL = [NSURL URLWithString:path];
    }
	return baseApiURL;
}

+ (NSString *)encryptString:(NSString *)string{
	NSMutableArray *hashed = [NSMutableArray array];
	NSMutableArray *preHash = [NSMutableArray array];
	NSInteger i = 0;
	while ([string length] > 0) {
		preHash[i] = [string substringToIndex:(string.length >= _kStringSplitFactor)?_kStringSplitFactor:string.length];
		NSString *encPiece = [JFBCrypt hashPassword:preHash[i] withSalt:_blowfishSaltDeprecated];
		hashed[i] = [encPiece substringFromIndex:_blowfishSaltDeprecated.length-1];
		string = (string.length > _kStringSplitFactor)?[string substringFromIndex:_kStringSplitFactor]:@"";
		i++;
	}
	//NSLog(@"%@", preHash);
	return [hashed componentsJoinedByString:@""];
}

+ (NSString *)encryptArray:(NSArray *)array {
	NSString *c = [RIPAPIRequest collapseArray:array];
    //NSLog(@"%@", array);
    //NSLog(@"%@",c);
    return [RIPAPIRequest encryptString:c];
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

+ (NSArray *)arraySignatureFromURL:(NSURLRequest *)urlRequest withParameters:(NSArray *)parameters username:(NSString *)username passwordHash:(NSString *)passwordHash{

	//Add HTTP_method key
	NSMutableArray *ans = [NSMutableArray arrayWithArray:@[@"HTTP_method"]];
	[ans addObject:[urlRequest HTTPMethod]];
	NSURL *url = [urlRequest URL];
	
	//timestamp, public_api_key,username, other parameters
	[ans addObject:@"username"];             [ans addObject:username];
	[ans addObject:@"public_api_key"];		 [ans addObject:_publicApiKey];
	_timestamp = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
	
	[ans addObject:@"timestamp"];			 [ans addObject:_timestamp];
	
    //Add parameters
	if(parameters != nil)
		ans = [NSMutableArray arrayWithArray:[ans arrayByAddingObjectsFromArray:parameters]];
    
	//Add url path
	NSArray *pathComponents = [url pathComponents];
	NSInteger i = [pathComponents indexOfObject:@"api"]+1;
	for(NSInteger j = 0; j+i <[pathComponents count]; j++){
		[ans addObject:[NSString stringWithFormat:@"%d", j]];
		[ans addObject:pathComponents[j+i]];
	}

	[ans addObject:@"password_hash"];        [ans addObject:passwordHash];
	[ans addObject:@"private_api_key_hash"]; [ans addObject:_privateApiKeyHash];
	
	return ans;
}

+ (NSURL *)urlFromURLString:(NSString *)path relativeToBaseURL:(NSURL *)baseURL withParameters:(NSArray *)parameters username:(NSString *)username passwordHash:(NSString *)passwordHash method:(NSString *)method{
	
	NSURL *url = [NSURL URLWithString:path relativeToURL:baseURL];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:method];
	
	NSString *hash = [RIPAPIRequest encryptArray:[RIPAPIRequest arraySignatureFromURL:request withParameters:(NSArray *)parameters username:(NSString *)username passwordHash:(NSString *)passwordHash]];
	
	path = [path stringByAppendingString:@"?"];
	if(parameters != nil){
		for (NSInteger i = 0; i < parameters.count; i++)
			if(i % 2 == 0)
				path = [path stringByAppendingFormat:@"%@=", parameters[i]];
			else
				path = [path stringByAppendingFormat:@"%@&", parameters[i]];
	}
	
	path = [path stringByAppendingFormat:@"username=%@&public_api_key=%@&timestamp=%@&hash=%@", username, _publicApiKey, _timestamp, hash];
	
	url = [NSURL URLWithString:path relativeToURL:baseURL];
	return url;
}

+ (NSURLRequest *)requestFromURLString:(NSString *)path relativeToBaseURL:(NSURL *)baseURL withParameters:(NSArray *)parameters username:(NSString *)username passwordHash:(NSString *)passwordHash method:(NSString *)method {
	
	NSURL *url = [NSURL URLWithString:path relativeToURL:baseURL];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSArray *dict = [RIPAPIRequest arraySignatureFromURL:request withParameters:(NSArray *)parameters username:(NSString *)username passwordHash:(NSString *)passwordHash];
    NSString *hash = [RIPAPIRequest encryptArray:dict];

	path = [path stringByAppendingString:@"?"];
	if(parameters != nil){
		for (NSInteger i = 0; i < parameters.count; i++)
			if(i % 2 == 0)
				path = [path stringByAppendingFormat:@"%@=", parameters[i]];
			else
				path = [path stringByAppendingFormat:@"%@&", parameters[i]];
	}

	path = [path stringByAppendingFormat:@"username=%@&public_api_key=%@&timestamp=%@&hash=%@", username, _publicApiKey, _timestamp, hash];

	url = [NSURL URLWithString:path relativeToURL:baseURL];
	request = [NSMutableURLRequest requestWithURL:url];
	[request setTimeoutInterval:4.5];
    //NSLog(@"<%@>", url);
    return request;
}

+ (AFHTTPRequestOperation *)httpRequestFromURLString:(NSString *)path relativeToBaseURL:(NSURL *)baseURL withParameters:(NSArray *)parameters username:(NSString *)username passwordHash:(NSString *)passwordHash method:(NSString *)method success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure{
	NSURLRequest *r = [RIPAPIRequest requestFromURLString:path relativeToBaseURL:baseURL withParameters:parameters username:(NSString *)username passwordHash:passwordHash method:method];
	
	AFHTTPRequestOperation *httpOp = [[AFHTTPRequestOperation alloc] initWithRequest:r];
	[httpOp setCompletionBlockWithSuccess:success failure:failure];
	return httpOp;
}

+ (AFHTTPRequestOperation *)JSONRequestFromURLString:(NSString *)path relativeToBaseURL:(NSURL *)baseURL withParameters:(NSArray *)parameters username:(NSString *)username passwordHash:(NSString *)passwordHash method:(NSString *)method success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure{
	
	NSURLRequest *r = [RIPAPIRequest requestFromURLString:path relativeToBaseURL:baseURL withParameters:parameters username:(NSString *)username passwordHash:passwordHash method:method];
	AFHTTPRequestOperation *jsonOp = [[AFHTTPRequestOperation alloc] initWithRequest:r];
    jsonOp.responseSerializer = [AFJSONResponseSerializer serializer];
    [jsonOp setCompletionBlockWithSuccess:success failure:failure];
	return jsonOp;
}

@end
