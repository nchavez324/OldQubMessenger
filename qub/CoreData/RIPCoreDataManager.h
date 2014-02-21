//
//  RIPContextManager.h
//  qub
//
//  Created by Nick on 1/10/14.
//  Copyright (c) 2014 RipStrike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIPErrorCodes.h"

@class User;
@class ContactStatus;
@class ImageCollection;
@class Message;

@interface RIPCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (assign, nonatomic) NSInteger currentUserID;

- (RIPCoreDataManager *)init;
+ (RIPCoreDataManager *)shared;

/* USER METHODS */
- (User *)currentUserInContext:(NSManagedObjectContext *)context;
- (User *)userWithId:(NSInteger)userID inContext:(NSManagedObjectContext *)context;
- (User *)addUserWithJSON:JSON isMin:(BOOL)isMin inContext:(NSManagedObjectContext *)context;
- (void)pullUser:(NSInteger)userID completion:(void(^)(NSManagedObjectID *userObjID, RIPError errorCode))completion;

/* CONTACTSTATUS METHODS */
- (ContactStatus *)contactStatusWithUser:(User *)contact inContext:(NSManagedObjectContext *)context;
- (ContactStatus *)addContactStatusWithUser:(User *)contact status:(NSString *)status inContext:(NSManagedObjectContext *)context;
- (void)updateContacts:(void(^)(NSSet *newContacts, NSSet *toDelete, RIPError errorCode))completion;

/* IMAGECOLLECTION METHODS */
- (ImageCollection *)imageCollection:(User *)owner inContext:(NSManagedObjectContext *)context;
- (ImageCollection *)addImageCollection:(User *)owner inContext:(NSManagedObjectContext *)context;

/* MESSAGES METHODS */
- (NSMutableArray *)addMessagesWithJSON:(id)JSON inContext:(NSManagedObjectContext *)context;
- (NSArray *)messagesBetween:(NSInteger)firstUserID and:(NSInteger)secondUserID count:(NSInteger)count offset:(NSInteger)offset inContext:(NSManagedObjectContext *)context;
- (Message *)messageFromID:(NSInteger)fromUserID toID:(NSInteger)toUserID at:(float)timestamp inContext:(NSManagedObjectContext *)context;
- (void)updateMessages:(void(^)(BOOL completeOnEmpty, RIPError errorCode))completion;

/* MISC */
+ (void)updateDataInBackgroundWithContext:(void(^)(NSManagedObjectContext *context))block completion:(void(^)())completion;
- (NSError *)saveContext:(NSManagedObjectContext *)context;
- (NSURL *)applicationDocumentsDirectory;
- (void)loadDataFile;
- (void)saveDataFile;
- (void)terminate;
@end
