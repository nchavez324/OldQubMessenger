//
//  User.h
//  qub
//
//  Created by Nick on 8/18/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContactStatus, ImageCollection;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * age_visible;
@property (nonatomic, retain) NSNumber * image_collection_id;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * location_visible;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * name_visible;
@property (nonatomic, retain) NSNumber * num_profile_pics;
@property (nonatomic, retain) NSString * password_hash;
@property (nonatomic, retain) NSString * seeking;
@property (nonatomic, retain) NSNumber * seeking_visible;
@property (nonatomic, retain) NSNumber * selected_image;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSNumber * sex_visible;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * username_visible;
@property (nonatomic, retain) NSNumber * dataCompletion;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) ImageCollection *imageCollection;

- (void)fillWithJSON:(id)JSON;
- (void)fillWithMinJSON:(id)JSON;
- (ContactStatus *)hasContact:(ContactStatus *)contactStatus;
- (BOOL)isContact:(User *)user;
- (BOOL)isContactWithID:(NSInteger)contactID;
+ (NSArray *)propertyList;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addContactsObject:(ContactStatus *)value;
- (void)removeContactsObject:(ContactStatus *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

@end
