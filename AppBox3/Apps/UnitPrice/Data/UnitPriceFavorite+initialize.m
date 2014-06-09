//
//  UnitPriceFavorite+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 3..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UnitPriceFavorite+initialize.h"
#import "UnitItem+initialize.h"
#import "UnitType+initialize.h"
#import "UnitCommon.h"
#import "NSManagedObject+MagicalFinders.h"
#import "NSManagedObject+MagicalAggregation.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSString+conversion.h"

@implementation UnitPriceFavorite (initialize)

+ (void)reset {
    
    FNLOG();
    
	[UnitPriceFavorite MR_truncateAll];
    
	if ([[UnitItem MR_numberOfEntities] isEqualToNumber:@0]) {
		[UnitItem resetUnitItemLists];
	}
    
    NSMutableArray *unitFavorites = [[NSMutableArray alloc] init];
	NSArray *item;
    
	// Angle
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:11],
			[NSNumber numberWithInt:14],
			nil];
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
    
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
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
	
	// Electric Currents
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:8],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:22],
			nil];
	[unitFavorites addObject:item];
	
	// Energy
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:7],
			[NSNumber numberWithInt:14],
			[NSNumber numberWithInt:16],
			[NSNumber numberWithInt:21],
			[NSNumber numberWithInt:26],
			nil];
	[unitFavorites addObject:item];
	
	// Force
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:5],
			[NSNumber numberWithInt:6],
			[NSNumber numberWithInt:10],
			[NSNumber numberWithInt:11],
			nil];
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
	
	// Temperature
	item = [NSArray arrayWithObjects:
			[NSNumber numberWithInt:0],
			[NSNumber numberWithInt:1],
			[NSNumber numberWithInt:2],
			[NSNumber numberWithInt:3],
			[NSNumber numberWithInt:4],
			nil];
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
	
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
	[unitFavorites addObject:item];
    
    for (int i=0; i<unitFavorites.count; i++) {
        NSArray *typeFavorites = unitFavorites[i];
        for (int j=0; j<typeFavorites.count; j++) {
            NSNumber *unitIdx = typeFavorites[j];
            NSString *unitName = [NSString stringWithCString:unitNames[i][unitIdx.intValue] encoding:NSUTF8StringEncoding];
            UnitItem *uitem = [UnitItem MR_findFirstByAttribute:@"unitName" withValue:unitName];
            
            if (!uitem) return;
            
            UnitPriceFavorite *favorite = [UnitPriceFavorite MR_createEntity];
            favorite.item = uitem;
            favorite.order = [NSString orderStringWithOrder:(j + 1) * 1000000];
        }
    }

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

@end
