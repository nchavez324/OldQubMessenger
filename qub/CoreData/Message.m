//
//  Message.m
//  qub
//
//  Created by Nick on 8/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "Message.h"
#import "DataCompletion.h"
#import "RIPAPIRequest.h"
#import "User.h"
#import "RIPCoreDataManager.h"
#import "AFHTTPRequestOperation.h"
#import "RIPErrorCodes.h"

@implementation Message

@dynamic content;
@dynamic dataCompletion;
@dynamic fromUserID;
@dynamic hasImageContent;
@dynamic imageContent;
@dynamic status;
@dynamic timestamp;
@dynamic toUserID;

- (void)fillWithJSON:(id)JSON {
	self.fromUserID = [NSNumber numberWithInteger:[(NSString *)[JSON objectForKey:@"from_user_id"] integerValue]];
	self.toUserID = [NSNumber numberWithInteger:[(NSString *)[JSON objectForKey:@"to_user_id"] integerValue]];
	self.timestamp = [NSNumber numberWithFloat:[(NSString *)[JSON objectForKey:@"timestamp"] floatValue]];
	if([JSON objectForKey:@"content"]==[NSNull null])
		self.content = @"";
	else
		self.content = (NSString *)[JSON objectForKey:@"content"];
	self.hasImageContent = [NSNumber numberWithBool:(BOOL)[JSON objectForKey:@"has_image"]];
	
	if(self.imageContent == nil){
		if([self.hasImageContent boolValue])
			self.dataCompletion = [NSNumber numberWithInteger:kNone];
		else
			self.dataCompletion = [NSNumber numberWithInteger:kFull];
	}
		
	self.status = (NSString *)[JSON objectForKey:@"status"];
}

- (void)pullImageWithQuality:(NSInteger)quality completion:(void(^)(RIPError errorCode))completion {
	User *user = [[RIPCoreDataManager shared] currentUserInContext:[RIPCoreDataManager shared].managedObjectContext];
	AFHTTPRequestOperation *picRequest = [RIPAPIRequest httpRequestFromURLString:[NSString stringWithFormat:@"profiles/%d/messages/%d/images/%f", self.fromUserID.integerValue, self.toUserID.integerValue, self.timestamp.floatValue] relativeToBaseURL:[RIPAPIRequest baseApiURL] withParameters:@[@"thumb",quality==kQualityThumb?@"YES":@"NO"] username:user.username passwordHash:user.password_hash method:@"GET" success:^(AFHTTPRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if(quality == kQualityThumb)
				self.dataCompletion = [NSNumber numberWithInteger:kMin];
			else if(quality == kQualityFull)
				self.dataCompletion = [NSNumber numberWithInteger:kFull];
			self.imageContent = responseObject;
			completion(RIPErrorNone);
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion([RIPErrorCodes errorCodeWithError:error httpStatusCode:operation.response.statusCode request:operation.request]);
	}];
	[picRequest start];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"[FR:%d, TO:%d, IM:%@, ST:%@, CN:%@, TM:%f]",self.fromUserID.integerValue, self.toUserID.integerValue, self.hasImageContent.boolValue?@"YES":@"NO", self.status, self.content, self.timestamp.floatValue];
}

@end
