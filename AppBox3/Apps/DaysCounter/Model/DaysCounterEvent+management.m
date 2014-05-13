//
//  DaysCounterEvent+management.m
//  AppBox3
//
//  Created by A3 on 5/13/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "DaysCounterEvent+management.h"
#import "DaysCounterFavorite.h"
#import "NSString+conversion.h"

@implementation DaysCounterEvent (management)

- (void)toggleFavorite {
	if (!self.favorite) {
		DaysCounterFavorite *favorite = [DaysCounterFavorite MR_createEntity];
		favorite.event = self;
		DaysCounterFavorite *lastFavorite = [DaysCounterFavorite MR_findFirstOrderedByAttribute:@"order" ascending:NO];
		favorite.order = [NSString orderStringWithOrder:[lastFavorite.order integerValue] + 1000000];
	} else {
		[self.favorite MR_deleteEntity];
	}
}

@end
