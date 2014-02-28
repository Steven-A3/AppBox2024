//
//  A3PercentCalcData.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PercentCalcType) {
    PercentCalcType_1 = 0,  // X is Y% of What
    PercentCalcType_2,      // What is X% of Y
    PercentCalcType_3,      // X is What % of Y
    PercentCalcType_4,      // % Change from X to Y
    PercentCalcType_5       // Compare % Change from X to Y
};

typedef NS_ENUM(NSInteger, ValueIdx) {
    ValueIdx_X1 = 0,
    ValueIdx_Y1,
    ValueIdx_X2,
    ValueIdx_Y2
};

@interface A3PercentCalcData : NSObject <NSCoding>

@property (nonatomic, assign) PercentCalcType dataType;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, assign) BOOL calculated;

-(NSArray *)formattedStringValuesByCalcType;
@end
