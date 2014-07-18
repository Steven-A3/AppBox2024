//
//  TranslatorHistory(manager)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/28/14 6:08 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "TranslatorHistory+manager.h"
#import "TranslatorFavorite.h"
#import "NSString+conversion.h"


@implementation TranslatorHistory (manager)

- (TranslatorFavorite *)favorite {
	return [TranslatorFavorite MR_findFirstByAttribute:@"historyID" withValue:self.uniqueID];
}

- (void)setAsFavoriteMember:(BOOL)isFavorite {
	TranslatorFavorite *favorite = [self favorite];
	if (favorite && isFavorite) return;
	if (!favorite && !isFavorite) return;

	if (isFavorite) {
		// Add Favorite
		favorite = [TranslatorFavorite MR_createInContext:self.managedObjectContext];
		favorite.uniqueID = [[NSUUID UUID] UUIDString];
		favorite.updateDate = [NSDate date];
		favorite.historyID = self.uniqueID;
		favorite.groupID = self.groupID;

		NSString *largest = [TranslatorFavorite MR_findLargestValueForAttribute:@"order" inContext:self.managedObjectContext];
		NSString *nextLargest = [NSString orderStringWithOrder:[largest integerValue] + 1000000];
		favorite.order = nextLargest;
	} else {
		[self.favorite MR_deleteInContext:self.managedObjectContext];
	}

	[[self managedObjectContext] MR_saveToPersistentStoreAndWait];
}

@end
