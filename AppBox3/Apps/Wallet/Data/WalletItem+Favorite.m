//
//  WalletItem+Favorite.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletItem+Favorite.h"
#import "WalletFavorite.h"
#import "NSMutableArray+A3Sort.h"
#import "WalletFavorite+initialize.h"
#import "A3AppDelegate.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"

@implementation WalletItem (Favorite)

- (void)changeFavorite:(BOOL)isAdd
{
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    if (isAdd) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID == %@", self.uniqueID];
        if ([WalletFavorite countOfEntitiesWithPredicate:predicate] == 0) {
            WalletFavorite *favorite = [[WalletFavorite alloc] initWithContext:context];
            favorite.uniqueID = [[NSUUID UUID] UUIDString];
            favorite.updateDate = [NSDate date];
            favorite.itemID = self.uniqueID;
            [favorite assignOrder];

            // order set
            NSArray *favors = [WalletFavorite findAllSortedBy:@"order" ascending:YES];
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:favors];
            [tmp addObjectToSortedArray:favorite];

        }
    } else {
		NSArray *favors = [WalletFavorite findByAttribute:@"itemID" withValue:self.uniqueID];
		for (WalletFavorite *favor in favors) {
            [context deleteObject:favor];
		}
    }
    [context saveContext];
}

@end
