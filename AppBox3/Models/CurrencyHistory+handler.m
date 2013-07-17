//
//  CurrencyHistory(handler)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/16/13 11:55 AM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "CurrencyHistory+handler.h"
#import "NSManagedObject+MagicalFinders.h"
#import "NSManagedObject+MagicalRecord.h"
#import "CurrencyFavorite.h"
#import "NSManagedObject+MagicalAggregation.h"
#import "CurrencyFavorite+initialize.h"
#import "CurrencyItem.h"


@implementation CurrencyHistory (handler)

+ (instancetype)firstObject {
	if ([[CurrencyFavorite MR_numberOfEntities] isEqualToNumber:@0]) {
		[CurrencyFavorite reset];
	}

	if ([[[self class] MR_numberOfEntities] isEqualToNumber:@0]) {
		return [[self class] appendNewHistory];
	}

	return [CurrencyHistory MR_findFirstOrderedByAttribute:@"date" ascending:NO];
}

+ (instancetype)appendNewHistory {
	CurrencyHistory *history = [CurrencyHistory MR_createEntity];
	// Fetch first ordered favorite item ordered by order field.
	CurrencyFavorite *favorite = [CurrencyFavorite MR_findFirstOrderedByAttribute:@"order" ascending:YES];
	history.sourceCurrencyCode = favorite.currencyItem.currencyCode;
	history.date = [NSDate date];
	history.value = @1.0;

	return history;
}

@end