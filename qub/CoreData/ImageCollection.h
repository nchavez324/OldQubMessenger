//
//  ImageCollection.h
//  qub
//
//  Created by Nick on 8/15/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DataCompletion.h"
#import "RIPErrorCodes.h"

extern NSInteger const kQualityNone;
extern NSInteger const kQualityThumb;
extern NSInteger const kQualityFull;

@class User;

@interface ImageCollection : NSManagedObject

@property (nonatomic, retain) NSData * cover_photo;
@property (nonatomic, retain) NSData * profile_pic_1;
@property (nonatomic, retain) NSData * profile_pic_2;
@property (nonatomic, retain) NSData * profile_pic_3;
@property (nonatomic, retain) NSData * profile_pic_4;
@property (nonatomic, retain) NSData * profile_pic_5;
@property (nonatomic, retain) User *user;

@property (assign, nonatomic) DataCompletion dataCompletion;


+ (UIImage *)noPhoto;
- (void)pullProfilePic:(NSInteger)index WithQuality:(NSInteger)quality completion:(void(^)(NSInteger userID, RIPError errorCode))completion;
- (void)pullAllProfilePicsWithQuality:(NSInteger)quality completion:(void(^)(NSInteger userID, NSInteger indexCompleted, RIPError errorCode))completion;
- (void)setProfilePic:(NSInteger)index image:(UIImage *)image;
- (UIImage *)profilePic:(NSInteger)index;
- (UIImage *)coverPhoto;
- (NSInteger)numPicsFilled;

@end
