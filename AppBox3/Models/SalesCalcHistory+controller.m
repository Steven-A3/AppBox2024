//
//  SalesCalcHistory(controller)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/30/13 12:51 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "SalesCalcHistory+controller.h"
#import "A3UserDefaults.h"

@interface SalesCalcHistory ()

@end

@implementation SalesCalcHistory (controller)

- (void)fillDefaultValues {
	self.isAdvanced = [[NSUserDefaults standardUserDefaults] objectForKey:A3SalesCalcDefaultShowAdvanced];
	self.isKnownValueOriginalPrice = [[NSUserDefaults standardUserDefaults] objectForKey:A3SalesCalcDefaultKnownValueOriginalPrice];
	self.created = [NSDate date];
	self.editing = @YES;
}

- (NSString *)price {
	if (self.isKnownValueOriginalPrice) {
		return self.originalPrice;
	}
	return self.salePrice;
}

- (void)setPrice:(NSString *)price {
	if (self.isKnownValueOriginalPrice) {
		[self setOriginalPrice:price];
	} else {
		[self setSalePrice:price];
	}
}

@end