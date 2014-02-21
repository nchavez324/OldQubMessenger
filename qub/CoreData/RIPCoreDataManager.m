//
//  RIPContextManager.m
//  qub
//
//  Created by Nick on 1/10/14.
//  Copyright (c) 2014 RipStrike. All rights reserved.
//

#import "RIPCoreDataManager.h"
#import "User.h"
#import "ContactStatus.h"
#import "Message.h"
#import "ImageCollection.h"
#import "RIPAPIRequest.h"
#import "RIPAppDelegate.h"
#import "AFHTTPRequestOperation.h"
#import "RIPErrorCodes.h"

static NSString *kLastReceivedMsgTimeKey = @"lastReceivedMsgTime";
static NSString *kLastSentMsgTimeKey     = @"lastSentMsgTime";

@interface RIPCoreDataManager ()
@property (strong, nonatomic) NSMutableDictionary *dataFile;
@property (assign, nonatomic) dispatch_queue_t backgroundQueue;
@property (strong, nonatomic) NSManagedObjectContext *childContext;
@end

@implementation RIPCoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (RIPCoreDataManager *)init {
    if(self = [super init]){
    }
    return self;
}

+ (RIPCoreDataManager *)shared {
    return [RIPAppDelegate sharedAppDelegate].contextManager;
}

- (void)loadDataFile {
    NSString *path = [self dataFilePath];
	if([[NSFileManager defaultManager] fileExistsAtPath:path]){
		_dataFile = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	}else{
		_dataFile = [[NSMutableDictionary alloc] init];
		_dataFile[kLastReceivedMsgTimeKey] = [NSNumber numberWithFloat:-1];
		_dataFile[kLastSentMsgTimeKey] = [NSNumber numberWithFloat:-1];
	}
}

- (void)saveDataFile {
    [_dataFile writeToFile:[self dataFilePath] atomically:YES];
}

- (void)terminate {
    if(_childContext != nil)
		[self saveContext:_childContext];
	[self saveContext:self.managedObjectContext];
    [self saveDataFile];
}

- (NSError *)saveContext:(NSManagedObjectContext *)context
{
	NSError *error = nil;
	if (context != nil) {
		if ([context hasChanges] && ![context save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			return error;
		}
	}
	return nil;
}

- (User *)currentUserInContext:(NSManagedObjectContext *)context{
	return [self userWithId:self.currentUserID inContext:context];
}

- (User *)addUserWithJSON:JSON isMin:(BOOL)isMin inContext:(NSManagedObjectContext *)context{
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
	User *user = nil;
	user = [self userWithId:[(NSString *)[JSON objectForKey:@"user_id"] integerValue] inContext:context];
	if(user == nil)
		user = (User *)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
	
	if(isMin)
		[user fillWithMinJSON:JSON];
	else
		[user fillWithJSON:JSON];
	NSError *error = [self saveContext:context];
	if(error != nil){
		return nil;
	}
	return user;
}

- (User *)userWithId:(NSInteger)userID inContext:(NSManagedObjectContext *)context{
	if(userID <= 0)
		return nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %d", userID];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *arr = [context executeFetchRequest:fetchRequest error:&error];
	if(error){
		NSLog(@"Context Error: %@", [error localizedDescription]);
	}
	if(arr != nil && arr.count > 0)
		return arr[0];
	return nil;
}

- (void)pullUser:(NSInteger)userID completion:(void(^)(NSManagedObjectID *userObjID, RIPError errorCode))completion{
	//make sure on main queue
	__block NSString *username = [self currentUserInContext:self.managedObjectContext].username;
	__block NSString *passwordHash = [self currentUserInContext:self.managedObjectContext].password_hash;
	AFHTTPRequestOperation *pRequest;
    pRequest = [RIPAPIRequest JSONRequestFromURLString:[NSString stringWithFormat:@"profiles/%d", userID] relativeToBaseURL:[RIPAPIRequest baseApiURL] withParameters:nil username:username passwordHash:passwordHash method:@"GET" success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__block NSManagedObjectID *o;
		__block RIPError errorCode = RIPErrorNone;
		[RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
			User *u = [self addUserWithJSON:responseObject isMin:NO inContext:context];
			if(u == nil)
				errorCode = RIPErrorContext;
            o = u.objectID;
			NSError *error = [self saveContext:context];
			if(error != nil) errorCode = [RIPErrorCodes errorCodeWithError:error httpStatusCode:0 request:pRequest.request];
		} completion:^{
			completion(o, errorCode);
		}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, [RIPErrorCodes errorCodeWithError:error httpStatusCode:operation.response.statusCode request:operation.request]);
    }];
    [pRequest start];
}

