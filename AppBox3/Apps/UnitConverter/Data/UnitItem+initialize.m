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
    
    for (int i=0; i<numOfUnitType; i++) {
        NSString *unitType = [NSString stringWithCString:unitTypes[i] encoding:NSUTF8StringEncoding];
        FNLOG(@"%@", unitType);
        UnitType *utype = [UnitType MR_findFirstByAttribute:@"unitTypeName" withValue:unitType];
        int numOfUnitOfType = numberOfUnits[i];
        for (int j=0; j<numOfUnitOfType; j++) {
            NSString *unitName = [NSString stringWithCString:unitNames[i][j] encoding:NSUTF8StringEncoding];
            NSString *unitShortName = [NSString stringWithCString:unitShortNames[i][j] encoding:NSUTF8StringEncoding];
            NSNumber *conversionRate = [NSNumber numberWithDouble:conversionTable[i][j]];
            UnitItem *unit = [UnitItem MR_createEntity];
            unit.type = utype;
            unit.unitName = unitName;
            unit.unitShortName = unitShortName;
            unit.conversionRate = conversionRate;
        }
    }

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

@end
