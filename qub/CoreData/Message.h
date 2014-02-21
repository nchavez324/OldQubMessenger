//
//  Message.h
//  qub
//
//  Created by Nick on 8/25/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ImageCollection.h"
#import "RIPErrorCodes.h"

@class User;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * dataCompletion;
@property (nonatomic, retain) NSNumber * fromUserID;
@property (nonatomic, retain) NSNumber * hasImageContent;
@property (nonatomic, retain) NSData * imageContent;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * toUserID;

- (void)fillWithJSON:(id)JSON;
- (void)pullImageWithQuality:(NSInteger)quality completion:(void(^)(RIPError errorCode))completion;

@end
