//
// Created by Byeong Kwon Kwak on 3/27/15.
// Copyright (c) 2015 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppDelegate+migration.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"


@implementation A3AppDelegate (migration)

- (void)migrateToV3_4_Holidays {
	// V3.4 부터 이스라엘 휴일과 유대교 휴일이 분리됨
	// 휴일 나라 목록에 "il"이 들어있는 경우, "jewish"를 추가하는 작업이 필요함
	NSArray *holidaysCountries = [HolidayData userSelectedCountries];
	NSUInteger indexOfIsrael = [holidaysCountries indexOfObject:@"il"];
	if (indexOfIsrael != NSNotFound) {
		NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:holidaysCountries];
		[mutableArray insertObject:@"jewish" atIndex:indexOfIsrael + 1];
		[HolidayData setUserSelectedCountries:mutableArray];
	}
}

@end