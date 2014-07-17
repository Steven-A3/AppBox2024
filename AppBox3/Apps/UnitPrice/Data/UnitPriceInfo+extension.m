//
//  UnitPriceInfo+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "UnitPriceInfo+extension.h"
#import "UnitItem.h"

@implementation UnitPriceInfo (extension)

- (UnitItem *)unit {
	return [UnitItem MR_findFirstByAttribute:@"uniqueID" withValue:self.unitID];
}

@end
