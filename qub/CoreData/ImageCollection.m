//
//  ImageCollection.m
//  qub
//
//  Created by Nick on 8/15/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "ImageCollection.h"
#import "User.h"
#import "RIPCoreDataManager.h"
#import "RIPAPIRequest.h"
#import "AFHTTPRequestOperation.h"
#import "RIPErrorCodes.h"

static CGFloat const compressionQuality = 0.8;

NSInteger const kQualityNone  = 0;
NSInteger const kQualityThumb = 1;
NSInteger const kQualityFull  = 2;

@implementation ImageCollection

@dynamic cover_photo;
@dynamic profile_pic_1;
@dynamic profile_pic_2;
@dynamic profile_pic_3;
@dynamic profile_pic_4;
@dynamic profile_pic_5;
@dynamic user;
@synthesize dataCompletion = _dataCompletion;

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self customInit];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self customInit];
}

- (void)customInit{
    _dataCompletion = kNone;
}

- (void)pullProfilePic:(NSInteger)index WithQuality:(NSInteger)quality completion:(void(^)(NSInteger userID, RIPError errorCode))completion {
	//User *currentUser = [[RIPAppDelegate sharedAppDelegate] currentUser];
	NSString *username = [[RIPCoreDataManager shared] currentUserInContext:[RIPCoreDataManager shared].managedObjectContext].username;
	NSString *passwordHash = [[RIPCoreDataManager shared] currentUserInContext:[RIPCoreDataManager shared].managedObjectContext].password_hash;
	AFHTTPRequestOperation *profileRequest = [RIPAPIRequest httpRequestFromURLString:[NSString stringWithFormat:@"profiles/%d/images/%d", [self.user.user_id integerValue], index] relativeToBaseURL:[RIPAPIRequest baseApiURL] withParameters:@[@"thumb", quality==kQualityThumb?@"YES":@"NO"] username:username passwordHash:passwordHash method:@"GET" success:^(AFHTTPRequestOperation *operation, id responseObject) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self setProfilePic:index data:responseObject];
			if(quality == kQualityThumb && index == [self.user.selected_image integerValue])
				if(_dataCompletion < kMin)
					_dataCompletion = kMin;
			[[RIPCoreDataManager shared] saveContext:[RIPCoreDataManager shared].managedObjectContext];
			if(completion != nil)
				completion([self.user.user_id integerValue], RIPErrorNone);
		});
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(0, [RIPErrorCodes errorCodeWithError:error httpStatusCode:operation.response.statusCode request:operation.request]);
        
	}];
	[profileRequest start];
}

- (void)pullAllProfilePicsWithQuality:(NSInteger)quality completion:(void(^)(NSInteger userID, NSInteger indexCompleted, RIPError errorCode))completion {
	__block NSInteger numProfilePics = self.user.num_profile_pics.integerValue;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		for (NSInteger i = 1; i <= numProfilePics; i++) {
			[self pullProfilePic:i WithQuality:quality completion:^(NSInteger userID, RIPError errorCode){
				//starting on main queue
				if(errorCode != RIPErrorNone){
					completion(0, i, errorCode);
				}else{
					if(i == numProfilePics)
						_dataCompletion = kFull;
					if(completion != nil)
						completion(userID, i, RIPErrorNone);
				}
			}];
		}
	});
}

- (void)setProfilePic:(NSInteger)index data:(NSData *)data {
	switch (index){
		case 1:
			self.profile_pic_1 = data;
			break;
		case 2:
			self.profile_pic_2 = data;
			break;
		case 3:
			self.profile_pic_3 = data;
			break;
		case 4:
			self.profile_pic_4 = data;
			break;
		case 5:
			self.profile_pic_5 = data;
			break;
		default:
			break;
	}
}

- (void)setProfilePic:(NSInteger)index image:(UIImage *)image {
	if(image != nil){
		switch (index){
			case 1:
				self.profile_pic_1 = UIImageJPEGRepresentation(image, compressionQuality);
				break;
			case 2:
				self.profile_pic_2 = UIImageJPEGRepresentation(image, compressionQuality);
				break;
			case 3:
				self.profile_pic_3 = UIImageJPEGRepresentation(image, compressionQuality);
				break;
			case 4:
				self.profile_pic_4 = UIImageJPEGRepresentation(image, compressionQuality);
				break;
			case 5:
				self.profile_pic_5 = UIImageJPEGRepresentation(image, compressionQuality);
				break;
			default:
				break;
		}
	}
}

- (UIImage *)profilePic:(NSInteger)index {
	UIImage *ans = nil;
	switch (index){
		case 1:
			if(self.profile_pic_1 != nil)
				ans = [UIImage imageWithData:self.profile_pic_1];
			break;
		case 2:
			if(self.profile_pic_2 != nil)
				ans = [UIImage imageWithData:self.profile_pic_2];
			break;
		case 3:
			if(self.profile_pic_3 != nil)
				ans = [UIImage imageWithData:self.profile_pic_3];
			break;
		case 4:
			if(self.profile_pic_4 != nil)
				ans = [UIImage imageWithData:self.profile_pic_4];
			break;
		case 5:
			if(self.profile_pic_5 != nil)
				ans = [UIImage imageWithData:self.profile_pic_5];
			break;
		default:
			break;
	}
	return ans;
}

- (UIImage *)coverPhoto {
	if(self.cover_photo != nil)
		return [UIImage imageWithData:self.cover_photo];
	return nil;
}

- (NSInteger)numPicsFilled {
	NSInteger ans = 0;
	for (NSInteger i = 1; i <= 5; i++) {
		if([self profilePic:i] != nil)
			ans++;
		else
			break;
	}
	return ans;
}

+ (UIImage *)noPhoto{
	return [UIImage imageNamed:@"noPhoto"];
}

@end
