//
//  A3PercentCalculator.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3PercentCalculator.h"
#import "PercentCalcHistory.h"

@implementation A3PercentCalculator

+(NSArray *)percentCalculateFor:(A3PercentCalcData *)aData {
    
    if (aData.dataType != PercentCalcType_5 && [aData.values containsObject:@0]) {
        return nil;
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];

    switch (aData.dataType) {
        case PercentCalcType_1:
        {
            // X is Y% of What
            NSNumber *x1Value = [aData.values objectAtIndex:0];
            NSNumber *y1Value = [aData.values objectAtIndex:1];
            double result = x1Value.doubleValue * 100.0 / y1Value.doubleValue;
            [resultArray addObject:@(result)];
        }
            break;
        case PercentCalcType_2:
        {
            // What is X% of Y
            NSNumber *x1Value = [aData.values objectAtIndex:0];
            NSNumber *y1Value = [aData.values objectAtIndex:1];
            double result = y1Value.doubleValue * x1Value.doubleValue / 100.0;
            [resultArray addObject:@(result)];
        }
            break;
        case PercentCalcType_3:
        {
            // X is What % of Y
            NSNumber *x1Value = [aData.values objectAtIndex:0];
            NSNumber *y1Value = [aData.values objectAtIndex:1];
            double result = x1Value.doubleValue * 100.0 / y1Value.doubleValue;
            [resultArray addObject:@(result)];
        }
            break;
        case PercentCalcType_4:
        {
            // % Change from X to Y
            NSNumber *x1Value = [aData.values objectAtIndex:0];
            NSNumber *y1Value = [aData.values objectAtIndex:1];
            double result = (y1Value.doubleValue - x1Value.doubleValue) / x1Value.doubleValue * 100.0;
            [resultArray addObject:@(result)];
        }
            break;
        case PercentCalcType_5:
        {
            // Compare % Change from X to Y:
            NSAssert(aData.values.count, @"count needs 4");
            double result1 = 0;
            NSNumber *x1Value = [aData.values objectAtIndex:0];
            NSNumber *y1Value = [aData.values objectAtIndex:1];
            
            if (![x1Value isEqualToNumber:@0] && ![y1Value isEqualToNumber:@0]) {
                result1 = (y1Value.doubleValue - x1Value.doubleValue) / x1Value.doubleValue * 100.0;
                [resultArray addObject:@(result1)];
            } else {
                [resultArray addObject:[NSNull null]];
            }
            
            double result2 = 0;
            NSNumber *x2Value = [aData.values objectAtIndex:2];
            NSNumber *y2Value = [aData.values objectAtIndex:3];
            
            if (![x2Value isEqualToNumber:@0] && ![y2Value isEqualToNumber:@0]) {
                result2 = (y2Value.doubleValue - x2Value.doubleValue) / x2Value.doubleValue * 100.0;
                [resultArray addObject:@(result2)];
            } else {
                [resultArray addObject:[NSNull null]];
            }
        }
            
            break;
            
        default:
            break;
    }
    
//    PercentCalcHistory *entity = [PercentCalcHistory MR_createEntity];
//    entity.historyDate = [NSDate date];
//    entity.historyItem = [NSKeyedArchiver archivedDataWithRootObject:aData];
//    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
//    NSArray *entityList = [PercentCalcHistory MR_findAll];
//    NSLog(@"%@", entityList);
//    [entityList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        PercentCalcHistory *row = (PercentCalcHistory *)obj;
//        A3PercentCalcData *rowData = [NSKeyedUnarchiver unarchiveObjectWithData:row.historyItem];
//        NSLog(@"values: %@", rowData.values);
//    }];
    
    return resultArray;
}

@end
