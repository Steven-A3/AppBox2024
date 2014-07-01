//
//  UnitConvertItem+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UnitConvertItem+initialize.h"
#import "UnitItem+initialize.h"
#import "UnitType+initialize.h"
#import "UnitCommon.h"
#import "NSManagedObject+MagicalFinders.h"
#import "NSManagedObject+MagicalAggregation.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSString+conversion.h"
#import "NSMutableArray+A3Sort.h"

@implementation UnitConvertItem (initialize)

+ (void)reset {
    
    FNLOG();
    
	[UnitConvertItem MR_truncateAll];
    
	if ([[UnitItem MR_numberOfEntities] isEqualToNumber:@0]) {
		[UnitItem resetUnitItemLists];
	}
    
    NSMutableArray *allUnitTypeItems = [[NSMutableArray alloc] init];
	NSArray *item;
    
	// Angle
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:14],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Area
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:9],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Bits
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			nil];
	[allUnitTypeItems addObject:item];
    
	// Cooking
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:25],
			[NSNumber numberWithInt:27],
			[NSNumber numberWithInt:28],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Density
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Electric Currents
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Energy
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:26],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Force
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Fuel Consumption
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Length
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			[NSNumber numberWithInt:30],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:15],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Power
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Pressure
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:33],
			[NSNumber numberWithInt:25],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Speed
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:9],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Temperature
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Time
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:0],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Volume
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:28],
			[NSNumber numberWithInt:25],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:29],
			[NSNumber numberWithInt:30],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:20],
			[NSNumber numberWithInt:22],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:26],
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			nil];
	[allUnitTypeItems addObject:item];
	
	// Weight
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:7],
			nil];
	[allUnitTypeItems addObject:item];
    
    for (NSInteger idxType = 0; idxType < allUnitTypeItems.count; idxType++) {
        NSArray *unitItems = allUnitTypeItems[idxType];
        for (NSInteger idxUnit = 0; idxUnit < unitItems.count; idxUnit++) {
            NSNumber *unitIdentifier = unitItems[idxUnit];
            NSString *unitName = [NSString stringWithCString:unitNames[idxType][unitIdentifier.intValue] encoding:NSUTF8StringEncoding];
            UnitItem *unitItem = [UnitItem MR_findFirstByAttribute:@"unitName" withValue:unitName];
            
            if (!unitItem) return;
            
            UnitConvertItem *convertItem = [UnitConvertItem MR_createEntity];
			convertItem.uniqueID = [[NSUUID UUID] UUIDString];
			convertItem.updateDate = [NSDate date];
            convertItem.item = unitItem;
			convertItem.order = [NSString orderStringWithOrder:idxUnit];
            NSLog(@"%@", convertItem.order);
        }
    }

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

@end
