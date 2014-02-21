//
//  User.m
//  qub
//
//  Created by Nick on 8/18/13.
//  Copyright (c) 2013 RipStrike. All rights reserved.
//

#import "User.h"
#import "ContactStatus.h"
#import "ImageCollection.h"
#import "DataCompletion.h"

@implementation User

@dynamic age;
@dynamic age_visible;
@dynamic image_collection_id;
@dynamic location;
@dynamic location_visible;
@dynamic name;
@dynamic name_visible;
@dynamic num_profile_pics;
@dynamic password_hash;
@dynamic seeking;
@dynamic seeking_visible;
@dynamic selected_image;
@dynamic sex;
@dynamic sex_visible;
@dynamic user_id;
@dynamic username;
@dynamic username_visible;
@dynamic dataCompletion;
@dynamic contacts;
@dynamic imageCollection;

- (void)fillWithMinJSON:(id)JSON {
	if(JSON != nil){
		[self setUser_id:[NSNumber numberWithInteger:[(NSString *)[JSON objectForKey:@"user_id"] integerValue]]];
		[self setUsername:[JSON objectForKey:@"username"]];
		[self setName:[JSON objectForKey:@"name"]];
		[self setNum_profile_pics:[NSNumber numberWithInteger:[(NSString *)[JSON objectForKey:@"num_profile_pics"] integerValue]]];
		if([JSON objectForKey:@"selected_image"] != [NSNull null])
			[self setSelected_image:[NSNumber numberWithInteger:[(NSString *)[JSON objectForKey:@"selected_image"] integerValue]]];
		if([self.dataCompletion integerValue] < kMin)
			self.dataCompletion = [NSNumber numberWithInteger:kMin];
	}
}

- (void)fillWithJSON:(id)JSON {
	if(JSON != nil){
		NSString *value = @"value";
		NSString *visible = @"visible";
		[self setUsername:[[JSON objectForKey:@"username"] objectForKey:value]];
		[self setName:[[JSON objectForKey:@"name"] objectForKey:value]];
		[self setAge:[NSNumber numberWithInteger:[(NSString *)[[JSON objectForKey:@"age"] objectForKey:value] integerValue]]];
		[self setSex:[[JSON objectForKey:@"sex"] objectForKey:value]];
		[self setSeeking:[[JSON objectForKey:@"seeking"] objectForKey:value]];
		[self setLocation:[[JSON objectForKey:@"location"] objectForKey:value]];
		
		[self setUsername_visible:[NSNumber numberWithBool:[(NSString *)[[JSON objectForKey:@"username"] objectForKey:visible] boolValue]]];
		[self setName_visible:[NSNumber numberWithBool:[(NSString *)[[JSON objectForKey:@"name"] objectForKey:visible] boolValue]]];
		[self setAge_visible:[NSNumber numberWithBool:[(NSString *)[[JSON objectForKey:@"age"] objectForKey:visible] boolValue]]];
		[self setSex_visible:[NSNumber numberWithBool:[(NSString *)[[JSON objectForKey:@"sex"] objectForKey:visible] boolValue]]];
		[self setSeeking_visible:[NSNumber numberWithBool:[(NSString *)[[JSON objectForKey:@"seeking"] objectForKey:visible] boolValue]]];
		[self setLocation_visible:[NSNumber numberWithBool:[(NSString *)[[JSON objectForKey:@"location"] objectForKey:visible] boolValue]]];
		
		[self setUser_id:[NSNumber numberWithInteger:[(NSString *)[JSON objectForKey:@"user_id"] integerValue]]];
		if([JSON objectForKey:@"selected_image"] != [NSNull null])
			[self setSelected_image:[NSNumber numberWithInteger:[(NSString *)[JSON objectForKey:@"selected_image"] integerValue]]];
		if([JSON objectForKey:@"image_collection_id"] != [NSNull null])
			[self setImage_collection_id:[NSNumber numberWithInteger:[(NSString *)[JSON objectForKey:@"image_collection_id"] integerValue]]];
		[self setNum_profile_pics:[NSNumber numberWithInteger:[(NSString *)[JSON objectForKey:@"num_profile_pics"] integerValue]]];
        self.dataCompletion = [NSNumber numberWithInteger:kFull];
    }
}

- (ContactStatus *)hasContact:(ContactStatus *)contactStatus{
	ContactStatus *ans = nil;
	for (ContactStatus *cs in self.contacts) {
		if([cs.user_id isEqualToNumber:contactStatus.user_id]){
			ans = cs;
			break;
		}
	}
	return ans;
}

- (BOOL)isContact:(User *)user{
	/*NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ContactStatus"];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(owner.user_id=%d AND user_id=%d) OR (owner.user_id=%d AND user_id=%d)", self.user_id.integerValue, user.user_id.integerValue, user.user_id.integerValue, self.user_id.integerValue]];
	
	[fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user_id" ascending:YES]]];
	NSError *error = nil;
	NSArray *arr = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if(error != nil){
		NSLog(@"Error: %@ Code %d", error.localizedDescription, error.code);
	}
	if(arr.count > 0)
		return [((ContactStatus *)arr[0]).status isEqual:@"CONF"];
	return false;*/
	for (ContactStatus *cs in self.contacts)
		if(cs.user_id.integerValue == user.user_id.integerValue)
			return YES;
	return NO;
}

- (BOOL)isContactWithID:(NSInteger)contactID {
	for (ContactStatus *cs in self.contacts)
		if(cs.user_id.integerValue == contactID)
			return YES;
	return NO;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"{ID:%d UN:%@, NM:%@, AG:%d, SX:%@, SK:%@, LC:%@}", [self.user_id integerValue], self.username, self.name, [self.age integerValue], self.sex, self.seeking, self.location];
}

+ (NSArray *)propertyList{
	return @[@"name",@"age",@"sex",@"seeking",@"location"];
}

@end
