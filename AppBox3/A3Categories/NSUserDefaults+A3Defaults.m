//
//  NSUserDefaults+A3Defaults.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/7/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "NSUserDefaults+A3Defaults.h"
#import "A3UserDefaults.h"

@implementation NSUserDefaults (A3Defaults)

- (BOOL)currencyAutoUpdate {
	@autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3CurrencyAutoUpdate];
		if (object) {
			return [object boolValue];
		}
		return YES;
	}
}

- (void)setCurrencyAutoUpdate:(BOOL)boolValue {
	@autoreleasepool {
		[self setBool:boolValue forKey:A3CurrencyAutoUpdate];
		[self synchronize];
	}
}

- (BOOL)currencyUseCellularData {
	@autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3CurrencyUseCellularData];
		if (object) {
			return [object boolValue];
		}
		return NO;
	}
}

- (void)setCurrencyUseCellularData:(BOOL)boolValue {
	@autoreleasepool {
		[self setBool:boolValue forKey:A3CurrencyUseCellularData];
		[self synchronize];
	}
}

- (BOOL)currencyShowNationalFlag {
	@autoreleasepool {
		NSNumber *object;
		object = [self objectForKey:A3CurrencyShowNationalFlag];
		if (object) {
			return [object boolValue];
		}
		return YES;
	}
}

- (void)setCurrencyShowNationalFlag:(BOOL)boolValue {
	@autoreleasepool {
		[self setBool:boolValue forKey:A3CurrencyShowNationalFlag];
		[self synchronize];
	}
}

@end
