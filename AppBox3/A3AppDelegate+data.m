//
//  A3AppDelegate(data)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/13/13 3:25 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+data.h"
#import "CurrencyFavorite.h"
#import "NSManagedObject+MagicalAggregation.h"
#import "CurrencyFavorite+initialize.h"


@implementation A3AppDelegate (data)

- (void)prepareDatabase {
	if ([[CurrencyFavorite MR_numberOfEntities] isEqualToNumber:@0 ]) {
		[CurrencyFavorite reset];
	}
}

@end