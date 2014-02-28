//
//  A3PercentCalcHistoryEntity.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 10..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class A3PercentCalcData;

@interface A3PercentCalcHistoryEntity : NSManagedObject

@property (retain, nonatomic) NSDate *calcDate;
@property (retain, nonatomic) A3PercentCalcData *calcData;

@end
