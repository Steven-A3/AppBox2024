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
    
    FNLOG(@"here");
    
	[UnitConvertItem MR_truncateAll];
    
	if ([[UnitItem MR_numberOfEntities] isEqualToNumber:@0]) {
		[UnitItem resetUnitItemLists];
	}
    
    NSMutableArray *unitConvertItems = [[NSMutableArray alloc] init];
	NSArray *item;
    
	// Angle
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:14],
			nil];
	[unitConvertItems addObject:item];
	
	// Area
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:12],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:16],
			nil];
	[unitConvertItems addObject:item];
	
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
			nil];
	[unitConvertItems addObject:item];
    
	// Cooking
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:25],
			[NSNumber numberWithInt:26],
			[NSNumber numberWithInt:27],
			[NSNumber numberWithInt:28],
			[NSNumber numberWithInt:29],
			[NSNumber numberWithInt:30],
			nil];
	[unitConvertItems addObject:item];
	
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
	[unitConvertItems addObject:item];
	
	// Electric Currents
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			nil];
	[unitConvertItems addObject:item];
	
	// Energy
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:26],
			nil];
	[unitConvertItems addObject:item];
	
	// Force
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			nil];
	[unitConvertItems addObject:item];
	
	// Fuel Consumption
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			nil];
	[unitConvertItems addObject:item];
	
	// Length
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:30],
			nil];
	[unitConvertItems addObject:item];
	
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
	[unitConvertItems addObject:item];
	
	// Pressure
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:33],
			nil];
	[unitConvertItems addObject:item];
	
	// Speed
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:20],
			[NSNumber numberWithInt:21],
			nil];
	[unitConvertItems addObject:item];
	
	// Temperature
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			nil];
	[unitConvertItems addObject:item];
	
	// Time
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:19],
			nil];
	[unitConvertItems addObject:item];
	
	// Volume
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:17],
			[NSNumber numberWithInt:18],
			[NSNumber numberWithInt:19],
			[NSNumber numberWithInt:20],
			[NSNumber numberWithInt:23],
			[NSNumber numberWithInt:24],
			[NSNumber numberWithInt:25],
			[NSNumber numberWithInt:26],
			[NSNumber numberWithInt:27],
			[NSNumber numberWithInt:28],
			nil];
	[unitConvertItems addObject:item];
	
	// Weight
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:9],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:13],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:15],
			[NSNumber numberWithInt:16],
			nil];
	[unitConvertItems addObject:item];
    
    for (int i=0; i<unitConvertItems.count; i++) {
        NSArray *typeConvertItems = unitConvertItems[i];
        NSMutableArray *sortArray = [[NSMutableArray alloc] init];
        for (int j=0; j<typeConvertItems.count; j++) {
            NSNumber *unitIdx = typeConvertItems[j];
            NSString *unitName = [NSString stringWithCString:unitNames[i][unitIdx.intValue] encoding:NSUTF8StringEncoding];
            UnitItem *uitem = [UnitItem MR_findFirstByAttribute:@"unitName" withValue:unitName];
            
            if (!uitem) return;
            
            UnitConvertItem *convertItem = [UnitConvertItem MR_createEntity];
            convertItem.item = uitem;
            
            [sortArray addObjectToSortedArray:convertItem];
        }
    }

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

@end
