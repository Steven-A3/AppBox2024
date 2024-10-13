//
//  TranslatorHistory(manager)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/28/14 6:08 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "TranslatorHistory+manager.h"
#import "A3AppDelegate.h"
#import <AppBoxKit/AppBoxKit.h>

@implementation TranslatorHistory_ (manager)

- (TranslatorFavorite_ *)favorite {
	return [TranslatorFavorite_ findFirstByAttribute:@"historyID" withValue:self.uniqueID];
}

- (void)setAsFavoriteMember:(BOOL)isFavorite {
	TranslatorFavorite_ *favorite = [self favorite];
	if (favorite && isFavorite) return;
	if (!favorite && !isFavorite) return;

    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
	if (isFavorite) {
		// Add Favorite
        favorite = [[TranslatorFavorite_ alloc] initWithContext:context];
		favorite.uniqueID = [[NSUUID UUID] UUIDString];
		favorite.updateDate = [NSDate date];
		favorite.historyID = self.uniqueID;
		favorite.groupID = self.groupID;

		TranslatorFavorite_ *lastFavorite = [TranslatorFavorite_ findFirstOrderedByAttribute:@"order" ascending:NO];
		NSString *largest = lastFavorite.order;
		NSString *nextLargest = [NSString orderStringWithOrder:[largest integerValue] + 1000000];
		favorite.order = nextLargest;
	} else {
        [context deleteObject:self.favorite];
	}

    [context saveIfNeeded];
}

@end
