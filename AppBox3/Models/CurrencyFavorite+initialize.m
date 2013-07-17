//
//  CurrencyFavorite(initialize)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/12/13 2:45 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "CurrencyFavorite+initialize.h"
#import "CurrencyItem.h"
#import "NSManagedObject+MagicalFinders.h"
#import "NSManagedObject+MagicalAggregation.h"
#import "NSManagedObject+MagicalRecord.h"
#import "CurrencyItem+NetworkUtility.h"

@implementation CurrencyFavorite (initialize)

+ (void)reset {
	[CurrencyFavorite MR_truncateAll];

	if ([[CurrencyItem MR_numberOfEntities] isEqualToNumber:@0]) {
		[CurrencyItem resetCurrencyLists];
	}

	NSArray *favorites = @[@"USD", @"EUR", @"GBP", @"CAD", @"JPY", @"HKD", @"CNY", @"CHF", @"KRW"];
	[favorites enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"currencyCode like %@", obj];
		NSArray *array = [CurrencyItem MR_findAllWithPredicate:predicate];
		if (![array count]) return;

		CurrencyFavorite *favorite = [CurrencyFavorite MR_createEntity];
		favorite.currencyItem = array[0];
		favorite.order = [NSString stringWithFormat:@"0000%d00000000", idx];
	}];
}

@end