//
//  WalletItem+Favorite.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletItem+Favorite.h"
#import "NSMutableArray+A3Sort.h"
#import "WalletFavorite+initialize.h"
#import "A3AppDelegate.h"
#import <AppBoxKit/AppBoxKit.h>

@implementation WalletItem_ (Favorite)

- (void)changeFavorite:(BOOL)isAdd
{
    NSManagedObjectContext *context = CoreDataStack.shared.persistentContainer.viewContext;
    if (isAdd) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID == %@", self.uniqueID];
        if ([WalletFavorite_ countOfEntitiesWithPredicate:predicate] == 0) {
            WalletFavorite_ *favorite = [[WalletFavorite_ alloc] initWithContext:context];
            favorite.uniqueID = [[NSUUID UUID] UUIDString];
            favorite.updateDate = [NSDate date];
            favorite.itemID = self.uniqueID;
            [favorite assignOrder];

            // order set
            NSArray *favors = [WalletFavorite_ findAllSortedBy:@"order" ascending:YES];
            NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:favors];
            [tmp addObjectToSortedArray:favorite];

        }
    } else {
		NSArray *favors = [WalletFavorite_ findByAttribute:@"itemID" withValue:self.uniqueID];
		for (WalletFavorite_ *favor in favors) {
            [context deleteObject:favor];
		}
    }
    [context saveIfNeeded];
}

@end
