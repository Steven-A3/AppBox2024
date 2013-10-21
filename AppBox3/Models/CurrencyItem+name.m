//
//  CurrencyItem+name.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "CurrencyItem+name.h"
#import "NSManagedObject+MagicalFinders.h"

NSString *const A3KeyCurrencyCode = @"currencyCode";

@implementation CurrencyItem (name)

- (NSString *)localizedName {
	NSLocale *locale = [NSLocale currentLocale];
	NSString *name = [locale displayNameForKey:NSLocaleCurrencyCode value:self.currencyCode];
	if ((nil == name) || ![name length]) {
		NSArray *knownSymbols = @[@"XCP", @"ZMW", @"CNH", @"XDR", @"CLF"];
		NSUInteger index = [knownSymbols indexOfObject:self.currencyCode];
		if (index != NSNotFound) {
			NSArray *knownNames = @[@"Copper Highgrade", @"Zambian kwacha", @"Offshore Renminbi", @"Special Drawing Rights", @"Unidad de Fomento"];
			name = [knownNames objectAtIndex:index];
		} else {
			NSLog(@"Failed to name resolution.");
		}
	}
	return name;
}

+ (void)updateNames {
	NSArray *allItems = [CurrencyItem MR_findAll];
	[allItems enumerateObjectsUsingBlock:^(CurrencyItem *obj, NSUInteger idx, BOOL *stop) {
		obj.name = [obj localizedName];
	}];
	[[NSManagedObjectContext MR_mainQueueContext] MR_saveToPersistentStoreAndWait];
}

@end