- (ContactStatus *)addContactStatusWithUser:(User *)contact status:(NSString *)status inContext:(NSManagedObjectContext *)context {
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ContactStatus" inManagedObjectContext:context];
	ContactStatus *contactStatus = nil;
	contactStatus = [self contactStatusWithUser:contact inContext:context];
	if(contactStatus == nil)
		contactStatus = (ContactStatus *)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
	[contactStatus fillWithUser:contact status:status];
    
	NSError *error = [self saveContext:context];
	if(error != nil)
		return nil;
	return contactStatus;
}

- (ContactStatus *)contactStatusWithUser:(User *)contact inContext:(NSManagedObjectContext *)context{
	if(contact == nil)
		return nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ContactStatus"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id == %d", [contact.user_id integerValue]];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *arr = [context executeFetchRequest:fetchRequest error:&error];
	if(error){
		NSLog(@"Context Error: %@", [error localizedDescription]);
	}
	if(arr != nil && arr.count > 0)
		return arr[0];
	return nil;
}

- (ImageCollection *)addImageCollection:(User *)owner inContext:(NSManagedObjectContext *)context {
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageCollection" inManagedObjectContext:context];
	ImageCollection *imageCollection = nil;
	imageCollection = [self imageCollection:owner inContext:(NSManagedObjectContext *)context];
	if(imageCollection == nil)
		imageCollection = (ImageCollection *)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
	
	NSError *error = [self saveContext:context];
	if(error != nil)
		return nil;
	return imageCollection;
}

- (ImageCollection *)imageCollection:(User *)owner inContext:(NSManagedObjectContext *)context {
	if(owner == nil)
		return nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ImageCollection"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.user_id == %d", [owner.user_id integerValue]];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *arr = [context executeFetchRequest:fetchRequest error:&error];
	if(error){
		NSLog(@"Context Error: %@", [error localizedDescription]);
		return nil;
	}
	if(arr != nil && arr.count > 0)
		return arr[0];
	return nil;
}

- (NSArray *)messagesBetween:(NSInteger)firstUserID and:(NSInteger)secondUserID count:(NSInteger)count offset:(NSInteger)offset inContext:(NSManagedObjectContext *)context {
	if(firstUserID <= 0 || secondUserID <= 0 || count < 0)
		return nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fromUserID == %d AND toUserID == %d) OR (fromUserID == %d AND toUserID == %d)", firstUserID, secondUserID, secondUserID, firstUserID];
	NSSortDescriptor *sortDescriptor  = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setSortDescriptors:@[sortDescriptor]];
	[fetchRequest setFetchBatchSize:50];
	if(count > 0)
		[fetchRequest setFetchLimit:count];
    if(offset >= 0)
        [fetchRequest setFetchOffset:offset];
	NSError *error = nil;
	NSArray *arr = [context executeFetchRequest:fetchRequest error:&error];
	if(error){
		NSLog(@"Context Error: %@", [error localizedDescription]);
		return nil;
	}
	return arr;
}

- (Message *)messageFromID:(NSInteger)fromUserID toID:(NSInteger)toUserID at:(float)timestamp inContext:(NSManagedObjectContext *)context {
	if(fromUserID <= 0 || toUserID <= 0 || fromUserID == toUserID || timestamp <= 0)
		return nil;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"fromUserID == %d AND toUserID == %d AND timestamp == %f",fromUserID,toUserID,timestamp];
	[fetchRequest setPredicate:pred];
	NSError *error = nil;
	NSArray *arr = [context executeFetchRequest:fetchRequest error:&error];
	if(error){
		NSLog(@"Context Error: %@", [error localizedDescription]);
		return nil;
	}
	if(arr != nil && arr.count > 0)
		return arr[0];
	return nil;
}

