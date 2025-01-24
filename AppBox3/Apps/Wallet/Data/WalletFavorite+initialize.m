//
//  WalletFavorite+initialize.m
//  AppBox3
//
//  Created by A3 on 4/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "WalletFavorite+initialize.h"
#import <AppBoxKit/AppBoxKit.h>
//#import "NSString+conversion.h"
//#import "NSManagedObject+extension.h"
//#import "NSManagedObjectContext+extension.h"

@implementation WalletFavorite (initialize)

- (void)assignOrder {
	WalletFavorite *favorite = [WalletFavorite findFirstOrderedByAttribute:@"order" ascending:NO];
	if (favorite) {
		NSInteger latestOrder = [favorite.order integerValue];
		self.order = [NSString orderStringWithOrder:latestOrder + 1000000];
	} else {
		self.order = [NSString orderStringWithOrder:1000000];
	}
}

+ (BOOL)isFavoriteForItemID:(NSString *)itemID {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID == %@", itemID];
	return [WalletFavorite countOfEntitiesWithPredicate:predicate] > 0;
}

@end
