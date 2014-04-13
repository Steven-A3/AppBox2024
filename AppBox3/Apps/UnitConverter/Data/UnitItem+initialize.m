//
//  UnitItem+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 16..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UnitItem+initialize.h"
#import "UnitType+initialize.h"
#import "UnitCommon.h"

@implementation UnitItem (initialize)

+ (void)resetUnitItemLists {
    
    FNLOG(@"here");
    
	if ([[UnitItem MR_numberOfEntities] integerValue] > 0) {
		[UnitItem MR_truncateAll];
	}
    
    if ([[UnitType MR_numberOfEntities] isEqualToNumber:@0]) {
		[UnitType resetUnitTypeLists];
	}

	BOOL excludePyungFromArea = ![[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] isEqualToString:@"KR"];

	for (NSInteger typeIdx = 0; typeIdx < numOfUnitType; typeIdx++) {
        NSString *unitTypeName = [NSString stringWithCString:unitTypes[typeIdx] encoding:NSUTF8StringEncoding];
        UnitType *unitType = [UnitType MR_findFirstByAttribute:@"unitTypeName" withValue:unitTypeName];
        NSInteger numOfUnitOfType = numberOfUnits[typeIdx];

        for (NSInteger unitIdx = 0; unitIdx < numOfUnitOfType; unitIdx++) {
            NSString *unitName = [NSString stringWithCString:unitNames[typeIdx][unitIdx] encoding:NSUTF8StringEncoding];

			if (excludePyungFromArea && [unitTypeName isEqualToString:@"Area"] && [unitName isEqualToString:@"pyung"]) {
				continue;
			}

            NSString *unitShortName = [NSString stringWithCString:unitShortNames[typeIdx][unitIdx] encoding:NSUTF8StringEncoding];
            NSNumber *conversionRate = [NSNumber numberWithDouble:conversionTable[typeIdx][unitIdx]];

            UnitItem *unit = [UnitItem MR_createEntity];
            unit.type = unitType;
            unit.unitName = unitName;
            unit.unitShortName = unitShortName;
            unit.conversionRate = conversionRate;
        }
    }

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

@end