- (NSMutableArray *)addMessagesWithJSON:(id)JSON inContext:(NSManagedObjectContext *)context {
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:context];
	NSMutableArray *messages = [[NSMutableArray alloc] init];
	NSMutableArray *newMessages = [[NSMutableArray alloc] init];
	NSMutableArray *oldMessages = [[NSMutableArray alloc] init];
	for (id msgJSON in JSON) {
		NSInteger fromUserID = 0, toUserID = 0;
		float timestamp = 0;
		fromUserID = [(NSString *)[msgJSON objectForKey:@"from_user_id"] integerValue];
		toUserID = [(NSString *)[msgJSON objectForKey:@"to_user_id"] integerValue];
		timestamp = [(NSString *)[msgJSON objectForKey:@"timestamp"] floatValue];
		Message *m = [self messageFromID:fromUserID toID:toUserID at:timestamp inContext:context];
		BOOL new = NO;
		if(m == nil){
			m = (Message *)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
			[newMessages addObject:m];
			new = YES;
		}else
			[oldMessages addObject:m];
		[m fillWithJSON:msgJSON];
		if(new){
			float ts = m.timestamp.floatValue;
			NSString *key = m.fromUserID.integerValue==self.currentUserID?kLastSentMsgTimeKey:kLastReceivedMsgTimeKey;
			float oldTimestamp = [[_dataFile objectForKey:key] floatValue];
			if(ts > oldTimestamp){
				_dataFile[key] = [NSNumber numberWithFloat:ts];
			}
		}
	}
	[messages addObject:newMessages];
	[messages addObject:oldMessages];
	
	[_dataFile writeToFile:[self dataFilePath] atomically:YES];
	return messages;
}

- (NSString *)dataFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDir = paths[0];
	return [documentDir stringByAppendingPathComponent:@"data.plist"];
}

- (void)updateMessages:(void(^)(BOOL completeOnEmpty, RIPError errorCode))completion {
	/*
	 Explanations are in order:
	 The app will save a timestamp in defaults or other storage
	 Its requests for messages will have this timestamp as a parameter
	 The Server will only return messages after this timestamp
	 This timestamp is the time at which it made the last request.
	 With regards to other devices, when someone logs in for the
	 first time, it will download everything, since there is no timestamp.
	 Will do this with plist persistence
	 */
	//on main queue
	float lastReceivedMsgTime = [[_dataFile objectForKey:kLastReceivedMsgTimeKey] floatValue];
	float lastSentMsgTime = [[_dataFile objectForKey:kLastSentMsgTimeKey] floatValue];
	NSMutableArray *parameters = [[NSMutableArray alloc] init];
	if(lastReceivedMsgTime > 0)
		[parameters addObjectsFromArray:@[@"last_received_time", [NSString stringWithFormat:@"%f",lastReceivedMsgTime]]];
	if(lastSentMsgTime > 0)
		[parameters addObjectsFromArray:@[@"last_sent_time", [NSString stringWithFormat:@"%f",lastSentMsgTime]]];
	NSString *username = [self currentUserInContext:self.managedObjectContext].username;
	NSString *passwordHash = [self currentUserInContext:self.managedObjectContext].password_hash;
	AFHTTPRequestOperation *msgUpdate;
    msgUpdate = [RIPAPIRequest JSONRequestFromURLString:[NSString stringWithFormat:@"profiles/%d/messages", self.currentUserID] relativeToBaseURL:[RIPAPIRequest baseApiURL] withParameters:parameters username:username passwordHash:passwordHash method:@"GET" success:^(AFHTTPRequestOperation *operation, id responseObject) {
		//add these messages no duplicates!
		__block RIPError errorCode = RIPErrorNone;
		[RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
			[self addMessagesWithJSON:responseObject inContext:context];
			NSError *error = [self saveContext:context];
			if(error != nil)
				errorCode = [RIPErrorCodes errorCodeWithError:error httpStatusCode:0 request:msgUpdate.request];
		} completion:^{
			//main queue
			completion(YES, errorCode);
		}];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(YES, [RIPErrorCodes errorCodeWithError:error httpStatusCode:operation.response.statusCode request:operation.request]);
	}];
	[msgUpdate start];
}

