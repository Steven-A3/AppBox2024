//
//  UnitType+initialize.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "UnitType+initialize.h"
#import "UnitCommon.h"

@implementation UnitType (initialize)

+ (void)resetUnitTypeLists
{
    if ([[UnitType MR_numberOfEntities] integerValue] > 0) {
		[UnitType MR_truncateAll];
	}
    
    // unit type set : make and set to coredata
    for (int i = 0; i < numOfUnitType; i++) {
        
        UnitType *utype = [UnitType MR_createEntity];
        NSString *unitType = [NSString stringWithCString:unitTypes[i] encoding:NSUTF8StringEncoding];
        FNLOG(@"%@", unitType);
        utype.unitTypeName = unitType;
        utype.order = [NSNumber numberWithInt:i];
    }

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (NSString *)flagImageName
{
    
    NSMutableArray *keys = [NSMutableArray array];
    
    for (int i = 0; i < numOfUnitType; i++) {
        NSString *unitType = [NSString stringWithCString:unitTypes[i] encoding:NSUTF8StringEncoding];
        
        [keys addObject:unitType];
    }
    
    NSArray *images = @[@"unit_angle",
                            @"unit_area",
                            @"unit_bits",
                            @"unit_cooking",
                            @"unit_density",
                            @"unit_electric",
                            @"unit_energy",
                            @"unit_force",
                            @"unit_fuel",
                            @"unit_length",
                            @"unit_power",
                            @"unit_pressure",
                            @"unit_speed",
                            @"unit_temperature",
                            @"unit_time",
                            @"unit_volume",
                            @"unit_weight"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:images forKeys:keys];
    return dic[self.unitTypeName];
}

- (NSString *)selectedFlagImagName
{
    
    NSMutableArray *keys = [NSMutableArray array];
    
    for (int i=0; i<numOfUnitType; i++) {
        NSString *unitType = [NSString stringWithCString:unitTypes[i] encoding:NSUTF8StringEncoding];
        
        [keys addObject:unitType];
    }
    
    NSArray *images = @[@"unit_angle_on",
                        @"unit_area_on",
                        @"unit_bits_on",
                        @"unit_cooking_on",
                        @"unit_density_on",
                        @"unit_electric_on",
                        @"unit_energy_on",
                        @"unit_force_on",
                        @"unit_fuel_on",
                        @"unit_length_on",
                        @"unit_power_on",
                        @"unit_pressure_on",
                        @"unit_speed_on",
                        @"unit_temperature_on",
                        @"unit_time_on",
                        @"unit_volume_on",
                        @"unit_weight_on"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:images forKeys:keys];
    return dic[self.unitTypeName];
}

@end
