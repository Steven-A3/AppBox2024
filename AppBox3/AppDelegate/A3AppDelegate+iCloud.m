//
//  A3AppDelegate+iCloud.m
//  AppBox3
//
//  Created by A3 on 12/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+iCloud.h"

@implementation A3AppDelegate (iCloud)

- (void)setupiCloud {
	
}

- (void)startListeniCloudNotification {
	// iCloud notification subscriptions
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	[dc addObserver:self
		   selector:@selector(storesWillChange:)
			   name:NSPersistentStoreCoordinatorStoresWillChangeNotification
			 object:nil];

	[dc addObserver:self
		   selector:@selector(storesDidChange:)
			   name:NSPersistentStoreCoordinatorStoresDidChangeNotification
			 object:nil];

	[dc addObserver:self
		   selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
			   name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
			 object:nil];
}

- (void)stopListeniCloudNotification {
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];

	[dc removeObserver:self name:NSPersistentStoreCoordinatorStoresWillChangeNotification object:nil];
	[dc removeObserver:self name:NSPersistentStoreCoordinatorStoresDidChangeNotification object:nil];
	[dc removeObserver:self name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
}

// Subscribe to NSPersistentStoreDidImportUbiquitousContentChangesNotification
- (void)persistentStoreDidImportUbiquitousContentChanges:(NSNotification*)note
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	NSLog(@"%@", note.userInfo.description);

	NSManagedObjectContext *moc = [NSManagedObjectContext MR_context];
	[moc performBlock:^{
		[moc mergeChangesFromContextDidSaveNotification:note];

		// you may want to post a notification here so that which ever part of your app
		// needs to can react appropriately to what was merged.
		// An exmaple of how to iterate over what was merged follows, although I wouldn't
		// recommend doing it here. Better handle it in a delegate or use notifications.
		// Note that the notification contains NSManagedObjectIDs
		// and not NSManagedObjects.
		NSDictionary *changes = note.userInfo;
		NSMutableSet *allChanges = [NSMutableSet new];
		[allChanges unionSet:changes[NSInsertedObjectsKey]];
		[allChanges unionSet:changes[NSUpdatedObjectsKey]];
		[allChanges unionSet:changes[NSDeletedObjectsKey]];

		for (NSManagedObjectID *objID in allChanges) {
			// do whatever you need to with the NSManagedObjectID
			// you can retrieve the object from with [moc objectWithID:objID]
		}

	}];
}

// Subscribe to NSPersistentStoreCoordinatorStoresWillChangeNotification
// most likely to be called if the user enables / disables iCloud
// (either globally, or just for your app) or if the user changes
// iCloud accounts.
- (void)storesWillChange:(NSNotification *)note {
	NSManagedObjectContext *moc = [NSManagedObjectContext MR_context];
	[moc performBlockAndWait:^{
		NSError *error = nil;
		if ([moc hasChanges]) {
			[moc save:&error];
		}

		[moc reset];
	}];

	// now reset your UI to be prepared for a totally different
	// set of data (eg, popToRootViewControllerAnimated:)
	// but don't load any new data yet.
}

// Subscribe to NSPersistentStoreCoordinatorStoresDidChangeNotification
- (void)storesDidChange:(NSNotification *)note {
	// here is when you can refresh your UI and
	// load new data from the new store
}

@end
