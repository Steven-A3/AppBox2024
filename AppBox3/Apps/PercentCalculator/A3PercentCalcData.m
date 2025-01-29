//
//  A3PercentCalcData.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3PercentCalcData.h"
#import "NSNumberFormatter+Extension.h"

@implementation A3PercentCalcData

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _dataType = [aDecoder decodeIntegerForKey:@"dataType"];
        _values = [aDecoder decodeObjectForKey:@"values"];
        _calculated = [aDecoder decodeBoolForKey:@"calculated"];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_dataType forKey:@"dataType"];
    [aCoder encodeObject:_values forKey:@"values"];
    [aCoder encodeBool:_calculated forKey:@"calculated"];
}

- (NSArray *)formattedStringValuesByCalcType
{
    FNLOG(@"formattedStringValuesByCalcType");
    FNLOG(@"%@", _values);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSNumber *x1 = _values[ValueIdx_X1];
    NSNumber *y1 = _values[ValueIdx_Y1];

    switch (self.dataType) {
        case PercentCalcType_1:      // X is Y% of What
        {
            NSString *sX1 = [NSNumberFormatter exponentStringFromNumber:x1];
            NSString *sY1 = [NSString stringWithFormat:@"%@%%", [NSNumberFormatter exponentStringFromNumber:y1]];
            [result addObject:sX1];
            [result addObject:sY1];
        }
            break;
        case PercentCalcType_2:      // What is X% of Y
        {
            NSString *sX1 = [NSString stringWithFormat:@"%@%%", [NSNumberFormatter exponentStringFromNumber:x1]];
            NSString *sY1 = [NSNumberFormatter exponentStringFromNumber:y1];
            [result addObject:sX1];
            [result addObject:sY1];
        }
            break;
        case PercentCalcType_3:      // X is What % of Y
        case PercentCalcType_4:      // % Change from X to Y
        {
            NSString *sX1 = [NSNumberFormatter exponentStringFromNumber:x1];
            NSString *sY1 = [NSNumberFormatter exponentStringFromNumber:y1];
            
            [result addObject:sX1];
            [result addObject:sY1];
        }
            break;
        case PercentCalcType_5:      // Compare % Change from X to Y:
        {
            FNLOG(@"formattedStringValuesByCalcType PercentCalcType_5");
            NSString *sX1 = [NSNumberFormatter exponentStringFromNumber:x1];
            NSString *sY1 = [NSNumberFormatter exponentStringFromNumber:y1];
            NSString *sX2 = [NSNumberFormatter exponentStringFromNumber:_values[ValueIdx_X2]];
            NSString *sY2 = [NSNumberFormatter exponentStringFromNumber:_values[ValueIdx_Y2]];

            [result addObject:sX1];
            [result addObject:sY1];
            [result addObject:sX2];
            [result addObject:sY2];
            FNLOG(@"formattedStringValuesByCalcType PercentCalcType_5 End");
        }
            break;
            
        default:
            break;
    }
    
    FNLOG(@"formattedStringValuesByCalcType return");
    return result;
}

+ (A3PercentCalcData *)unarchiveFromData:(NSData *)data {
    NSError *error;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
    A3PercentCalcData *decodedObject = nil;
    if (error) {
        FNLOG(@"Error unarchiving color data: %@", error.localizedDescription);
    } else {
        unarchiver.requiresSecureCoding = NO; // Set this to YES if your object conforms to NSSecureCoding
        decodedObject = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
        [unarchiver finishDecoding];
    }
    return decodedObject;
}

@end
