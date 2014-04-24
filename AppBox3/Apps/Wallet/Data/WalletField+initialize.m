//
//  WalletField+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "WalletField+initialize.h"
#import "WalletCategory.h"
#import "WalletCategory+initialize.h"
#import "NSString+conversion.h"

@implementation WalletField (initialize)

- (void)awakeFromInsert {
	[super awakeFromInsert];

	self.uniqueID = [[NSUUID UUID] UUIDString];
	self.type = @"Text";
	self.style = @"Normal";

	WalletField *field = [WalletField MR_findFirstOrderedByAttribute:@"order" ascending:NO];
	if (field) {
		NSInteger latestOrder = [field.order integerValue];
		self.order = [NSString orderStringWithOrder:latestOrder + 1000000];
	} else {
		self.order = [NSString orderStringWithOrder:1000000];
	}
}

@end