- (void)updateContacts:(void(^)(NSSet *newContacts, NSSet *toDelete, RIPError errorCode))completion{
	//main queue
	NSString *username = [self currentUserInContext:self.managedObjectContext].username;
	NSString *passwordHash = [self currentUserInContext:self.managedObjectContext].password_hash;
	NSManagedObjectID *userObjID = [self currentUserInContext:self.managedObjectContext].objectID;
	AFHTTPRequestOperation *contactsRequest = [RIPAPIRequest JSONRequestFromURLString:[NSString stringWithFormat:@"profiles/%d/contacts", self.currentUserID] relativeToBaseURL:[RIPAPIRequest baseApiURL] withParameters:nil username:username passwordHash:passwordHash method:@"GET" success:^(AFHTTPRequestOperation *operation, id responseObject) {
		__block NSMutableSet *toDelete = [[NSMutableSet alloc] init];
		__block NSMutableArray *newContacts = [[NSMutableArray alloc] init];
		__block RIPError errorCode = RIPErrorNone;
		[RIPCoreDataManager updateDataInBackgroundWithContext:^(NSManagedObjectContext *context) {
			User *myUser = (User *)[context objectWithID:userObjID];
			NSSet *oldContacts = myUser.contacts;
			for(id contactObj in responseObject){
				User *contact = [[RIPCoreDataManager shared] addUserWithJSON:contactObj isMin:YES inContext:context];
				if(contact == nil){
					//SWERVE
					errorCode = RIPErrorContext;
					return;
				}
				if([contact.selected_image integerValue] != 0){
					ImageCollection *imageCollection = [[RIPCoreDataManager shared] addImageCollection:contact inContext:context];
					if(imageCollection != nil){
						imageCollection.user = contact;
						contact.imageCollection = imageCollection;
					}
				}
				ContactStatus *contactStatus = [[RIPCoreDataManager shared] addContactStatusWithUser:contact status:@"CONF" inContext:context];
				//contactStatus.owner = self.currentUser;
				[newContacts addObject:contactStatus.objectID];
			}
			for (__block ContactStatus *contactStatus in oldContacts) {
				NSUInteger index = [newContacts indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
					NSManagedObjectID *moid = obj;
					if([moid isEqual:contactStatus.objectID]){
						*stop = YES;
						return YES;
					}
					return NO;
				}];
				if(index == NSNotFound){
					[toDelete addObject:contactStatus.objectID];
				}else{
					[newContacts removeObjectAtIndex:index];
					//dont worry! already saved/updated in context!
				}
			}
			//newContacts only contains new contacts, toDelete is complete as well
			NSError *error = [self saveContext:context];
			if(error != nil)
				errorCode = [RIPErrorCodes errorCodeWithError:error httpStatusCode:0 request:nil];
			//[self.currentUser addContacts:newContactsSet];
			//[self.currentUser removeContacts:toDelete];
		} completion:^{
			[self saveContext:self.managedObjectContext];
			completion([NSSet setWithArray:newContacts], toDelete, errorCode);
		}];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(nil, nil, [RIPErrorCodes errorCodeWithError:error httpStatusCode:operation.response.statusCode request:operation.request]);
	}];
	[contactsRequest start];
}

+ (void)updateInContext:(void(^)(NSManagedObjectContext *context))block {
	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
	[context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
	//register here for changes! -- prolly not neccessary since refetching.
	NSManagedObjectContext *mainContext = [RIPCoreDataManager shared].managedObjectContext;
	[mainContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
	[context setParentContext:mainContext];
	[[RIPCoreDataManager shared] setChildContext:context];
	block(context);
	[[RIPCoreDataManager shared] setChildContext:nil];
	[[RIPCoreDataManager shared] saveContext:context];
}

+ (void)updateDataInBackgroundWithContext:(void(^)(NSManagedObjectContext *context))block completion:(void(^)())completion {
	RIPCoreDataManager *m = [RIPCoreDataManager shared];
	dispatch_queue_t q = m.backgroundQueue;
	if(q == NULL)
		q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(q, ^{
		[RIPCoreDataManager updateInContext:block];
		[m saveContext:m.managedObjectContext];
        if(completion != nil)
            completion();
	});
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
		
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"qub" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"qub.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
