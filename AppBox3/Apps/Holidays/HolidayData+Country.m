//
//  HolidayData+Country.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "HolidayData+Country.h"

@implementation HolidayData (Country)

- (NSArray *)supportedCountries {
	return @[
			@"ar", @"au", @"at", @"be", @"bw", @"br", @"cm", @"ca", @"cf", @"cl", // 10
			@"cn", @"co", @"hr", @"cz", @"dk", @"do", @"ec", @"eg", @"sv", @"gq", // 20
			@"ee", @"fi", @"fr", @"de", @"gr", @"gt", @"gn", @"gw", @"hn", @"hk", // 30
			@"hu", @"id", @"ie", @"it", @"ci", @"jm", @"jp", @"il", @"jo", @"ke", // 40
			@"lv", @"li", @"lt", @"lu", @"mo", @"mg", @"ml", @"mt", @"mu", @"mx", // 50
			@"md", @"nl", @"nz", @"ni", @"ne", @"no", @"pa", @"py", @"pe", @"ph", // 60
			@"pl", @"pt", @"pr", @"qa", @"kr", @"re", @"ro", @"ru", @"sa", @"sn", // 70
			@"sg", @"sk", @"za", @"es", @"se", @"ch", @"tw", @"tr", @"ae", @"gb", // 80
			@"uy", @"us", @"vi", @"ve", @"my", @"cr", @"in", @"ht", @"kw", @"ua", // 90
			@"mk", @"et", @"bd", @"bg", @"bs", @"pk", @"th", @"mz",
			];
}

@end
